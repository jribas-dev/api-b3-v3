import { CfgEntity } from 'src/tenant/entities/cfg.entity';
import { ClienteEntity } from 'src/b3vendas/cliente/entities/cliente.entity';
import { VendaEntity } from 'src/b3vendas/venda/entities/venda.entity';
import { VendaCaixaEntity } from 'src/b3vendas/venda/entities/venda-caixa.entity';
import { VendaItemEntity } from 'src/b3vendas/venda-item/entities/venda-item.entity';
import { OperacaoEntity } from 'src/b3vendas/operacao/entities/operacao.entity';
import { ProdutoEntity } from 'src/b3vendas/produto/entities/produto.entity';
import { ProdutoImpostoEntity } from 'src/b3vendas/produto/entities/produto-imposto.entity';
import { ImpostoEntity } from 'src/b3vendas/produto/entities/imposto.entity';
import { ProdutoTabValorEntity } from 'src/b3vendas/produto/entities/produto-tab-valor.entity';
import { FormaPagamentoEntity } from 'src/b3vendas/formas-pagamento/entities/forma-pagamento.entity';
import { CondicaoPagamentoEntity } from 'src/b3vendas/formas-pagamento/entities/condicao-pagamento.entity';

export const TENANT_ENTITIES = [
  CfgEntity,
  ClienteEntity,
  VendaEntity,
  VendaCaixaEntity,
  VendaItemEntity,
  OperacaoEntity,
  ProdutoEntity,
  ProdutoImpostoEntity,
  ImpostoEntity,
  ProdutoTabValorEntity,
  FormaPagamentoEntity,
  CondicaoPagamentoEntity,
];
