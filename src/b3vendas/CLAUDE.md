# b3vendas

Módulo de domínio para **gestão de vendas** no banco de dados do tenant. Implementa um ciclo completo de pedido: criação → inclusão de itens → fechamento com forma de pagamento.

## Estrutura Interna

```
src/b3vendas/
├── b3vendas.module.ts          # Módulo raiz — importa todos os sub-módulos
├── shared/
│   ├── shared.module.ts        # Re-exporta TenantModule + SellerContextService
│   ├── seller-context.service.ts  # Resolve usuário → vendedor/empresa no tenant
│   └── decimal.transformer.ts  # ValueTransformer TypeORM para campos DECIMAL
├── cliente/                    # CRUD de clientes (tabela cnt)
├── operacao/                   # Tipos de operação fiscal (tabela operacoes)
├── produto/                    # Catálogo, preços e cálculo de impostos
│   └── tax-calculator.service.ts  # Lógica pura de cálculo IPI/ST
├── formas-pagamento/           # Formas e condições de pagamento (formapg, condpg)
├── venda/                      # Pedidos/vendas (tabela venda)
├── venda-item/                 # Itens do pedido (tabela vendaitem)
├── equipe/                     # Equipe de vendas (tabela cntequipe)
└── metricas/                   # Indicadores de desempenho do vendedor
```

> **Atenção:** As entities deste módulo usam IDs numéricos inteiros (legado), **não** CUID2 como nas demais entities da aplicação.

## SellerContextService — Contexto do Vendedor

Serviço central de `shared/`. Todo endpoint do módulo chama `sellerContext.resolve(dbId, userId)` para obter:

| Campo | Tipo | Descrição |
|---|---|---|
| `usuId` | number | ID do registro `usu` no tenant |
| `vendId` | number | ID do vendedor vinculado ao usuário |

Lança `ForbiddenException` se o usuário não estiver vinculado a um vendedor no tenant. Todas as queries subsequentes filtram por `idvend = vendId` para isolamento multi-tenant.

> **`idemp` não está mais no contexto do vendedor.** O frontend deve informar `idemp` obrigatoriamente em cada request. Isso permite que um mesmo usuário opere em diferentes empresas sem troca de token.

## DecimalTransformer

`shared/decimal.transformer.ts` — TypeORM converte colunas `DECIMAL` do banco para `string` no JS. O transformer aplica `parseFloat()` na leitura. Deve ser aplicado em **todos** os campos decimais das entities deste módulo (`custo`, `venda`, `qtde`, `vlrtotal`, etc.).

## Tabelas e Relacionamentos

> Esquema completo do banco do tenant (253 tabelas, versão 2.38) documentado em **[agent_docs/tenant_schema.md](../../../agent_docs/tenant_schema.md)**.

Tabelas usadas por este módulo (seções relevantes no schema doc):

| Tabela | Seção no schema | Papel |
|---|---|---|
| `cnt` | §2 Clientes e Contatos | Clientes, vendedores, empresas |
| `cntequipe` | §2 Clientes e Contatos | Relação líder (supervisor) × liderado (vendedor) |
| `operacoes` | §4 Operações Fiscais | Tipo de operação fiscal da venda |
| `formapg` | §4 Operações Fiscais | Formas de pagamento |
| `condpg` | §4 Operações Fiscais | Condições de pagamento |
| `prd` | §5 Produtos | Catálogo de produtos |
| `prdtab` / `prdtabvalor` | §5 Produtos | Tabelas e preços por cliente |
| `prdimposto` | §5 Produtos | Produto × imposto × operação |
| `impostos` | §5 Produtos | Regras de tributação (IPI, ST, ICMS) |
| `venda` | §3 Vendas | Pedidos/vendas |
| `vendaitem` | §3 Vendas | Itens do pedido |
| `vendacaixa` | §3 Vendas | Pagamento da venda |
| `usu` | §1 Core | Usuário do tenant (resolução de vendedor) |
| `cfg` | §21 Configuração | Parâmetros dinâmicos (`VWEBOPERCOND`, `VERSAO_DB`) |

