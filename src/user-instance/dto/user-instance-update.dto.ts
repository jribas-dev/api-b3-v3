import { PartialType } from '@nestjs/mapped-types';
import { CreateUserInstanceDto } from './user-instance-create.dto';

if (typeof CreateUserInstanceDto !== 'function') {
  throw new Error('CreateUserInstanceDto must be a valid class or type.');
}

export class UpdateUserInstanceDto extends PartialType(CreateUserInstanceDto) {}
