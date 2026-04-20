import { ForbiddenException, Injectable } from '@nestjs/common';
import { TenantService } from 'src/tenant/tenant.service';

export interface SellerContext {
  usuId: number;
  vendId: number;
}

@Injectable()
export class SellerContextService {
  constructor(private readonly tenantService: TenantService) {}

  async resolve(dbId: string, userId: string): Promise<SellerContext> {
    const ds = await this.tenantService.getDataSource(dbId);
    const rows = await ds.query<{ id: number; idvend: number | null }[]>(
      `SELECT u.id, u.idvend
         FROM usu u
        WHERE u.userId = ?
        LIMIT 1`,
      [userId],
    );

    const row = rows[0];
    if (!row || row.idvend == null) {
      throw new ForbiddenException(
        'Usuário não vinculado a vendedor nesta instância',
      );
    }

    return { usuId: row.id, vendId: row.idvend };
  }
}
