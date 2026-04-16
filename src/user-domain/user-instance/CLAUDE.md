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
| `rolefront` | RoleFront enum | Papel no Web app. Default: `notallow` |
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

### `RoleFront` — Acesso ao Web App
| Valor | Descrição |
|---|---|
| `supervisor` | Supervisor |
| `saler` | Vendedor |
| `buyer` | Comprador |
| `notallow` | Sem acesso ao Web app |

## Endpoints

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/user-instances` | JwtGuard + RootGuard | Cria vínculo manualmente |
| `GET` | `/user-instances/user/:userId` | JwtGuard | Lista tenants do usuário (próprio ou Root) |
| `GET` | `/user-instances/db/:dbId` | JwtGuard + RootGuard | Lista usuários de um tenant |
| `GET` | `/user-instances/:id` | JwtGuard | Busca por id (somente próprio vínculo) |
| `PATCH` | `/user-instances/:id` | JwtGuard + RootGuard | Atualiza roles ou isActive |
| `DELETE` | `/user-instances/:id` | JwtGuard + RootGuard | Remove vínculo |

## Regras de Negócio

- Um usuário pode ter vínculos com múltiplos tenants, cada um com roles independentes.
- `findByUser` ordena os resultados pelo nome da instance (`ASC`).
- Ao inativar um `UserEntity` (`isActive = false`), o `UserService` propaga automaticamente `isActive = false` para todos os vínculos desse usuário.
- O campo `idBackendUser` é opcional — usado para mapear o usuário da API ao registro correspondente no banco legado do tenant.
- O `addUserInstance` (chamado pelo fluxo de confirm do `user-pre`) sempre força `isActive: true`.

## Uso no Fluxo de Autenticação

No `POST /auth/instance`, o guard utiliza `findValid(userId, dbId)` para confirmar que o vínculo existe e está ativo, e então inclui `roleBack` e `roleFront` no payload do JWT com escopo completo.
