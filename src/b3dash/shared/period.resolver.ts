import { Injectable } from '@nestjs/common';

export interface PeriodSpec {
  sinceSql: string;
  groupExpr: string;
  label: string;
}

@Injectable()
export class PeriodResolver {
  resolve(column: string, periodo: 'S' | 'M' | 'T'): PeriodSpec {
    switch (periodo) {
      case 'S':
        return {
          sinceSql: `${column} >= DATE_SUB(CURDATE(), INTERVAL 16 WEEK)`,
          groupExpr: `YEARWEEK(${column}, 1)`,
          label: 'periodo',
        };
      case 'M':
        return {
          sinceSql: `${column} >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)`,
          groupExpr: `DATE_FORMAT(${column}, '%Y-%m')`,
          label: 'periodo',
        };
      case 'T':
        return {
          sinceSql: `${column} >= DATE_SUB(CURDATE(), INTERVAL 6 QUARTER)`,
          groupExpr: `CONCAT(YEAR(${column}),'-T',QUARTER(${column}))`,
          label: 'periodo',
        };
    }
  }

  // Gera todos os labels esperados para o período (garante buckets zerados no frontend)
  generateLabels(periodo: 'S' | 'M' | 'T'): string[] {
    const now = new Date();
    const labels: string[] = [];

    if (periodo === 'M') {
      for (let i = 11; i >= 0; i--) {
        const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
        labels.push(
          `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`,
        );
      }
    } else if (periodo === 'T') {
      for (let i = 5; i >= 0; i--) {
        const d = new Date(now.getFullYear(), now.getMonth() - i * 3, 1);
        const q = Math.floor(d.getMonth() / 3) + 1;
        labels.push(`${d.getFullYear()}-T${q}`);
      }
    } else {
      // S — 16 semanas ISO
      for (let i = 15; i >= 0; i--) {
        const d = new Date(now);
        d.setDate(d.getDate() - i * 7);
        labels.push(this.isoWeekLabel(d));
      }
    }

    return labels;
  }

  // Converte chave bruta do SQL para o formato do label (necessário para semanas)
  normalizePeriodKey(raw: string, periodo: 'S' | 'M' | 'T'): string {
    if (periodo !== 'S') return raw;
    // YEARWEEK retorna número 6 dígitos, ex: 202617 → "2026-W17"
    const s = String(raw);
    const year = s.slice(0, 4);
    const week = s.slice(4).padStart(2, '0');
    return `${year}-W${week}`;
  }

  // Mapeia rows SQL para array numérico alinhado a labels, preenchendo zeros nos buckets vazios
  fillSeries(
    rows: Array<Record<string, string | number | Date | null>>,
    labels: string[],
    periodKey: string,
    valueKey: string,
    periodo: 'S' | 'M' | 'T',
  ): number[] {
    const map = new Map<string, number>();
    for (const row of rows) {
      const rawKey = row[periodKey];
      const rawValue = row[valueKey];
      if (rawKey == null) continue;
      const key = this.normalizePeriodKey(String(rawKey), periodo);
      map.set(key, parseFloat(String(rawValue ?? 0)) || 0);
    }
    return labels.map((l) => map.get(l) ?? 0);
  }

  private isoWeekLabel(date: Date): string {
    // Calcula semana ISO (começa na segunda-feira)
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    // Quinta-feira da semana ISO determina o ano
    d.setDate(d.getDate() + 3 - ((d.getDay() + 6) % 7));
    const year = d.getFullYear();
    const jan4 = new Date(year, 0, 4);
    const week = Math.ceil(
      ((d.getTime() - jan4.getTime()) / 86400000 + jan4.getDay() + 1) / 7,
    );
    return `${year}-W${String(week).padStart(2, '0')}`;
  }
}
