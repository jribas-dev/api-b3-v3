import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ResponseOperacaoDto {
  @Expose()
  id: number;

  @Expose()
  operacao: string;

  @Expose()
  subtipo: 'N' | 'T' | 'B' | 'G';

  @Expose()
  cfopnormal: string;

  @Expose()
  cfopst: string;
}
