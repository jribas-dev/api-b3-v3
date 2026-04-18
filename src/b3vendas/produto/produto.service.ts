import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { DataSource } from 'typeorm';
import { TenantService } from 'src/tenant/tenant.service';
import { ProdutoEntity } from './entities/produto.entity';
import { ResponseProdutoBuscaDto } from './dto/response-produto-busca.dto';
import { ResponsePrecoDto } from './dto/response-preco.dto';
import { ResponseImpostoDto } from './dto/response-imposto.dto';
import { TaxCalculatorService, TaxRule } from './tax-calculator.service';

type ProdutoBuscaRow = { id: number; nome: string };
type ImpostoRow = {
  icmsaliq: string | number;
  icmsredu: string | number;
  icmsiva: string | number;
  ipialiq: string | number;
  cfopnormal: string | null;
  cfopst: string | null;
};
type PrecoRow = { valor: string | number | null };

function padLeft(value: number, length: number): string {
  return String(value).padStart(length, '0');
}

function toNumber(value: string | number | null | undefined): number {
  if (value == null) return 0;
  return typeof value === 'number' ? value : parseFloat(value);
}

@Injectable()
export class ProdutoService {
  constructor(
    private readonly tenantService: TenantService,
    private readonly taxCalculator: TaxCalculatorService,
  ) {}

  async buscar(
    dbId: string,
    termo: string,
  ): Promise<ResponseProdutoBuscaDto[]> {
    if (!termo || termo.trim().length < 2) {
      throw new BadRequestException(
        'Informe ao menos 2 caracteres para a busca',
      );
    }

    const ds = await this.tenantService.getDataSource(dbId);
    const termoUpper = termo.toUpperCase();
    const isNumerico = /^\d+$/.test(termo.trim());

    const rows = isNumerico
      ? await ds.query<ProdutoBuscaRow[]>(
          `SELECT id, nome FROM prd
            WHERE NOT consumo AND ativo AND podevender
              AND (acabado OR revenda)
              AND id = ?
            LIMIT 50`,
          [parseInt(termo.trim(), 10)],
        )
      : await ds.query<ProdutoBuscaRow[]>(
          `SELECT id, nome FROM prd
            WHERE NOT consumo AND ativo AND podevender
              AND (acabado OR revenda)
              AND UPPER(nome) LIKE ?
            ORDER BY nome
            LIMIT 50`,
          [`%${termoUpper}%`],
        );

    return rows.map((r) =>
      plainToInstance(ResponseProdutoBuscaDto, {
        id: r.id,
        nome: r.nome,
        display: `[${padLeft(r.id, 5)}] ${r.nome}`,
      }),
    );
  }

  async preco(
    dbId: string,
    idProd: number,
    idCli: number,
    idOper: number,
  ): Promise<ResponsePrecoDto> {
    const ds = await this.tenantService.getDataSource(dbId);
    const produto = await ds.getRepository(ProdutoEntity).findOneBy({
      id: idProd,
    });
    if (!produto)
      throw new NotFoundException(`Produto ${idProd} não encontrado`);

    const cfop = await this.resolverCfop(ds, idProd, idOper);
    const vunit = await this.resolverPreco(ds, idProd, idCli, produto.venda);

    return plainToInstance(ResponsePrecoDto, {
      cfop,
      custo: produto.custo,
      vunit,
    });
  }

  async calcImposto(
    dbId: string,
    idProd: number,
    subtotal: number,
    idOper: number,
  ): Promise<ResponseImpostoDto> {
    const ds = await this.tenantService.getDataSource(dbId);
    const rule = await this.buscarRegraImposto(ds, idProd, idOper);
    const breakdown = this.taxCalculator.calc(subtotal, rule);
    return plainToInstance(ResponseImpostoDto, breakdown);
  }

  async buscarRegraImposto(
    ds: DataSource,
    idProd: number,
    idOper: number,
  ): Promise<TaxRule | null> {
    const rows = await ds.query<ImpostoRow[]>(
      `SELECT b.icmsaliq, b.icmsredu, b.icmsiva, b.ipialiq,
              c.cfopnormal, c.cfopst
         FROM prdimposto a
         LEFT OUTER JOIN impostos  b ON a.idimposto = b.id
         LEFT OUTER JOIN operacoes c ON a.idoperacao = c.id
        WHERE a.idprd = ? AND a.idoperacao = ?
        LIMIT 1`,
      [idProd, idOper],
    );
    const row = rows[0];
    if (!row) return null;

    return {
      icmsaliq: toNumber(row.icmsaliq),
      icmsredu: toNumber(row.icmsredu),
      icmsiva: toNumber(row.icmsiva),
      ipialiq: toNumber(row.ipialiq),
    };
  }

  private async resolverCfop(
    ds: DataSource,
    idProd: number,
    idOper: number,
  ): Promise<string> {
    const rows = await ds.query<ImpostoRow[]>(
      `SELECT b.icmsiva, c.cfopnormal, c.cfopst
         FROM prdimposto a
         LEFT OUTER JOIN impostos  b ON a.idimposto  = b.id
         LEFT OUTER JOIN operacoes c ON a.idoperacao = c.id
        WHERE a.idprd = ? AND a.idoperacao = ?
        LIMIT 1`,
      [idProd, idOper],
    );
    const row = rows[0];
    if (row) {
      const iva = toNumber(row.icmsiva);
      const cfop = iva > 0 ? row.cfopst : row.cfopnormal;
      if (cfop) return cfop;
    }

    const fallback = await ds.query<{ cfopnormal: string }[]>(
      `SELECT cfopnormal FROM operacoes WHERE id = ? LIMIT 1`,
      [idOper],
    );
    return fallback[0]?.cfopnormal ?? '';
  }

  private async resolverPreco(
    ds: DataSource,
    idProd: number,
    idCli: number,
    fallbackVenda: number,
  ): Promise<number> {
    const rows = await ds.query<PrecoRow[]>(
      `SELECT COALESCE(t.valor, 0) AS valor
         FROM cnt
         LEFT OUTER JOIN prdtab    pt ON cnt.idtab = pt.id
         LEFT OUTER JOIN prdtabvalor t
                ON t.idtab = pt.id AND t.idprod = ?
        WHERE cnt.id = ?
        LIMIT 1`,
      [idProd, idCli],
    );
    const valorTabela = toNumber(rows[0]?.valor);
    return valorTabela > 0 ? valorTabela : fallbackVenda;
  }
}
