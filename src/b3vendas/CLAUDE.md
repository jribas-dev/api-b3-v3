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
├── formas-pagamento/               # formapg + condpg (sem controller próprio)
├── venda/                          # Pedido/venda mestre (venda + vendacaixa)
├── venda-item/                     # Itens do pedido (vendaitem)
├── equipe/                         # Equipe de vendas (cntequipe)
└── metricas/                       # Indicadores agregados (read-only)
```

## Sub-módulos

| Sub-módulo | Responsabilidade | Documentação |
|---|---|---|
| `cliente` | CRUD de clientes (`cnt`), busca, catálogo com tabela de preços | [cliente/CLAUDE.md](cliente/CLAUDE.md) |
| `operacao` | Operações fiscais permitidas por empresa (`operacoes`) | [operacao/CLAUDE.md](operacao/CLAUDE.md) |
| `produto` | Catálogo, busca, pricing (CFOP + valor) e cálculo de impostos (IPI/ST) | [produto/CLAUDE.md](produto/CLAUDE.md) |
| `formas-pagamento` | `formapg` + `condpg`, união padrão + histórico (sem controller próprio) | [formas-pagamento/CLAUDE.md](formas-pagamento/CLAUDE.md) |
| `venda` | Pedido/venda mestre, estados (`tipo`/`subtipo`/`fiscal`), `recalcTotals` | [venda/CLAUDE.md](venda/CLAUDE.md) |
| `venda-item` | Itens do pedido (`vendaitem`), gatilho de recálculo | [venda-item/CLAUDE.md](venda-item/CLAUDE.md) |
| `equipe` | Equipe de vendas (`cntequipe`) — sem entity, raw SQL | [equipe/CLAUDE.md](equipe/CLAUDE.md) |
| `metricas` | Indicadores agregados read-only (4 endpoints) | [metricas/CLAUDE.md](metricas/CLAUDE.md) |

`shared/` permanece documentado **apenas neste arquivo** (ver "SellerContextService" abaixo).

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

## Tabelas e Relacionamentos (visão geral)

| Tabela | Seção | Papel | Sub-módulo principal |
|---|---|---|---|
| `cnt` | §2 | Pessoas/contatos: clientes, vendedores, empresas, comissionados | `cliente`, `equipe` |
| `cntclass` / `cntclasses` | §2 | Catálogo + N:N de tipos de pessoa | (transversal) |
| `cntequipe` | §2 | `idcntlider` × `idcntliderado` (sem entity) | `equipe` |
| `usu` | §1 | Usuário do tenant — resolução `userId → usu → vendedor` | `shared` |
| `operacoes` | §4 | Operações fiscais | `operacao` |
| `formapg` / `condpg` | §4 | Formas e condições de pagamento | `formas-pagamento` |
| `prd` | §5 | Produtos | `produto` |
| `prdtab` / `prdtabvalor` | §5 | Tabelas de preço (vínculo `cnt.idtab`) | `produto`, `cliente` |
| `prdimposto` | §5 | Produto × operação × imposto | `produto` |
| `impostos` | §5 | Regras de tributação (ICMS, IVA, redução, IPI) | `produto` |
| `venda` | §3 | Pedido / venda mestre | `venda` |
| `vendaitem` | §3 | Itens do pedido | `venda-item` |
| `vendacaixa` | §3 | Pagamento do pedido | `venda`, `formas-pagamento` |
| `cfg` | §21 | Parâmetros dinâmicos (ex.: `VWEBOPERCOND`) | `operacao` |

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

## Endpoints (catálogo consolidado)

| Método | Rota | Roles | Sub-módulo |
|---|---|---|---|
| GET | `/b3vendas/clientes/buscar?q=` | qualquer | [cliente](cliente/CLAUDE.md) |
| GET | `/b3vendas/clientes/rede-sp` | SUPERSALER/SALER | [cliente](cliente/CLAUDE.md) |
| GET | `/b3vendas/clientes/tabela?idOper=&idCli=` | SUPERSALER/SALER | [cliente](cliente/CLAUDE.md) |
| GET | `/b3vendas/clientes/:id` | qualquer | [cliente](cliente/CLAUDE.md) |
| POST | `/b3vendas/clientes` | SUPERSALER | [cliente](cliente/CLAUDE.md) |
| PATCH | `/b3vendas/clientes/:id` | SUPERSALER | [cliente](cliente/CLAUDE.md) |
| DELETE | `/b3vendas/clientes/:id` | SUPERSALER | [cliente](cliente/CLAUDE.md) |
| GET | `/b3vendas/equipe` | SUPERSALER/SALER | [equipe](equipe/CLAUDE.md) |
| GET | `/b3vendas/equipe/sem-equipe` | SUPERSALER | [equipe](equipe/CLAUDE.md) |
| POST | `/b3vendas/equipe` | SUPERSALER | [equipe](equipe/CLAUDE.md) |
| DELETE | `/b3vendas/equipe/:id` | SUPERSALER | [equipe](equipe/CLAUDE.md) |
| GET | `/b3vendas/operacoes?idemp=` | qualquer | [operacao](operacao/CLAUDE.md) |
| GET | `/b3vendas/produtos/buscar?q=` | qualquer | [produto](produto/CLAUDE.md) |
| GET | `/b3vendas/produtos/:id/preco?idCli=&idOper=` | qualquer | [produto](produto/CLAUDE.md) |
| POST | `/b3vendas/produtos/:id/calc-imposto` | qualquer | [produto](produto/CLAUDE.md) |
| POST | `/b3vendas/pedidos` | qualquer | [venda](venda/CLAUDE.md) |
| GET | `/b3vendas/pedidos/editaveis?idemp=` | qualquer | [venda](venda/CLAUDE.md) |
| GET | `/b3vendas/pedidos/fechados?idemp=` | qualquer | [venda](venda/CLAUDE.md) |
| GET | `/b3vendas/pedidos/:id` | qualquer | [venda](venda/CLAUDE.md) |
| GET | `/b3vendas/pedidos/:id/formas-disponiveis` | qualquer | [formas-pagamento](formas-pagamento/CLAUDE.md) |
| GET | `/b3vendas/pedidos/:id/condicoes-disponiveis` | qualquer | [formas-pagamento](formas-pagamento/CLAUDE.md) |
| POST | `/b3vendas/pedidos/:id/fechar` | qualquer | [venda](venda/CLAUDE.md) |
| POST | `/b3vendas/pedidos/:id/itens` | qualquer | [venda-item](venda-item/CLAUDE.md) |
| DELETE | `/b3vendas/pedidos/:id/itens/:seq` | qualquer | [venda-item](venda-item/CLAUDE.md) |
| GET | `/b3vendas/metricas/vendas-semanais?idemp=&idvende=[&join=]` | SUPERSALER/SALER | [metricas](metricas/CLAUDE.md) |
| GET | `/b3vendas/metricas/vendas-mensais?idemp=&idvende=[&join=]` | SUPERSALER/SALER | [metricas](metricas/CLAUDE.md) |
| GET | `/b3vendas/metricas/top-clientes-ativos?idemp=&idvende=[&join=]` | SUPERSALER/SALER | [metricas](metricas/CLAUDE.md) |
| GET | `/b3vendas/metricas/clientes-inativos?idemp=&idvende=[&join=]` | SUPERSALER/SALER | [metricas](metricas/CLAUDE.md) |

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
