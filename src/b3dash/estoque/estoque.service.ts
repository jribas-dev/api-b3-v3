import { ForbiddenException, Injectable } from '@nestjs/common';
import { TenantService } from 'src/tenant/tenant.service';
import { EmpService } from 'src/tenant/emp.service';
import { PeriodResolver } from '../shared/period.resolver';
import { ChartDataDto } from '../shared/dto/chart-data.dto';
import { GridResponseDto } from '../shared/dto/grid-response.dto';
import { EstLancamentoDto } from './dto/est-lancamento.dto';
import { EstProdutoDto } from './dto/est-produto.dto';
import { EstFornecedorDto } from './dto/est-fornecedor.dto';

@Injectable()
export class EstoqueService {
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

  private buildTipoFilter(tipo?: string): string {
    if (tipo === 'entradas') return "AND e.tipo = 'E'";
    if (tipo === 'saidas') return "AND e.tipo = 'S'";
    return '';
  }

  // ── Graphs ──────────────────────────────────────────────────────────────

  async graphEntradasVsSaidas(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql, groupExpr } = this.periodResolver.resolve(
      'dthrestoque',
      periodo,
    );
    const labels = this.periodResolver.generateLabels(periodo);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT ${groupExpr} AS periodo,
              ROUND(SUM(IF(tipo = 'E', qtde, 0)), 3) AS entradas,
              ROUND(SUM(IF(tipo = 'S', qtde, 0)), 3) AS saidas
       FROM estoque
       WHERE cancelado = 0
         AND idemp = ?
         AND tipo IN ('E','S')
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
          name: 'Entradas',
          data: this.periodResolver.fillSeries(
            rows,
            labels,
            'periodo',
            'entradas',
            periodo,
          ),
        },
        {
          name: 'Saídas',
          data: this.periodResolver.fillSeries(
            rows,
            labels,
            'periodo',
            'saidas',
            periodo,
          ),
        },
      ],
    };
  }

  async graphTopProdutosComprados(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('m.dthremissao', periodo);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT p.id AS idprd,
              p.nome AS label,
              ROUND(SUM(mp.qtde), 3) AS qtd,
              ROUND(SUM(mp.qtde * mp.vunit), 2) AS valor
       FROM movprd mp
       JOIN mov m ON m.id = mp.idmov
       JOIN prd p ON p.id = mp.idprd
       WHERE m.cancelado = 0
         AND m.saidaentrada = '0'
         AND m.idemp = ?
         AND ${sinceSql}
       GROUP BY p.id, p.nome
       ORDER BY qtd DESC
       LIMIT 15`,
      [idemp],
    );

    return {
      chartType: 'bar_h',
      labels: rows.map((r) => String(r.label)),
      series: [
        {
          name: 'Quantidade comprada',
          data: rows.map((r) => parseFloat(String(r.qtd)) || 0),
        },
      ],
    };
  }

  async graphTopFornecedores(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('m.dthremissao', periodo);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT c.id AS idcnt,
              COALESCE(c.fantasia, c.razao) AS label,
              ROUND(SUM(m.vtotdoc), 2) AS valor
       FROM mov m
       JOIN cnt c ON c.id = m.idcnt
       WHERE m.cancelado = 0
         AND m.saidaentrada = '0'
         AND m.idemp = ?
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
          name: 'Valor de compras',
          data: rows.map((r) => parseFloat(String(r.valor)) || 0),
        },
      ],
    };
  }

  async graphCurvaAbc(
    dbId: string,
    userId: string,
    idemp: number,
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);

    const rows = await ds.query<Array<{ valor: string }>>(
      `SELECT ROUND(s.saldo * p.customedio, 2) AS valor
       FROM prdsaldo s
       JOIN prd p ON p.id = s.idprod
       WHERE s.idemp = ?
         AND s.saldo > 0
         AND p.customedio > 0
       ORDER BY valor DESC`,
      [idemp],
    );

    const totalValor = rows.reduce(
      (acc, r) => acc + (parseFloat(r.valor) || 0),
      0,
    );

    let cumSum = 0;
    const categories = { A: 0, B: 0, C: 0 };

    for (const row of rows) {
      const v = parseFloat(row.valor) || 0;
      cumSum += v;
      const pct = totalValor > 0 ? (cumSum / totalValor) * 100 : 0;
      if (pct <= 80) categories.A += v;
      else if (pct <= 95) categories.B += v;
      else categories.C += v;
    }

    return {
      chartType: 'pie',
      labels: ['A', 'B', 'C'],
      series: [
        {
          name: 'Valor imobilizado',
          data: [
            Math.round(categories.A * 100) / 100,
            Math.round(categories.B * 100) / 100,
            Math.round(categories.C * 100) / 100,
          ],
        },
      ],
    };
  }

  async graphRuptura(
    dbId: string,
    userId: string,
    idemp: number,
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT p.nome AS label,
              ROUND(s.saldo - p.saldomin, 3) AS saldoRuptura
       FROM prd p
       JOIN prdsaldo s ON s.idprod = p.id
       WHERE s.idemp = ?
         AND s.saldo < p.saldomin
         AND p.saldomin > 0
       ORDER BY saldoRuptura DESC
       LIMIT 15`,
      [idemp],
    );

    return {
      chartType: 'bar_h',
      labels: rows.map((r) => String(r.label)),
      series: [
        {
          name: 'Saldo ruptura',
          data: rows.map((r) => parseFloat(String(r.saldoRuptura)) || 0),
        },
      ],
    };
  }

  async graphValorPorGrupo(
    dbId: string,
    userId: string,
    idemp: number,
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT COALESCE(g.grupo, 'Sem grupo') AS label,
              ROUND(SUM(s.saldo * p.customedio), 2) AS valor
       FROM prdsaldo s
       JOIN prd p ON p.id = s.idprod
       LEFT JOIN prdsubgrupo ps ON ps.id = p.idsubgrupo
       LEFT JOIN prdgrupo g ON g.id = ps.idgrupo
       WHERE s.idemp = ?
         AND s.saldo > 0
         AND p.customedio > 0
       GROUP BY g.id, g.grupo
       ORDER BY valor DESC`,
      [idemp],
    );

    return {
      chartType: 'pie',
      labels: rows.map((r) => String(r.label)),
      series: [
        {
          name: 'Valor imobilizado',
          data: rows.map((r) => parseFloat(String(r.valor)) || 0),
        },
      ],
    };
  }

  // ── Lists ────────────────────────────────────────────────────────────────

  async listLancamentos(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
    page: number,
    limit: number,
    tipo?: string,
  ): Promise<GridResponseDto<EstLancamentoDto>> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('e.dthrestoque', periodo);
    const offset = (page - 1) * limit;

    const tipoFilter = this.buildTipoFilter(tipo);

    const [rows, countRows] = await Promise.all([
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT e.idestoque,
                e.dthrestoque,
                e.tipo,
                p.nome AS produto,
                e.sku,
                e.qtde,
                e.custo,
                e.origem
         FROM estoque e
         JOIN prd p ON p.id = e.idprd
         WHERE e.cancelado = 0
           AND e.idemp = ?
           AND ${sinceSql}
           ${tipoFilter}
         ORDER BY e.dthrestoque, p.nome DESC
         LIMIT ? OFFSET ?`,
        [idemp, limit, offset],
      ),
      ds.query<Array<{ total: string }>>(
        `SELECT COUNT(*) AS total
         FROM estoque e
         WHERE e.cancelado = 0
           AND e.idemp = ?
           AND ${sinceSql}
           ${tipoFilter}`,
        [idemp],
      ),
    ]);

    return {
      total: parseInt(countRows[0]?.total ?? '0', 10),
      page,
      limit,
      items: rows.map((r) => ({
        idmov: Number(r.idestoque),
        dthrestoque: String(r.dthrestoque ?? ''),
        tipo: String(r.tipo ?? ''),
        produto: String(r.produto ?? ''),
        sku: r.sku != null ? String(r.sku) : null,
        qtde: parseFloat(String(r.qtde)) || 0,
        custo: parseFloat(String(r.custo)) || 0,
        origem: r.origem != null ? String(r.origem) : null,
      })),
    };
  }

  async listPorProduto(
    dbId: string,
    userId: string,
    idemp: number,
    page: number,
    limit: number,
    apenasRuptura?: boolean,
  ): Promise<GridResponseDto<EstProdutoDto>> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const offset = (page - 1) * limit;

    const rupturaFilter = apenasRuptura
      ? 'AND s.saldo < p.saldomin AND p.saldomin > 0'
      : '';

    const [rows, countRows] = await Promise.all([
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT p.id AS idprd,
                p.codigo,
                p.nome,
                p.unidade,
                s.saldo AS saldoatu,
                p.saldomin,
                p.saldomax,
                p.customedio,
                ROUND(s.saldo * p.customedio, 2) AS valorEstoque
         FROM prdsaldo s
         JOIN prd p ON p.id = s.idprod
         WHERE s.idemp = ?
           ${rupturaFilter}
         ORDER BY valorEstoque DESC
         LIMIT ? OFFSET ?`,
        [idemp, limit, offset],
      ),
      ds.query<Array<{ total: string }>>(
        `SELECT COUNT(*) AS total
         FROM prdsaldo s
         JOIN prd p ON p.id = s.idprod
         WHERE s.idemp = ?
           ${rupturaFilter}`,
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
        saldoatu: parseFloat(String(r.saldoatu)) || 0,
        saldomin: parseFloat(String(r.saldomin)) || 0,
        saldomax: parseFloat(String(r.saldomax)) || 0,
        customedio: parseFloat(String(r.customedio)) || 0,
        valorEstoque: parseFloat(String(r.valorEstoque)) || 0,
      })),
    };
  }

  async listPorFornecedor(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
    page: number,
    limit: number,
  ): Promise<GridResponseDto<EstFornecedorDto>> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('m.dthremissao', periodo);
    const offset = (page - 1) * limit;

    const [rows, countRows] = await Promise.all([
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT c.id AS idcnt,
                c.razao,
                c.docfed,
                COUNT(*) AS qtdCompras,
                ROUND(SUM(m.vtotdoc), 2) AS valorTotal,
                MAX(m.dthremissao) AS ultimaCompraEm
         FROM mov m
         JOIN cnt c ON c.id = m.idcnt
         WHERE m.cancelado = 0
           AND m.saidaentrada = '0'
           AND m.idemp = ?
           AND ${sinceSql}
         GROUP BY c.id, c.razao, c.docfed
         ORDER BY valorTotal DESC
         LIMIT ? OFFSET ?`,
        [idemp, limit, offset],
      ),
      ds.query<Array<{ total: string }>>(
        `SELECT COUNT(DISTINCT m.idcnt) AS total
         FROM mov m
         WHERE m.cancelado = 0
           AND m.saidaentrada = '0'
           AND m.idemp = ?
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
        qtdCompras: Number(r.qtdCompras),
        valorTotal: parseFloat(String(r.valorTotal)) || 0,
        ultimaCompraEm: String(r.ultimaCompraEm ?? ''),
      })),
    };
  }
}
