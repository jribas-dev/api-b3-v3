import { SetMetadata } from '@nestjs/common';
import { RoleBack } from 'src/user-instance/enums/user-instance-roles.enum';

export const ROLES_BACK_KEY = 'rolesBack';
export const RolesBack = (...roles: RoleBack[]) =>
  SetMetadata(ROLES_BACK_KEY, roles);
