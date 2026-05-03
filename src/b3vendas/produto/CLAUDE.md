# b3vendas / produto

Catálogo, busca, preço por cliente e cálculo de impostos.

> Convenções gerais em [../CLAUDE.md](../CLAUDE.md). Schema completo em [../../../agent_docs/tenant_schema.md](../../../agent_docs/tenant_schema.md).

## Tabelas

| Tabela | Papel |
|---|---|
| `prd` | Produto |
| `prdtab` / `prdtabvalor` | Tabelas de preço (vínculo `cnt.idtab`) |
| `prdimposto` | Produto × operação × imposto |
| `impostos` | Regras de tributação (ICMS, IVA, redução, IPI) |

## Endpoints

| Método | Rota | Roles | Sumário |
|---|---|---|---|
| GET | `/b3vendas/produtos/buscar?q=` | qualquer | Autocomplete — se `q` é só dígitos, busca por `id` exato; senão `UPPER(nome) LIKE`. Filtros fixos: `NOT consumo`, `ativo`, `podevender`, `(acabado OR revenda)`. Limite 50. |
| GET | `/b3vendas/produtos/:id/preco?idCli=&idOper=` | qualquer | Preço unitário + CFOP + custo (ver "Pricing"). |
| POST | `/b3vendas/produtos/:id/calc-imposto` | qualquer | Calcular IPI/ST a partir de `{ subtotal, idOper }`. |

## Pricing — Resolução do Preço Unitário

`ProdutoService.preco(dbId, idProd, idCli, idOper)` retorna `{ cfop, custo, vunit }`. A resolução ocorre em duas etapas independentes:

**1. CFOP** (`prdimposto` × `operacoes` × `impostos`):

```
SE existe regra (prdimposto.idprd = produto AND prdimposto.idoperacao = operacao):
  SE impostos.icmsiva > 0 → operacoes.cfopst
  SENÃO                    → operacoes.cfopnormal
SENÃO (fallback): operacoes.cfopnormal direto
```

**2. Preço unitário** (`cnt.idtab` × `prdtabvalor`):

```
SE cnt.idtab definido E prdtabvalor.valor > 0 para (idtab, idprod) → valor da tabela
SENÃO (fallback): prd.venda
```

`custo` vem direto de `prd.custo`. Os três valores são consumidos pelo frontend ao montar o item do pedido.

## Cálculo de Impostos

`TaxCalculatorService` (`tax-calculator.service.ts`) é puro — sem injeção de banco. Recebe `subtotal` + `TaxRule` (`{ icmsaliq, icmsredu, icmsiva, ipialiq }`) extraída por `ProdutoService.buscarRegraImposto` da junção `prdimposto → impostos`.

```ts
calc(subtotal, rule) → { ipi, st, total }
```

Regras:

- **Sem regra (`rule == null`)** → `{ ipi: 0, st: 0, total: round(subtotal) }`.
- **`ipialiq <= 0`** → IPI = 0.
- **`icmsiva <= 0`** → ST = 0.

Endpoint: `POST /b3vendas/produtos/:id/calc-imposto` (body `{ subtotal, idOper }`) → `{ ipi, st, total }`. Use **antes** de `POST /pedidos/:id/itens` para preencher `vST` e `vIPI` do item.

## Entities e DTOs

| Entity | Tabela | PK | DTOs |
|---|---|---|---|
| `ProdutoEntity` | `prd` | `id` int | `ResponseProdutoBusca`, `ResponsePreco`, `ResponseImposto`, `CalcImposto` |
| `ImpostoEntity` | `impostos` | `id` int | (sem DTO — leitura interna) |
| `ProdutoImpostoEntity` | `prdimposto` | `(idprd, idoperacao, idimposto)` | (sem DTO) |
| `ProdutoTabValorEntity` | `prdtabvalor` | `(idtab, idprod)` | (sem DTO) |
