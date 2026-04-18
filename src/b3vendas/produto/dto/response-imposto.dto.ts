import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ResponseImpostoDto {
  @Expose()
  ipi: number;

  @Expose()
  st: number;

  @Expose()
  total: number;
}
