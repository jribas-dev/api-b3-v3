import { Module } from '@nestjs/common';
import { B3vendasService } from './b3vendas.service';
import { B3vendasController } from './b3vendas.controller';
import { TenantModule } from 'src/tenant/tenant.module';

@Module({
  providers: [B3vendasService],
  controllers: [B3vendasController],
  imports: [TenantModule],
})
export class B3vendasModule {}
