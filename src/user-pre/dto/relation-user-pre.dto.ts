import { IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';
import {
  RoleBack,
  RoleFront,
} from 'src/user-instance/enums/user-instance-roles.enum';

export class RelationUserPreDto {
  @IsNotEmpty()
  @IsString()
  dbId: string;

  @IsNumber()
  @IsOptional()
  idBackendUser: number | null;

  @IsNotEmpty()
  roleBack: RoleBack;

  @IsNotEmpty()
  roleFront: RoleFront;
}
