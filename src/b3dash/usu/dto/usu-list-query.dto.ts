import { IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class UsuListQueryDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  idemp: number;
}
