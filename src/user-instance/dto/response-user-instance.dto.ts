import { Exclude, Expose } from 'class-transformer';
import { RoleBack, RoleFront } from '../enums/user-instance-roles.enum';

@Exclude()
export class ResponseUserInstanceDto {
  @Expose()
  id: number;

  @Expose()
  userId: string;

  @Expose()
  dbId: string;

  @Expose()
  roleBack: RoleBack;

  @Expose()
  roleFront: RoleFront;

  @Expose()
  isActive: boolean;
}
