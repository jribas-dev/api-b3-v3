# b3vendas

Domínio de **gestão de vendas** sobre o banco do tenant. O módulo cobre todo o ciclo de um pedido — cadastro/seleção de cliente, montagem de itens com preço e impostos, fechamento com forma de pagamento — além da gestão da equipe de vendas e indicadores de desempenho.

> Todas as queries deste módulo executam no banco do tenant resolvido pelo [`TenantModule`](../tenant/CLAUDE.md). Schema completo das 253 tabelas em **[agent_docs/tenant_schema.md](../../agent_docs/tenant_schema.md)**. Contrato HTTP (DTOs, exemplos de payload) em **[agent_docs/api-b3vendas.md](../../agent_docs/api-b3vendas.md)**.

## Estrutura Interna

```
src/b3vendas/
├── b3vendas.module.ts              # Importa todos os sub-módulos
├── shared/                         # SellerContext + DecimalTransformer (re-exporta TenantModule)
├── cliente/                        # CRUD de clientes (cnt) e tabela de preços
├── operacao/                       # Operações fiscais permitidas por empresa (operacoes)
├── produto/                        # Catálogo, busca, preço por cliente, cálculo de impostos
│   └── tax-calculator.service.ts   # Lógica pura de IPI / ICMS-ST (sem banco)
├── formas-pagamento/               # formapg + condpg (sem controller próprio)
├── venda/                          # Pedido/venda mestre (venda + vendacaixa)
├── venda-item/                     # Itens do pedido (vendaitem)
├── equipe/                         # Equipe de vendas (cntequipe)
└── metricas/                       # Indicadores agregados (read-only)
```

## Convenções do Módulo

| Convenção | Detalhe |
|---|---|
| **IDs numéricos** | Todas as entities usam IDs `int`/`smallint` legados — **não** CUID2 como no banco principal. |
| **`DecimalTransformer`** | Todo campo `DECIMAL` deve usar `transformer: DecimalTransformer` (em `shared/`) para converter `string` (padrão TypeORM) ⇄ `number`. |
| **`synchronize: false`** | Schema do tenant não é gerenciado pelo TypeORM — DDL governado por scripts versionados. |
| **Queries raw vs. repositório** | Quando há agregação, função SQL (`format_docfed`, `YEARWEEK`) ou JOIN sem entity dedicada, usa-se `ds.query()` com placeholders posicionais; caso contrário, repositório TypeORM. |
| **Função SQL `format_docfed`** | Função armazenada no tenant que formata CNPJ/CPF — usada em vários SELECTs (cliente, métricas). |
| **Filtragem por vendedor** | Toda lista filtra por `idvend = vendId` (vendas) ou `idvende = vendId` (clientes). Isolamento é tenant + vendedor. |

## SellerContextService

`shared/seller-context.service.ts`. Resolve o **vendedor** vinculado ao usuário autenticado. Toda operação tenant-scoped começa por aqui.

```ts
const { usuId, vendId } = await sellerContext.resolve(dbId, userId);
```

| Campo | Tipo | Origem | Uso |
|---|---|---|---|
| `usuId` | `number` | `usu.id` (resolvido por `usu.userId = ?`) | `venda.ultimousu` ao gravar pedido |
| `vendId` | `number` | `usu.idvend` | Filtro padrão de visibilidade (`venda.idvend`, `cnt.idvende`) |

Lança `403 Forbidden` se o usuário não tiver `usu.idvend` no tenant. **`idemp` saiu do contexto** — o frontend é obrigado a enviar em cada request, permitindo um único usuário operar em várias empresas sem trocar token.

## Tabelas e Relacionamentos

Tabelas usadas pelo módulo (ver seção indicada em `tenant_schema.md`):

