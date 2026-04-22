import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import {
  RoleBack,
  RoleFront,
} from 'src/user-domain/user-instance/enums/user-instance-roles.enum';

@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<{
      user: { isRoot: boolean; roleBack: RoleBack; roleFront: RoleFront };
    }>();
    const user = request.user;

    if (
      user?.isRoot === true ||
      user?.roleFront === RoleFront.SUPER ||
      user?.roleBack === RoleBack.SUPER ||
      user?.roleBack === RoleBack.ADMIN
    ) {
      return true;
    }

    throw new ForbiddenException('Acesso restrito a administradores');
  }
}
