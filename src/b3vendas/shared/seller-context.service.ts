import { ForbiddenException, Injectable } from '@nestjs/common';
import { TenantService } from 'src/tenant/tenant.service';

export interface SellerContext {
  usuId: number;
  vendId: number;
  empId: number;
}

@Injectable()
export class SellerContextService {
  constructor(private readonly tenantService: TenantService) {}

  async resolve(dbId: string, userId: string): Promise<SellerContext> {
    const ds = await this.tenantService.getDataSource(dbId);
    const rows = await ds.query<
      { id: number; idvend: number | null; idemp: number | null }[]
    >(
      `SELECT u.id, u.idvend,
              (SELECT idcnt FROM usuemp WHERE idusu = u.id LIMIT 1) AS idemp
         FROM usu u
        WHERE u.userId = ?
        LIMIT 1`,
      [userId],
    );

    const row = rows[0];
    if (!row || row.idvend == null || row.idemp == null) {
      throw new ForbiddenException(
        'Usuário não vinculado a vendedor/empresa nesta instância',
      );
    }

    return { usuId: row.id, vendId: row.idvend, empId: row.idemp };
  }
}
