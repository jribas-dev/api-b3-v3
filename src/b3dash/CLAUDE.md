# b3dash

Módulo de **dashboard multi-tenant** que expõe endpoints de leitura para montagem de **gráficos e grids** em três domínios: Faturamento, Financeiro e Estoque, além de um sub-módulo auxiliar `usu` para listagem de usuários do legado. Todos os dados vêm do banco do tenant (via `TenantService`). Nenhuma escrita é realizada.

## Responsabilidade

- Consolidar métricas agregadas e listagens paginadas sobre dados já existentes no tenant (`fat`, `venda`, `vendaitem`, `ctareceber`, `ctapag`, `ctapagp`, `finmov`, `estoque`, `mov`, `movprd`, `prdsaldo`, `prd`, `prdgrupo`, `prdsubgrupo`, `cnt`, `operacoes`).
- Prover shape unificado de resposta para **gráficos** (`ChartDataDto`) e **grids** (`GridResponseDto<T>`), simplificando a integração com o front.
- Garantir **isolamento por tenant + empresa** via `EmpService.listEmitentes`, com cache de 24h tenant-aware apenas nos endpoints `/graph/*`.

## Estrutura Interna

```
src/b3dash/
├── b3dash.module.ts                       # Módulo raiz — agrega os 3 sub-módulos
├── shared/
│   ├── shared.module.ts                   # Importa TenantModule + CacheModule, exporta tudo
│   ├── period.resolver.ts                 # Resolve flag S|M|T → SQL + labels + fillSeries
│   ├── tenant-aware-cache.interceptor.ts  # Chave: b3dash:<dbId>:<path>:idemp=N:periodo=X
│   └── dto/
│       ├── graph-query.dto.ts             # { idemp, periodo }
│       ├── list-query.dto.ts              # { idemp, periodo, page, limit, status? }
│       ├── pagination-query.dto.ts        # { page=1, limit=50 (max 200) }
│       ├── chart-series.dto.ts            # { name, data[] }
│       ├── chart-data.dto.ts              # { chartType, labels[], series[] }
│       └── grid-response.dto.ts           # { total, page, limit, items[] }
├── faturamento/
│   ├── faturamento.module.ts
│   ├── faturamento.controller.ts          # 6 graph + 3 list
│   ├── faturamento.service.ts
│   └── dto/                               # FatPorClienteDto, FatPorProdutoDto, FatPorVendedorDto
├── financeiro/
│   ├── financeiro.module.ts
│   ├── financeiro.controller.ts
│   ├── financeiro.service.ts
│   └── dto/                               # FinReceberDto, FinPagarDto, FinMovimentoDto
├── estoque/
│   ├── estoque.module.ts
│   ├── estoque.controller.ts
│   ├── estoque.service.ts
│   └── dto/                               # EstLancamentoDto, EstProdutoDto, EstFornecedorDto
└── usu/
    ├── usu.module.ts
    ├── usu.controller.ts                  # 1 endpoint — list/backoffice
    ├── usu.service.ts
    └── dto/                               # UsuBackofficeDto
```

## Convenção de Rotas

```
GET /b3dash/{dominio}/graph/{metrica}?idemp=<int>&periodo=<S|M|T>
GET /b3dash/{dominio}/list/{tipo}?idemp=<int>&periodo=<S|M|T>&page=<int>&limit=<int>
```

- `{dominio}` ∈ `faturamento | financeiro | estoque`
- `{metrica}` / `{tipo}` são slugs fixos, roteados via `switch` no controller
- Todos exigem `idemp` (int) — validado contra `EmpService.listEmitentes(dbId, userId)`; empresa não autorizada → `403 Forbidden`
- Todos GET retornam `@HttpCode(200)` explícito

## Flag de Período (`periodo`)

Resolução centralizada em `PeriodResolver.resolve(column, periodo)`:

