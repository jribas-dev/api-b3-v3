# b3vendas / venda

Pedido / venda mestre (`venda` + `vendacaixa`).

> Convenções gerais em [../CLAUDE.md](../CLAUDE.md). Itens do pedido em [../venda-item/CLAUDE.md](../venda-item/CLAUDE.md). Schema completo em [../../../agent_docs/tenant_schema.md](../../../agent_docs/tenant_schema.md).

## Tabelas

| Tabela | Papel |
|---|---|
| `venda` | Pedido / venda mestre |
| `vendacaixa` | Pagamento do pedido |

## Estados da Venda

### `venda.tipo` — máquina de estados

| Valor | Estado | Editável (itens) |
|---|---|---|
| `'O'` | Orçamento aberto / rascunho | ✅ `assertEditavel` permite |
| `'P'` | Pedido pendente | ❌ |
| `'V'` | Venda confirmada | ❌ |

> ⚠️ **Importante:** `POST /pedidos` aceita `rctipo` ∈ `{O, P, V}` e grava esse valor diretamente em `venda.tipo`. **Não há transição automática** — `POST /pedidos/:id/fechar` apenas registra o pagamento em `vendacaixa`; **não altera `venda.tipo`**. Mudança de estado para `'P'`/`'V'` ocorre fora desta API (cliente legado / processos internos).

### `venda.subtipo` — natureza fiscal

| Valor | Estado |
|---|---|
| `'N'` | Normal |
| `'T'` | Transferência |
| `'B'` | Bonificação |
| `'G'` | Garantia |

Definido em `POST /pedidos`: o service copia `operacoes.subtipo` da operação informada para `venda.subtipo` (default `'N'` se nulo).

### `venda.fiscal` — regime fiscal (mapeado de `rcfat`)

| Valor | Significado |
|---|---|
| `'F'` | Fiscal (movimenta tributação) |
| `'E'` | Estimativa (sem efeito fiscal) |

O DTO recebe o campo como `rcfat` e o service grava em `venda.fiscal`.

## Endpoints

| Método | Rota | Roles | Sumário |
|---|---|---|---|
| POST | `/b3vendas/pedidos` | qualquer | Cria com `idvend = vendId`, `ultimousu = usuId`, `idcomi = cnt[id=vendId].idcomi`, `plataforma = 'SALESFORCE'`, `processo = 'B3PED.exe'`, `subtipo = operacoes[idOper].subtipo` (ou `'N'`), `tipo = dto.rctipo`, `fiscal = dto.rcfat`. **Não força `tipo='O'`** — depende do `rctipo` enviado. |
| GET | `/b3vendas/pedidos/editaveis?idemp=` | qualquer | `tipo='O'`, `idvend=vendId`, `idemp`, `dthremissao` nos últimos 5 dias. |
| GET | `/b3vendas/pedidos/fechados?idemp=` | qualquer | `tipo IN ('P','V')`, mesmas chaves, últimos 30 dias. |
| GET | `/b3vendas/pedidos/:id` | qualquer | `loadVendaVinculada` (404 se não existir, 403 se outro vendedor). Devolve venda + itens (com nome do produto) + cliente completo (incluindo `format_docfed`) + `idForma`/`idCond` do `vendacaixa`. |
| POST | `/b3vendas/pedidos/:id/fechar` | qualquer | Exige `tipo='O'`. Em transação: `DELETE FROM vendacaixa WHERE idvenda=?` → `INSERT vendacaixa (seq=1, valor=vlrtotal, idforma, idcond, operacao=formapg.operacao, baixado=1)`. Atualiza `obsinter` se enviado. **Não altera `venda.tipo`**. |
| GET | `/b3vendas/pedidos/:id/formas-disponiveis` | qualquer | Delega para [formas-pagamento](../formas-pagamento/CLAUDE.md) — união padrão + histórico. |
| GET | `/b3vendas/pedidos/:id/condicoes-disponiveis` | qualquer | Idem. |

## Fórmula de Totais — `recalcTotals`

Disparada após cada `POST` ou `DELETE` de item (ver [venda-item](../venda-item/CLAUDE.md)). Executa duas atualizações em sequência sobre `venda` (sem transação explícita):

```sql
-- 1. Soma agregada dos itens em vendaitem
UPDATE venda v JOIN (
  SELECT SUM(bruto), SUM(desconto), SUM(acrescimo), SUM(st), SUM(ipi)
    FROM vendaitem WHERE idvenda = ?
) src
   SET v.vlrbruto, v.desconto, v.acrescimo, v.st, v.ipi  -- vindos dos itens
 WHERE v.id = ?

-- 2. Total geral (mistura agregados de itens com campos do mestre)
UPDATE venda
   SET vlrtotal = (vlrbruto + acrescimo + st + ipi + frete + seguro + outros)
                - (desconto + deducoes)
 WHERE id = ?
```

> `frete`, `seguro`, `outros`, `deducoes` ficam em `venda` (mestre) e **não** vêm dos itens; nesta API eles permanecem zerados.

> Sem transação explícita por performance; risco de inconsistência aceitável (writer único por venda).

## Entities e DTOs

| Entity | Tabela | PK | DTOs |
|---|---|---|---|
| `VendaEntity` | `venda` | `id` int unsigned | Create/Fechar + `ResponseVendaResumo`, `ResponseVendaDetalhe`, `ResponseVendaItem`, `ListVendasQuery` |
| `VendaCaixaEntity` | `vendacaixa` | `(idvenda, idforma, seq)` | (sem DTO) |
