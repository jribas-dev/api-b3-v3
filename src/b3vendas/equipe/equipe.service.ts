import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { SellerContextService } from 'src/b3vendas/shared/seller-context.service';
import { TenantService } from 'src/tenant/tenant.service';
import { RoleFront } from 'src/user-domain/user-instance/enums/user-instance-roles.enum';
import { ResponseEquipeDto } from './dto/response-equipe.dto';

interface EquipeRow {
  id: number;
  razao: string;
  cel: string | null;
  fax: string | null;
  liderado: number;
}

@Injectable()
export class EquipeService {
  constructor(
    private readonly tenantService: TenantService,
    private readonly sellerContextService: SellerContextService,
  ) {}

  async listar(
    dbId: string,
    userId: string,
    roleFront: RoleFront,
  ): Promise<ResponseEquipeDto[]> {
    const { vendId } = await this.sellerContextService.resolve(dbId, userId);
    const ds = await this.tenantService.getDataSource(dbId);

    if (roleFront === RoleFront.SUPER) {
      const rows = await ds.query<EquipeRow[]>(
        `SELECT x.id, x.razao, x.cel, x.fax, x.liderado
           FROM (
             SELECT c.id, c.razao, c.cel, c.fax, 0 AS liderado
               FROM cnt c
              WHERE c.id = ?
             UNION ALL
             SELECT c.id, c.razao, c.cel, c.fax, 1 AS liderado
               FROM cntequipe e
               INNER JOIN cnt c ON c.id = e.idcntliderado
              WHERE e.idcntlider = ?
           ) AS x
          ORDER BY x.liderado ASC, x.razao ASC`,
        [vendId, vendId],
      );
      return rows.map((r) => plainToInstance(ResponseEquipeDto, r));
    }

    if (roleFront === RoleFront.SALER) {
      const rows = await ds.query<EquipeRow[]>(
        `SELECT c.id, c.razao, c.cel, c.fax, 0 AS liderado
           FROM cnt c
          WHERE c.id = ?
          LIMIT 1`,
        [vendId],
      );
      return rows.map((r) => plainToInstance(ResponseEquipeDto, r));
    }

    throw new ForbiddenException('Perfil sem acesso à equipe de vendas');
  }

  async inserir(
    dbId: string,
    userId: string,
    idcntliderado: number,
  ): Promise<void> {
    const { vendId } = await this.sellerContextService.resolve(dbId, userId);
    const ds = await this.tenantService.getDataSource(dbId);

    if (idcntliderado === vendId) {
      throw new BadRequestException(
        'Não é possível adicionar a si mesmo à equipe',
      );
    }

    const existing = await ds.query<{ id: number }[]>(
      `SELECT id FROM cntequipe WHERE idcntlider = ? AND idcntliderado = ? LIMIT 1`,
      [vendId, idcntliderado],
    );
    if (existing.length) {
      throw new ConflictException('Vendedor já pertence a esta equipe');
    }

    await ds.query(
      `INSERT INTO cntequipe (idcntlider, idcntliderado) VALUES (?, ?)`,
      [vendId, idcntliderado],
    );
  }

  async remover(
    dbId: string,
    userId: string,
    idcntliderado: number,
  ): Promise<void> {
    const { vendId } = await this.sellerContextService.resolve(dbId, userId);
    const ds = await this.tenantService.getDataSource(dbId);

    const result = await ds.query<{ affectedRows: number }>(
      `DELETE FROM cntequipe WHERE idcntlider = ? AND idcntliderado = ?`,
      [vendId, idcntliderado],
    );
    if (!result.affectedRows) {
      throw new NotFoundException('Vínculo não encontrado nesta equipe');
    }
  }

  async semEquipe(dbId: string, userId: string): Promise<ResponseEquipeDto[]> {
    const { vendId } = await this.sellerContextService.resolve(dbId, userId);
    const ds = await this.tenantService.getDataSource(dbId);

    const rows = await ds.query<EquipeRow[]>(
      `SELECT DISTINCT c.id, c.razao, c.cel, c.fax, 0 AS liderado
        FROM cnt c
        INNER JOIN cntclasses ON (cntclasses.idcnt=c.id)
        INNER JOIN cntclass ON (cntclass.id=cntclasses.idclass) AND (cntclass.comissionado)
      WHERE c.id != ?
        AND NOT EXISTS (SELECT 1 FROM cntequipe e WHERE e.idcntliderado = c.id)
      ORDER BY c.razao ASC`,
      [vendId],
    );
    return rows.map((r) => plainToInstance(ResponseEquipeDto, r));
  }
}
