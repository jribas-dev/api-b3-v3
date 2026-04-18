import { Injectable, NotFoundException } from '@nestjs/common';
import { TenantService } from 'src/tenant/tenant.service';
import { VendaService } from 'src/b3vendas/venda/venda.service';
import { VendaItemEntity } from './entities/venda-item.entity';
import { CreateVendaItemDto } from './dto/create-venda-item.dto';

@Injectable()
export class VendaItemService {
  constructor(
    private readonly tenantService: TenantService,
    private readonly vendaService: VendaService,
  ) {}

  async add(
    dbId: string,
    userId: string,
    idVenda: number,
    dto: CreateVendaItemDto,
  ): Promise<{ seq: number }> {
    await this.vendaService.assertEditavel(dbId, userId, idVenda);
    const ds = await this.tenantService.getDataSource(dbId);
    const repo = ds.getRepository(VendaItemEntity);

    const [{ nro }] = await ds.query<{ nro: number }[]>(
      `SELECT (COALESCE(MAX(seq),0) + 1) AS nro
         FROM vendaitem WHERE idvenda = ?`,
      [idVenda],
    );
    const seq = Number(nro);

    const totItem = dto.qtde * dto.vunit;

    await repo.insert({
      idvenda: idVenda,
      seq,
      idprod: dto.idProd,
      qtde: dto.qtde,
      unitario: dto.vunit,
      desconto: 0,
      acrescimo: 0,
      bruto: totItem,
      total: totItem,
      custo: dto.custo,
      cfop: dto.cfop,
      st: dto.vST,
      ipi: dto.vIPI,
      vlrtab: dto.tabela,
      obsprd: dto.obsprod?.trim() || null,
    });

    await this.vendaService.recalcTotals(dbId, idVenda);
    return { seq };
  }

  async remove(
    dbId: string,
    userId: string,
    idVenda: number,
    seq: number,
  ): Promise<void> {
    await this.vendaService.assertEditavel(dbId, userId, idVenda);
    const ds = await this.tenantService.getDataSource(dbId);
    const result = await ds
      .getRepository(VendaItemEntity)
      .delete({ idvenda: idVenda, seq });

    if (!result.affected) {
      throw new NotFoundException(
        `Item ${seq} não encontrado no pedido ${idVenda}`,
      );
    }

    await this.vendaService.recalcTotals(dbId, idVenda);
  }
}
