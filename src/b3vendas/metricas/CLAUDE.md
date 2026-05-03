# b3vendas / metricas

Indicadores agregados read-only sobre `venda` + `cnt`.

> Convenções gerais e `SellerContext` em [../CLAUDE.md](../CLAUDE.md). Estados da venda em [../venda/CLAUDE.md](../venda/CLAUDE.md#estados-da-venda).

## Roles e parâmetros

Controller aplica `@RolesFront(SUPERSALER, SALER)` no nível da classe. Todos os endpoints recebem `QueryMetricasDto` via `@Query()`:

| Param | Obrig.? | Notas |
|---|---|---|
| `idemp` | sim | Empresa — validada via `usuemp` |
| `idvende` | sim | Vendedor alvo |
| `join` | não | Apenas SUPERSALER pode usar `join=true` |

## resolveScope

`MetricasService.resolveScope` executa três checagens antes de montar `vendIds`:

1. **Acesso à empresa:** `userId → usu → usuemp` — `ForbiddenException` se `idemp` não autorizado.
2. **Acesso ao vendedor:** se `idvende ≠ vendId_logado` → exige SUPERSALER + `idvende` em `cntequipe` como subordinado.
3. **`join=true`:** exclusivo de SUPERSALER; expande escopo para `[vendId_logado, ...subordinados]`. SALER com `join=true` recebe `403`.

`vendIds` resultante:
- `join=true` (supersaler): `[vendId_logado, ...subordinados]` — deduplicado em `Set`.
- caso contrário: `[idvende]`.

`vendIds` é interpolado nas queries via `IN (?, ?, ...)` com placeholders gerados por `vendIds.map(() => '?').join(',')`. O filtro `v.idemp = ?` é adicionado a **todas** as queries.

## Filtro padrão de venda considerada

Aplicado em `vendas-semanais`, `vendas-mensais`, `top-clientes-ativos`:

```sql
v.tipo = 'V' AND v.subtipo = 'N' AND v.baixado = 1
```

`clientes-inativos` **não** aplica esse filtro — usa lógica própria de "última venda".

## Endpoints

| Endpoint | Tipo | Janela | Detalhe |
|---|---|---|---|
| `GET /b3vendas/metricas/vendas-semanais` | `line` (12 buckets) | 12 semanas ISO | `GROUP BY YEARWEEK(dthremissao, 1)`. Labels (`YYYY-Www`) geradas em TS via `last12WeekLabels` + `fillSeries` para preencher zeros. |
| `GET /b3vendas/metricas/vendas-mensais` | `line` (12 buckets) | 12 meses | `GROUP BY DATE_FORMAT(dthremissao, '%Y-%m')`. Idem para preenchimento. |
| `GET /b3vendas/metricas/top-clientes-ativos` | `bar_h` | 90 dias | `JOIN cnt`, `GROUP BY c.id, c.razao, c.fantasia`, `ORDER BY valor DESC LIMIT 15`. Duas séries: `Valor (R$)` e `Pedidos`. Label = `COALESCE(fantasia, razao)`. |
| `GET /b3vendas/metricas/clientes-inativos` | listagem | 60 dias | **Não aplica** o filtro padrão. Filtra `c.ativo`, `c.idvende IN (vendIds)`, `NOT EXISTS venda (com idemp) nos últimos 60 dias`. Inclui clientes que nunca venderam. Subquery `(SELECT MAX(v2.dthremissao) FROM venda v2 WHERE v2.idcli = c.id AND v2.idemp = ?)` produz `ultimaVenda` filtrada por empresa. |

Todos os 4 endpoints aceitam `?idemp=&idvende=[&join=]`.

## ChartDataDto

`ChartDataDto` é local ao módulo (não compartilha com `b3dash`):

```ts
type ChartType = 'bar_v' | 'bar_h' | 'pie' | 'line';
class ChartDataDto {
  chartType: ChartType;
  labels: string[];
  series: { name: string; data: number[] }[];
}
```

> Duplicação intencional para evitar dependência cruzada entre `b3vendas` e `b3dash`.
