# COORDINATION.md — Módulo `b3dash`

Dashboard multi-tenant que expõe endpoints de leitura para montagem de **gráficos e grids** nos três domínios: Faturamento, Financeiro e Estoque. Todos os dados vêm do banco do tenant (`TenantService.getDataSource`). Nenhuma escrita é realizada por este módulo.

---

## Índice

1. [Visão Geral](#1-visão-geral)
2. [Estrutura de Diretórios Planejada](#2-estrutura-de-diretórios-planejada)
3. [Decisões de Arquitetura](#3-decisões-de-arquitetura)
4. [Passos de Implementação](#4-passos-de-implementação)
5. [Domínio: Faturamento](#5-domínio-faturamento)
6. [Domínio: Financeiro](#6-domínio-financeiro)
7. [Domínio: Estoque](#7-domínio-estoque)
8. [Queries de Referência](#8-queries-de-referência)
9. [Insights e Armadilhas](#9-insights-e-armadilhas)

---

## 1. Visão Geral

| Item | Detalhe |
|---|---|
| Prefixo REST | `/b3dash` |
| Banco de dados | Tenant (via `TenantService`) — `synchronize: false` |
| Autenticação | `JwtGuard` + `UserInstanceGuard` em todos os endpoints |
| Autorização | `RolesFrontGuard` com roles a definir por endpoint |
| Tipo de retorno | Objetos tipados para gráfico (`ChartDataDto`) e grid (`GridDataDto`) |
| Módulo no `AppModule` | Importar `B3dashModule` ao lado de `B3vendasModule` |

---

## 2. Estrutura de Diretórios Planejada

```
src/b3dash/
├── b3dash.module.ts            # Módulo raiz — agrega os 3 sub-módulos
├── shared/
│   └── shared.module.ts        # Importa TenantModule, exporta para os sub-módulos
├── faturamento/
│   ├── faturamento.module.ts
│   ├── faturamento.controller.ts
│   ├── faturamento.service.ts
│   └── dto/
│       ├── query-periodo.dto.ts       # ?de=YYYY-MM-DD&ate=YYYY-MM-DD&idemp=N
│       ├── chart-series.dto.ts        # { label, value }[]
│       └── fat-grid-item.dto.ts       # linha da tabela de faturas
├── financeiro/
│   ├── financeiro.module.ts
│   ├── financeiro.controller.ts
│   ├── financeiro.service.ts
│   └── dto/
│       ├── query-periodo.dto.ts
│       ├── chart-series.dto.ts
│       └── fin-grid-item.dto.ts
└── estoque/
    ├── estoque.module.ts
    ├── estoque.controller.ts
    ├── estoque.service.ts
    └── dto/
        ├── query-estoque.dto.ts       # ?idemp=N&idprd=N (opcional)
        ├── chart-series.dto.ts
        └── estoque-grid-item.dto.ts
```

> `query-periodo.dto.ts` e `chart-series.dto.ts` são idênticos nos três sub-módulos — considere movê-los para `shared/` após o primeiro sub-módulo estar estável.

---

## 3. Decisões de Arquitetura

### 3.1 Sem entities novas no tenant
As queries do dashboard são todas leituras de dados já existentes (`fat`, `ctareceber`, `finmov`, `prdsaldo`, `estoque`, etc.). Usar `ds.query<T[]>(sql, params)` diretamente — sem adicionar novas entities em `TENANT_ENTITIES` — evita overhead de sincronização e mantém `synchronize: false` intacto.

### 3.2 Services com `ds.query()`, não `QueryBuilder`
Queries de dashboard são complexas (múltiplos JOINs, GROUP BY, subselects). SQL raw via `ds.query()` é mais legível, testável e performático do que QueryBuilder encadeado para esse caso.

### 3.3 Parâmetros sempre tipados no DTO de query
Todos os filtros de período, empresa e produto chegam via `@Query()` com validação `class-validator`. Nunca interpolar strings — sempre usar placeholders `?` para evitar SQL injection.

### 3.4 Filtro por `idemp` obrigatório
O banco do tenant é multi-empresa (campo `idemp` presente em `fat`, `ctareceber`, `finmov`, `estoque`). Todos os endpoints exigem `idemp` no query param para que os dados retornados sejam da empresa correta. Validar contra as empresas autorizadas ao usuário via `EmpService.listEmitentes`.

### 3.5 Retornos para gráfico vs. grid
Dois shapes de resposta distintos:
- **Gráfico** — array de `{ label: string, value: number }` ou `{ periodo: string, series: { name, value }[] }` para gráficos de série temporal.
- **Grid** — array de objetos com campos completos para exibição em tabela paginada.

---

## 4. Passos de Implementação

### Etapa 1 — Scaffold do módulo raiz
- [ ] Criar `src/b3dash/shared/shared.module.ts` (importa `TenantModule`, exporta `TenantModule` + `EmpService`)
- [ ] Criar `src/b3dash/b3dash.module.ts` (importa os 3 sub-módulos)
- [ ] Registrar `B3dashModule` em `src/app.module.ts`

### Etapa 2 — DTOs compartilhados
- [ ] `QueryPeriodoDto` — `de`, `ate` (ISO date), `idemp` (int, obrigatório)
- [ ] `ChartSeriesDto` — `{ label: string; value: number }`
- [ ] `ChartTimeSeriesDto` — `{ periodo: string; total: number; [extra]?: number }`

### Etapa 3 — Sub-módulo Faturamento
- [ ] `FaturamentoController` com 3 endpoints (ver §5)
- [ ] `FaturamentoService` com queries em `fat` + `cnt` + `vendaitem`
- [ ] DTOs de resposta para cada endpoint

### Etapa 4 — Sub-módulo Financeiro
- [ ] `FinanceiroController` com 3 endpoints (ver §6)
- [ ] `FinanceiroService` com queries em `ctareceber` + `finmov` + `finlancto`
- [ ] DTOs de resposta

### Etapa 5 — Sub-módulo Estoque
- [ ] `EstoqueController` com 3 endpoints (ver §7)
- [ ] `EstoqueService` com queries em `prdsaldo` + `estoque` + `prd`
- [ ] DTOs de resposta

### Etapa 6 — Validação e polimento
- [ ] Testar cada endpoint com dados reais via MCP MySQL antes de publicar
- [ ] Revisar limites de paginação nos grids (`LIMIT ?` com default 50)
- [ ] Adicionar `@HttpCode(200)` explícito em todos os GET handlers

---

## 5. Domínio: Faturamento

### Tabelas principais
| Tabela | Papel |
|---|---|
| `fat` | Fatura emitida — `valortotal`, `dthremissao`, `cancelado`, `idemp`, `idcnt` |
| `cnt` | Cliente — `razao`, `docfed` |
| `vendaitem` | Itens da venda — para ranking de produtos |
| `prd` | Produto — `nome` |

### Endpoints planejados

#### `GET /b3dash/faturamento/evolucao`
Série temporal de faturamento por período (mês ou dia).

**Query params:** `de`, `ate`, `idemp`, `agrupamento` (`mes` | `dia`, default `mes`)

**Retorno (gráfico de linha/barra):**
```json
[
  { "periodo": "2025-11", "total": 6838.54 },
  { "periodo": "2025-12", "total": 1810.77 },
  { "periodo": "2026-01", "total": 6621.80 }
]
```

**Tabela fonte:** `fat` — `WHERE cancelado = 0 AND idemp = ? AND dthremissao BETWEEN ? AND ?`

---

#### `GET /b3dash/faturamento/top-clientes`
Ranking dos clientes com maior faturamento no período.

**Query params:** `de`, `ate`, `idemp`, `limite` (default `10`)

**Retorno (gráfico de barras horizontais):**
```json
[
  { "label": "CLIENTE ABC LTDA", "value": 45320.00 },
  { "label": "FULANO COMÉRCIO",  "value": 12800.00 }
]
```

**Tabela fonte:** `fat JOIN cnt ON cnt.id = fat.idcnt`

---

#### `GET /b3dash/faturamento/grid`
Listagem das faturas emitidas no período com paginação.

**Query params:** `de`, `ate`, `idemp`, `page` (default `1`), `limit` (default `50`)

**Retorno (grid):**
```json
{
  "total": 142,
  "items": [
    {
      "id": 1001,
      "fatura": "NF-001234",
      "dthremissao": "2026-02-15T10:30:00",
      "cliente": "CLIENTE ABC LTDA",
      "valortotal": 3200.00,
      "cancelado": false
    }
  ]
}
```

---

## 6. Domínio: Financeiro

### Tabelas principais
| Tabela | Papel |
|---|---|
| `ctareceber` | Parcelas a receber — `vencimento`, `pagamento`, `valor`, `valorpago`, `anulada` |
| `finmov` | Movimentos financeiros — `dataemi`, `debcred`, `valor`, `baixado` |
| `finlancto` | Lançamentos — `dtemi`, `valor`, `baixado`, `idemp` |
| `finespecie` | Espécie financeira (tipo do movimento) |
| `finhist` | Histórico financeiro (descrição do lançamento) |

### Endpoints planejados

#### `GET /b3dash/financeiro/inadimplencia`
Resumo de títulos vencidos vs. a vencer vs. recebidos.

**Query params:** `idemp`, `ate` (data de corte, default hoje)

**Retorno (gráfico de pizza/donut):**
```json
[
  { "label": "Recebido",  "value": 28500.00 },
  { "label": "A Vencer",  "value": 9200.00  },
  { "label": "Vencido",   "value": 3400.00  }
]
```

**Tabela fonte:** `ctareceber` — `pagamento IS NULL` → vencido vs. a vencer; `pagamento IS NOT NULL` → recebido.

---

#### `GET /b3dash/financeiro/fluxo-caixa`
Projeção de entradas (a receber) agrupadas por semana ou mês.

**Query params:** `de`, `ate`, `idemp`, `agrupamento` (`semana` | `mes`, default `mes`)

**Retorno (gráfico de linha):**
```json
[
  { "periodo": "2026-04", "previsto": 15200.00, "realizado": 12800.00 },
  { "periodo": "2026-05", "previsto": 18000.00, "realizado": 0.00 }
]
```

**Tabela fonte:** `ctareceber` — `previsto` = SUM(valor) agrupado por `vencimento`; `realizado` = SUM(valorpago) agrupado por `pagamento`.

---

#### `GET /b3dash/financeiro/grid-titulos`
Listagem de títulos a receber com status de pagamento.

**Query params:** `de`, `ate`, `idemp`, `status` (`todos` | `aberto` | `vencido` | `pago`, default `aberto`), `page`, `limit`

**Retorno (grid):**
```json
{
  "total": 87,
  "items": [
    {
      "idctarec": 501,
      "cliente": "CLIENTE XYZ",
      "emissao": "2026-03-01",
      "vencimento": "2026-04-01",
      "pagamento": null,
      "valor": 1200.00,
      "valorpago": 0.00,
      "status": "vencido"
    }
  ]
}
```

---

## 7. Domínio: Estoque

### Tabelas principais
| Tabela | Papel |
|---|---|
| `prdsaldo` | Saldo atual por produto/empresa — `idemp`, `idprod`, `saldo` |
| `estoque` | Movimentos de entrada/saída — `tipo` (B/E/S/X), `qtde`, `dthrestoque`, `idprd` |
| `prd` | Produto — `nome`, `unidade`, `ativo` |
| `estoquek200` | Kardex 200 — contagem física de inventário |
| `estoqueh010` | Histórico de custo médio |

### Endpoints planejados

#### `GET /b3dash/estoque/saldos`
Produtos com saldo atual — ordenados por valor em estoque (qtde × custo médio).

**Query params:** `idemp`, `apenas_positivos` (boolean, default `true`), `limite` (default `20`)

**Retorno (gráfico de barras):**
```json
[
  { "label": "PRODUTO ALFA",  "value": 342.0 },
  { "label": "PRODUTO BETA",  "value": 198.5 },
  { "label": "PRODUTO GAMA",  "value": 75.0  }
]
```

**Tabela fonte:** `prdsaldo JOIN prd ON prd.id = prdsaldo.idprod WHERE prdsaldo.idemp = ? AND prdsaldo.saldo > 0`

---

#### `GET /b3dash/estoque/movimentos`
Série temporal de entradas e saídas no período.

**Query params:** `de`, `ate`, `idemp`, `agrupamento` (`dia` | `mes`, default `mes`)

**Retorno (gráfico de linha dupla — entradas vs. saídas):**
```json
[
  { "periodo": "2026-02", "entradas": 520.0, "saidas": 310.0 },
  { "periodo": "2026-03", "entradas": 410.0, "saidas": 480.0 }
]
```

**Tabela fonte:** `estoque` — `tipo = 'E'` para entradas, `tipo = 'S'` para saídas. Ignorar `tipo = 'X'` (cancelados).

---

#### `GET /b3dash/estoque/grid`
Listagem de movimentos de estoque com detalhes de produto.

**Query params:** `de`, `ate`, `idemp`, `tipo` (`E` | `S` | todos), `page`, `limit`

**Retorno (grid):**
```json
{
  "total": 260,
  "items": [
    {
      "idestoque": 8821,
      "dthrestoque": "2026-03-15T14:22:00",
      "produto": "PRODUTO ALFA",
      "tipo": "S",
      "qtde": 10.0,
      "custo": 45.50,
      "origem": "VENDA"
    }
  ]
}
```

---

## 8. Queries de Referência

Queries validadas via MCP MySQL — prontas para uso nos services.

### Faturamento — evolução mensal
```sql
SELECT
  DATE_FORMAT(dthremissao, '%Y-%m') AS periodo,
  ROUND(SUM(valortotal), 2)         AS total
FROM fat
WHERE cancelado = 0
  AND idemp = ?
  AND dthremissao BETWEEN ? AND ?
GROUP BY periodo
ORDER BY periodo
```

### Financeiro — inadimplência (snapshot)
```sql
SELECT
  CASE
    WHEN pagamento IS NOT NULL THEN 'Recebido'
    WHEN vencimento < CURDATE() THEN 'Vencido'
    ELSE 'A Vencer'
  END                         AS label,
  ROUND(SUM(valor), 2)        AS value
FROM ctareceber
WHERE anulada = 0
  AND idemp = ?
GROUP BY label
```

### Estoque — saldos com nome do produto
```sql
SELECT
  p.nome  AS label,
  s.saldo AS value
FROM prdsaldo s
JOIN prd p ON p.id = s.idprod
WHERE s.idemp = ?
  AND s.saldo > 0
ORDER BY s.saldo DESC
LIMIT ?
```

### Estoque — movimentos por período
```sql
SELECT
  DATE_FORMAT(dthrestoque, '%Y-%m')              AS periodo,
  ROUND(SUM(IF(tipo = 'E', qtde, 0)), 3)         AS entradas,
  ROUND(SUM(IF(tipo = 'S', qtde, 0)), 3)         AS saidas
FROM estoque
WHERE cancelado = 0
  AND idemp = ?
  AND tipo IN ('E','S')
  AND dthrestoque BETWEEN ? AND ?
GROUP BY periodo
ORDER BY periodo
```

---

## 9. Insights e Armadilhas

### `fat.valortotal` vs `venda.vlrtotal`
A tabela `fat` é gerada **após** o faturamento fiscal — nem toda `venda` tem uma `fat` correspondente (pedidos em aberto, orçamentos). Para dados de faturamento real (NF emitida), usar `fat`. Para dados de vendas brutas (incluindo pedidos não faturados), usar `venda`.

### Decimais chegam como `string` do MySQL
Colunas `DECIMAL` retornam como string no driver `mysql2`. Ao usar `ds.query()` raw, fazer `parseFloat(row.total)` explicitamente nos DTOs ou usar `CAST(SUM(valor) AS DECIMAL(15,2))` no SQL.

### `ctareceber` sem `idemp` no JOIN com `cnt`
`ctareceber` não possui campo `razao` — é necessário JOIN com `cnt` via `ctareceber.idcnt = cnt.id` para obter o nome do cliente no grid de títulos.

### Estoque: `tipo = 'X'` são cancelamentos
Sempre filtrar `cancelado = 0` na tabela `estoque` e excluir `tipo = 'X'` em queries de movimentação para não distorcer saldos.

### `prdsaldo` é snapshot, não histórico
`prdsaldo` guarda o **saldo atual** — não tem histórico temporal. Para série histórica de estoque, usar a tabela `estoque` com GROUP BY de período.

### Autorização por empresa
Antes de executar qualquer query, validar que o `idemp` informado pertence às empresas autorizadas para o `userId` via `EmpService.listEmitentes(dbId, userId)`. Caso contrário lançar `ForbiddenException`.

### Paginação em grids
Usar `SQL_CALC_FOUND_ROWS` + `SELECT FOUND_ROWS()` **ou** uma query `COUNT(*)` separada para retornar o total de registros sem carregar tudo na memória. Preferir a query separada para legibilidade.