| Tabela | Seção | Papel |
|---|---|---|
| `cnt` | §2 | Pessoas/contatos: clientes, vendedores, empresas, comissionados |
| `cntclass` / `cntclasses` | §2 | Catálogo + N:N de tipos de pessoa |
| `cntequipe` | §2 | `idcntlider` × `idcntliderado` (sem entity) |
| `usu` | §1 | Usuário do tenant — resolução `userId → usu → vendedor` |
| `operacoes` | §4 | Operações fiscais |
| `formapg` / `condpg` | §4 | Formas e condições de pagamento |
| `prd` | §5 | Produtos |
| `prdtab` / `prdtabvalor` | §5 | Tabelas de preço (vínculo `cnt.idtab`) |
| `prdimposto` | §5 | Produto × operação × imposto |
| `impostos` | §5 | Regras de tributação (ICMS, IVA, redução, IPI) |
| `venda` | §3 | Pedido / venda mestre |
| `vendaitem` | §3 | Itens do pedido |
| `vendacaixa` | §3 | Pagamento do pedido |
| `cfg` | §21 | Parâmetros dinâmicos (ex.: `VWEBOPERCOND`) |

```
cnt(cliente) ── cnt.idtab → prdtab → prdtabvalor (preço da tabela do cliente)
cnt(cliente) ── cnt.idforma → formapg          (forma padrão)
cnt(cliente) ── cnt.idcond  → condpg           (condição padrão)
cnt(vendedor) ─ cnt.idcomi  → cnt(comissionado)
prd ── prdimposto(idoper) → impostos           (regra fiscal por produto+operação)
operacoes ←── venda.idoper / prdimposto.idoperacao
venda → vendaitem → prd
venda → vendacaixa → formapg / condpg
```

## Tipos de Pessoa (`cnt` + `cntclass` / `cntclasses`)

`cnt` é a entidade forte de **todos** os contatos. O tipo é resolvido por:

- **`cntclass`** — catálogo (uma coluna booleana por tipo): `ativo` (Cliente), `passivo` (Fornecedor), `emitente` (Empresa), `comissionado` (Vendedor), `colaborador` (Funcionário), `logistica` (Transportadora).
- **`cntclasses`** — junção N:N (`idcnt`, `idclass`).

Para filtrar por tipo, sempre use o JOIN duplo:

```sql
INNER JOIN cntclasses cc ON cc.idcnt = c.id
INNER JOIN cntclass   cl ON cl.id = cc.idclass AND cl.<tipo>
```

Tipos efetivamente referenciados neste módulo:

| Coluna | Significado | Onde |
|---|---|---|
| `ativo` | Cliente | `cliente/buscar`, métricas |
| `comissionado` | Vendedor | `equipe/sem-equipe`, `seller-context` (via `usu.idvend`) |
| `emitente` | Empresa | resolução de `idemp` (módulo de tenant) |

**Vínculos importantes:**

- **Vendedor ↔ Sistema:** quando um `cnt` é `comissionado` e está vinculado a `usu`, o vendedor pode acessar a API. JWT carrega `userId`; o `SellerContext` resolve `userId → usu.idvend → cnt`.
- **Cliente ↔ Vendedor:** `cnt.idvende` aponta para o vendedor responsável. Toda visibilidade (busca, rede-sp, métricas, alteração) filtra por `cnt.idvende = vendId`.

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

`TaxCalculatorService` (`produto/tax-calculator.service.ts`) é puro — sem injeção de banco. Recebe `subtotal` + `TaxRule` (`{ icmsaliq, icmsredu, icmsiva, ipialiq }`) extraída por `ProdutoService.buscarRegraImposto` da junção `prdimposto → impostos`.

```ts
calc(subtotal, rule) → { ipi, st, total }
```

Regras:

- **Sem regra (`rule == null`)** → `{ ipi: 0, st: 0, total: round(subtotal) }`.
- **`ipialiq <= 0`** → IPI = 0.
- **`icmsiva <= 0`** → ST = 0.

Endpoint público: `POST /produtos/:id/calc-imposto` (body `{ subtotal, idOper }`) → `{ ipi, st, total }`. Use **antes** de `POST /pedidos/:id/itens` para preencher `vST` e `vIPI` do item.

## Fórmula de Totais — `recalcTotals`

Disparada após cada `POST` ou `DELETE` de item (`VendaItemService`). Executa duas atualizações em sequência sobre `venda` (sem transação explícita):

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

## Sub-módulos

### `cliente/` — CRUD e catálogo

