# b3vendas

Módulo de domínio para **gestão de vendas** no banco de dados do tenant. Implementa um ciclo completo de pedido: criação → inclusão de itens → fechamento com forma de pagamento.

## Estrutura Interna

```
src/b3vendas/
├── b3vendas.module.ts          # Módulo raiz — importa todos os sub-módulos
├── shared/
│   ├── shared.module.ts        # Re-exporta TenantModule + SellerContextService
│   ├── seller-context.service.ts  # Resolve usuário → vendedor/empresa no tenant
│   └── decimal.transformer.ts  # ValueTransformer TypeORM para campos DECIMAL
├── cliente/                    # CRUD de clientes (tabela cnt)
├── operacao/                   # Tipos de operação fiscal (tabela operacoes)
├── produto/                    # Catálogo, preços e cálculo de impostos
│   └── tax-calculator.service.ts  # Lógica pura de cálculo IPI/ST
├── formas-pagamento/           # Formas e condições de pagamento (formapg, condpg)
├── venda/                      # Pedidos/vendas (tabela venda)
└── venda-item/                 # Itens do pedido (tabela vendaitem)
```

> **Atenção:** As entities deste módulo usam IDs numéricos inteiros (legado), **não** CUID2 como nas demais entities da aplicação.

## SellerContextService — Contexto do Vendedor

Serviço central de `shared/`. Todo endpoint do módulo chama `sellerContext.resolve(dbId, userId)` para obter:

| Campo | Tipo | Descrição |
|---|---|---|
| `usuId` | number | ID do registro `usu` no tenant |
| `vendId` | number | ID do vendedor vinculado ao usuário |
| `empId` | number | ID da empresa vinculada ao usuário |

Lança `ForbiddenException` se o usuário não tiver vendedor/empresa configurados no tenant. Todas as queries subsequentes filtram por `idvend = vendId` para isolamento multi-tenant.

## DecimalTransformer

`shared/decimal.transformer.ts` — TypeORM converte colunas `DECIMAL` do banco para `string` no JS. O transformer aplica `parseFloat()` na leitura. Deve ser aplicado em **todos** os campos decimais das entities deste módulo (`custo`, `venda`, `qtde`, `vlrtotal`, etc.).

## Tabelas e Relacionamentos

```
cnt (clientes)
  └── idtab → prdtabvalor (tabela de preços por cliente)

operacoes
  └── referenciada por: venda.idoper, prdimposto.idoperacao

prd (produtos)
  ├── prdimposto (produto × imposto × operação) → impostos
  └── prdtabvalor (preços por tabela de cliente)

venda
  ├── vendaitem (itens do pedido) → prd
  └── vendacaixa (pagamento) → formapg, condpg

formapg (formas de pagamento)
condpg (condições de pagamento)
```

## Máquina de Estados da Venda (`venda.tipo`)

| Valor | Estado | Editável |
|---|---|---|
| `'O'` | Aberto / Rascunho | Sim |
| `'P'` | Pendente | Não |
| `'V'` | Validado / Confirmado | Não |

Somente vendas com `tipo = 'O'` permitem inclusão/remoção de itens e atualização. O endpoint `POST /pedidos/:id/fechar` transita de `'O'` para o estado definido pelo chamador.

## Fluxo de Criação de Pedido

1. `POST /b3vendas/pedidos` — cria venda em estado `'O'`, com `idvend` e `idemp` do contexto do vendedor. `plataforma="SALESFORCE"`, `processo="B3PED.exe"`.
2. `POST /b3vendas/pedidos/:id/itens` — adiciona itens; após cada inserção, `recalcTotals()` recalcula os totais da venda.
3. `DELETE /b3vendas/pedidos/:id/itens/:seq` — remove item; dispara `recalcTotals()`.
4. `POST /b3vendas/pedidos/:id/fechar` — insere registro em `vendacaixa` (em transação, deletando entradas anteriores) e salva `obsinter`.

**Fórmula de total:**
```
vlrtotal = vlrbruto + acrescimo + st + ipi + frete + seguro + outros - desconto - deducoes
```

## Cálculo de Impostos (IPI / ICMS-ST)

`TaxCalculatorService` é um serviço de lógica pura (sem acesso a banco):

- **IPI:** `subtotal × ipialiq / 100`
- **ST:** `(subtotal + ipi) × (1 + icmsiva/100) × icmsaliq/100 × (1 - icmsredu/100) - (subtotal × icmsaliq/100 × (1 - icmsredu/100))`

A regra de imposto é buscada na tabela `prdimposto` (junção produto × operação → `impostos`). O endpoint `POST /produtos/:id/calc-imposto` retorna `{ ipi, st, total }`.

