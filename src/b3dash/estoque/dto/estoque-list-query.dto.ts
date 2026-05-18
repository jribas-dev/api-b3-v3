import { IsBoolean, IsOptional } from 'class-validator';
import { Transform } from 'class-transformer';
import { ListQueryDto } from '../../shared/dto/list-query.dto';

export class EstoqueListQueryDto extends ListQueryDto {
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  apenasRuptura?: boolean;
}