| Flag | Nome | Janela | GROUP BY SQL | Formato label |
|---|---|---|---|---|
| `S` | Semanal | 54 semanas atrás até hoje | `YEARWEEK(col, 1)` | `YYYY-Www` |
| `M` | Mensal | 12 meses atrás até hoje | `DATE_FORMAT(col, '%Y-%m')` | `YYYY-MM` |
| `T` | Trimestral | 4 trimestres atrás até hoje | `CONCAT(YEAR(col),'-T',QUARTER(col))` | `YYYY-Tn` |

Uso típico:

```ts
const { sinceSql, groupExpr } = this.periodResolver.resolve('f.dthremissao', periodo);
// sinceSql  → "f.dthremissao >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)"
// groupExpr → "DATE_FORMAT(f.dthremissao, '%Y-%m')"
```

**Importante:** as strings `sinceSql` e `groupExpr` são fixas (derivadas do enum `'S'|'M'|'T'`), portanto seguras para concatenação. Parâmetros do usuário (`idemp`, `limit`, `offset`) sempre vão por placeholder `?`.

### Buckets vazios

`PeriodResolver.generateLabels(periodo)` gera **todos** os labels esperados da janela (com ISO week para `S`). `fillSeries(rows, labels, periodKey, valueKey, periodo)` faz o merge com os dados SQL, **preenchendo zero** nas lacunas — garantindo eixo X completo no front.

## Shapes de Resposta Unificados

### Gráfico — `ChartDataDto`

```ts
type ChartType = 'bar_v' | 'bar_h' | 'pie' | 'line';

class ChartDataDto {
  chartType: ChartType;      // hint para o front escolher o componente
  labels: string[];          // eixo X (ou nomes das fatias em pie)
  series: ChartSeriesDto[];  // 1+ séries com mesmo len que labels
}

class ChartSeriesDto {
  name: string;
  data: number[];
}
```

- `bar_v` / `bar_h` / `pie` → 1 série.
- `line` → 1 ou N séries compartilhando `labels`.

### Grid — `GridResponseDto<T>`

```ts
class GridResponseDto<T> {
  total: number;   // COUNT(*) separado
  page: number;
  limit: number;
  items: T[];
}
```

Paginação: `page` default 1, `limit` default 50 (max 200). `total` via query `COUNT(*)` separada.

## Cache Tenant-Aware

- `CacheModule.register({ ttl: 86_400_000, max: 500 })` no `B3dashSharedModule` — TTL 24 h.
- `TenantAwareCacheInterceptor` estende `CacheInterceptor` e sobrescreve `trackBy()`:
  ```
  b3dash:<dbId>:<path>:idemp=<N>:periodo=<S|M|T>
  ```
- Aplicado **apenas** em handlers `/graph/*` (via `@UseInterceptors(TenantAwareCacheInterceptor) @CacheTTL(86_400_000)`).
- Endpoints `/list/*` **não** usam cache (paginação torna inefetivo).

## Guards e Autorização

- **Faturamento, Financeiro, Estoque** — `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard` no controller, com `@RolesFront(RoleFrontEnum.ADMIN)`. Apenas usuários com o papel administrativo no array `roleFront` enxergam o dashboard. A autorização fina por empresa acontece no service via `validateIdemp(dbId, userId, idemp)` → compara o `idemp` recebido com a lista de `EmpService.listEmitentes`; se não bater → `ForbiddenException`.
- **Usu** — `JwtGuard` + `UserInstanceGuard` + `AdminGuard`. O `AdminGuard` aceita `isRoot`, `roleBack ∈ {admin, supervisor}` ou `roleFront` contendo `admin`. Não há validação de `idemp` (a listagem é tenant-scoped, não empresa-scoped).

## Decisões de Arquitetura

