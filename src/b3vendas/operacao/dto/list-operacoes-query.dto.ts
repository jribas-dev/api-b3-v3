import { Type } from 'class-transformer';
import { IsInt, Min } from 'class-validator';

export class ListOperacoesQueryDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  idemp: number;
}
