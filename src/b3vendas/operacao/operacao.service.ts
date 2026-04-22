import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { In } from 'typeorm';
import { SellerContextService } from 'src/b3vendas/shared/seller-context.service';
import { TenantService } from 'src/tenant/tenant.service';
import { CfgService } from 'src/tenant/cfg.service';
import { EmpService } from 'src/tenant/emp.service';
import { OperacaoEntity } from './entities/operacao.entity';
import { ResponseOperacaoDto } from './dto/response-operacao.dto';

@Injectable()
export class OperacaoService {
  constructor(
    private readonly tenantService: TenantService,
    private readonly sellerContextService: SellerContextService,
    private readonly cfgService: CfgService,
    private readonly empService: EmpService,
  ) {}

  async listarPermitidas(
    dbId: string,
    userId: string,
    idemp: number,
  ): Promise<ResponseOperacaoDto[]> {
    const emitentes = await this.empService.listEmitentes(dbId, userId);
    const authorizedIds = emitentes.map((e) => e.id);
    if (!authorizedIds.includes(idemp)) {
      throw new ForbiddenException('Empresa não autorizada para este usuário');
    }

    await this.sellerContextService.resolve(dbId, userId);
    const { valor: operFilter } = await this.cfgService.get(
      dbId,
      'VWEBOPERCOND',
    );
    const ds = await this.tenantService.getDataSource(dbId);
    const repo = ds.getRepository(OperacaoEntity);

    const rows = await repo
      .createQueryBuilder('o')
      .where('o.saidaentrada = :saidaentrada', { saidaentrada: '1' })
      .andWhere(operFilter)
      .andWhere('(o.idemp IS NULL OR o.idemp = 0 OR o.idemp = :idemp)', {
        idemp,
      })
      .orderBy('o.operacao', 'ASC')
      .getMany();

    return rows.map((o) => plainToInstance(ResponseOperacaoDto, o));
  }

  async findOneOrFail(dbId: string, id: number): Promise<OperacaoEntity> {
    const ds = await this.tenantService.getDataSource(dbId);
    const repo = ds.getRepository(OperacaoEntity);
    const op = await repo.findOneBy({ id });
    if (!op) throw new NotFoundException(`Operação ${id} não encontrada`);
    return op;
  }

  async findByIds(dbId: string, ids: number[]): Promise<OperacaoEntity[]> {
    const ds = await this.tenantService.getDataSource(dbId);
    const repo = ds.getRepository(OperacaoEntity);
    return repo.findBy({ id: In(ids) });
  }
}
