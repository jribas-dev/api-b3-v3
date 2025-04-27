import { IsNotEmpty, IsString } from 'class-validator';
import {
  RoleBack,
  RoleFront,
} from 'src/user-instance/enums/user-instance-roles.enum';

export class RelationUserPreDto {
  @IsNotEmpty()
  @IsString()
  dbId: string;

  @IsNotEmpty()
  roleBack: RoleBack;

  @IsNotEmpty()
  roleFront: RoleFront;
}
