import { Module } from '@nestjs/common';
import { B3vendasSharedModule } from 'src/b3vendas/shared/shared.module';
import { VendaModule } from 'src/b3vendas/venda/venda.module';
import { VendaItemController } from './venda-item.controller';
import { VendaItemService } from './venda-item.service';

@Module({
  imports: [B3vendasSharedModule, VendaModule],
  controllers: [VendaItemController],
  providers: [VendaItemService],
})
export class VendaItemModule {}
