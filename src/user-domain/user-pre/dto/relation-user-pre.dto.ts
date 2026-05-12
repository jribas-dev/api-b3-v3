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
} from 'src/user-domain/user-instance/enums/user-instance-roles.enum';

export class RelationUserPreDto {
  @IsNotEmpty()
  @IsString()
  dbId: string;

  @ValidateIf((o: RelationUserPreDto) => o.roleBack !== RoleBack.NOTALLOW)
  @IsNotEmpty({
    message: 'idBackendUser é obrigatório quando roleBack é diferente de notallow',
  })
  @IsNumber()
  idBackendUser: number | null;

  @IsEnum(RoleBack)
  @IsNotEmpty()
  roleBack: RoleBack;

  @IsArray()
  @ArrayNotEmpty()
  @IsEnum(RoleFrontEnum, { each: true })
  roleFront: RoleFront;
}
