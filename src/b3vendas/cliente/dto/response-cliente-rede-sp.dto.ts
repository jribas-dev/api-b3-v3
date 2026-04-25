import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ResponseClienteRedeSpDto {
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
}
