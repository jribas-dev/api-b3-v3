import { PartialType } from '@nestjs/mapped-types';
import { CreateUserInstanceDto } from './create-user-instance.dto';
import { IsBoolean } from 'class-validator';

export class UpdateUserInstanceDto extends PartialType(CreateUserInstanceDto) {
  @IsBoolean()
  isActive?: boolean;
}