```
cnt (cliente) ──── cnt.idtab → prdtab → prdtabvalor (preço por tabela)
operacoes ←── venda.idoper / prdimposto.idoperacao
prd ──── prdimposto → impostos
venda ──── vendaitem → prd
      └─── vendacaixa → formapg / condpg
```

## Tipos de Pessoa (`cnt` / `cntclass` / `cntclasses`)

`cnt` é a entidade forte de **todos** os tipos de pessoas/contatos. O tipo é determinado via:

- **`cntclass`** — catálogo de tipos (uma coluna booleana por tipo):

  | Coluna | Tipo de pessoa |
  |---|---|
  | `ativo` | Cliente |
  | `passivo` | Fornecedor |
  | `emitente` | Empresa |
  | `comissionado` | Vendedor |
  | `colaborador` | Funcionário |
  | `logistica` | Transportadora |

- **`cntclasses`** — junção N:N (`idcnt`, `idclass`) entre `cnt` e `cntclass`. Um mesmo `cnt` pode ter múltiplos tipos.

Para filtrar por tipo, sempre use o JOIN duplo:

```sql
INNER JOIN cntclasses ON cntclasses.idcnt = c.id
INNER JOIN cntclass   ON cntclass.id = cntclasses.idclass AND cntclass.<tipo>
```

**Tipos em uso nesta API:**

| Coluna | Tipo | Onde é usado |
|---|---|---|
| `ativo` | Cliente | Módulo `cliente/`, filtros de visibilidade por vendedor |
| `emitente` | Empresa | `SellerContextService` (resolução de `idEmp`) |
| `comissionado` | Vendedor | `equipe/semEquipe`, `seller-context` |

**Regras de vínculo:**

- **Vendedor ↔ Sistema:** quando um `cnt comissionado` está vinculado a `usu`, esse vendedor também acessa o sistema. O JWT carrega `userId`; a resolução é `userId → usu → cnt (comissionado)`.
- **Cliente ↔ Vendedor:** `cnt.idvende` aponta para o vendedor padrão do cliente. Um cliente é visível somente para o próprio vendedor ou para o supervisor da equipe desse vendedor.

## Máquina de Estados da Venda (`venda.tipo`)

| Valor | Estado | Editável |
|---|---|---|
| `'O'` | Aberto / Rascunho | Sim |
| `'P'` | Pendente | Não |
| `'V'` | Validado / Confirmado | Não |

Somente vendas com `tipo = 'O'` permitem inclusão/remoção de itens e atualização. O endpoint `POST /pedidos/:id/fechar` transita de `'O'` para o estado definido pelo chamador.

## Fluxo de Criação de Pedido

1. `POST /b3vendas/pedidos` — cria venda em estado `'O'`, com `idvend` do contexto do vendedor e `idemp` enviado pelo frontend no corpo do request. `plataforma="SALESFORCE"`, `processo="B3PED.exe"`.
2. `POST /b3vendas/pedidos/:id/itens` — adiciona itens; após cada inserção, `recalcTotals()` recalcula os totais da venda.
3. `DELETE /b3vendas/pedidos/:id/itens/:seq` — remove item; dispara `recalcTotals()`.
4. `POST /b3vendas/pedidos/:id/fechar` — insere registro em `vendacaixa` (em transação, deletando entradas anteriores) e salva `obsinter`.

**Fórmula de total:**
```
vlrtotal = vlrbruto + acrescimo + st + ipi + frete + seguro + outros - desconto - deducoes
```

## Cálculo de Impostos (IPI / ICMS-ST)

`TaxCalculatorService` é um serviço de lógica pura (sem acesso a banco):

- **IPI:** `subtotal × ipialiq / 100`
- **ST:** `(subtotal + ipi) × (1 + icmsiva/100) × icmsaliq/100 × (1 - icmsredu/100) - (subtotal × icmsaliq/100 × (1 - icmsredu/100))`

