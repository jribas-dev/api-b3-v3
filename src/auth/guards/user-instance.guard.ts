import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';

@Injectable()
export class UserInstanceGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context
      .switchToHttp()
      .getRequest<
        Request & { user: { isRoot: boolean; userId: string; dbId: string } }
      >();
    const user = request.user;

    if (user?.dbId) {
      return true;
    }

    throw new ForbiddenException(
      'Acesso restrito a usuários dentro de uma instância',
    );
  }
}
