import { IsIn, IsInt, IsOptional, IsString, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { PaginationQueryDto } from './pagination-query.dto';

export class ListQueryDto extends PaginationQueryDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  idemp: number;

  @IsIn(['S', 'M', 'T'])
  periodo: 'S' | 'M' | 'T';

  @IsOptional()
  @IsString()
  status?: string;
}
