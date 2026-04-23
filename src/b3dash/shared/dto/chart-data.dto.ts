import { ChartSeriesDto } from './chart-series.dto';

export type ChartType = 'bar_v' | 'bar_h' | 'pie' | 'line';

export class ChartDataDto {
  chartType: ChartType;
  labels: string[];
  series: ChartSeriesDto[];
}
