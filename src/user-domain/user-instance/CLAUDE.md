# Módulo: user-instance

## Responsabilidade

Gerencia o **vínculo entre usuário e tenant (instance)**. É a tabela de junção `user_instances` que implementa o multi-tenancy por usuário, armazenando os papéis RBAC específicos de cada combinação usuário + tenant.

## Entidade: `user_instances`

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | int (auto) | PK |
| `userId` | string (CUID2) | FK → user |
| `dbId` | string (CUID2) | FK → instance (tenant) |
| `idBackendUser` | int \| null | ID do usuário no sistema legado do tenant (BackOffice desktop) |
| `roleback` | RoleBack enum | Papel no BackOffice. Default: `user` |
| `rolefront` | RoleFront (`RoleFrontEnum[]`) | Conjunto de papéis no Web app, persistido como string separada por vírgula via `RoleFrontTransformer`. Default: `['notallow']` |
| `isActive` | boolean | Vínculo ativo/inativo. Default: `true` |

Relações carregadas com `eager: true`: `user` e `instance`.  
`onDelete: CASCADE` em ambas as FK — deletar usuário ou instance remove os vínculos.

## Enums de Roles

### `RoleBack` — Acesso ao BackOffice (aplicativo desktop)
| Valor | Descrição |
|---|---|
| `admin` | Administrador do tenant |
| `supervisor` | Supervisor |
| `user` | Usuário padrão |
| `notallow` | Sem acesso ao BackOffice |

### `RoleFrontEnum` — Papéis no Web App
| Valor | Significado | Acesso |
|---|---|---|
| `admin` | Administrativo | Total a [`b3dash`](../../b3dash/CLAUDE.md). É também o papel front que satisfaz `AdminGuard`. |
| `supersaler` | Supervisor de vendas | Total a [`b3vendas`](../../b3vendas/CLAUDE.md): vê equipe inteira, pode configurar equipe, criar/alterar/remover cliente. |
| `saler` | Vendedor de campo | Parcial a `b3vendas`: só vê a si mesmo (equipe e métricas), **não pode** configurar equipe nem criar/alterar/remover cliente. |
| `inventory` | Estoquista | Reservado para módulo futuro. |
| `buyer` | Comprador externo | Reservado para módulo futuro (catálogo + montagem de pedidos pelo próprio cliente). |
| `notallow` | Sem acesso | Bloqueia tudo. |

`RoleFront` é o tipo array (`RoleFrontEnum[]`). Um vínculo pode acumular vários papéis distintos (ex.: `['admin','supersaler']`), gravados no banco como CSV (`'admin,supersaler'`); o `RoleFrontTransformer` converte ida e volta. Comparações no código usam `.includes()` / `.some()`.

#### Regra de exclusividade

`SALER` e `SUPERSALER` **não podem coexistir** no mesmo vínculo — são níveis hierárquicos sobre o mesmo módulo. A validação está no helper [`assertRoleFrontConsistent`](./validators/role-front.validator.ts), invocado pelos hooks `@BeforeInsert` / `@BeforeUpdate` em `UserInstanceEntity` e `UserPreInstanceEntity`. Tentativas de persistir o par lançam `BadRequestException` antes do INSERT/UPDATE.

## Endpoints

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/user-instances` | JwtGuard + AdminGuard | Cria vínculo manualmente |
| `GET` | `/user-instances/user/:userId` | JwtGuard | Lista tenants do usuário (próprio ou Root) |
| `GET` | `/user-instances/db/:dbId` | JwtGuard + AdminGuard | Lista usuários de um tenant. Aceita `?include=user\|database` para enriquecer cada item |
| `GET` | `/user-instances/:id` | JwtGuard | Busca por id (somente próprio vínculo) |
| `PATCH` | `/user-instances/:id` | JwtGuard + AdminGuard | Atualiza roles ou isActive. **Bloqueio supervisor → admin** (ver Regras) |
| `DELETE` | `/user-instances/:id` | JwtGuard + AdminGuard | Remove vínculo. **Bloqueio supervisor → admin** (ver Regras) |

## Regras de Negócio

- Um usuário pode ter vínculos com múltiplos tenants, cada um com roles independentes.
- `findByUser` ordena os resultados pelo nome da instance (`ASC`).
- Ao inativar um `UserEntity` (`isActive = false`), o `UserService` propaga automaticamente `isActive = false` para todos os vínculos desse usuário.
- O campo `idBackendUser` é opcional — usado para mapear o usuário da API ao registro correspondente no banco legado do tenant.
- O `addUserInstance` (chamado pelo fluxo de confirm do `user-pre`) sempre força `isActive: true`.
- **Bloqueio supervisor → admin (PATCH e DELETE):** se o solicitante **não é `isRoot`** e tem `roleBack = supervisor`, ambos os endpoints fazem um `findOne(id)` prévio e lançam `403 Forbidden` quando o vínculo alvo tem `roleback = admin`. Supervisores podem editar/remover vínculos com qualquer outra role (`user`/`supervisor`/`notallow`), mas não podem tocar em administradores.
- **Query `include` em `GET /db/:dbId`:**
  - `include=user` carrega a relação `user` (sem o `password`, que é `select:false`) e adiciona `{ email, phone, name, isRoot, isActive }` em cada item.
  - `include=database` carrega a relação `instance` e adiciona `{ name, maxCompanies, maxUsers, isActive }`.
  - Sem `include`, apenas a relação `user` é carregada (necessária para o `ResponseUserInstanceDto`), mas o objeto enriquecido **não** é anexado.
  - Qualquer valor diferente de `user`/`database`/ausente lança `400 Bad Request` no controller.

## Métodos do Service

| Método | Descrição |
|---|---|
| `create(data)` | Cria vínculo (uso administrativo). |
| `addUserInstance(data)` | Variante chamada pelo `user-pre.confirm`; força `isActive: true`. |
| `findByUser(userId)` | Lista vínculos do usuário ordenados pelo `instance.name`. |
| `findByDb(dbId, include?)` | Lista vínculos do tenant. Quando `include` é `user`/`database`, anexa o objeto correspondente — ver "Query `include`" acima. |
| `findOne(id)` | Busca o vínculo pelo PK. |
| `findOneByUserAndDb(userId, dbId)` | Busca um vínculo específico pelo par `(userId, dbId)`. Usado pelo `UserController` para validar o bloqueio supervisor → admin em `PATCH /users/active`. |
| `findValid(userId, dbId)` | Usado pelo `auth.module` em `POST /auth/instance` — confirma vínculo ativo e devolve roles para o JWT. |
| `update(id, updates)` | Atualiza roles/`isActive`. |
| `delete(id)` | Remove o vínculo. |

## Uso no Fluxo de Autenticação

No `POST /auth/instance`, o guard utiliza `findValid(userId, dbId)` para confirmar que o vínculo existe e está ativo, e então inclui `roleBack` e `roleFront` no payload do JWT com escopo completo.
