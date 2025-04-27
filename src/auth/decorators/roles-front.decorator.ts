import { SetMetadata } from '@nestjs/common';
import { RoleFront } from 'src/user-instance/enums/user-instance-roles.enum';

export const ROLES_FRONT_KEY = 'rolesFront';
export const RolesFront = (...roles: RoleFront[]) =>
  SetMetadata(ROLES_FRONT_KEY, roles);
