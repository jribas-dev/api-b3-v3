import { ForbiddenException, Injectable } from '@nestjs/common';
import { TenantService } from 'src/tenant/tenant.service';
import { EmpService } from 'src/tenant/emp.service';
import { PeriodResolver } from '../shared/period.resolver';
import { ChartDataDto } from '../shared/dto/chart-data.dto';
import { GridResponseDto } from '../shared/dto/grid-response.dto';
import { FinReceberDto } from './dto/fin-receber.dto';
import { FinPagarDto } from './dto/fin-pagar.dto';
import { FinMovimentoDto } from './dto/fin-movimento.dto';

@Injectable()
export class FinanceiroService {
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

  async graphReceberVsPagar(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const labels = this.periodResolver.generateLabels(periodo);

    const { sinceSql: sinceRec, groupExpr: groupRec } =
      this.periodResolver.resolve('r.emissao', periodo);
    const { sinceSql: sincePag, groupExpr: groupPag } =
      this.periodResolver.resolve('cp.dtemissao', periodo);

    const [recRows, pagRows] = await Promise.all([
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT ${groupRec} AS periodo,
                ROUND(SUM(IFNULL(r.valorpago, 0)), 2) AS recebido
         FROM ctareceber r
         WHERE r.anulada = 0
           AND r.idemp = ?
           AND r.pagamento IS NOT NULL
           AND ${sinceRec}
         GROUP BY periodo
         ORDER BY periodo`,
        [idemp],
      ),
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT ${groupPag} AS periodo,
                ROUND(SUM(IFNULL(pg.valorpago, 0)), 2) AS pago
         FROM ctapag cp
         LEFT JOIN (
           SELECT idpag, SUM(valorpago) AS valorpago
           FROM ctapagp
           GROUP BY idpag
         ) pg ON pg.idpag = cp.id
         WHERE cp.idemp = ?
           AND ${sincePag}
         GROUP BY periodo
         ORDER BY periodo`,
        [idemp],
      ),
    ]);

