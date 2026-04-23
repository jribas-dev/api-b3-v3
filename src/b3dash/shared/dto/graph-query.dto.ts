import { IsIn, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class GraphQueryDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  idemp: number;

  @IsIn(['S', 'M', 'T'])
  periodo: 'S' | 'M' | 'T';
}