A regra de imposto é buscada na tabela `prdimposto` (junção produto × operação → `impostos`). O endpoint `POST /produtos/:id/calc-imposto` retorna `{ ipi, st, total }`.

## Pricing e Tabela de Preços

O preço unitário segue esta ordem de precedência:
1. Valor em `prdtabvalor` para a tabela do cliente (`cnt.idtab`) — preço personalizado.
2. Campo `prd.venda` — preço padrão do produto.

## CfgService — Configuração Dinâmica

`OperacaoService` injeta `CfgService` para ler a chave `VWEBOPERCOND` do banco do tenant. Esse valor é interpolado como cláusula SQL extra no filtro de operações permitidas, permitindo configuração por deployment sem alterar código.

## Entities

> Especificação completa das colunas (tipos, defaults, FKs) está em **[agent_docs/tenant_schema.md](../../../agent_docs/tenant_schema.md)** — seções §1–§5.

Resumo das entities e suas tabelas:

| Entity | Tabela | PK | Seção no schema |
|---|---|---|---|
| `ClienteEntity` | `cnt` | `id` int unsigned | §2 |
| `OperacaoEntity` | `operacoes` | `id` smallint unsigned | §4 |
| `ProdutoEntity` | `prd` | `id` int | §5 |
| `ImpostoEntity` | `impostos` | `id` int | §5 |
| `ProdutoImpostoEntity` | `prdimposto` | `idprd` + `idoperacao` | §5 |
| `ProdutoTabValorEntity` | `prdtabvalor` | `idtab` + `idprod` | §5 |
| `FormaPagamentoEntity` | `formapg` | `id` smallint unsigned | §4 |
| `CondicaoPagamentoEntity` | `condpg` | `idcond` smallint unsigned | §4 |
| `VendaEntity` | `venda` | `id` int unsigned | §3 |
| `VendaCaixaEntity` | `vendacaixa` | `idvenda` + `idforma` + `seq` | §3 |
| `VendaItemEntity` | `vendaitem` | `idvenda` + `seq` | §3 |

