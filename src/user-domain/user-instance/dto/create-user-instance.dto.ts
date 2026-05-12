import {
  ArrayNotEmpty,
  IsArray,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsString,
  ValidateIf,
} from 'class-validator';
import {
  RoleBack,
  RoleFront,
  RoleFrontEnum,
} from '../enums/user-instance-roles.enum';
import { OmitType } from '@nestjs/mapped-types';
import { UserInstanceEntity } from '../entities/user-instance.entity';

export class CreateUserInstanceDto extends OmitType(UserInstanceEntity, [
  'id',
  'user',
  'instance',
  'validateRoleFront',
]) {
  @IsString()
  @IsNotEmpty()
  userId: string;

  @IsString()
  @IsNotEmpty()
  dbId: string;

  @ValidateIf((o: CreateUserInstanceDto) => o.roleback !== RoleBack.NOTALLOW)
  @IsNotEmpty({
    message: 'idBackendUser é obrigatório quando roleback é diferente de notallow',
  })
  @IsNumber()
  idBackendUser: number | null;

  @IsEnum(RoleBack)
  roleback: RoleBack;

  @IsArray()
  @ArrayNotEmpty()
  @IsEnum(RoleFrontEnum, { each: true })
  rolefront: RoleFront;
}
