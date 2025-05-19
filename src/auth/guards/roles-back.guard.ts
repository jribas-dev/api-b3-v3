import {
  CanActivate,
  ExecutionContext,
  Injectable,
  SetMetadata,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_BACK_KEY } from '../decorators/roles-back.decorator';
import { RoleBack } from 'src/user-instance/enums/user-instance-roles.enum';

// Decorator para permitir acesso do root
export const ALLOW_ROOT_KEY = 'allow-root';
export const AllowRoot = () => SetMetadata(ALLOW_ROOT_KEY, true);

@Injectable()
export class RolesBackGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    const required: RoleBack[] = this.reflector.getAllAndMerge<RoleBack[]>(
      ROLES_BACK_KEY,
      [ctx.getHandler(), ctx.getClass()],
    );
    if (!required || required.length === 0) return true;

    const request = ctx
      .switchToHttp()
      .getRequest<
        Request & { user: { roleBack?: RoleBack; isRoot: boolean } }
      >();
    const user = request.user;

    // Verifica se a rota permite explicitamente o root
    const allowRoot = this.reflector.getAllAndOverride<boolean>(
      ALLOW_ROOT_KEY,
      [ctx.getHandler(), ctx.getClass()],
    );

    // Verificação normal de roles
    const hasRequiredRole = user.roleBack && required.includes(user.roleBack);

    // Permite se tem a role OU se é root e a rota permite root
    return hasRequiredRole || (user.isRoot && allowRoot);

    // return required.includes(user.roleBack);
  }
}