## Endpoints

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/b3vendas/clientes/buscar?q=` | Busca clientes (mín. 2 chars, máx. 50) |
| `GET` | `/b3vendas/clientes/rede-sp` | Clientes do vendedor ativos, UF SP ou nula, com tabela de preços (roles SUPER/SALER) |
| `GET` | `/b3vendas/clientes/tabela?idOper=&idCli=` | Catálogo com preços e impostos pré-calculados para cliente/operação (roles SUPER/SALER) |
| `GET` | `/b3vendas/clientes/:id` | Dados do cliente |
| `POST` | `/b3vendas/clientes` | Criar cliente |
| `PATCH` | `/b3vendas/clientes/:id` | Atualizar cliente |
| `DELETE` | `/b3vendas/clientes/:id` | Remover cliente (role SUPER) |
| `GET` | `/b3vendas/operacoes?idemp=` | Listar operações permitidas para a empresa |
| `GET` | `/b3vendas/produtos/buscar?q=` | Busca produtos (mín. 2 chars, máx. 50) |
| `GET` | `/b3vendas/produtos/:id/preco?idCli=&idOper=` | Preço do produto para cliente/operação |
| `POST` | `/b3vendas/produtos/:id/calc-imposto` | Calcular IPI/ST sobre subtotal |
| `POST` | `/b3vendas/pedidos` | Criar pedido (`idemp` obrigatório no body) |
| `GET` | `/b3vendas/pedidos/editaveis?idemp=` | Pedidos abertos do vendedor/empresa (últimos 5 dias) |
| `GET` | `/b3vendas/pedidos/fechados?idemp=` | Pedidos fechados do vendedor/empresa (últimos 30 dias, `tipo IN ('P','V')`) |
| `GET` | `/b3vendas/pedidos/:id` | Detalhes do pedido com itens |
| `GET` | `/b3vendas/pedidos/:id/formas-disponiveis` | Formas de pagamento disponíveis |
| `GET` | `/b3vendas/pedidos/:id/condicoes-disponiveis` | Condições de pagamento disponíveis |
| `POST` | `/b3vendas/pedidos/:id/fechar` | Fechar pedido com pagamento |
| `POST` | `/b3vendas/pedidos/:id/itens` | Adicionar item ao pedido |
| `DELETE` | `/b3vendas/pedidos/:id/itens/:seq` | Remover item do pedido |
| `GET` | `/b3vendas/equipe` | Lista a equipe de vendas do usuário autenticado (ver seção Equipe) |
| `GET` | `/b3vendas/metricas/vendas-semanais` | Total de vendas por semana ISO — últimas 12 semanas (gráfico, roles SUPER/SALER) |
| `GET` | `/b3vendas/metricas/vendas-mensais` | Total de vendas por mês — últimos 12 meses (gráfico, roles SUPER/SALER) |
| `GET` | `/b3vendas/metricas/top-clientes-ativos` | Top 15 clientes por valor — últimos 90 dias (gráfico, roles SUPER/SALER) |
| `GET` | `/b3vendas/metricas/clientes-inativos` | Clientes do vendedor sem qualquer lançamento em `venda` nos últimos 60 dias (listagem, roles SUPER/SALER) |

## Equipe de Vendas (`/b3vendas/equipe`)

Endpoint único `GET /b3vendas/equipe` que lista a equipe visível ao vendedor autenticado. O comportamento depende de `roleFront`:

- **`SUPER`** (supervisor): retorna o próprio líder **e** todos os vendedores subordinados. Consulta via `UNION ALL`:
  - `cnt` onde `id = vendId` — o próprio líder, com `liderado = 0`.
  - `cntequipe INNER JOIN cnt ON c.id = e.idcntliderado` onde `e.idcntlider = vendId` — liderados, com `liderado = 1`.
  - Resultado ordenado por `liderado ASC, razao ASC` (líder sempre primeiro; subordinados a seguir, em ordem alfabética).
- **`SALER`** (vendedor): retorna uma única linha com os dados do próprio vendedor (`cnt` onde `id = vendId`), com `liderado = 0`.

Qualquer outro `roleFront` recebe `403 Forbidden` — o `RolesFrontGuard` já filtra (`@RolesFront(SUPER, SALER)`), mas o service revalida defensivamente.

**Shape da resposta (`ResponseEquipeDto[]`):**

| Campo | Origem | Descrição |
|---|---|---|
| `id` | `cnt.id` | ID do vendedor |
| `razao` | `cnt.razao` | Nome do vendedor |
| `cel` | `cnt.cel` | Telefone celular |
| `fax` | `cnt.fax` | Número de WhatsApp (campo legado `fax` reaproveitado) |
| `liderado` | literal | `0` = linha do próprio vendedor autenticado (origem `cnt`); `1` = subordinado (origem `cntequipe`) |

A tabela `cntequipe` tem chave composta `(idcntlider, idcntliderado)` — ambos apontando para `cnt.id` com `ON DELETE CASCADE`. Não há entity dedicada; o serviço usa `ds.query()` com parâmetros posicionais.

## Métricas de Desempenho (`/b3vendas/metricas`)

Submódulo read-only que expõe indicadores de performance do vendedor autenticado. Quatro endpoints `GET`, todos com `@RolesFront(SUPER, SALER)` no nível do controller:

| Rota | Tipo | Janela | Origem |
|---|---|---|---|
| `vendas-semanais` | gráfico (`line`) | 12 semanas ISO | `venda.vlrtotal` agregado por `YEARWEEK(dthremissao, 1)` |
| `vendas-mensais` | gráfico (`line`) | 12 meses | `venda.vlrtotal` agregado por `DATE_FORMAT(dthremissao, '%Y-%m')` |
| `top-clientes-ativos` | gráfico (`bar_h`) | 90 dias | `venda` ⨝ `cnt`, top 15 por `SUM(vlrtotal)` desc |
| `clientes-inativos` | listagem | 60 dias | `cnt` LEFT excludes via `NOT EXISTS` em `venda` |

### Escopo (resolução de `vendIds`)

`MetricasService.resolveScope(dbId, userId, roleFront)` retorna a lista de IDs de vendedor a considerar:

- **`SALER`** — `[vendId]` (somente o próprio).
- **`SUPER`** — `[vendId, ...subordinados]` via `SELECT idcntliderado FROM cntequipe WHERE idcntlider = ?`.
- Qualquer outra role lança `ForbiddenException` (defense in depth — o `RolesFrontGuard` já filtra).

A lista é injetada nas queries via `IN (?, ?, ...)` com placeholders gerados dinamicamente. Spread no array de parâmetros: `[...vendIds]`.

### Critério de venda considerada (gráficos 1, 2, 3)

```sql
v.tipo = 'V' AND v.subtipo = 'N' AND v.baixado = 1
```

Este filtro **não se aplica** a `clientes-inativos`: o cálculo de inatividade considera **qualquer** registro em `venda` (independente de `tipo`/`subtipo`/`baixado`) — uma venda em rascunho conta como "atividade" e remove o cliente da lista.

### Critério de cliente inativo

```sql
WHERE c.ativo
  AND c.idvende IN (vendIds)
  AND NOT EXISTS (
    SELECT 1 FROM venda v
     WHERE v.idcli = c.id
       AND v.dthremissao >= DATE_SUB(CURDATE(), INTERVAL 60 DAY)
  )
