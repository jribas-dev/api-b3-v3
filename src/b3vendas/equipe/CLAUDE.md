# b3vendas / equipe

Gestão da equipe de vendas (`cntequipe`).

> Convenções gerais e `SellerContext` em [../CLAUDE.md](../CLAUDE.md). Tipos de pessoa (comissionado/vendedor) em [../CLAUDE.md](../CLAUDE.md#tipos-de-pessoa-cnt--cntclass--cntclasses).

## Tabela

`cntequipe` tem PK composta `(idcntlider, idcntliderado)`, ambos FK para `cnt.id` com `ON DELETE CASCADE`. **Sem entity** — todas as operações usam `ds.query()`.

## Endpoints

| Método | Rota | Roles | Comportamento |
|---|---|---|---|
| GET | `/b3vendas/equipe` | SUPERSALER ou SALER | SUPERSALER: `UNION ALL` de (próprio cnt, `liderado=0`) + (subordinados via `cntequipe.idcntlider = vendId`, `liderado=1`); order `liderado ASC, razao ASC`. SALER: somente o próprio. Outros: `403`. |
| GET | `/b3vendas/equipe/sem-equipe` | SUPERSALER | `cnt JOIN cntclasses+cntclass.comissionado` onde `c.id != vendId` e `NOT EXISTS` em `cntequipe.idcntliderado`. Order by `razao ASC`. |
| POST | `/b3vendas/equipe` | SUPERSALER | `idcntliderado != vendId`; verifica duplicidade (`409`); `INSERT cntequipe(vendId, idcntliderado)`. |
| DELETE | `/b3vendas/equipe/:id` | SUPERSALER | `DELETE WHERE idcntlider=vendId AND idcntliderado=:id`; `404` se nada afetado. |

> Na prática um usuário não tem ambos `SUPERSALER` e `SALER` — a regra é validada em `assertRoleFrontConsistent` no `BeforeInsert/Update` de `UserInstanceEntity`. O service revalida defensivamente via `RoleFrontGuard`.

## DTOs

| DTO | Uso |
|---|---|
| `ResponseEquipe` | `GET /equipe`, `GET /equipe/sem-equipe` |
| `CreateEquipe` | `POST /equipe` |

## Consumidor cruzado

`MetricasService.resolveScope` lê `cntequipe` para validar e expandir o escopo de `idvende` quando SUPERSALER usa `join=true` (ver [../metricas/CLAUDE.md](../metricas/CLAUDE.md)).
