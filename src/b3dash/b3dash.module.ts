import { Module } from '@nestjs/common';
import { B3dashSharedModule } from './shared/shared.module';
import { FaturamentoModule } from './faturamento/faturamento.module';
import { FinanceiroModule } from './financeiro/financeiro.module';
import { EstoqueModule } from './estoque/estoque.module';

@Module({
  imports: [
    B3dashSharedModule,
    FaturamentoModule,
    FinanceiroModule,
    EstoqueModule,
  ],
})
export class B3dashModule {}
