import { Exclude, Expose, Type } from 'class-transformer';
import { RoleBack, RoleFront } from '../enums/user-instance-roles.enum';
import { RelationInstanceDto } from './relation-instance.dto';

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

  @Expose()
  @Type(() => RelationInstanceDto)
  instance: RelationInstanceDto;
}
