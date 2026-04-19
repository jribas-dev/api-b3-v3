import { Injectable } from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { ClienteEntity } from 'src/b3vendas/cliente/entities/cliente.entity';
import { TenantService } from './tenant.service';
import { ResponseEmitenteDto } from './dto/response-emitente.dto';

@Injectable()
export class EmpService {
  constructor(private readonly tenantService: TenantService) {}

  async listEmitentes(
    dbId: string,
    userId: string,
  ): Promise<ResponseEmitenteDto[]> {
    const ds = await this.tenantService.getDataSource(dbId);

    const rows = await ds
      .getRepository(ClienteEntity)
      .createQueryBuilder('cnt')
      .select('cnt.id', 'id')
      .addSelect('COALESCE(cnt.fantasia, cnt.razao)', 'nome')
      .addSelect('format_docfed(cnt.docfed)', 'docfed')
      .innerJoin('cntclasses', 'cc', 'cc.idcnt = cnt.id')
      .innerJoin('cntclass', 'cl', 'cl.id = cc.idclass')
      .innerJoin('usuemp', 'ue', 'ue.idcnt = cnt.id')
      .innerJoin('usu', 'u', 'u.id = ue.idusu')
      .where('cl.emitente = TRUE')
      .andWhere('u.userId = :userId', { userId })
      .distinct(true)
      .orderBy('nome', 'ASC')
      .getRawMany<{ id: number; nome: string; docfed: string }>();

    return rows.map((r) => plainToInstance(ResponseEmitenteDto, r));
  }
}
