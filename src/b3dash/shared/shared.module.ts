import { Module } from '@nestjs/common';
import { CacheModule } from '@nestjs/cache-manager';
import { TenantModule } from 'src/tenant/tenant.module';
import { PeriodResolver } from './period.resolver';
import { TenantAwareCacheInterceptor } from './tenant-aware-cache.interceptor';

@Module({
  imports: [TenantModule, CacheModule.register({ ttl: 86_400_000, max: 500 })],
  providers: [PeriodResolver, TenantAwareCacheInterceptor],
  exports: [
    TenantModule,
    CacheModule,
    PeriodResolver,
    TenantAwareCacheInterceptor,
  ],
})
export class B3dashSharedModule {}
