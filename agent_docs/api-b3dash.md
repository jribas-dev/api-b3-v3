# API Contracts — Módulo b3dash

> Módulo de **dashboard** multi-tenant (somente leitura).
>
> Base URL: `https://<host>/b3dash`
>
> **Todos os endpoints exigem token de etapa 2** (com `dbId` no payload):
> ```
> Authorization: Bearer <accessToken-etapa2>
> ```
>
> Guards aplicados a toda a base:
> - `JwtGuard`
> - `UserInstanceGuard`
> - **Faturamento, Financeiro, Estoque** — `RolesFrontGuard` exigindo `RoleFrontEnum.ADMIN` no array `roleFront` do token. Retorna `403 Forbidden` se o usuário não tiver `admin` no seu array de papéis.
>
> **Nenhuma escrita é realizada** — todos os endpoints são leitura (`GET`).
>
> > Operações sobre a tabela `usu` do tenant (listagem back-office e update de campos pelo próprio usuário) foram movidas para `/tenant/usu/*`. Ver [api-core.md](./api-core.md#tenant).

---

## Índice

- [Convenção de Rotas](#convenção-de-rotas)
- [Parâmetros Comuns](#parâmetros-comuns)
- [Shapes de Resposta](#shapes-de-resposta)
- [Faturamento](#faturamento)
- [Financeiro](#financeiro)
- [Estoque](#estoque)

---

## Convenção de Rotas

```
GET /b3dash/{dominio}/graph/{metrica}   → retorna dados para um gráfico (com cache 24h)
GET /b3dash/{dominio}/list/{tipo}       → retorna grid paginado (sem cache)
```

Domínios disponíveis: `faturamento`, `financeiro`, `estoque`.

---

## Parâmetros Comuns

### Para endpoints `/graph/:metrica`

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `idemp` | integer | ✅ | ID da empresa (emitente) no banco do tenant. Deve pertencer ao tenant do token |
| `periodo` | string | ✅ | Janela de tempo: `S`=Semanal (54 semanas), `M`=Mensal (12 meses), `T`=Trimestral (4 trimestres) |

### Para endpoints `/list/:tipo`

Herda os parâmetros de graph e adiciona paginação:

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `idemp` | integer | ✅ | ID da empresa (emitente) |
| `periodo` | string | ✅ | Janela de tempo: `S`, `M` ou `T` |
| `page` | integer | ❌ | Número da página (mínimo: 1, default: 1) |
| `limit` | integer | ❌ | Itens por página (mínimo: 1, máximo: 200, default: 50) |
| `status` | string | ❌ | Filtro de status (varia por endpoint — detalhado em cada seção) |

---

## Shapes de Resposta

### Gráfico — `ChartDataDto`

Todos os endpoints `/graph/*` retornam este formato:

```jsonc
{
  "chartType": "line",  // hint para o frontend escolher o componente de gráfico
  "labels": ["2026-01", "2026-02", "2026-03"],  // eixo X ou nomes das fatias (pie)
  "series": [
    {
      "name": "Faturamento",
      "data": [15000.00, 22000.00, 18500.00]  // mesmo tamanho que labels
    }
  ]
}
```

**Valores de `chartType`:**

| Valor | Tipo de gráfico sugerido |
|---|---|
| `bar_v` | Barras verticais |
| `bar_h` | Barras horizontais |
| `pie` | Pizza / Rosca |
| `line` | Linha (pode ter múltiplas séries) |

> **Buckets vazios são sempre preenchidos com `0`** — o array `data` sempre tem o mesmo comprimento que `labels`, mesmo que não haja dados no período.

### Grid — `GridResponseDto`

Todos os endpoints `/list/*` retornam este formato:

```jsonc
{
  "total": 142,      // total de registros (para paginação)
  "page": 1,
  "limit": 50,
  "items": [ /* array de objetos do tipo específico */ ]
}
```

---

## Faturamento

Base: `/b3dash/faturamento`

Dados provenientes de notas fiscais emitidas (tabela `fat`) e pedidos (tabela `venda`/`vendaitem`).

---

### `GET /b3dash/faturamento/graph/evolucao`

Evolução do faturamento total ao longo do tempo.

**Chart type:** `line`

**Séries:** 1 — `Total` (soma de `fat.valortotal` por período)

**Resposta `200`:**

```jsonc
{
  "chartType": "line",
  "labels": ["2026-01", "2026-02", "2026-03"],
  "series": [
    { "name": "Total", "data": [120000.00, 98500.00, 145000.00] }
  ]
}
```

---

### `GET /b3dash/faturamento/graph/ticket-medio`

Ticket médio por NF ao longo do tempo.

**Chart type:** `line`

**Séries:** 1 — `Ticket Médio` (média de `fat.valortotal` por período)

**Resposta `200`:** mesmo shape de `evolucao`, com valores de média.

---

### `GET /b3dash/faturamento/graph/top-produtos`

Top 15 produtos por valor faturado no período.

**Chart type:** `bar_h`

**Séries:** 1 — `Valor` (soma do valor por produto)

**Labels:** nomes dos produtos

**Resposta `200`:**

```jsonc
{
  "chartType": "bar_h",
  "labels": ["Produto A", "Produto B", "Produto C"],
  "series": [
    { "name": "Valor", "data": [85000.00, 62000.00, 41000.00] }
  ]
}
```

---

### `GET /b3dash/faturamento/graph/top-clientes`

Top 15 clientes por valor faturado no período.

**Chart type:** `bar_h`

**Séries:** 1 — `Valor`

**Labels:** razões sociais dos clientes

**Resposta `200`:** mesmo shape de `top-produtos`.

---

### `GET /b3dash/faturamento/graph/ranking-vendedores`

Ranking de vendedores por valor faturado no período.

**Chart type:** `bar_v`

**Séries:** 1 — `Valor`

**Labels:** nomes dos vendedores (vendedores sem NF no período aparecem com `0`)

**Resposta `200`:** mesmo shape de `top-produtos`.

---

### `GET /b3dash/faturamento/graph/mix-operacoes`

Distribuição do faturamento por tipo de operação fiscal.

**Chart type:** `pie`

**Séries:** 1 — `Valor`

**Labels:** descrições das operações

**Resposta `200`:**

```jsonc
{
  "chartType": "pie",
  "labels": ["Venda Normal", "Venda ST", "Devolução"],
  "series": [
    { "name": "Valor", "data": [250000.00, 45000.00, 8000.00] }
  ]
}
```

---

### `GET /b3dash/faturamento/list/por-cliente`

Grid de faturamento agrupado por cliente.

**Query extra:** `status` (não aplicável neste endpoint)

**Resposta `200` — cada item:**

```jsonc
{
  "idcnt": 123,
  "razao": "Empresa ABC Ltda",
  "docfed": "12.345.678/0001-90",
  "qtdPedidos": 15,              // Quantidade de NFs no período
  "valorTotal": 85000.00,        // Soma do faturamento
  "ultimoPedidoEm": "2026-04-10T00:00:00.000Z",
  "ticketMedio": 5666.67         // valorTotal / qtdPedidos
}
```

---

### `GET /b3dash/faturamento/list/por-produto`

Grid de faturamento agrupado por produto.

**Resposta `200` — cada item:**

```jsonc
{
  "idprd": 456,
  "codigo": "SKU-001",
  "nome": "Produto XYZ",
  "unidade": "UN",
  "qtdeTotal": 320.000,   // Quantidade total vendida
  "valorTotal": 28768.00,
  "precoMedio": 89.90
}
```

---

### `GET /b3dash/faturamento/list/por-vendedor`

Grid de faturamento agrupado por vendedor.

**Resposta `200` — cada item:**

```jsonc
{
  "idvend": 10,
  "nomeVendedor": "Carlos Silva",
  "qtdPedidos": 42,
  "valorTotal": 187000.00,
  "clientesUnicos": 18,     // Clientes distintos atendidos no período
  "ticketMedio": 4452.38
}
```

---

## Financeiro

Base: `/b3dash/financeiro`

Dados de contas a receber (`ctareceber`), contas a pagar (`ctapag`/`ctapagp`) e movimentos de caixa (`finmov`).

---

### `GET /b3dash/financeiro/graph/receber-vs-pagar`

Comparativo de recebimentos × pagamentos realizados ao longo do tempo.

**Chart type:** `line` com **2 séries**

**Resposta `200`:**

```jsonc
{
  "chartType": "line",
  "labels": ["2026-01", "2026-02", "2026-03"],
  "series": [
    { "name": "Recebimentos", "data": [85000.00, 92000.00, 78000.00] },
    { "name": "Pagamentos",   "data": [62000.00, 71000.00, 68000.00] }
  ]
}
```

---

### `GET /b3dash/financeiro/graph/fluxo-caixa-projetado`

Fluxo de caixa projetado: entradas previstas × saídas previstas (por vencimento).

**Chart type:** `line` com **2 séries**

**Resposta `200`:** mesmo shape de `receber-vs-pagar`, com séries `Entradas Previstas` e `Saídas Previstas`.

---

### `GET /b3dash/financeiro/graph/inadimplencia`

Composição do contas a receber: Recebido × A Vencer × Vencido (snapshot — ignora o parâmetro `periodo`).

**Chart type:** `pie`

**Resposta `200`:**

```jsonc
{
  "chartType": "pie",
  "labels": ["Recebido", "A Vencer", "Vencido"],
  "series": [
    { "name": "Valor", "data": [320000.00, 95000.00, 28000.00] }
  ]
}
```

---

### `GET /b3dash/financeiro/graph/top-inadimplentes`

Top 15 clientes com maior valor vencido (snapshot — ignora `periodo`).

**Chart type:** `bar_h`

**Labels:** razões sociais dos clientes

**Resposta `200`:**

```jsonc
{
  "chartType": "bar_h",
  "labels": ["Cliente A", "Cliente B"],
  "series": [
    { "name": "Vencido", "data": [12500.00, 8300.00] }
  ]
}
```

---

### `GET /b3dash/financeiro/graph/entradas-por-especie`

Composição das entradas de caixa por espécie de recebimento no período.

**Chart type:** `pie`

**Labels:** nomes das espécies (ex: Dinheiro, Cheque, Transferência)

**Resposta `200`:** mesmo shape de `inadimplencia`.

---

### `GET /b3dash/financeiro/graph/saldo-destinos`

Saldo líquido (entradas - saídas) por destino de caixa no período.

**Chart type:** `bar_v`

**Labels:** nomes dos destinos de caixa

**Resposta `200`:**

```jsonc
{
  "chartType": "bar_v",
  "labels": ["Caixa", "Banco A", "Banco B"],
  "series": [
    { "name": "Saldo", "data": [15000.00, 42000.00, -3000.00] }
  ]
}
```

---

### `GET /b3dash/financeiro/list/receber`

Grid de contas a receber.

**Query extra — `status`:**

| Valor | Descrição |
|---|---|
| `pago` | Registros já recebidos |
| `vencido` | Vencimento passado, não pago |
| `aberto` | A vencer, não pago |
| _(omitido)_ | Todos |

**Resposta `200` — cada item:**

```jsonc
{
  "idctarec": 7001,                          // ID do registro (PK da tabela ctareceber)
  "cliente": "Empresa ABC Ltda",
  "emissao": "2026-03-01T00:00:00.000Z",
  "vencimento": "2026-04-01T00:00:00.000Z",
  "pagamento": "2026-04-02T00:00:00.000Z",   // null se não pago
  "valor": 5000.00,                          // Valor original
  "valorpago": 5000.00,                      // Valor efetivamente recebido (0 se não pago)
  "status": "pago"                           // "pago" | "vencido" | "aberto"
}
```

---

### `GET /b3dash/financeiro/list/pagar`

Grid de contas a pagar.

**Query extra — `status`:** mesmos valores de `receber`.

**Resposta `200` — cada item:**

```jsonc
{
  "idpag": 3050,                             // ID do registro (ctapag.id)
  "nrodoc": "NF-001234",                     // Número do documento
  "fornecedor": "Fornecedor XYZ Ltda",
  "emissao": "2026-03-15T00:00:00.000Z",
  "vencimentoMin": "2026-04-15T00:00:00.000Z", // Vencimento da primeira parcela
  "valortotal": 12000.00,                    // Valor total da conta
  "valorPagoAcum": 6000.00,                  // Soma dos pagamentos já realizados
  "status": "aberto"
}
```

---

### `GET /b3dash/financeiro/list/movimentos`

Grid de movimentos de caixa.

**Query extra — `status`:** não aplicável (campo `status` é ignorado neste endpoint).

**Resposta `200` — cada item:**

```jsonc
{
  "idmov": 9001,                           // ID do movimento (finmov.idmov)
  "dataemi": "2026-04-20T00:00:00.000Z",
  "debcred": "C",                          // "C" = crédito/entrada | "D" = débito/saída
  "especie": "Transferência",              // Nome da espécie de recebimento/pagamento
  "destino": "Banco A",                    // Destino de caixa
  "valor": 3500.00,
  "baixado": true,                         // Se o movimento foi baixado/confirmado
  "tborigem": "ctareceber"                 // Tabela que originou o movimento
}
```

---

## Estoque

Base: `/b3dash/estoque`

Dados de movimentos de estoque (`estoque`), saldo atual (`prdsaldo`) e compras (`mov`/`movprd`).

---

### `GET /b3dash/estoque/graph/entradas-vs-saidas`

Evolução de entradas × saídas de estoque (em quantidade) ao longo do tempo.

**Chart type:** `line` com **2 séries**

**Resposta `200`:**

```jsonc
{
  "chartType": "line",
  "labels": ["2026-01", "2026-02", "2026-03"],
  "series": [
    { "name": "Entradas", "data": [850.0, 720.0, 930.0] },
    { "name": "Saídas",   "data": [620.0, 810.0, 700.0] }
  ]
}
```

---

### `GET /b3dash/estoque/graph/top-produtos-comprados`

Top 15 produtos mais comprados por quantidade no período.

**Chart type:** `bar_h`

**Labels:** nomes dos produtos

**Resposta `200`:**

```jsonc
{
  "chartType": "bar_h",
  "labels": ["Produto A", "Produto B"],
  "series": [
    { "name": "Qtde", "data": [1500.0, 980.0] }
  ]
}
```

---

### `GET /b3dash/estoque/graph/top-fornecedores`

Top 15 fornecedores por valor de compras no período.

**Chart type:** `bar_h`

**Labels:** nomes dos fornecedores

**Resposta `200`:** mesmo shape de `top-produtos-comprados`, com valores em R$.

---

### `GET /b3dash/estoque/graph/curva-abc`

Classificação ABC de produtos por participação no valor total de estoque (snapshot — ignora `periodo`).

**Chart type:** `pie`

**Classificação:**
- **A**: produtos que somam até 80% do valor total
- **B**: produtos entre 80% e 95%
- **C**: produtos acima de 95%

**Resposta `200`:**

```jsonc
{
  "chartType": "pie",
  "labels": ["A", "B", "C"],
  "series": [
    { "name": "Valor", "data": [380000.00, 95000.00, 25000.00] }
  ]
}
```

---

### `GET /b3dash/estoque/graph/ruptura`

Produtos com saldo abaixo do estoque mínimo, agrupados por grupo de produto (snapshot — ignora `periodo`).

**Chart type:** `bar_v`

**Labels:** nomes dos grupos de produto

**Resposta `200`:**

```jsonc
{
  "chartType": "bar_v",
  "labels": ["Eletrônicos", "Ferramentas", "Papelaria"],
  "series": [
    { "name": "Qtde em Ruptura", "data": [8, 3, 12] }
  ]
}
```

---

### `GET /b3dash/estoque/graph/valor-por-grupo`

Valor imobilizado em estoque (saldo × custo médio) por grupo de produto (snapshot — ignora `periodo`).

**Chart type:** `pie`

**Labels:** nomes dos grupos

**Resposta `200`:**

```jsonc
{
  "chartType": "pie",
  "labels": ["Eletrônicos", "Ferramentas", "Papelaria"],
  "series": [
    { "name": "Valor", "data": [180000.00, 45000.00, 12000.00] }
  ]
}
```

---

### `GET /b3dash/estoque/list/lancamentos`

Grid de lançamentos de estoque (movimentos diários de entrada e saída).

**Query extra — `status`:**

| Valor | Mapeamento | Descrição |
|---|---|---|
| `entradas` | `tipo = 'E'` | Somente entradas |
| `saidas` | `tipo = 'S'` | Somente saídas |
| _(omitido)_ | `tipo IN ('E','S')` | Todos os lançamentos |

**Resposta `200` — cada item:**

```jsonc
{
  "idmov": 55001,                           // ID do lançamento (estoque.idestoque)
  "dthrestoque": "2026-04-15T10:30:00.000Z",
  "tipo": "E",                              // "E" = entrada | "S" = saída
  "produto": "Produto XYZ",
  "sku": "SKU-001",                         // Código do produto
  "qtde": 50.000,                           // Quantidade movimentada
  "custo": 45.80,                           // Custo unitário no momento do lançamento
  "origem": "movprd"                        // Origem: "vendaitem", "movprd", "estoquek200", etc.
}
```

---

### `GET /b3dash/estoque/list/por-produto`

Grid de posição de estoque por produto (saldo atual).

**Query extra — `apenasRuptura`:**

| Valor | Descrição |
|---|---|
| `true` | Retorna apenas produtos com `saldo < saldomin` (em ruptura) |
| _(omitido ou `false`)_ | Retorna todos os produtos |

> O parâmetro `periodo` é aceito por consistência de interface mas **não filtra** os dados — `prdsaldo` é um snapshot do saldo atual.

**Resposta `200` — cada item:**

```jsonc
{
  "idprd": 456,
  "codigo": "SKU-001",
  "nome": "Produto XYZ",
  "unidade": "UN",
  "saldoatu": 120.000,        // Saldo atual em estoque
  "saldomin": 50.000,         // Estoque mínimo configurado
  "saldomax": 500.000,        // Estoque máximo configurado
  "customedio": 45.80,        // Custo médio atual
  "valorEstoque": 5496.00     // saldoatu × customedio
}
```

---

### `GET /b3dash/estoque/list/por-fornecedor`

Grid de compras agrupadas por fornecedor no período.

**Resposta `200` — cada item:**

```jsonc
{
  "idcnt": 200,
  "razao": "Fornecedor XYZ Ltda",
  "docfed": "98.765.432/0001-10",
  "qtdCompras": 12,                         // Número de ordens de compra no período
  "valorTotal": 145000.00,                  // Soma do valor das compras
  "ultimaCompraEm": "2026-04-18T00:00:00.000Z"
}
```

---

## Tabela Resumo dos Endpoints

### Faturamento

| Endpoint | Tipo | Chart type | Usa `periodo`? |
|---|---|---|---|
| `GET /b3dash/faturamento/graph/evolucao` | Gráfico | `line` | ✅ |
| `GET /b3dash/faturamento/graph/ticket-medio` | Gráfico | `line` | ✅ |
| `GET /b3dash/faturamento/graph/top-produtos` | Gráfico | `bar_h` | ✅ |
| `GET /b3dash/faturamento/graph/top-clientes` | Gráfico | `bar_h` | ✅ |
| `GET /b3dash/faturamento/graph/ranking-vendedores` | Gráfico | `bar_v` | ✅ |
| `GET /b3dash/faturamento/graph/mix-operacoes` | Gráfico | `pie` | ✅ |
| `GET /b3dash/faturamento/list/por-cliente` | Grid | — | ✅ |
| `GET /b3dash/faturamento/list/por-produto` | Grid | — | ✅ |
| `GET /b3dash/faturamento/list/por-vendedor` | Grid | — | ✅ |

### Financeiro

| Endpoint | Tipo | Chart type | Usa `periodo`? |
|---|---|---|---|
| `GET /b3dash/financeiro/graph/receber-vs-pagar` | Gráfico | `line` (2 séries) | ✅ |
| `GET /b3dash/financeiro/graph/fluxo-caixa-projetado` | Gráfico | `line` (2 séries) | ✅ |
| `GET /b3dash/financeiro/graph/inadimplencia` | Gráfico | `pie` | ❌ snapshot |
| `GET /b3dash/financeiro/graph/top-inadimplentes` | Gráfico | `bar_h` | ❌ snapshot |
| `GET /b3dash/financeiro/graph/entradas-por-especie` | Gráfico | `pie` | ✅ |
| `GET /b3dash/financeiro/graph/saldo-destinos` | Gráfico | `bar_v` | ✅ |
| `GET /b3dash/financeiro/list/receber` | Grid | — | ✅ |
| `GET /b3dash/financeiro/list/pagar` | Grid | — | ✅ |
| `GET /b3dash/financeiro/list/movimentos` | Grid | — | ✅ |

### Estoque

| Endpoint | Tipo | Chart type | Usa `periodo`? |
|---|---|---|---|
| `GET /b3dash/estoque/graph/entradas-vs-saidas` | Gráfico | `line` (2 séries) | ✅ |
| `GET /b3dash/estoque/graph/top-produtos-comprados` | Gráfico | `bar_h` | ✅ |
| `GET /b3dash/estoque/graph/top-fornecedores` | Gráfico | `bar_h` | ✅ |
| `GET /b3dash/estoque/graph/curva-abc` | Gráfico | `pie` | ❌ snapshot |
| `GET /b3dash/estoque/graph/ruptura` | Gráfico | `bar_v` | ❌ snapshot |
| `GET /b3dash/estoque/graph/valor-por-grupo` | Gráfico | `pie` | ❌ snapshot |
| `GET /b3dash/estoque/list/lancamentos` | Grid | — | ✅ |
| `GET /b3dash/estoque/list/por-produto` | Grid | — | ❌ snapshot |
| `GET /b3dash/estoque/list/por-fornecedor` | Grid | — | ✅ |

> **"snapshot"** = endpoint retorna posição atual, independente do período informado. O parâmetro `periodo` ainda deve ser enviado (validação) mas não afeta o resultado.
