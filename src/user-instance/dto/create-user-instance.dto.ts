import { IsEnum, IsNotEmpty, IsString } from 'class-validator';
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

  @IsEnum(RoleBack)
  roleback: RoleBack;

  @IsEnum(RoleFront)
  rolefront: RoleFront;
}