| Endpoint | Roles | Comentários |
|---|---|---|
| `GET /clientes/buscar?q=` | qualquer (JwtGuard+UserInstance) | mín. 2 caracteres; LIKE em `UPPER(razao)`, `docfed`, `id`. Filtro: `cntclass.ativo`, `cnt.ativo`, `cnt.idvende = vendId`. **Inclui sempre `OR id = 99`** (Consumidor Final). Limite 50, distinct, order by razao. |
| `GET /clientes/rede-sp` | SUPERSALER/SALER | Raw SQL: clientes ativos com `idtab IS NOT NULL` e `(uf='SP' OR uf IS NULL)` do vendedor. |
| `GET /clientes/tabela?idOper=&idCli=` | SUPERSALER/SALER | Catálogo com preço (da tabela do cliente) + IPI/ST pré-calculados em SQL. **`INNER JOIN prdtabvalor`** — só produtos da tabela do cliente entram. Filtros: `prd.ativo`, `prd.podevender`, `NOT prd.servico`, `prdtabvalor.valor > 0`. `operacoes.finalidade IN ('C','R','I')`; `finalidade='C'` zera `ivast` e `vicmsst`. |
| `GET /clientes/:id` | qualquer | `findOneOrFail` com `addSelect('format_docfed(c.docfed) AS c_docformatado')`. Retorna 404 se não encontrado ou inativo. |
| `POST /clientes` | SUPERSALER | `idvende` default = vendedor logado; `ativo = true`. **Não valida unicidade de `docfed`.** |
| `PATCH /clientes/:id` | SUPERSALER | `assertVinculoVendedor` — apenas o vendedor de `cnt.idvende` pode alterar. Atualização campo a campo. |
| `DELETE /clientes/:id` | SUPERSALER | **Hard delete** (`repo.remove`). Não exige vínculo do vendedor. |

### `operacao/` — operações fiscais permitidas

`OperacaoService.listarPermitidas(dbId, userId, idemp)` aplica três filtros:

1. `o.saidaentrada = '1'` (apenas operações de **saída**).
2. `o.<filtro do `cfg.VWEBOPERCOND`>` — cláusula SQL adicional configurável por tenant via `CfgService` (sem aspas/saneamento — é uma string interpolada literal).
3. `o.idemp IS NULL OR o.idemp = 0 OR o.idemp = :idemp` (operações globais ou específicas da empresa).

Order by `operacao ASC`. Retorna `{ id, operacao, subtipo, cfopnormal, cfopst }`.

### `produto/` — busca, preço, impostos

- `GET /produtos/buscar?q=` — se `q` é só dígitos, busca por `id` exato; senão `UPPER(nome) LIKE`. Filtros fixos: `NOT consumo`, `ativo`, `podevender`, `(acabado OR revenda)`. Limite 50.
- `GET /produtos/:id/preco?idCli=&idOper=` — ver "Pricing" acima.
- `POST /produtos/:id/calc-imposto` — ver "Cálculo de Impostos" acima.

### `formas-pagamento/` — sem controller próprio

Service consumido por `VendaController` (`/pedidos/:id/formas-disponiveis` e `.../condicoes-disponiveis`). A lista é a **união**:

- Forma/condição padrão do cliente (`cnt.idforma`, `cnt.idcond`).
- Histórico: formas/condições já usadas em vendas anteriores do mesmo cliente (via `vendacaixa`).

`operacaoDaForma(idForma)` retorna `formapg.operacao` (char 1) — gravado em `vendacaixa.operacao` no fechamento.

### `venda/` — pedido mestre

| Operação | Detalhes |
|---|---|
| `POST /pedidos` | Cria com `idvend = vendId`, `ultimousu = usuId`, `idcomi = cnt[id=vendId].idcomi`, `plataforma = 'SALESFORCE'`, `processo = 'B3PED.exe'`, `subtipo = operacoes[idOper].subtipo` (ou `'N'`), `tipo = dto.rctipo`, `fiscal = dto.rcfat`. **Não força `tipo='O'`** — depende do `rctipo` enviado. |
| `GET /pedidos/editaveis` | `tipo='O'`, `idvend=vendId`, `idemp`, `dthremissao` nos últimos 5 dias. |
| `GET /pedidos/fechados` | `tipo IN ('P','V')`, mesmas chaves, últimos 30 dias. |
| `GET /pedidos/:id` | `loadVendaVinculada` (404 se não existir, 403 se outro vendedor). Devolve venda + itens (com nome do produto) + cliente completo (incluindo `format_docfed`) + `idForma`/`idCond` do `vendacaixa`. |
| `POST /pedidos/:id/fechar` | Exige `tipo='O'`. Em transação: `DELETE FROM vendacaixa WHERE idvenda=?` → `INSERT vendacaixa (seq=1, valor=vlrtotal, idforma, idcond, operacao=formapg.operacao, baixado=1)`. Atualiza `obsinter` se enviado. **Não altera `venda.tipo`**. |
| Get formas/condições | Delega para `FormasPagamentoService` usando o `idcli` do pedido. Retorna `[]` se a venda não tem cliente. |

