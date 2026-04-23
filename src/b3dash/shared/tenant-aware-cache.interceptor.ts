import { ExecutionContext, Inject, Injectable } from '@nestjs/common';
import { CACHE_MANAGER, CacheInterceptor } from '@nestjs/cache-manager';
import { Reflector } from '@nestjs/core';

@Injectable()
export class TenantAwareCacheInterceptor extends CacheInterceptor {
  constructor(@Inject(CACHE_MANAGER) cacheManager: any, reflector: Reflector) {
    super(cacheManager, reflector);
  }

  protected trackBy(context: ExecutionContext): string | undefined {
    const request = context.switchToHttp().getRequest<{
      user?: { dbId?: string };
      path: string;
      query: Record<string, string>;
    }>();

    const dbId = request.user?.dbId;
    if (!dbId) return undefined;

    const { idemp, periodo } = request.query;
    if (!idemp || !periodo) return undefined;

    // Compõe chave: b3dash:<dbId>:<path>:idemp=<N>:periodo=<S|M|T>
    // path ex: /b3dash/faturamento/graph/evolucao
    return `b3dash:${dbId}:${request.path}:idemp=${idemp}:periodo=${periodo}`;
  }
}
