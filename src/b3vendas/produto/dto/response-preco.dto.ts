import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ResponsePrecoDto {
  @Expose()
  cfop: string;

  @Expose()
  custo: number;

  @Expose()
  vunit: number;
}
