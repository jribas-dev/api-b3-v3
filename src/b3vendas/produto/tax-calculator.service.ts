import { Injectable } from '@nestjs/common';

export interface TaxRule {
  icmsaliq: number;
  icmsredu: number;
  icmsiva: number;
  ipialiq: number;
}

export interface TaxBreakdown {
  ipi: number;
  st: number;
  total: number;
}

@Injectable()
export class TaxCalculatorService {
  private round(value: number): number {
    return Math.round(value * 100) / 100;
  }

  calcIpi(subtotal: number, ipialiq: number): number {
    if (ipialiq <= 0) return 0;
    return this.round(subtotal * (ipialiq / 100));
  }

  calcSt(
    subtotal: number,
    ipi: number,
    icmsaliq: number,
    icmsredu: number,
    icmsiva: number,
  ): number {
    if (icmsiva <= 0) return 0;

    const baseCheia = (subtotal + ipi) * (1 + icmsiva / 100);
    const baseDeduzida =
      icmsredu > 0
        ? (subtotal * (100 - icmsredu)) / 100
        : (subtotal * icmsaliq) / 100;

    return this.round((baseCheia - baseDeduzida) * (icmsaliq / 100));
  }

  calc(subtotal: number, rule: TaxRule | null): TaxBreakdown {
    if (!rule) {
      return { ipi: 0, st: 0, total: this.round(subtotal) };
    }

    const ipi = this.calcIpi(subtotal, rule.ipialiq);
    const st = this.calcSt(
      subtotal,
      ipi,
      rule.icmsaliq,
      rule.icmsredu,
      rule.icmsiva,
    );
    const total = this.round(subtotal + ipi + st);

    return { ipi, st, total };
  }
}
