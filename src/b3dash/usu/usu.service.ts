import { ForbiddenException, Injectable } from '@nestjs/common';
import { TenantService } from 'src/tenant/tenant.service';
import { EmpService } from 'src/tenant/emp.service';
import { UsuBackofficeDto } from './dto/usu-backoffice.dto';

@Injectable()
export class UsuService {
  constructor(
    private readonly tenantService: TenantService,
    private readonly empService: EmpService,
  ) {}

  private async validateIdemp(
    dbId: string,
    userId: string,
    idemp: number,
  ): Promise<void> {
    const emitentes = await this.empService.listEmitentes(dbId, userId);
    if (!emitentes.some((e) => e.id === idemp)) {
      throw new ForbiddenException('Empresa não autorizada para este usuário');
    }
  }

  async listBackoffice(
    dbId: string,
    userId: string,
    idemp: number,
  ): Promise<UsuBackofficeDto[]> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);

    const rows = await ds.query<Array<{ id: number | string; login: string }>>(
      `SELECT u.id, u.login
       FROM usu u
       INNER JOIN usuemp ue ON ue.idusu = u.id
       WHERE u.userId IS NULL
         AND NOT u.inativo
         AND ue.idcnt = ?
       ORDER BY u.login`,
      [idemp],
    );

    return rows.map((r) => ({
      id: Number(r.id),
      login: String(r.login ?? ''),
    }));
  }
}
