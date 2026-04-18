import { Module } from '@nestjs/common';
import { TenantModule } from 'src/tenant/tenant.module';
import { SellerContextService } from './seller-context.service';

@Module({
  imports: [TenantModule],
  providers: [SellerContextService],
  exports: [SellerContextService, TenantModule],
})
export class B3vendasSharedModule {}