### `venda-item/` — itens

- `POST /pedidos/:id/itens` — `assertEditavel` (`tipo='O'`); calcula `seq = MAX(seq)+1`; insere com `bruto = total = qtde * vunit`, `desconto = 0`, `acrescimo = 0`, `st = vST`, `ipi = vIPI`, `vlrtab = tabela`, `obsprd = trim(obsprod) || null`. Dispara `recalcTotals`.
- `DELETE /pedidos/:id/itens/:seq` — `assertEditavel`; `delete({ idvenda, seq })`; 404 se nada apagado; recalcula totais.

### `equipe/` — gestão da equipe de vendas

`cntequipe` tem PK composta `(idcntlider, idcntliderado)`, ambos FK para `cnt.id` com `ON DELETE CASCADE`. **Sem entity** — todas as operações usam `ds.query()`.

| Endpoint | Role | Comportamento |
|---|---|---|
| `GET /equipe` | SUPERSALER ou SALER | SUPERSALER: `UNION ALL` de (próprio cnt, `liderado=0`) + (subordinados via `cntequipe.idcntlider = vendId`, `liderado=1`); order `liderado ASC, razao ASC`. SALER: somente o próprio. Outros: `403`. |
| `GET /equipe/sem-equipe` | SUPERSALER | `cnt JOIN cntclasses+cntclass.comissionado` onde `c.id != vendId` e `NOT EXISTS` em `cntequipe.idcntliderado`. Order by `razao ASC`. |
| `POST /equipe` | SUPERSALER | `idcntliderado != vendId`; verifica duplicidade (`409`); `INSERT cntequipe(vendId, idcntliderado)`. |
| `DELETE /equipe/:id` | SUPERSALER | `DELETE WHERE idcntlider=vendId AND idcntliderado=:id`; `404` se nada afetado. |

> Na prática um usuário não tem ambos `SUPERSALER` e `SALER` — a regra é validada em `assertRoleFrontConsistent` no `BeforeInsert/Update` de `UserInstanceEntity`. O service revalida defensivamente via `RoleFrontGuard`.

### `metricas/` — indicadores read-only

Controller aplica `@RolesFront(SUPERSALER, SALER)` no nível da classe. Todos os endpoints recebem `QueryMetricasDto` via `@Query()`: `idemp` (obrigatório), `idvende` (obrigatório), `join` (opcional, só SUPERSALER).

`MetricasService.resolveScope` executa três checagens antes de montar `vendIds`:

1. **Acesso à empresa:** `userId → usu → usuemp` — `ForbiddenException` se `idemp` não autorizado.
2. **Acesso ao vendedor:** se `idvende ≠ vendId_logado` → exige SUPERSALER + `idvende` em `cntequipe` como subordinado.
3. **`join=true`:** exclusivo de SUPERSALER; expande escopo para `[vendId_logado, ...subordinados]`. SALER com `join=true` recebe `403`.

`vendIds` resultante:
- `join=true` (supersaler): `[vendId_logado, ...subordinados]` — deduplicado em `Set`.
- caso contrário: `[idvende]`.

`vendIds` é interpolado nas queries via `IN (?, ?, ...)` com placeholders gerados por `vendIds.map(() => '?').join(',')`. O filtro `v.idemp = ?` é adicionado a **todas** as queries.

**Filtro padrão de venda considerada** (gráficos 1, 2, 3):

```sql
v.tipo = 'V' AND v.subtipo = 'N' AND v.baixado = 1
```