| Decisão | Justificativa |
|---|---|
| **Sem entities novas** no tenant | Queries são leituras sobre tabelas existentes. `ds.query<T[]>(sql, params)` direto evita overhead de sync e mantém `synchronize: false` intacto. |
| **SQL raw** (não QueryBuilder) | Queries complexas com múltiplos JOINs, GROUP BY, subselects e CASE são mais legíveis/performáticas em SQL literal. |
| **`ChartDataDto` universal** | Um shape serve todos os renders (bar_v/h, pie, line). O front usa `chartType` como hint e pode trocar o render sem mudar contrato. |
| **Fill de buckets em TS** | Gera labels em TypeScript (`PeriodResolver.generateLabels`) e faz merge em memória — mais simples que CTE recursivo em SQL. |
| **Curva ABC em memória** | Para `curva-abc`, busca produtos ordenados e classifica A/B/C com soma acumulada em JS — evita window functions complexas no SQL. |
| **Conversão de `DECIMAL`** | `DECIMAL` vem como `string` do driver mysql2. Service faz `parseFloat(row.campo)` no mapeamento do DTO. |
| **BIT → UNSIGNED em SQL** | `fm.baixado` (BIT(1)) é retornado como `Buffer` pelo driver, o que faz `Boolean(buf)` sempre `true`. Cast `CAST(fm.baixado AS UNSIGNED)` retorna `0/1` e `Boolean(num)` funciona. |

## Tabelas do Tenant Consumidas

| Domínio | Tabelas |
|---|---|
| Faturamento | `fat`, `venda`, `vendaitem`, `cnt`, `prd`, `operacoes` |
| Financeiro | `ctareceber`, `ctapag`, `ctapagp`, `finmov`, `finespecie`, `findestino`, `cnt` |
| Estoque | `estoque`, `mov`, `movprd`, `prd`, `prdsaldo`, `prdgrupo`, `prdsubgrupo`, `cnt` |

> Esquema completo documentado em **[agent_docs/tenant_schema.md](../../agent_docs/tenant_schema.md)**.

## Insights de Schema (após validação MCP MySQL)

- **`ctareceber`** — PK é `idctarec` (não `id`); não possui campo `razao` → JOIN com `cnt` via `ctareceber.idcnt = cnt.id`.
- **`ctapag`** — PK é `id`; **não possui `vencimento`**. O vencimento vem de `ctapagp.vencimento` (parcelas). Em listagens, agregar via `MIN(pg2.vencimento)` com JOIN em `ctapagp`.
- **`ctapagp`** — FK é `idpag` (aponta para `ctapag.id`). Valor pago acumulado via subquery `SELECT idpag, SUM(valorpago) FROM ctapagp GROUP BY idpag`.
- **`finmov`** — PK é `idmov`. Campo `debcred`: `'C'` = crédito (entrada), `'D'` = débito (saída). Saldo líquido: `SUM(IF(debcred='C', valor, -valor))`. Campo `baixado` é `BIT(1)` → cast para `UNSIGNED` em SQL.
- **`findestino.destino`**, **`finespecie.especie`** — nomes de coluna (não `descricao`).
- **`mov`** — não possui `valortotal`; usar `vtotdoc`. Campo `saidaentrada`: `'0'` = entrada (compras), `'1'` = saída.
- **`movprd`** — preço unitário é `vunit` (não `valorunitario`).
- **`estoque`** — PK auto-increment `idestoque`. Campo `tipo` ∈ `{B, E, S, X}` (B=balanço, E=entrada, S=saída, X=não contar). Sempre filtrar `cancelado = 0 AND tipo IN ('E','S')` em métricas de movimentação. `estoque.origem` identifica o gerador: `'vendaitem'`, `'movprd'`, `'pcpopmp'`, `'estoquek200'`, etc.
- **`prdsaldo`** — FK é `idprod` (não `idprd`). É snapshot, sem histórico temporal.
- **`prdgrupo.grupo`**, **`prdsubgrupo.subgrupo`** — nomes de coluna (não `descricao`). Hierarquia: `prd.idsubgrupo → prdsubgrupo.id`, `prdsubgrupo.idgrupo → prdgrupo.id`.
- **`venda`** — `idvend` pode ser `NULL`. Em rankings, usar `COALESCE(c.razao, 'Sem vendedor')` e preservar o bucket.
- **`fat` vs `venda`** — `fat` = NF efetivamente emitida (faturamento fiscal); `venda` com `tipo='V'` = pedidos validados (pode incluir não faturados). Gráficos de **faturamento** usam `fat`; gráfico **top-produtos** usa `vendaitem/venda` porque `fat` não tem granularidade por item.

