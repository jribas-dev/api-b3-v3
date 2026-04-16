import { PartialType } from '@nestjs/mapped-types';
import { CreateUserInstanceDto } from './create-user-instance.dto';
import { IsBoolean, IsOptional } from 'class-validator';

export class UpdateUserInstanceDto extends PartialType(CreateUserInstanceDto) {
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
