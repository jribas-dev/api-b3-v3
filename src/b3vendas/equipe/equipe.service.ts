import { ForbiddenException, Injectable } from '@nestjs/common';
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
}
