import { Injectable } from '@nestjs/common';
import { TenantService } from 'src/tenant/tenant.service';
import { UsuBackofficeDto } from './dto/usu-backoffice.dto';

@Injectable()
export class UsuService {
  constructor(private readonly tenantService: TenantService) {}

  async listBackoffice(dbId: string): Promise<UsuBackofficeDto[]> {
    const ds = await this.tenantService.getDataSource(dbId);
    const rows = await ds.query<Array<{ id: number | string; login: string }>>(
      `SELECT id, login
       FROM usu
       WHERE userId IS NULL
         AND NOT inativo
       ORDER BY login`,
    );

    return rows.map((r) => ({
      id: Number(r.id),
      login: String(r.login ?? ''),
    }));
  }
}
