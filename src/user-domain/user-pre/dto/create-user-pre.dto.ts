import { OmitType } from '@nestjs/mapped-types';
import { IsEmail, IsOptional } from 'class-validator';
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
  @IsOptional()
  @IsEmail()
  email: string;

  @IsOptional()
  @Type(() => RelationUserPreDto)
  dblist: RelationUserPreDto[];
}
