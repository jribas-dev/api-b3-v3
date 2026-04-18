import { Module } from '@nestjs/common';
import { B3vendasSharedModule } from 'src/b3vendas/shared/shared.module';
import { OperacaoModule } from 'src/b3vendas/operacao/operacao.module';
import { FormasPagamentoModule } from 'src/b3vendas/formas-pagamento/formas-pagamento.module';
import { VendaController } from './venda.controller';
import { VendaService } from './venda.service';

@Module({
  imports: [B3vendasSharedModule, OperacaoModule, FormasPagamentoModule],
  controllers: [VendaController],
  providers: [VendaService],
  exports: [VendaService],
})
export class VendaModule {}
