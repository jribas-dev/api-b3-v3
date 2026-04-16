import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';
import { RoleBack, RoleFront } from '../enums/user-instance-roles.enum';
import { OmitType } from '@nestjs/mapped-types';
import { UserInstanceEntity } from '../entities/user-instance.entity';

export class CreateUserInstanceDto extends OmitType(UserInstanceEntity, [
  'id',
  'user',
  'instance',
]) {
  @IsString()
  @IsNotEmpty()
  userId: string;

  @IsString()
  @IsNotEmpty()
  dbId: string;

  @IsNumber()
  @IsOptional()
  idBackendUser: number | null;

  @IsEnum(RoleBack)
  roleback: RoleBack;

  @IsEnum(RoleFront)
  rolefront: RoleFront;
}
