import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';
import {
  RoleBack,
  RoleFront,
} from 'src/user-domain/user-instance/enums/user-instance-roles.enum';

export class RelationUserPreDto {
  @IsNotEmpty()
  @IsString()
  dbId: string;

  @IsNumber()
  @IsOptional()
  idBackendUser: number | null;

  @IsEnum(RoleBack)
  @IsNotEmpty()
  roleBack: RoleBack;

  @IsEnum(RoleFront)
  @IsNotEmpty()
  roleFront: RoleFront;
}