## Endpoints — Faturamento (`/b3dash/faturamento`)

### Graphs (`/graph/{metrica}`) — cache 24 h

| Slug | `chartType` | Descrição |
|---|---|---|
| `evolucao` | `line` | `SUM(fat.valortotal)` por período |
| `ticket-medio` | `line` | `AVG(fat.valortotal)` por período |
| `top-produtos` | `bar_h` | Top 15 produtos por valor (`vendaitem` + `venda` + `prd`) |
| `top-clientes` | `bar_h` | Top 15 clientes por faturamento (`fat` + `cnt`) |
| `ranking-vendedores` | `bar_v` | Top 15 vendedores (`venda` + `cnt`, LEFT JOIN preserva `NULL`) |
| `mix-operacoes` | `pie` | Distribuição por operação fiscal (`fat` + `operacoes`) |

### Lists (`/list/{tipo}`)

| Slug | Campos do item |
|---|---|
| `por-cliente` | `idcnt`, `razao`, `docfed`, `qtdPedidos`, `valorTotal`, `ultimoPedidoEm`, `ticketMedio` |
| `por-produto` | `idprd`, `codigo`, `nome`, `unidade`, `qtdeTotal`, `valorTotal`, `precoMedio` |
| `por-vendedor` | `idvend`, `nomeVendedor`, `qtdPedidos`, `valorTotal`, `clientesUnicos`, `ticketMedio` |

## Endpoints — Financeiro (`/b3dash/financeiro`)

### Graphs (`/graph/{metrica}`) — cache 24 h

| Slug | `chartType` | Descrição |
|---|---|---|
| `receber-vs-pagar` | `line` | 2 séries: realizado em recebimentos (`ctareceber.valorpago`) × pagamentos (`ctapagp.valorpago`) |
| `fluxo-caixa-projetado` | `line` | 2 séries: entradas previstas (`ctareceber.vencimento`) × saídas previstas (`ctapag.dtemissao`) |
| `inadimplencia` | `pie` | Snapshot: Recebido / A Vencer / Vencido (ignora `periodo`) |
| `top-inadimplentes` | `bar_h` | Top 15 com maior valor vencido (snapshot) |
| `entradas-por-especie` | `pie` | Composição de entradas por espécie (`finmov.debcred='C'` + `finespecie`) |
| `saldo-destinos` | `bar_v` | Saldo líquido por destino (`SUM(IF(debcred='C', valor, -valor))`) |

### Lists (`/list/{tipo}`)

Query extra: `status` ∈ `pago | vencido | aberto` (opcional; default = todos).

| Slug | Campos do item |
|---|---|
| `receber` | `idctarec`, `cliente`, `emissao`, `vencimento`, `pagamento`, `valor`, `valorpago`, `status` |
| `pagar` | `idpag`, `nrodoc`, `fornecedor`, `emissao`, `vencimentoMin`, `valortotal`, `valorPagoAcum`, `status` |
| `movimentos` | `idmov`, `dataemi`, `debcred`, `especie`, `destino`, `valor`, `baixado`, `tborigem` |

**Mapa de `status`:**
- `receber`: `pagamento IS NOT NULL` → `pago`; `vencimento < CURDATE()` → `vencido`; senão `aberto`.
- `pagar`: `SUM(ctapagp.valorpago) >= valortotal` → `pago`; `MIN(ctapagp.vencimento) < CURDATE()` → `vencido`; senão `aberto`. O filtro por status aplica-se após a agregação (`WHERE status = ?` em subquery externa).

## Endpoints — Estoque (`/b3dash/estoque`)

### Graphs (`/graph/{metrica}`) — cache 24 h

