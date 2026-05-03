# b3vendas / cliente

CRUD de clientes (`cnt`) e catálogo com tabela de preços por cliente.

> Convenções gerais, `SellerContext` e isolamento por vendedor estão em [../CLAUDE.md](../CLAUDE.md). Schema completo em [../../../agent_docs/tenant_schema.md](../../../agent_docs/tenant_schema.md). DTOs em [../../../agent_docs/api-b3vendas.md](../../../agent_docs/api-b3vendas.md).

## Tabelas

| Tabela | Papel |
|---|---|
| `cnt` | Cliente (filtrado por `cntclass.ativo`) |
| `cntclass` / `cntclasses` | Tipo "ativo" = Cliente |
| `prdtab` / `prdtabvalor` | Tabela de preço vinculada via `cnt.idtab` |
| `formapg` / `condpg` | Forma e condição de pagamento padrão (`cnt.idforma`, `cnt.idcond`) |

`ClienteEntity.docformatado` é uma coluna virtual (`select: false, insert: false, update: false`) populada por `addSelect('format_docfed(c.docfed)')` em `findOneOrFail`.

## Endpoints

| Endpoint | Roles | Comentários |
|---|---|---|
| `GET /b3vendas/clientes/buscar?q=` | qualquer (JwtGuard+UserInstance) | mín. 2 caracteres; LIKE em `UPPER(razao)`, `docfed`, `id`. Filtro: `cntclass.ativo`, `cnt.ativo`, `cnt.idvende = vendId`. **Inclui sempre `OR id = 99`** (Consumidor Final). Limite 50, distinct, order by razao. |
| `GET /b3vendas/clientes/rede-sp` | SUPERSALER/SALER | Raw SQL: clientes ativos com `idtab IS NOT NULL` e `(uf='SP' OR uf IS NULL)` do vendedor. |
| `GET /b3vendas/clientes/tabela?idOper=&idCli=` | SUPERSALER/SALER | Catálogo com preço (da tabela do cliente) + IPI/ST pré-calculados em SQL. **`INNER JOIN prdtabvalor`** — só produtos da tabela do cliente entram. Filtros: `prd.ativo`, `prd.podevender`, `NOT prd.servico`, `prdtabvalor.valor > 0`. `operacoes.finalidade IN ('C','R','I')`; `finalidade='C'` zera `ivast` e `vicmsst`. |
| `GET /b3vendas/clientes/:id` | qualquer | `findOneOrFail` com `addSelect('format_docfed(c.docfed) AS c_docformatado')`. Retorna 404 se não encontrado ou inativo. |
| `POST /b3vendas/clientes` | SUPERSALER | `idvende` default = vendedor logado; `ativo = true`. **Não valida unicidade de `docfed`.** |
| `PATCH /b3vendas/clientes/:id` | SUPERSALER | `assertVinculoVendedor` — apenas o vendedor de `cnt.idvende` pode alterar. Atualização campo a campo. |
| `DELETE /b3vendas/clientes/:id` | SUPERSALER | **Hard delete** (`repo.remove`). Não exige vínculo do vendedor. |

## Entities e DTOs

| Entity | Tabela | PK | DTOs |
|---|---|---|---|
| `ClienteEntity` | `cnt` | `id` int unsigned | Create/Update + `ResponseClienteInfo`, `ResponseClienteBusca`, `ResponseClienteRedeSp`, `ResponseClienteTabela` |

## Regras de Visibilidade

- **Listagem/busca:** `cnt.idvende = vendId` (vindo do `SellerContext`).
- **Consumidor Final (`id = 99`):** sempre incluído em `buscar`, independente de vendedor.
- **Edição:** `assertVinculoVendedor` impede `PATCH` de cliente de outro vendedor.
- **Hard delete intencional:** UI legada depende disso; integridade preservada por FKs.
