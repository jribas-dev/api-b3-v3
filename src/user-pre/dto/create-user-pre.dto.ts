import { OmitType } from '@nestjs/mapped-types';
import { IsEmail } from 'class-validator';
import { UserPreEntity } from '../entities/user-pre.entity';
import { RelationUserPreDto } from './relation-user-pre.dto';
import { Type } from 'class-transformer';

export class CreateUserPreDto extends OmitType(UserPreEntity, [
  'userPreId',
  'token',
  'expiresAt',
  'createdAt',
  'instances',
]) {
  @IsEmail()
  email: string;

  @Type(() => RelationUserPreDto)
  instances: RelationUserPreDto[];
}
