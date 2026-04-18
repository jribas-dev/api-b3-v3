import { Injectable, NotFoundException } from '@nestjs/common';
import { TenantService } from './tenant.service';
import { CfgEntity } from './entities/cfg.entity';

export interface CfgValue {
  valor: string;
  descricao: string | null;
}

@Injectable()
export class CfgService {
  constructor(private readonly tenantService: TenantService) {}

  async get(dbId: string, param: string): Promise<CfgValue> {
    const ds = await this.tenantService.getDataSource(dbId);
    const repo = ds.getRepository(CfgEntity);
    const row = await repo.findOneBy({ param });
    if (!row) {
      throw new NotFoundException(
        `Parâmetro de configuração "${param}" não encontrado`,
      );
    }
    return { valor: row.valor, descricao: row.descricao };
  }

  async find(dbId: string, param: string): Promise<CfgValue | null> {
    const ds = await this.tenantService.getDataSource(dbId);
    const repo = ds.getRepository(CfgEntity);
    const row = await repo.findOneBy({ param });
    return row ? { valor: row.valor, descricao: row.descricao } : null;
  }
}
