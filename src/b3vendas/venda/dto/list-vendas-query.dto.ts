import { Type } from 'class-transformer';
import { IsInt, Min } from 'class-validator';

export class ListVendasQueryDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  idemp: number;
}