| Slug | `chartType` | Descrição |
|---|---|---|
| `entradas-vs-saidas` | `line` | 2 séries: `SUM(qtde)` onde `tipo='E'` × `tipo='S'` em `estoque` |
| `top-produtos-comprados` | `bar_h` | Top 15 por quantidade (`movprd` + `mov.saidaentrada='0'` + `prd`) |
| `top-fornecedores` | `bar_h` | Top 15 por valor de compras (`mov` + `cnt`) |
| `curva-abc` | `pie` | Classificação A/B/C por % acumulado (A ≤ 80%, B ≤ 95%, C > 95%) — ignora `periodo` |
| `ruptura` | `bar_v` | Produtos com `saldo < saldomin` agrupados por `prdgrupo` (snapshot) |
| `valor-por-grupo` | `pie` | Valor imobilizado (`saldo × customedio`) por grupo (snapshot) |

### Lists (`/list/{tipo}`)

| Slug | Query extra | Campos do item |
|---|---|---|
| `lancamentos` | `status` (mapeado para `tipo` `E`/`S`/`B`) | `idmov` (= `estoque.idestoque`), `dthrestoque`, `tipo`, `produto`, `sku`, `qtde`, `custo`, `origem` |
| `por-produto` | `apenasRuptura=true/false` | `idprd`, `codigo`, `nome`, `unidade`, `saldoatu`, `saldomin`, `saldomax`, `customedio`, `valorEstoque` |
| `por-fornecedor` | — | `idcnt`, `razao`, `docfed`, `qtdCompras`, `valorTotal`, `ultimaCompraEm` |

> `lancamentos` consome `estoque` (movimentos diários); `por-produto` consome `prdsaldo` (snapshot atual — `periodo` é mantido para consistência mas não filtra); `por-fornecedor` agrega `mov` com `saidaentrada='0'`.

## Endpoints — Usu (`/b3dash/usu`)

Sub-módulo auxiliar para back-office. **Não** participa da convenção `graph/list` — é um endpoint simples de leitura, sem cache, sem paginação, sem `periodo` e sem `idemp`.

| Endpoint | Guard | Descrição |
|---|---|---|
| `GET /b3dash/usu/list/backoffice` | `JwtGuard + UserInstanceGuard + AdminGuard` | Lista usuários do legado (`usu.id`, `usu.login`) que ainda não estão vinculados a um usuário da API e que estão ativos |

**Query SQL:**
```sql
SELECT id, login
FROM usu
WHERE userId IS NULL
  AND NOT inativo
ORDER BY login
```

- `userId IS NULL` filtra contas do legado que ainda não foram associadas a um usuário da API (campo de vínculo).
- `NOT inativo` exclui contas marcadas como inativas (`inativo` = TINYINT/BIT).
- Resposta é um array simples `[{ id, login }, ...]` (sem `GridResponseDto`) — pensado para popular um `<select>` no front durante o vínculo de um novo usuário da API a uma conta do legado.

## Padrão de Consumo

```ts
// Service
constructor(
  private readonly tenantService: TenantService,
  private readonly empService: EmpService,
  private readonly periodResolver: PeriodResolver,
) {}

async graphEvolucao(dbId: string, userId: string, idemp: number, periodo: 'S'|'M'|'T') {
  await this.validateIdemp(dbId, userId, idemp);           // 1. autoriza empresa
  const ds = await this.tenantService.getDataSource(dbId); // 2. conexão do tenant
  const { sinceSql, groupExpr } = this.periodResolver.resolve('f.dthremissao', periodo);
  const labels = this.periodResolver.generateLabels(periodo);

  const rows = await ds.query<Array<Record<string, string | number | Date | null>>>(
    `SELECT ${groupExpr} AS periodo, ROUND(SUM(f.valortotal),2) AS total
     FROM fat f WHERE f.cancelado=0 AND f.idemp=? AND ${sinceSql}
     GROUP BY periodo ORDER BY periodo`,
    [idemp],
  );

  return {
    chartType: 'line',
    labels,
    series: [{ name: 'Total',
               data: this.periodResolver.fillSeries(rows, labels, 'periodo', 'total', periodo) }],
  };
}
```

Controller aplica `@UseGuards(JwtGuard, UserInstanceGuard)` no nível da classe, e `@UseInterceptors(TenantAwareCacheInterceptor)` + `@CacheTTL(86_400_000)` apenas nos métodos `/graph/:metrica`.
