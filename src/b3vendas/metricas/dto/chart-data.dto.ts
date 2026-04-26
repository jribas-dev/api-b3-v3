import { Exclude, Expose } from 'class-transformer';
import { ChartSeriesDto } from './chart-series.dto';

export type ChartType = 'bar_v' | 'bar_h' | 'pie' | 'line';

@Exclude()
export class ChartDataDto {
  @Expose()
  chartType: ChartType;

  @Expose()
  labels: string[];

  @Expose()
  series: ChartSeriesDto[];
}
