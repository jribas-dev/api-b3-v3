import { Exclude, Expose, Transform } from 'class-transformer';
import { RoleBack, RoleFront } from '../enums/user-instance-roles.enum';
import { UserInstanceEntity } from '../entities/user-instance.entity';

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
  @Transform(
    ({ obj }: { obj: UserInstanceEntity }): string => obj.instance?.name ?? '',
  )
  instanceName: string;

  @Expose()
  @Transform(
    ({ obj }: { obj: UserInstanceEntity }): string =>
      obj.instance?.dbName ?? '',
  )
  instanceDbName: string;

  @Expose()
  @Transform(
    ({ obj }: { obj: UserInstanceEntity }): string =>
      obj.instance?.dbHost ?? '',
  )
  instanceDbHost: string;
}
