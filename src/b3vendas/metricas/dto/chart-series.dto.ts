import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ChartSeriesDto {
  @Expose()
  name: string;

  @Expose()
  data: number[];
}
