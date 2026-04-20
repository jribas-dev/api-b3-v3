import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { DataSource } from 'typeorm';
import { TenantService } from 'src/tenant/tenant.service';
import { SellerContextService } from 'src/b3vendas/shared/seller-context.service';
import { OperacaoService } from 'src/b3vendas/operacao/operacao.service';
import { FormasPagamentoService } from 'src/b3vendas/formas-pagamento/formas-pagamento.service';
import { VendaEntity } from './entities/venda.entity';
import { VendaCaixaEntity } from './entities/venda-caixa.entity';
import { CreateVendaDto } from './dto/create-venda.dto';
import { FecharVendaDto } from './dto/fechar-venda.dto';
import {
  ResponseVendaDetalheDto,
  ResponseVendaItemDto,
  ResponseVendaResumoDto,
} from './dto/response-venda.dto';

type VendaResumoRow = {
  id: number;
  idcli: number | null;
  razaoCliente: string | null;
  dthremissao: Date;
  tipo: string;
  vlrtotal: string | number;
};

type VendaItemRow = {
  seq: number;
  idprod: number;
  nomeProduto: string | null;
  qtde: string | number;
  unitario: string | number;
  total: string | number;
};

type FormaCondRow = { idforma: number | null; idcond: number | null };

function toNumber(value: string | number | null | undefined): number {
  if (value == null) return 0;
  return typeof value === 'number' ? value : parseFloat(value);
}

@Injectable()
export class VendaService {
  constructor(
    private readonly tenantService: TenantService,
    private readonly sellerContextService: SellerContextService,
    private readonly operacaoService: OperacaoService,
    private readonly formasPagamentoService: FormasPagamentoService,
  ) {}

  async create(
    dbId: string,
    userId: string,
    dto: CreateVendaDto,
  ): Promise<{ id: number }> {
    const { usuId, vendId } = await this.sellerContextService.resolve(
      dbId,
      userId,
    );
    const operacao = await this.operacaoService.findOneOrFail(dbId, dto.idOper);

    const ds = await this.tenantService.getDataSource(dbId);
    const repo = ds.getRepository(VendaEntity);

    const entity = repo.create({
      idoper: dto.idOper,
      fiscal: dto.rcfat,
      tipo: dto.rctipo,
      subtipo: operacao.subtipo ?? 'N',
      idcli: dto.idCli,
      idvend: vendId,
      idemp: dto.idemp,
      plataforma: 'SALESFORCE',
      processo: 'B3PED.exe',
      ultimousu: usuId,
    });

    const saved = await repo.save(entity);
    return { id: saved.id };
  }

  async findEditaveis(
    dbId: string,
    userId: string,
    idemp: number,
  ): Promise<ResponseVendaResumoDto[]> {
    const { vendId } = await this.sellerContextService.resolve(dbId, userId);
    const ds = await this.tenantService.getDataSource(dbId);

    const rows = await ds.query<VendaResumoRow[]>(
      `SELECT a.id, a.idcli, b.razao AS razaoCliente,
              a.dthremissao, a.tipo, a.vlrtotal
         FROM venda a
         LEFT JOIN cnt b ON a.idcli = b.id
        WHERE a.tipo = 'O'
          AND a.idvend = ?
          AND a.idemp = ?
          AND CURRENT_TIMESTAMP < DATE_ADD(a.dthremissao, INTERVAL 5 DAY)
        ORDER BY a.id DESC`,
      [vendId, idemp],
    );

    return rows.map((r) =>
      plainToInstance(ResponseVendaResumoDto, {
        ...r,
        vlrtotal: toNumber(r.vlrtotal),
      }),
    );
  }

  async findFechados(
    dbId: string,
    userId: string,
    idemp: number,
  ): Promise<ResponseVendaResumoDto[]> {
    const { vendId } = await this.sellerContextService.resolve(dbId, userId);
    const ds = await this.tenantService.getDataSource(dbId);

    const rows = await ds.query<VendaResumoRow[]>(
      `SELECT a.id, a.idcli, b.razao AS razaoCliente,
              a.dthremissao, a.tipo, a.vlrtotal
         FROM venda a
         LEFT JOIN cnt b ON a.idcli = b.id
        WHERE a.tipo IN ('P', 'V')
          AND a.idvend = ?
          AND a.idemp = ?
          AND CURRENT_TIMESTAMP < DATE_ADD(a.dthremissao, INTERVAL 30 DAY)
        ORDER BY a.id DESC`,
      [vendId, idemp],
    );

    return rows.map((r) =>
      plainToInstance(ResponseVendaResumoDto, {
        ...r,
        vlrtotal: toNumber(r.vlrtotal),
      }),
    );
  }

