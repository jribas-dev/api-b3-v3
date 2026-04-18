import { Module } from '@nestjs/common';
import { B3vendasSharedModule } from 'src/b3vendas/shared/shared.module';
import { FormasPagamentoService } from './formas-pagamento.service';

@Module({
  imports: [B3vendasSharedModule],
  providers: [FormasPagamentoService],
  exports: [FormasPagamentoService],
})
export class FormasPagamentoModule {}
