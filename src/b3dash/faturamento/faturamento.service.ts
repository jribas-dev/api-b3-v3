import { ForbiddenException, Injectable } from '@nestjs/common';
import { TenantService } from 'src/tenant/tenant.service';
import { EmpService } from 'src/tenant/emp.service';
import { PeriodResolver } from '../shared/period.resolver';
import { ChartDataDto } from '../shared/dto/chart-data.dto';
import { GridResponseDto } from '../shared/dto/grid-response.dto';
import { FatPorClienteDto } from './dto/fat-por-cliente.dto';
import { FatPorProdutoDto } from './dto/fat-por-produto.dto';
import { FatPorVendedorDto } from './dto/fat-por-vendedor.dto';

@Injectable()
export class FaturamentoService {
  constructor(
    private readonly tenantService: TenantService,
    private readonly empService: EmpService,
    private readonly periodResolver: PeriodResolver,
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

  // ── Graphs ──────────────────────────────────────────────────────────────

  async graphEvolucao(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql, groupExpr } = this.periodResolver.resolve(
      'f.dthremissao',
      periodo,
    );
    const labels = this.periodResolver.generateLabels(periodo);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT ${groupExpr} AS periodo,
              ROUND(SUM(f.valortotal), 2) AS total
       FROM fat f
       WHERE f.cancelado = 0
         AND f.idemp = ?
         AND ${sinceSql}
       GROUP BY periodo
       ORDER BY periodo`,
      [idemp],
    );

    return {
      chartType: 'line',
      labels,
      series: [
        {
          name: 'Total',
          data: this.periodResolver.fillSeries(
            rows,
            labels,
            'periodo',
            'total',
            periodo,
          ),
        },
      ],
    };
  }

  async graphTicketMedio(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql, groupExpr } = this.periodResolver.resolve(
      'f.dthremissao',
      periodo,
    );
    const labels = this.periodResolver.generateLabels(periodo);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT ${groupExpr} AS periodo,
              ROUND(AVG(f.valortotal), 2) AS ticket
       FROM fat f
       WHERE f.cancelado = 0
         AND f.idemp = ?
         AND ${sinceSql}
       GROUP BY periodo
       ORDER BY periodo`,
      [idemp],
    );

