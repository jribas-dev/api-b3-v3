import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
} from '@nestjs/common';

@Injectable()
export class RootGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context
      .switchToHttp()
      .getRequest<Request & { user: { isRoot: boolean; userId: string } }>();
    const user = request.user;

    if (user?.isRoot) {
      return true;
    }

    throw new ForbiddenException('Acesso restrito ao administrador');
  }
}
