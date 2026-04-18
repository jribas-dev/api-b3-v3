import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ResponseProdutoBuscaDto {
  @Expose()
  id: number;

  @Expose()
  nome: string;

  @Expose()
  display: string;
}