## Pricing e Tabela de Preços

O preço unitário segue esta ordem de precedência:
1. Valor em `prdtabvalor` para a tabela do cliente (`cnt.idtab`) — preço personalizado.
2. Campo `prd.venda` — preço padrão do produto.

## CfgService — Configuração Dinâmica

`OperacaoService` injeta `CfgService` para ler a chave `VWEBOPERCOND` do banco do tenant. Esse valor é interpolado como cláusula SQL extra no filtro de operações permitidas, permitindo configuração por deployment sem alterar código.

## Entities

### ClienteEntity — tabela `cnt`

| Campo | Tipo DB | Descrição |
|---|---|---|
| `id` | int unsigned PK | — |
| `razao` | varchar(100) | Razão social (obrigatório) |
| `fantasia` | varchar(60) | Nome fantasia |
| `docfed` | varchar(20) | CNPJ/CPF |
| `docest` | varchar(20) | Inscrição estadual |
| `email` | varchar(120) | — |
| `cep` | varchar(10) | — |
| `endereco` | varchar(120) | — |
| `nroend` | varchar(10) | Número do endereço |
| `bairro` | varchar(60) | — |
| `cidade` | varchar(60) | — |
| `uf` | varchar(2) | Estado |
| `fone` / `fone2` / `cel` | varchar(20) | Telefones |
| `obsvenda` | varchar(255) | Observações para vendas |
| `idoper` | int | Operação padrão do cliente (FK) |
| `idvend` | int | Vendedor proprietário (isolamento tenant) |
| `ativo` | boolean | Padrão true |

### OperacaoEntity — tabela `operacoes`

| Campo | Tipo DB | Descrição |
|---|---|---|
| `id` | smallint unsigned PK | — |
| `operacao` | varchar(60) | Nome da operação |
| `saidaentrada` | enum `'0'`/`'1'` | Entrada/Saída (padrão `'1'`) |
| `cfopnormal` | varchar(5) | CFOP padrão (ex: `5102`) |
| `cfopst` | varchar(5) | CFOP com ST (ex: `5405`) |
| `subtipo` | enum `N`/`T`/`B`/`G` | Normal/Tributo/Orçamento/Governo |
| `idemp` | int | Empresa (null = compartilhada) |

### ProdutoEntity — tabela `prd`

| Campo | Tipo DB | Descrição |
|---|---|---|
| `id` | int PK | — |
| `nome` | varchar(100) | — |
| `custo` | decimal(12,3) | Preço de custo |
| `venda` | decimal(12,3) | Preço de venda padrão |
| `ativo` | boolean | — |

### ImpostoEntity — tabela `impostos`

| Campo | Tipo DB | Descrição |
|---|---|---|
| `id` | int PK | — |
| `descricao` | varchar(60) | — |
| `icmscst` | varchar(3) | CST do ICMS (padrão `'41'`) |
| `icmsaliq` | decimal(8,4) | Alíquota ICMS |
| `icmsredu` | decimal(8,4) | Redução ICMS |
| `icmsiva` | decimal(8,4) | IVA para ST |
| `ipicst` | varchar(3) | CST do IPI (padrão `'53'`) |
| `ipialiq` | decimal(8,4) | Alíquota IPI |

### ProdutoImpostoEntity — tabela `prdimposto` (junção)

PK composta: `idprd` + `idoperacao` + `idimposto`. Liga produto à regra de imposto por operação.

### ProdutoTabValorEntity — tabela `prdtabvalor`

PK composta: `idtab` + `idprod`. Armazena preço (`decimal 12.3`) por tabela de cliente.

### FormaPagamentoEntity — tabela `formapg`

| Campo | Tipo DB | Descrição |
|---|---|---|
| `id` | smallint unsigned PK | — |
| `nmforma` | varchar(60) | Nome da forma |
| `operacao` | varchar(1) | `'I'` entrada / `'D'` débito |
| `inativo` | boolean | — |

### CondicaoPagamentoEntity — tabela `condpg`

| Campo | Tipo DB | Descrição |
|---|---|---|
| `idcond` | smallint unsigned PK | — |
| `nomecond` | varchar(80) | Nome da condição |
| `parcelas` | smallint | Número de parcelas |
| `inativo` | boolean | — |

### VendaEntity — tabela `venda`

