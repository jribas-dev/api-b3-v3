import {
  RoleBack,
  RoleFront,
} from 'src/user-instance/enums/user-instance-roles.enum';

export interface JwtPayload {
  sub: string; // userId
  email: string;
  isRoot: boolean;
  instanceName?: string; // Optional, only for user instances
  dbId?: string; // Optional, only for user instances
  roleBack?: RoleBack; // Optional, only for user instances
  roleFront?: RoleFront; // Optional, only for user instances
}