| Endpoint | Tipo | Janela | Detalhe |
|---|---|---|---|
| `vendas-semanais` | `line` (12 buckets) | 12 semanas ISO | `GROUP BY YEARWEEK(dthremissao, 1)`. Labels (`YYYY-Www`) geradas em TS via `last12WeekLabels` + `fillSeries` para preencher zeros. |
| `vendas-mensais` | `line` (12 buckets) | 12 meses | `GROUP BY DATE_FORMAT(dthremissao, '%Y-%m')`. Idem para preenchimento. |
| `top-clientes-ativos` | `bar_h` | 90 dias | `JOIN cnt`, `GROUP BY c.id, c.razao, c.fantasia`, `ORDER BY valor DESC LIMIT 15`. Duas séries: `Valor (R$)` e `Pedidos`. Label = `COALESCE(fantasia, razao)`. |
| `clientes-inativos` | listagem | 60 dias | **Não aplica** o filtro padrão. Filtra `c.ativo`, `c.idvende IN (vendIds)`, `NOT EXISTS venda (com idemp) nos últimos 60 dias`. Inclui clientes que nunca venderam. Subquery `(SELECT MAX(v2.dthremissao) FROM venda v2 WHERE v2.idcli = c.id AND v2.idemp = ?)` produz `ultimaVenda` filtrada por empresa. |

`ChartDataDto` é local ao módulo (não compartilha com `b3dash`):

```ts
type ChartType = 'bar_v' | 'bar_h' | 'pie' | 'line';
class ChartDataDto {
  chartType: ChartType;
  labels: string[];
  series: { name: string; data: number[] }[];
}
```

## Entities (resumo)

| Entity | Tabela | PK | DTOs principais |
|---|---|---|---|
| `ClienteEntity` | `cnt` | `id` int unsigned | Create/Update + `ResponseClienteInfo`, `ResponseClienteBusca`, `ResponseClienteRedeSp`, `ResponseClienteTabela` |
| `OperacaoEntity` | `operacoes` | `id` smallint unsigned | `ResponseOperacao`, `ListOperacoesQuery` |
| `ProdutoEntity` | `prd` | `id` int | `ResponseProdutoBusca`, `ResponsePreco`, `ResponseImposto`, `CalcImposto` |
| `ImpostoEntity` | `impostos` | `id` int | (sem DTO — leitura interna) |
| `ProdutoImpostoEntity` | `prdimposto` | `(idprd, idoperacao, idimposto)` | (sem DTO) |
| `ProdutoTabValorEntity` | `prdtabvalor` | `(idtab, idprod)` | (sem DTO) |
| `FormaPagamentoEntity` | `formapg` | `id` smallint unsigned | `ResponseForma` (compartilhado com condições) |
| `CondicaoPagamentoEntity` | `condpg` | `idcond` smallint unsigned | `ResponseForma` |
| `VendaEntity` | `venda` | `id` int unsigned | Create/Fechar + `ResponseVendaResumo`, `ResponseVendaDetalhe`, `ResponseVendaItem`, `ListVendasQuery` |
| `VendaCaixaEntity` | `vendacaixa` | `(idvenda, idforma, seq)` | (sem DTO) |
| `VendaItemEntity` | `vendaitem` | `(idvenda, seq)` | `CreateVendaItem` |
| (sem entity) | `cntequipe` | `(idcntlider, idcntliderado)` | `ResponseEquipe`, `CreateEquipe` |

`ClienteEntity.docformatado` é uma coluna virtual (`select: false, insert: false, update: false`) populada por `addSelect('format_docfed(c.docfed)')` em `findOneOrFail`.

## Endpoints (Catálogo Consolidado)

