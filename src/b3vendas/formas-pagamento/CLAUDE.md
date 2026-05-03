# b3vendas / formas-pagamento

`formapg` + `condpg`. **Sem controller próprio** — o serviço é consumido por `VendaController`.

> Convenções gerais em [../CLAUDE.md](../CLAUDE.md).

## Tabelas

| Tabela | Papel |
|---|---|
| `formapg` | Forma de pagamento |
| `condpg` | Condição de pagamento |
| `vendacaixa` | Histórico (lookup das já usadas pelo cliente) |

## Comportamento

A lista retornada para um pedido é a **união** de:

- Forma/condição padrão do cliente (`cnt.idforma`, `cnt.idcond`).
- Histórico: formas/condições já usadas em vendas anteriores do mesmo cliente (via `vendacaixa`).

`operacaoDaForma(idForma)` retorna `formapg.operacao` (char 1) — gravado em `vendacaixa.operacao` no fechamento do pedido.

## Endpoints (expostos via `/b3vendas/pedidos`)

| Método | Rota | Roles | Sumário |
|---|---|---|---|
| GET | `/b3vendas/pedidos/:id/formas-disponiveis` | qualquer | União padrão + histórico |
| GET | `/b3vendas/pedidos/:id/condicoes-disponiveis` | qualquer | União padrão + histórico |

> Retorna `[]` se a venda não tem cliente.

## Entities e DTOs

| Entity | Tabela | PK | DTOs |
|---|---|---|---|
| `FormaPagamentoEntity` | `formapg` | `id` smallint unsigned | `ResponseForma` (compartilhado com condições) |
| `CondicaoPagamentoEntity` | `condpg` | `idcond` smallint unsigned | `ResponseForma` |
