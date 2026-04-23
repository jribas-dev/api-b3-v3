import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_BACK_KEY } from '../decorators/roles-back.decorator';
import { RoleBack } from 'src/user-domain/user-instance/enums/user-instance-roles.enum';

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
      .getRequest<Request & { user: { roleBack?: RoleBack } }>();
    const user = request.user;

    if (user?.roleBack && required.includes(user.roleBack)) {
      return true;
    }

    throw new ForbiddenException(
      'Acesso restrito: roleBack insuficiente para o recurso solicitado',
    );
  }
}
