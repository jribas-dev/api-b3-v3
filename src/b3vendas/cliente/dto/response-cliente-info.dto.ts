import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ResponseClienteInfoDto {
  @Expose()
  id: number;

  @Expose()
  razao: string;

  @Expose()
  docfed: string | null;

  @Expose()
  fone: string | null;

  @Expose()
  endereco: string | null;

  @Expose()
  nroend: string | null;

  @Expose()
  bairro: string | null;

  @Expose()
  cidade: string | null;

  @Expose()
  uf: string | null;

  @Expose()
  obsvenda: string | null;

  @Expose()
  idoper: number | null;
}
