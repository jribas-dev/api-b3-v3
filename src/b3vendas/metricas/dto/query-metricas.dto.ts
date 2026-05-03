import { Transform, Type } from 'class-transformer';
import { IsBoolean, IsInt, IsOptional, Min } from 'class-validator';

export class QueryMetricasDto {
  @IsInt()
  @Min(1)
  @Type(() => Number)
  idemp: number;

  @IsInt()
  @Min(1)
  @Type(() => Number)
  idvende: number;

  @IsBoolean()
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  join?: boolean;
}
