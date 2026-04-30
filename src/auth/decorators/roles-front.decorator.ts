import { SetMetadata } from '@nestjs/common';
import { RoleFrontEnum } from 'src/user-domain/user-instance/enums/user-instance-roles.enum';

export const ROLES_FRONT_KEY = 'rolesFront';
export const RolesFront = (...roles: RoleFrontEnum[]) =>
  SetMetadata(ROLES_FRONT_KEY, roles);