| Método | Rota | Roles | Sumário |
|---|---|---|---|
| GET | `/b3vendas/clientes/buscar?q=` | qualquer | Autocomplete de cliente |
| GET | `/b3vendas/clientes/rede-sp` | SUPERSALER/SALER | Clientes do vendedor com tabela em SP/sem UF |
| GET | `/b3vendas/clientes/tabela?idOper=&idCli=` | SUPERSALER/SALER | Catálogo com preço+impostos pré-calculados |
| GET | `/b3vendas/clientes/:id` | qualquer | Detalhe |
| POST | `/b3vendas/clientes` | SUPERSALER | Criar |
| PATCH | `/b3vendas/clientes/:id` | SUPERSALER | Atualizar (vendedor vinculado) |
| DELETE | `/b3vendas/clientes/:id` | SUPERSALER | Hard delete |
| GET | `/b3vendas/equipe` | SUPERSALER/SALER | Equipe (própria ou completa) |
| GET | `/b3vendas/equipe/sem-equipe` | SUPERSALER | Vendedores comissionados sem equipe |
| POST | `/b3vendas/equipe` | SUPERSALER | Adicionar liderado |
| DELETE | `/b3vendas/equipe/:id` | SUPERSALER | Remover liderado |
| GET | `/b3vendas/operacoes?idemp=` | qualquer | Operações fiscais permitidas |
| GET | `/b3vendas/produtos/buscar?q=` | qualquer | Autocomplete de produto |
| GET | `/b3vendas/produtos/:id/preco?idCli=&idOper=` | qualquer | Preço unitário + CFOP + custo |
| POST | `/b3vendas/produtos/:id/calc-imposto` | qualquer | Calcular IPI/ST |
| POST | `/b3vendas/pedidos` | qualquer | Criar venda (`idemp` obrigatório) |
| GET | `/b3vendas/pedidos/editaveis?idemp=` | qualquer | Tipo `'O'`, últimos 5 dias |
| GET | `/b3vendas/pedidos/fechados?idemp=` | qualquer | Tipo `'P'`/`'V'`, últimos 30 dias |
| GET | `/b3vendas/pedidos/:id` | qualquer | Detalhe + itens + cliente + pagamento |
| GET | `/b3vendas/pedidos/:id/formas-disponiveis` | qualquer | União padrão + histórico |
| GET | `/b3vendas/pedidos/:id/condicoes-disponiveis` | qualquer | União padrão + histórico |
| POST | `/b3vendas/pedidos/:id/fechar` | qualquer | Registra pagamento (não muda `tipo`) |
| POST | `/b3vendas/pedidos/:id/itens` | qualquer | Adicionar item + recalc |
| DELETE | `/b3vendas/pedidos/:id/itens/:seq` | qualquer | Remover item + recalc |
| GET | `/b3vendas/metricas/vendas-semanais?idemp=&idvende=[&join=]` | SUPERSALER/SALER | Gráfico line — 12 semanas ISO |
| GET | `/b3vendas/metricas/vendas-mensais?idemp=&idvende=[&join=]` | SUPERSALER/SALER | Gráfico line — 12 meses |
| GET | `/b3vendas/metricas/top-clientes-ativos?idemp=&idvende=[&join=]` | SUPERSALER/SALER | Gráfico bar_h — top 15 / 90d |
| GET | `/b3vendas/metricas/clientes-inativos?idemp=&idvende=[&join=]` | SUPERSALER/SALER | Listagem — sem venda nos últimos 60d |

## Guards Aplicados

Todo controller usa `JwtGuard + UserInstanceGuard` (token de etapa 2 obrigatório, com `dbId` no payload).

- `@RolesFront(SUPERSALER)` — escrita em clientes (`POST/PATCH/DELETE`); gestão de equipe (`POST/DELETE/sem-equipe`).
- `@RolesFront(SUPERSALER, SALER)` — `clientes/rede-sp`, `clientes/tabela`, `equipe` (GET), todas as 4 rotas de `metricas`.
- Sem `@RolesFront` (apenas Jwt+UserInstance) — `operacoes`, `produtos/*`, `pedidos/*`, `pedidos/:id/itens/*`, `clientes/buscar`, `clientes/:id` (detalhe).

## Decisões de Design Importantes

| Decisão | Motivo |
|---|---|
| `idemp` fora do contexto, no body | Permite alternar entre empresas sem renovar o token. |
| Hard delete em `cliente` | Compatível com a UI legada; integridade preservada por FKs do banco. |
| `id = 99` sempre incluído na busca de cliente | "Consumidor Final" — disponível para qualquer vendedor. |
| `recalcTotals` em duas queries (sem transação) | Performance; risco de inconsistência aceitável (writer único por venda). |
| Sem entity para `cntequipe` | Tabela puramente associativa — operações sempre raw SQL. |
| `ChartDataDto` duplicado em `b3vendas` e `b3dash` | Evitar dependência cruzada entre módulos. |
| `cfg.VWEBOPERCOND` interpolado direto em SQL | Configuração por deployment; valor é confiado (banco do tenant). |