    return {
      chartType: 'line',
      labels,
      series: [
        {
          name: 'Ticket Médio',
          data: this.periodResolver.fillSeries(
            rows,
            labels,
            'periodo',
            'ticket',
            periodo,
          ),
        },
      ],
    };
  }

  async graphTopProdutos(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('v.dthremissao', periodo);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT p.id AS idprd,
              p.nome AS label,
              ROUND(SUM(vi.qtde), 3) AS qtd,
              ROUND(SUM(vi.total), 2) AS valor
       FROM vendaitem vi
       JOIN venda v ON v.id = vi.idvenda
       JOIN prd   p ON p.id = vi.idprod
       WHERE v.tipo = 'V'
         AND v.idemp = ?
         AND ${sinceSql}
       GROUP BY p.id, p.nome
       ORDER BY valor DESC
       LIMIT 15`,
      [idemp],
    );

    return {
      chartType: 'bar_h',
      labels: rows.map((r) => String(r.label)),
      series: [
        {
          name: 'Valor vendido',
          data: rows.map((r) => parseFloat(String(r.valor)) || 0),
        },
      ],
    };
  }

  async graphTopClientes(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('f.dthremissao', periodo);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT c.id AS idcnt,
              COALESCE(c.fantasia, c.razao) AS label,
              ROUND(SUM(f.valortotal), 2) AS valor
       FROM fat f
       JOIN cnt c ON c.id = f.idcnt
       WHERE f.cancelado = 0
         AND f.idemp = ?
         AND ${sinceSql}
       GROUP BY c.id, c.razao, c.fantasia
       ORDER BY valor DESC
       LIMIT 15`,
      [idemp],
    );

    return {
      chartType: 'bar_h',
      labels: rows.map((r) => String(r.label)),
      series: [
        {
          name: 'Faturamento',
          data: rows.map((r) => parseFloat(String(r.valor)) || 0),
        },
      ],
    };
  }

  async graphRankingVendedores(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql, groupExpr } = this.periodResolver.resolve(
      'v.dthremissao',
      periodo,
    );
    const labels = this.periodResolver.generateLabels(periodo);

    const topRows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT v.idvend,
              COALESCE(c.razao, 'Sem vendedor') AS nomeVendedor,
              ROUND(SUM(v.vlrtotal), 2) AS total
       FROM venda v
       LEFT JOIN cnt c ON c.id = v.idvend
       WHERE v.tipo = 'V'
         AND v.idemp = ?
         AND ${sinceSql}
       GROUP BY v.idvend, c.razao
       ORDER BY total DESC
       LIMIT 15`,
      [idemp],
    );

    const top = topRows.map((r) => ({
      idvend: r.idvend == null ? null : Number(r.idvend),
      nomeVendedor: String(r.nomeVendedor ?? 'Sem vendedor'),
    }));

    if (top.length === 0) {
      return { chartType: 'line', labels, series: [] };
    }

    const numericIds = top
      .map((t) => t.idvend)
      .filter((id): id is number => id != null);
    const hasNull = top.some((t) => t.idvend == null);

    const vendFilters: string[] = [];
    const vendParams: number[] = [];
    if (numericIds.length > 0) {
      vendFilters.push(`v.idvend IN (${numericIds.map(() => '?').join(',')})`);
      vendParams.push(...numericIds);
    }
    if (hasNull) {
      vendFilters.push(`v.idvend IS NULL`);
    }
    const vendFilter = `AND (${vendFilters.join(' OR ')})`;

    const buckets = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT ${groupExpr} AS periodo,
              v.idvend,
              ROUND(SUM(v.vlrtotal), 2) AS total
       FROM venda v
       WHERE v.tipo = 'V'
         AND v.idemp = ?
         AND ${sinceSql}
         ${vendFilter}
       GROUP BY periodo, v.idvend
       ORDER BY periodo`,
      [idemp, ...vendParams],
    );

    const byVend = new Map<
      number | null,
      Array<Record<string, string | number | Date | null>>
    >();
    for (const row of buckets) {
      const key = row.idvend == null ? null : Number(row.idvend);
      const arr = byVend.get(key);
      if (arr) arr.push(row);
      else byVend.set(key, [row]);
    }

    const series = top.map((t) => ({
      name: t.nomeVendedor,
      data: this.periodResolver.fillSeries(
        byVend.get(t.idvend) ?? [],
        labels,
        'periodo',
        'total',
        periodo,
      ),
    }));

    return {
      chartType: 'line',
      labels,
      series,
    };
  }

  async graphMixOperacoes(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('f.dthremissao', periodo);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT o.operacao AS label,
              ROUND(SUM(f.valortotal), 2) AS valor
       FROM fat f
       JOIN operacoes o ON o.id = f.idoper
       WHERE f.cancelado = 0
         AND f.idemp = ?
         AND ${sinceSql}
       GROUP BY o.id, o.operacao
       ORDER BY valor DESC`,
      [idemp],
    );

    return {
      chartType: 'pie',
      labels: rows.map((r) => String(r.label)),
      series: [
        {
          name: 'Faturamento',
          data: rows.map((r) => parseFloat(String(r.valor)) || 0),
        },
      ],
    };
  }

  // ── Lists ────────────────────────────────────────────────────────────────

  async listPorCliente(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
    page: number,
    limit: number,
  ): Promise<GridResponseDto<FatPorClienteDto>> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('f.dthremissao', periodo);
    const offset = (page - 1) * limit;

    const [rows, countRows] = await Promise.all([
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT c.id AS idcnt,
                c.razao,
                c.docfed,
                COUNT(*) AS qtdPedidos,
                ROUND(SUM(f.valortotal), 2) AS valorTotal,
                MAX(f.dthremissao) AS ultimoPedidoEm,
                ROUND(AVG(f.valortotal), 2) AS ticketMedio
         FROM fat f
         JOIN cnt c ON c.id = f.idcnt
         WHERE f.cancelado = 0
           AND f.idemp = ?
           AND ${sinceSql}
         GROUP BY c.id, c.razao, c.docfed
         ORDER BY valorTotal DESC
         LIMIT ? OFFSET ?`,
        [idemp, limit, offset],
      ),
      ds.query<Array<{ total: string }>>(
        `SELECT COUNT(DISTINCT f.idcnt) AS total
         FROM fat f
         WHERE f.cancelado = 0
           AND f.idemp = ?
           AND ${sinceSql}`,
        [idemp],
      ),
    ]);

    return {
      total: parseInt(countRows[0]?.total ?? '0', 10),
      page,
      limit,
      items: rows.map((r) => ({
        idcnt: Number(r.idcnt),
        razao: String(r.razao ?? ''),
        docfed: r.docfed != null ? String(r.docfed) : null,
        qtdPedidos: Number(r.qtdPedidos),
        valorTotal: parseFloat(String(r.valorTotal)) || 0,
        ultimoPedidoEm: String(r.ultimoPedidoEm ?? ''),
        ticketMedio: parseFloat(String(r.ticketMedio)) || 0,
      })),
    };
  }

  async listPorProduto(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
    page: number,
    limit: number,
  ): Promise<GridResponseDto<FatPorProdutoDto>> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('v.dthremissao', periodo);
    const offset = (page - 1) * limit;

    const [rows, countRows] = await Promise.all([
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT p.id AS idprd,
                p.codigo,
                p.nome,
                p.unidade,
                ROUND(SUM(vi.qtde), 3) AS qtdeTotal,
                ROUND(SUM(vi.total), 2) AS valorTotal,
                ROUND(SUM(vi.total) / NULLIF(SUM(vi.qtde), 0), 2) AS precoMedio
         FROM vendaitem vi
         JOIN venda v ON v.id = vi.idvenda
         JOIN prd   p ON p.id = vi.idprod
         WHERE v.tipo = 'V'
           AND v.idemp = ?
           AND ${sinceSql}
         GROUP BY p.id, p.codigo, p.nome, p.unidade
         ORDER BY valorTotal DESC
         LIMIT ? OFFSET ?`,
        [idemp, limit, offset],
      ),
      ds.query<Array<{ total: string }>>(
        `SELECT COUNT(DISTINCT vi.idprod) AS total
         FROM vendaitem vi
         JOIN venda v ON v.id = vi.idvenda
         WHERE v.tipo = 'V'
           AND v.idemp = ?
           AND ${sinceSql}`,
        [idemp],
      ),
    ]);

    return {
      total: parseInt(countRows[0]?.total ?? '0', 10),
      page,
      limit,
      items: rows.map((r) => ({
        idprd: Number(r.idprd),
        codigo: r.codigo != null ? String(r.codigo) : null,
        nome: String(r.nome ?? ''),
        unidade: String(r.unidade ?? ''),
        qtdeTotal: parseFloat(String(r.qtdeTotal)) || 0,
        valorTotal: parseFloat(String(r.valorTotal)) || 0,
        precoMedio: parseFloat(String(r.precoMedio)) || 0,
      })),
    };
  }

  async listPorVendedor(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
    page: number,
    limit: number,
  ): Promise<GridResponseDto<FatPorVendedorDto>> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('v.dthremissao', periodo);
    const offset = (page - 1) * limit;

    const [rows, countRows] = await Promise.all([
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT v.idvend,
                COALESCE(c.razao, 'Sem vendedor') AS nomeVendedor,
                COUNT(*) AS qtdPedidos,
                ROUND(SUM(v.vlrtotal), 2) AS valorTotal,
                COUNT(DISTINCT v.idcli) AS clientesUnicos,
                ROUND(AVG(v.vlrtotal), 2) AS ticketMedio
         FROM venda v
         LEFT JOIN cnt c ON c.id = v.idvend
         WHERE v.tipo = 'V'
           AND v.idemp = ?
           AND ${sinceSql}
         GROUP BY v.idvend, c.razao
         ORDER BY valorTotal DESC
         LIMIT ? OFFSET ?`,
        [idemp, limit, offset],
      ),
      ds.query<Array<{ total: string }>>(
        `SELECT COUNT(DISTINCT v.idvend) AS total
         FROM venda v
         WHERE v.tipo = 'V'
           AND v.idemp = ?
           AND ${sinceSql}`,
        [idemp],
      ),
    ]);

    return {
      total: parseInt(countRows[0]?.total ?? '0', 10),
      page,
      limit,
      items: rows.map((r) => ({
        idvend: r.idvend != null ? Number(r.idvend) : null,
        nomeVendedor: String(r.nomeVendedor ?? 'Sem vendedor'),
        qtdPedidos: Number(r.qtdPedidos),
        valorTotal: parseFloat(String(r.valorTotal)) || 0,
        clientesUnicos: Number(r.clientesUnicos),
        ticketMedio: parseFloat(String(r.ticketMedio)) || 0,
      })),
    };
  }
}