    return {
      chartType: 'line',
      labels,
      series: [
        {
          name: 'Recebido',
          data: this.periodResolver.fillSeries(
            recRows,
            labels,
            'periodo',
            'recebido',
            periodo,
          ),
        },
        {
          name: 'Pago',
          data: this.periodResolver.fillSeries(
            pagRows,
            labels,
            'periodo',
            'pago',
            periodo,
          ),
        },
      ],
    };
  }

  async graphFluxoCaixaProjetado(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const labels = this.periodResolver.generateLabels(periodo);

    const { sinceSql: sinceRec, groupExpr: groupRec } =
      this.periodResolver.resolve('r.vencimento', periodo);
    const { sinceSql: sincePag, groupExpr: groupPag } =
      this.periodResolver.resolve('cp.dtemissao', periodo);

    const [entRows, saiRows] = await Promise.all([
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT ${groupRec} AS periodo,
                ROUND(SUM(r.valor), 2) AS entrada
         FROM ctareceber r
         WHERE r.anulada = 0
           AND r.idemp = ?
           AND ${sinceRec}
         GROUP BY periodo
         ORDER BY periodo`,
        [idemp],
      ),
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT ${groupPag} AS periodo,
                ROUND(SUM(cp.valortotal - IFNULL(pg.valorpago, 0)), 2) AS saida
         FROM ctapag cp
         LEFT JOIN (
           SELECT idpag, SUM(valorpago) AS valorpago
           FROM ctapagp
           GROUP BY idpag
         ) pg ON pg.idpag = cp.id
         WHERE cp.idemp = ?
           AND ${sincePag}
         GROUP BY periodo
         ORDER BY periodo`,
        [idemp],
      ),
    ]);

    return {
      chartType: 'line',
      labels,
      series: [
        {
          name: 'Entradas previstas',
          data: this.periodResolver.fillSeries(
            entRows,
            labels,
            'periodo',
            'entrada',
            periodo,
          ),
        },
        {
          name: 'Saídas previstas',
          data: this.periodResolver.fillSeries(
            saiRows,
            labels,
            'periodo',
            'saida',
            periodo,
          ),
        },
      ],
    };
  }

  async graphInadimplencia(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('r.emissao', periodo);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT CASE
                WHEN r.pagamento IS NOT NULL THEN 'Recebido'
                WHEN r.vencimento < CURDATE() THEN 'Vencido'
                ELSE 'A Vencer'
              END AS label,
              ROUND(SUM(r.valor), 2) AS value
       FROM ctareceber r
       WHERE r.anulada = 0
         AND r.idemp = ?
         AND ${sinceSql}
       GROUP BY label`,
      [idemp],
    );

    return {
      chartType: 'pie',
      labels: rows.map((r) => String(r.label)),
      series: [
        {
          name: 'Valor',
          data: rows.map((r) => parseFloat(String(r.value)) || 0),
        },
      ],
    };
  }

  async graphTopInadimplentes(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('r.emissao', periodo);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT c.id AS idcnt,
              COALESCE(c.fantasia, c.razao) AS label,
              ROUND(SUM(r.valor), 2) AS valorVencido
       FROM ctareceber r
       JOIN cnt c ON c.id = r.idcnt
       WHERE r.anulada = 0
         AND r.idemp = ?
         AND r.pagamento IS NULL
         AND r.vencimento < CURDATE()
         AND ${sinceSql}
       GROUP BY c.id, c.razao, c.fantasia
       ORDER BY valorVencido DESC
       LIMIT 15`,
      [idemp],
    );

    return {
      chartType: 'bar_h',
      labels: rows.map((r) => String(r.label)),
      series: [
        {
          name: 'Valor vencido',
          data: rows.map((r) => parseFloat(String(r.valorVencido)) || 0),
        },
      ],
    };
  }

  async graphEntradasPorEspecie(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('fm.dataemi', periodo);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT fe.especie AS label,
              ROUND(SUM(fm.valor), 2) AS valor
       FROM finmov fm
       JOIN finespecie fe ON fe.id = fm.idespecie
       WHERE fm.idemp = ?
         AND fm.debcred = 'C'
         AND ${sinceSql}
       GROUP BY fe.id, fe.especie
       ORDER BY valor DESC`,
      [idemp],
    );

    return {
      chartType: 'pie',
      labels: rows.map((r) => String(r.label)),
      series: [
        {
          name: 'Entradas',
          data: rows.map((r) => parseFloat(String(r.valor)) || 0),
        },
      ],
    };
  }

  async graphSaldoDestinos(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
  ): Promise<ChartDataDto> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('fm.dataemi', periodo);

    const rows = await ds.query<
      Array<Record<string, string | number | Date | null>>
    >(
      `SELECT fd.destino AS label,
              ROUND(SUM(IF(fm.debcred = 'C', fm.valor, -fm.valor)), 2) AS saldo
       FROM finmov fm
       JOIN findestino fd ON fd.id = fm.iddest
       WHERE fm.idemp = ?
         AND ${sinceSql}
       GROUP BY fd.id, fd.destino
       ORDER BY saldo DESC`,
      [idemp],
    );

    return {
      chartType: 'bar_v',
      labels: rows.map((r) => String(r.label)),
      series: [
        {
          name: 'Saldo',
          data: rows.map((r) => parseFloat(String(r.saldo)) || 0),
        },
      ],
    };
  }

  // ── Lists ────────────────────────────────────────────────────────────────

  async listReceber(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
    page: number,
    limit: number,
    status?: string,
  ): Promise<GridResponseDto<FinReceberDto>> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('r.emissao', periodo);
    const offset = (page - 1) * limit;

    const statusFilter = this.buildReceberStatusFilter(status);

    const [rows, countRows] = await Promise.all([
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT r.idctarec,
                COALESCE(c.fantasia, c.razao, '') AS cliente,
                r.emissao,
                r.vencimento,
                r.pagamento,
                r.valor,
                IFNULL(r.valorpago, 0) AS valorpago,
                CASE
                  WHEN r.pagamento IS NOT NULL    THEN 'pago'
                  WHEN r.vencimento < CURDATE()   THEN 'vencido'
                  ELSE 'aberto'
                END AS status
         FROM ctareceber r
         LEFT JOIN cnt c ON c.id = r.idcnt
         WHERE r.anulada = 0
           AND r.idemp = ?
           AND ${sinceSql}
           ${statusFilter}
         ORDER BY r.vencimento ASC
         LIMIT ? OFFSET ?`,
        [idemp, limit, offset],
      ),
      ds.query<Array<{ total: string }>>(
        `SELECT COUNT(*) AS total
         FROM ctareceber r
         WHERE r.anulada = 0
           AND r.idemp = ?
           AND ${sinceSql}
           ${statusFilter}`,
        [idemp],
      ),
    ]);

    return {
      total: parseInt(countRows[0]?.total ?? '0', 10),
      page,
      limit,
      items: rows.map((r) => ({
        idctarec: Number(r.idctarec),
        cliente: String(r.cliente ?? ''),
        emissao: String(r.emissao ?? ''),
        vencimento: String(r.vencimento ?? ''),
        pagamento: r.pagamento != null ? String(r.pagamento) : null,
        valor: parseFloat(String(r.valor)) || 0,
        valorpago: parseFloat(String(r.valorpago)) || 0,
        status: (r.status as FinReceberDto['status']) ?? 'aberto',
      })),
    };
  }

  async listPagar(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
    page: number,
    limit: number,
    status?: string,
  ): Promise<GridResponseDto<FinPagarDto>> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('cp.dtemissao', periodo);
    const offset = (page - 1) * limit;

    // Status baseado em subquery pois vencimento está em ctapagp
    const outerStatusFilter = this.buildPagarStatusFilter(status);

    // Query principal envolve subquery para permitir filtro de status pós-agregação
    const innerSql = `
      SELECT cp.id AS idpag,
             cp.nrodoc,
             COALESCE(c.fantasia, c.razao, '') AS fornecedor,
             cp.dtemissao AS emissao,
             MIN(pg2.vencimento) AS vencimentoMin,
             cp.valortotal,
             IFNULL(pg.valorpago, 0) AS valorPagoAcum,
             CASE
               WHEN IFNULL(pg.valorpago, 0) >= cp.valortotal THEN 'pago'
               WHEN MIN(pg2.vencimento) < CURDATE()          THEN 'vencido'
               ELSE 'aberto'
             END AS status
      FROM ctapag cp
      LEFT JOIN cnt c ON c.id = cp.idcnt
      LEFT JOIN (
        SELECT idpag, SUM(valorpago) AS valorpago
        FROM ctapagp
        GROUP BY idpag
      ) pg ON pg.idpag = cp.id
      LEFT JOIN ctapagp pg2 ON pg2.idpag = cp.id
      WHERE cp.idemp = ?
        AND ${sinceSql}
      GROUP BY cp.id, cp.nrodoc, c.fantasia, c.razao,
               cp.dtemissao, cp.valortotal, pg.valorpago`;

    const [rows, countRows] = await Promise.all([
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT * FROM (${innerSql}) sub
         ${outerStatusFilter}
         ORDER BY emissao DESC
         LIMIT ? OFFSET ?`,
        [idemp, limit, offset],
      ),
      ds.query<Array<{ total: string }>>(
        `SELECT COUNT(*) AS total FROM (${innerSql}) sub ${outerStatusFilter}`,
        [idemp],
      ),
    ]);

    return {
      total: parseInt(countRows[0]?.total ?? '0', 10),
      page,
      limit,
      items: rows.map((r) => ({
        idpag: Number(r.idpag),
        nrodoc: r.nrodoc != null ? String(r.nrodoc) : null,
        fornecedor: String(r.fornecedor ?? ''),
        emissao: String(r.emissao ?? ''),
        vencimentoMin: r.vencimentoMin != null ? String(r.vencimentoMin) : null,
        valortotal: parseFloat(String(r.valortotal)) || 0,
        valorPagoAcum: parseFloat(String(r.valorPagoAcum)) || 0,
        status: (r.status as FinPagarDto['status']) ?? 'aberto',
      })),
    };
  }

  async listMovimentos(
    dbId: string,
    userId: string,
    idemp: number,
    periodo: 'S' | 'M' | 'T',
    page: number,
    limit: number,
  ): Promise<GridResponseDto<FinMovimentoDto>> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);
    const { sinceSql } = this.periodResolver.resolve('fm.dataemi', periodo);
    const offset = (page - 1) * limit;

    const [rows, countRows] = await Promise.all([
      ds.query<Array<Record<string, string | number | Date | null>>>(
        `SELECT fm.idmov,
                fm.dataemi,
                fm.debcred,
                IFNULL(fe.especie, '') AS especie,
                IFNULL(fd.destino, '') AS destino,
                fm.valor,
                CAST(fm.baixado AS UNSIGNED) AS baixado,
                fm.tborigem
         FROM finmov fm
         LEFT JOIN finespecie fe ON fe.id = fm.idespecie
         LEFT JOIN findestino fd ON fd.id = fm.iddest
         WHERE fm.idemp = ?
           AND ${sinceSql}
         ORDER BY fm.dataemi DESC
         LIMIT ? OFFSET ?`,
        [idemp, limit, offset],
      ),
      ds.query<Array<{ total: string }>>(
        `SELECT COUNT(*) AS total
         FROM finmov fm
         WHERE fm.idemp = ?
           AND ${sinceSql}`,
        [idemp],
      ),
    ]);

    return {
      total: parseInt(countRows[0]?.total ?? '0', 10),
      page,
      limit,
      items: rows.map((r) => ({
        idmov: Number(r.idmov),
        dataemi: String(r.dataemi ?? ''),
        debcred: (r.debcred as 'C' | 'D') ?? 'D',
        especie: String(r.especie ?? ''),
        destino: String(r.destino ?? ''),
        valor: parseFloat(String(r.valor)) || 0,
        baixado: Boolean(r.baixado),
        tborigem: r.tborigem != null ? String(r.tborigem) : null,
      })),
    };
  }

  private buildReceberStatusFilter(status?: string): string {
    switch (status) {
      case 'pago':
        return 'AND r.pagamento IS NOT NULL';
      case 'vencido':
        return 'AND r.pagamento IS NULL AND r.vencimento < CURDATE()';
      case 'aberto':
        return 'AND r.pagamento IS NULL AND r.vencimento >= CURDATE()';
      default:
        return '';
    }
  }

  // Retorna cláusula WHERE para subquery externa (status já calculado)
  private buildPagarStatusFilter(status?: string): string {
    switch (status) {
      case 'pago':
        return "WHERE status = 'pago'";
      case 'vencido':
        return "WHERE status = 'vencido'";
      case 'aberto':
        return "WHERE status = 'aberto'";
      default:
        return '';
    }
  }
}
