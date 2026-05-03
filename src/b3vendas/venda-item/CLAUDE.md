# b3vendas / venda-item

Itens do pedido (`vendaitem`).

> Pedido mestre e estados em [../venda/CLAUDE.md](../venda/CLAUDE.md). Convenções gerais em [../CLAUDE.md](../CLAUDE.md).

## Tabela

| Tabela | Papel |
|---|---|
| `vendaitem` | Itens do pedido |

## Endpoints

| Método | Rota | Roles | Sumário |
|---|---|---|---|
| POST | `/b3vendas/pedidos/:id/itens` | qualquer | `assertEditavel` (`tipo='O'`); calcula `seq = MAX(seq)+1`; insere com `bruto = total = qtde * vunit`, `desconto = 0`, `acrescimo = 0`, `st = vST`, `ipi = vIPI`, `vlrtab = tabela`, `obsprd = trim(obsprod) || null`. Dispara `recalcTotals`. |
| DELETE | `/b3vendas/pedidos/:id/itens/:seq` | qualquer | `assertEditavel`; `delete({ idvenda, seq })`; 404 se nada apagado; recalcula totais. |

## Recálculo de totais

Toda mutação dispara `VendaService.recalcTotals(idvenda)` — duas queries `UPDATE venda` em sequência (ver [../venda/CLAUDE.md](../venda/CLAUDE.md#fórmula-de-totais--recalctotals)).

## Edição

`assertEditavel` exige `venda.tipo = 'O'`. Pedidos `'P'` ou `'V'` rejeitam tanto `POST` quanto `DELETE` de item.

## Cálculo dos campos do item

Antes de `POST /itens`, o frontend deve chamar `POST /produtos/:id/calc-imposto` (ver [../produto/CLAUDE.md](../produto/CLAUDE.md#cálculo-de-impostos)) para obter `vST` e `vIPI` e enviar no payload.

## Entity e DTOs

| Entity | Tabela | PK | DTOs |
|---|---|---|---|
| `VendaItemEntity` | `vendaitem` | `(idvenda, seq)` | `CreateVendaItem` |