| Campo | Tipo DB | Descrição |
|---|---|---|
| `id` | int unsigned PK | — |
| `dthremissao` | datetime | Criação (auto) |
| `idoper` | smallint unsigned | Operação fiscal (FK) |
| `fiscal` | varchar(1) | `'F'` fiscal / `'E'` estimativa |
| `tipo` | varchar(1) | Estado: `O`/`P`/`V` |
| `subtipo` | enum `N`/`T`/`B`/`G` | Herdado da operação |
| `vlrbruto` | decimal(16,3) | Soma bruta dos itens |
| `acrescimo` | decimal(12,3) | Acréscimo |
| `desconto` | decimal(12,3) | Desconto |
| `frete` | decimal(12,3) | Frete |
| `seguro` | decimal(12,3) | Seguro |
| `outros` | decimal(12,3) | Outras despesas |
| `deducoes` | decimal(12,3) | Deduções |
| `st` | decimal(12,3) | ICMS-ST total |
| `ipi` | decimal(12,3) | IPI total |
| `vlrtotal` | decimal(16,3) | Total calculado |
| `idcli` | int | Cliente (FK, nullable) |
| `idvend` | int | Vendedor (isolamento tenant) |
| `idemp` | int | Empresa (FK) |
| `plataforma` | varchar(20) | Origem (ex: `"SALESFORCE"`) |
| `processo` | varchar(20) | Processo origem (ex: `"B3PED.exe"`) |
| `ultimousu` | int unsigned | Último usuário que editou |
| `obsinter` | varchar(255) | Observação interna |

### VendaCaixaEntity — tabela `vendacaixa`

PK composta: `idvenda` + `idforma` + `seq`. Registra o pagamento da venda.

| Campo | Descrição |
|---|---|
| `valor` | decimal(12,2) — valor pago |
| `idcond` | condição de pagamento (FK) |
| `operacao` | `'I'` ou `'D'` herdado da forma |
| `baixado` | boolean, padrão true |

### VendaItemEntity — tabela `vendaitem`

PK composta: `idvenda` + `seq`.

| Campo | Tipo DB | Descrição |
|---|---|---|
| `idprod` | int | Produto (FK) |
| `qtde` | decimal(10,3) | Quantidade |
| `custo` | decimal(12,3) | Custo no momento |
| `unitario` | decimal(12,3) | Preço unitário |
| `desconto` | decimal(10,2) | Desconto do item |
| `acrescimo` | decimal(10,2) | Acréscimo do item |
| `bruto` | decimal(12,2) | `qtde × unitario` |
| `total` | decimal(12,2) | `bruto + acrescimo - desconto` |
| `st` | decimal(12,3) | ICMS-ST do item |
| `ipi` | decimal(12,3) | IPI do item |
| `cfop` | varchar(5) | CFOP aplicado |
| `vlrtab` | decimal(12,3) | Preço da tabela usado |
| `obsprd` | varchar(60) | Observação do item |

## Endpoints

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/b3vendas/clientes/buscar?q=` | Busca clientes (mín. 2 chars, máx. 50) |
| `GET` | `/b3vendas/clientes/:id` | Dados do cliente |
| `POST` | `/b3vendas/clientes` | Criar cliente |
| `PATCH` | `/b3vendas/clientes/:id` | Atualizar cliente |
| `DELETE` | `/b3vendas/clientes/:id` | Remover cliente (role SUPER) |
| `GET` | `/b3vendas/operacoes` | Listar operações permitidas |
| `GET` | `/b3vendas/produtos/buscar?q=` | Busca produtos (mín. 2 chars, máx. 50) |
| `GET` | `/b3vendas/produtos/:id/preco?idCli=&idOper=` | Preço do produto para cliente/operação |
| `POST` | `/b3vendas/produtos/:id/calc-imposto` | Calcular IPI/ST sobre subtotal |
| `POST` | `/b3vendas/pedidos` | Criar pedido |
| `GET` | `/b3vendas/pedidos/editaveis` | Pedidos abertos (últimos 5 dias) |
| `GET` | `/b3vendas/pedidos/fechados` | Pedidos fechados (últimos 30 dias) |
| `GET` | `/b3vendas/pedidos/:id` | Detalhes do pedido com itens |
| `GET` | `/b3vendas/pedidos/:id/formas-disponiveis` | Formas de pagamento disponíveis |
| `GET` | `/b3vendas/pedidos/:id/condicoes-disponiveis` | Condições de pagamento disponíveis |
| `POST` | `/b3vendas/pedidos/:id/fechar` | Fechar pedido com pagamento |
| `POST` | `/b3vendas/pedidos/:id/itens` | Adicionar item ao pedido |
| `DELETE` | `/b3vendas/pedidos/:id/itens/:seq` | Remover item do pedido |

## Guards

Todos os endpoints exigem `JwtGuard` + `UserInstanceGuard`. O `DELETE /clientes/:id` exige adicionalmente `RolesFrontGuard` com role `SUPER`.
