import { ForbiddenException, Injectable } from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { DataSource } from 'typeorm';
import { SellerContextService } from 'src/b3vendas/shared/seller-context.service';
import { TenantService } from 'src/tenant/tenant.service';
import {
  RoleFront,
  RoleFrontEnum,
} from 'src/user-domain/user-instance/enums/user-instance-roles.enum';
import { ChartDataDto } from './dto/chart-data.dto';
import { QueryMetricasDto } from './dto/query-metricas.dto';
import { ResponseClienteInativoDto } from './dto/response-cliente-inativo.dto';

interface SellerScope {
  ds: DataSource;
  vendIds: number[];
  idemp: number;
}

interface PeriodoRow {
  periodo: string | number;
  total: string | number | null;
}

interface TopClienteRow {
  idcli: number;
  nome: string;
  valor: string | number | null;
  qtd: string | number | null;
}

interface ClienteInativoRow {
  id: number;
  nome: string;
  docfed: string | null;
  email: string | null;
  fone: string | null;
  cel: string | null;
  cidade: string | null;
  uf: string | null;
  ultimaVenda: Date | string | null;
  idvende: number | null;
}

const VENDA_ANALISE_FILTER = `v.tipo = 'V' AND v.subtipo = 'N' AND v.baixado = 1`;

@Injectable()
export class MetricasService {
  constructor(
    private readonly tenantService: TenantService,
    private readonly sellerContextService: SellerContextService,
  ) {}

  async vendasSemanais(
    dbId: string,
    userId: string,
    roleFront: RoleFront,
    query: QueryMetricasDto,
  ): Promise<ChartDataDto> {
    const { ds, vendIds, idemp } = await this.resolveScope(
      dbId,
      userId,
      roleFront,
      query,
    );
    const placeholders = vendIds.map(() => '?').join(',');

    const rows = await ds.query<PeriodoRow[]>(
      `SELECT YEARWEEK(v.dthremissao, 1) AS periodo,
              ROUND(SUM(v.vlrtotal), 2) AS total
         FROM venda v
        WHERE ${VENDA_ANALISE_FILTER}
          AND v.idvend IN (${placeholders})
          AND v.idemp = ?
          AND v.dthremissao >= DATE_SUB(CURDATE(), INTERVAL 12 WEEK)
        GROUP BY periodo
        ORDER BY periodo`,
      [...vendIds, idemp],
    );

    const labels = this.last12WeekLabels();
    const data = this.fillSeries(rows, labels, (raw) =>
      this.yearweekToIsoLabel(String(raw)),
    );

    return plainToInstance(ChartDataDto, {
      chartType: 'line',
      labels,
      series: [{ name: 'Vendas (R$)', data }],
    });
  }

  async vendasMensais(
    dbId: string,
    userId: string,
    roleFront: RoleFront,
    query: QueryMetricasDto,
  ): Promise<ChartDataDto> {
    const { ds, vendIds, idemp } = await this.resolveScope(
      dbId,
      userId,
      roleFront,
      query,
    );
    const placeholders = vendIds.map(() => '?').join(',');

    const rows = await ds.query<PeriodoRow[]>(
      `SELECT DATE_FORMAT(v.dthremissao, '%Y-%m') AS periodo,
              ROUND(SUM(v.vlrtotal), 2) AS total
         FROM venda v
        WHERE ${VENDA_ANALISE_FILTER}
          AND v.idvend IN (${placeholders})
          AND v.idemp = ?
          AND v.dthremissao >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
        GROUP BY periodo
        ORDER BY periodo`,
      [...vendIds, idemp],
    );

    const labels = this.last12MonthLabels();
    const data = this.fillSeries(rows, labels, (raw) => String(raw));

    return plainToInstance(ChartDataDto, {
      chartType: 'line',
      labels,
      series: [{ name: 'Vendas (R$)', data }],
    });
  }

  async topClientesAtivos(
    dbId: string,
    userId: string,
    roleFront: RoleFront,
    query: QueryMetricasDto,
  ): Promise<ChartDataDto> {
    const { ds, vendIds, idemp } = await this.resolveScope(
      dbId,
      userId,
      roleFront,
      query,
    );
    const placeholders = vendIds.map(() => '?').join(',');

    const rows = await ds.query<TopClienteRow[]>(
      `SELECT c.id AS idcli,
              COALESCE(c.fantasia, c.razao) AS nome,
              ROUND(SUM(v.vlrtotal), 2) AS valor,
              COUNT(*) AS qtd
         FROM venda v
         JOIN cnt c ON c.id = v.idcli
        WHERE ${VENDA_ANALISE_FILTER}
          AND v.idvend IN (${placeholders})
          AND v.idemp = ?
          AND v.dthremissao >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
        GROUP BY c.id, c.razao, c.fantasia
        ORDER BY valor DESC
        LIMIT 15`,
      [...vendIds, idemp],
    );

    const labels = rows.map((r) => r.nome);
    const valores = rows.map((r) => this.toNumber(r.valor));
    const pedidos = rows.map((r) => this.toNumber(r.qtd));

    return plainToInstance(ChartDataDto, {
      chartType: 'bar_h',
      labels,
      series: [
        { name: 'Valor (R$)', data: valores },
        { name: 'Pedidos', data: pedidos },
      ],
    });
  }

