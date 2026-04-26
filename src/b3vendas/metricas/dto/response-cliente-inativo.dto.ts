import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ResponseClienteInativoDto {
  @Expose()
  id: number;

  @Expose()
  nome: string;

  @Expose()
  docfed: string | null;

  @Expose()
  email: string | null;

  @Expose()
  fone: string | null;

  @Expose()
  cel: string | null;

  @Expose()
  cidade: string | null;

  @Expose()
  uf: string | null;

  @Expose()
  ultimaVenda: string | null;

  @Expose()
  idvende: number | null;
}
