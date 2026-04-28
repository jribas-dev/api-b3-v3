import { Exclude, Expose } from 'class-transformer';
import { TipoPessoa } from '../entities/cliente.entity';

@Exclude()
export class ResponseClienteInfoDto {
  @Expose()
  id: number;

  @Expose()
  tipopessoa: TipoPessoa;

  @Expose()
  razao: string;

  @Expose()
  fantasia: string | null;

  @Expose()
  docfed: string | null;

  @Expose()
  docformatado: string | null;

  @Expose()
  docest: string | null;

  @Expose()
  email: string | null;

  @Expose()
  emailnfe: string | null;

  @Expose()
  emailcob: string | null;

  @Expose()
  site: string | null;

  @Expose()
  cep: string | null;

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
  fone: string | null;

  @Expose()
  fone2: string | null;

  @Expose()
  cel: string | null;

  @Expose()
  obsvenda: string | null;

  @Expose()
  idoper: number | null;

  @Expose()
  idvende: number | null;
}
