# b3vendas / operacao

Operações fiscais permitidas por empresa (`operacoes`).

> Convenções gerais e `SellerContext` em [../CLAUDE.md](../CLAUDE.md). Schema completo em [../../../agent_docs/tenant_schema.md](../../../agent_docs/tenant_schema.md).

## Filtros aplicados

`OperacaoService.listarPermitidas(dbId, userId, idemp)` aplica três filtros:

1. `o.saidaentrada = '1'` (apenas operações de **saída**).
2. `o.<filtro do cfg.VWEBOPERCOND>` — cláusula SQL adicional configurável por tenant via `CfgService` (sem aspas/saneamento — é uma string interpolada literal).
3. `o.idemp IS NULL OR o.idemp = 0 OR o.idemp = :idemp` (operações globais ou específicas da empresa).

Order by `operacao ASC`. Retorna `{ id, operacao, subtipo, cfopnormal, cfopst }`.

> ⚠️ `cfg.VWEBOPERCOND` é interpolado **direto na SQL** sem escape. Confia-se que o valor seja seguro (banco do tenant — sem entrada de usuário).

## Endpoints

| Método | Rota | Roles | Sumário |
|---|---|---|---|
| GET | `/b3vendas/operacoes?idemp=` | qualquer | Operações fiscais permitidas |

## Entity e DTOs

| Entity | Tabela | PK | DTOs |
|---|---|---|---|
| `OperacaoEntity` | `operacoes` | `id` smallint unsigned | `ResponseOperacao`, `ListOperacoesQuery` |

## Consumidores Internos

- `VendaService` lê `operacoes.subtipo` para gravar em `venda.subtipo`.
- `ProdutoService` lê `operacoes.cfopnormal` / `operacoes.cfopst` em `preco()` (resolução de CFOP).
- `ClienteService.tabela` lê `operacoes.finalidade` (zera ST quando `'C'`).