  async findOne(
    dbId: string,
    userId: string,
    id: number,
  ): Promise<ResponseVendaDetalheDto> {
    const ds = await this.tenantService.getDataSource(dbId);
    const venda = await this.loadVendaVinculada(ds, dbId, userId, id);

    const [clienteRow] = await ds.query<{ razao: string | null }[]>(
      `SELECT razao FROM cnt WHERE id = ? LIMIT 1`,
      [venda.idcli],
    );

    const itens = await ds.query<VendaItemRow[]>(
      `SELECT a.seq, a.idprod, b.nome AS nomeProduto,
              a.qtde, a.unitario, a.total
         FROM vendaitem a
         LEFT JOIN prd b ON a.idprod = b.id
        WHERE a.idvenda = ?
        ORDER BY a.seq ASC`,
      [id],
    );

    const [formaCond] = await ds.query<FormaCondRow[]>(
      `SELECT idforma, idcond FROM vendacaixa WHERE idvenda = ? LIMIT 1`,
      [id],
    );

    return plainToInstance(ResponseVendaDetalheDto, {
      id: venda.id,
      idcli: venda.idcli,
      razaoCliente: clienteRow?.razao ?? null,
      idoper: venda.idoper,
      fiscal: venda.fiscal,
      tipo: venda.tipo,
      vlrbruto: venda.vlrbruto,
      desconto: venda.desconto,
      acrescimo: venda.acrescimo,
      st: venda.st,
      ipi: venda.ipi,
      vlrtotal: venda.vlrtotal,
      obsinter: venda.obsinter,
      idForma: formaCond?.idforma ?? null,
      idCond: formaCond?.idcond ?? null,
      itens: itens.map((it) =>
        plainToInstance(ResponseVendaItemDto, {
          ...it,
          qtde: toNumber(it.qtde),
          unitario: toNumber(it.unitario),
          total: toNumber(it.total),
        }),
      ),
    });
  }

  async fechar(
    dbId: string,
    userId: string,
    id: number,
    dto: FecharVendaDto,
  ): Promise<{ id: number; vlrtotal: number }> {
    const ds = await this.tenantService.getDataSource(dbId);
    const venda = await this.loadVendaVinculada(ds, dbId, userId, id);
    if (venda.tipo !== 'O') {
      throw new BadRequestException(
        'Somente pedidos abertos podem ser fechados',
      );
    }

    const operForma = await this.formasPagamentoService.operacaoDaForma(
      dbId,
      dto.idForma,
    );

    await ds.transaction(async (tx) => {
      await tx.delete(VendaCaixaEntity, { idvenda: id });
      await tx.insert(VendaCaixaEntity, {
        idvenda: id,
        idforma: dto.idForma,
        seq: 1,
        valor: venda.vlrtotal,
        idcond: dto.idCond,
        operacao: operForma,
        baixado: true,
      });

      if (dto.obsInter !== undefined) {
        await tx.update(VendaEntity, { id }, { obsinter: dto.obsInter });
      }
    });

    return { id, vlrtotal: venda.vlrtotal };
  }

  async recalcTotals(dbId: string, idVenda: number): Promise<void> {
    const ds = await this.tenantService.getDataSource(dbId);
    await ds.query(
      `UPDATE venda v
         INNER JOIN (
            SELECT COALESCE(SUM(bruto), 0)     AS bruto,
                   COALESCE(SUM(desconto), 0)  AS desconto,
                   COALESCE(SUM(acrescimo), 0) AS acrescimo,
                   COALESCE(SUM(st), 0)        AS st,
                   COALESCE(SUM(ipi), 0)       AS ipi
              FROM vendaitem
             WHERE idvenda = ?
         ) src
         SET v.vlrbruto  = src.bruto,
             v.desconto  = src.desconto,
             v.acrescimo = src.acrescimo,
             v.st        = src.st,
             v.ipi       = src.ipi
       WHERE v.id = ?`,
      [idVenda, idVenda],
    );

    await ds.query(
      `UPDATE venda
          SET vlrtotal = (vlrbruto + acrescimo + st + ipi + frete + seguro + outros)
                         - (desconto + deducoes)
        WHERE id = ?`,
      [idVenda],
    );
  }

  async loadVendaVinculada(
    ds: DataSource,
    dbId: string,
    userId: string,
    id: number,
  ): Promise<VendaEntity> {
    const { vendId } = await this.sellerContextService.resolve(dbId, userId);
    const venda = await ds.getRepository(VendaEntity).findOneBy({ id });
    if (!venda) throw new NotFoundException(`Pedido ${id} não encontrado`);
    if (venda.idvend !== vendId) {
      throw new ForbiddenException(
        'Esse pedido não está vinculado ao seu usuário',
      );
    }
    return venda;
  }

  async assertEditavel(
    dbId: string,
    userId: string,
    id: number,
  ): Promise<VendaEntity> {
    const ds = await this.tenantService.getDataSource(dbId);
    const venda = await this.loadVendaVinculada(ds, dbId, userId, id);
    if (venda.tipo !== 'O') {
      throw new BadRequestException('Esse pedido não pode ser alterado');
    }
    return venda;
  }
}
