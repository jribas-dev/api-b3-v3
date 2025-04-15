import { IsBoolean, IsEnum, IsNotEmpty, IsString } from 'class-validator';
import { RoleBack, RoleFront } from 'src/user-instance/enums/user-instance-roles.enum';

export class CreateUserInstanceDto {
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

  @IsBoolean()
  isActive: boolean;
}
