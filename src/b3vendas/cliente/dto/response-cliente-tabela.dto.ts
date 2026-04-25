import { Exclude, Expose, Transform } from 'class-transformer';

@Exclude()
export class ResponseClienteTabelaDto {
  @Expose()
  operacao: string;

  @Expose()
  nometab: string;

  @Expose()
  ufbase: string;

  @Expose()
  id: number;

  @Expose()
  codigo: string | null;

  @Expose()
  ref: string | null;

  @Expose()
  barras: string | null;

  @Expose()
  nome: string;

  @Expose()
  unidade: string | null;

  @Expose()
  @Transform(({ value }: { value: unknown }) => parseFloat(String(value)))
  venda: number;

  @Expose()
  @Transform(({ value }: { value: unknown }) => parseFloat(String(value)))
  ivast: number;

  @Expose()
  @Transform(({ value }: { value: unknown }) => parseFloat(String(value)))
  vicmsst: number;

  @Expose()
  @Transform(({ value }: { value: unknown }) => parseFloat(String(value)))
  ipisaliq: number;

  @Expose()
  @Transform(({ value }: { value: unknown }) => parseFloat(String(value)))
  vipi: number;
}