```

O vínculo cliente↔vendedor é via `cnt.idvende` (vendedor padrão). A subquery `(SELECT MAX(v2.dthremissao) FROM venda v2 WHERE v2.idcli = c.id)` retorna a data da última venda registrada (qualquer status), útil para distinguir "nunca comprou" (`null`) de "comprou há muito tempo".

### Shape de gráfico (`ChartDataDto`)

```ts
type ChartType = 'bar_v' | 'bar_h' | 'pie' | 'line';

class ChartDataDto {
  chartType: ChartType;
  labels: string[];
  series: { name: string; data: number[] }[];
}
```

Mesma forma do `ChartDataDto` usado em `b3dash` — DTO local no módulo (sem dependência cruzada). Buckets vazios são preenchidos com `0` em TypeScript via `last12WeekLabels()` / `last12MonthLabels()` + `fillSeries()`, garantindo eixo X completo no front.

### Decisões

| Decisão | Justificativa |
|---|---|
| **Sem entities novas** | Queries são leituras agregadas em `venda` e `cnt`. `ds.query<T[]>(sql, params)` direto. |
| **Janelas fixas (12/12/90/60)** | Conforme requisito de produto. Sem `?periodo` query param — manter a API simples para o front. |
| **`IN (?,?,...)` expandido** | mysql2/typeorm não tem suporte oficial documentado para arrays em `IN (?)`. Geramos placeholders manualmente para evitar surpresas. |
| **`venda.baixado = 1`** | `bit(1)` aceita comparação numérica em `WHERE` no MySQL 8 — não precisa `CAST` aqui (ao contrário de leitura no SELECT, onde voltaria como `Buffer`). |
| **Label de cliente = `COALESCE(fantasia, razao)`** | Mesmo padrão de `clientes/rede-sp` e `b3dash/faturamento/top-clientes`. |
| **`top-clientes-ativos` com 2 séries** | Frontend pode renderizar valor + nº de pedidos lado a lado sem nova request. |

## Guards

Todos os endpoints exigem `JwtGuard` + `UserInstanceGuard`. Endpoints com restrição de papel aplicam também `RolesFrontGuard`:

- `DELETE /clientes/:id` — role `SUPER`.
- `GET /clientes/rede-sp` — roles `SUPER` ou `SALER`.
- `GET /clientes/tabela` — roles `SUPER` ou `SALER`.
- `GET /equipe` — roles `SUPER` ou `SALER`.
- `GET /metricas/*` (todas as 4 rotas) — roles `SUPER` ou `SALER` (decorator no controller).