  async clientesInativos(
    dbId: string,
    userId: string,
    roleFront: RoleFront,
    query: QueryMetricasDto,
  ): Promise<ResponseClienteInativoDto[]> {
    const { ds, vendIds, idemp } = await this.resolveScope(
      dbId,
      userId,
      roleFront,
      query,
    );
    const placeholders = vendIds.map(() => '?').join(',');

    const rows = await ds.query<ClienteInativoRow[]>(
      `SELECT c.id,
              COALESCE(c.fantasia, c.razao) AS nome,
              format_docfed(c.docfed) AS docfed,
              c.email, c.fone, c.cel, c.cidade, c.uf,
              c.idvende,
              (SELECT MAX(v2.dthremissao)
                 FROM venda v2
                WHERE v2.idcli = c.id
                  AND v2.idemp = ?) AS ultimaVenda
         FROM cnt c
        WHERE c.ativo
          AND c.idvende IN (${placeholders})
          AND NOT EXISTS (
            SELECT 1 FROM venda v
             WHERE v.idcli = c.id
               AND v.idemp = ?
               AND v.dthremissao >= DATE_SUB(CURDATE(), INTERVAL 60 DAY)
          )
        ORDER BY nome ASC`,
      [idemp, ...vendIds, idemp],
    );

    return rows.map((r) =>
      plainToInstance(ResponseClienteInativoDto, {
        ...r,
        ultimaVenda:
          r.ultimaVenda instanceof Date
            ? r.ultimaVenda.toISOString()
            : (r.ultimaVenda ?? null),
      }),
    );
  }

  private async resolveScope(
    dbId: string,
    userId: string,
    roleFront: RoleFront,
    { idemp, idvende, join }: QueryMetricasDto,
  ): Promise<SellerScope> {
    const { vendId } = await this.sellerContextService.resolve(dbId, userId);
    const ds = await this.tenantService.getDataSource(dbId);

    // Validate that the connected user has access to the requested company
    const [empAccess] = await ds.query<{ ok: number }[]>(
      `SELECT COUNT(*) AS ok
         FROM usuemp ue
         INNER JOIN usu u ON u.id = ue.idusu
        WHERE u.userId = ? AND ue.idcnt = ?`,
      [userId, idemp],
    );
    if (!empAccess || Number(empAccess.ok) === 0) {
      throw new ForbiddenException('Empresa não autorizada para este usuário');
    }

    const isSuperSaler = roleFront.includes(RoleFrontEnum.SUPERSALER);

    if (!isSuperSaler && !roleFront.includes(RoleFrontEnum.SALER)) {
      throw new ForbiddenException('Perfil sem acesso às métricas de vendas');
    }

    // Validate access to the requested vendor
    if (idvende !== vendId) {
      if (!isSuperSaler) {
        throw new ForbiddenException(
          'Acesso negado: apenas supersaler pode visualizar dados de outro vendedor',
        );
      }
      const [inTeam] = await ds.query<{ ok: number }[]>(
        `SELECT COUNT(*) AS ok
           FROM cntequipe
          WHERE idcntlider = ? AND idcntliderado = ?`,
        [vendId, idvende],
      );
      if (!inTeam || Number(inTeam.ok) === 0) {
        throw new ForbiddenException('Vendedor não pertence à sua equipe');
      }
    }

    // join=true: full team scope (only supersaler can use)
    if (join) {
      if (!isSuperSaler) {
        throw new ForbiddenException(
          'Acesso negado: apenas supersaler pode utilizar o modo join',
        );
      }
      const team = await ds.query<{ idliderado: number }[]>(
        `SELECT idcntliderado AS idliderado
           FROM cntequipe
          WHERE idcntlider = ?`,
        [vendId],
      );
      const ids = new Set<number>([vendId, ...team.map((t) => t.idliderado)]);
      return { ds, vendIds: [...ids], idemp };
    }

    return { ds, vendIds: [idvende], idemp };
  }

  private toNumber(value: string | number | null | undefined): number {
    if (value == null) return 0;
    return typeof value === 'number' ? value : parseFloat(value);
  }

  private fillSeries(
    rows: PeriodoRow[],
    labels: string[],
    keyFromRaw: (raw: string | number) => string,
  ): number[] {
    const map = new Map<string, number>();
    for (const r of rows) {
      if (r.periodo == null) continue;
      map.set(keyFromRaw(r.periodo), this.toNumber(r.total));
    }
    return labels.map((l) => map.get(l) ?? 0);
  }

  private last12MonthLabels(): string[] {
    const now = new Date();
    const labels: string[] = [];
    for (let i = 11; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      labels.push(
        `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`,
      );
    }
    return labels;
  }

  private last12WeekLabels(): string[] {
    const now = new Date();
    const labels: string[] = [];
    for (let i = 11; i >= 0; i--) {
      const d = new Date(now);
      d.setDate(d.getDate() - i * 7);
      labels.push(this.isoWeekLabel(d));
    }
    return labels;
  }

  private isoWeekLabel(date: Date): string {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() + 3 - ((d.getDay() + 6) % 7));
    const year = d.getFullYear();
    const jan4 = new Date(year, 0, 4);
    const week = Math.ceil(
      ((d.getTime() - jan4.getTime()) / 86400000 + jan4.getDay() + 1) / 7,
    );
    return `${year}-W${String(week).padStart(2, '0')}`;
  }

  private yearweekToIsoLabel(raw: string): string {
    // YEARWEEK(col, 1) returns 6-digit number e.g. "202617" → "2026-W17"
    if (raw.length < 5) return raw;
    const year = raw.slice(0, 4);
    const week = raw.slice(4).padStart(2, '0');
    return `${year}-W${week}`;
  }
}
