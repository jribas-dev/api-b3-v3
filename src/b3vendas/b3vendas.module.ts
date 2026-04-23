import { Module } from '@nestjs/common';
import { B3vendasSharedModule } from './shared/shared.module';
import { OperacaoModule } from './operacao/operacao.module';
import { ClienteModule } from './cliente/cliente.module';
import { ProdutoModule } from './produto/produto.module';
import { FormasPagamentoModule } from './formas-pagamento/formas-pagamento.module';
import { VendaModule } from './venda/venda.module';
import { VendaItemModule } from './venda-item/venda-item.module';
import { EquipeModule } from './equipe/equipe.module';

@Module({
  imports: [
    B3vendasSharedModule,
    OperacaoModule,
    ClienteModule,
    ProdutoModule,
    FormasPagamentoModule,
    VendaModule,
    VendaItemModule,
    EquipeModule,
  ],
})
export class B3vendasModule {}
