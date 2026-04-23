import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_FRONT_KEY } from '../decorators/roles-front.decorator';
import { RoleFront } from 'src/user-domain/user-instance/enums/user-instance-roles.enum';

@Injectable()
export class RolesFrontGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    const required: RoleFront[] = this.reflector.getAllAndMerge<RoleFront[]>(
      ROLES_FRONT_KEY,
      [ctx.getHandler(), ctx.getClass()],
    );
    if (!required || required.length === 0) return true;

    const request = ctx
      .switchToHttp()
      .getRequest<Request & { user: { roleFront?: RoleFront } }>();
    const user = request.user;

    if (user?.roleFront && required.includes(user.roleFront)) {
      return true;
    }

    throw new ForbiddenException(
      'Acesso restrito: roleFront insuficiente para o recurso solicitado',
    );
  }
}
