import { Module } from '@nestjs/common';
import { B3vendasSharedModule } from 'src/b3vendas/shared/shared.module';
import { ClienteController } from './cliente.controller';
import { ClienteService } from './cliente.service';

@Module({
  imports: [B3vendasSharedModule],
  controllers: [ClienteController],
  providers: [ClienteService],
  exports: [ClienteService],
})
export class ClienteModule {}
