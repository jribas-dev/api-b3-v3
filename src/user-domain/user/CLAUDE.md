# Módulo: user

## Responsabilidade

Gerencia os **usuários ativos da API**. Um usuário só chega aqui após concluir o fluxo de convite do `user-pre`. É a entidade central de autenticação e autorização da aplicação.

## Entidade: `user`

| Campo | Tipo | Descrição |
|---|---|---|
| `userId` | string (CUID2) | PK — gerado via `@BeforeInsert()` com `createId()` |
| `email` | varchar(128) unique | Login principal |
| `phone` | varchar(128) nullable | Telefone BR |
| `password` | varchar(300) select:false | Hash bcrypt — nunca retornado em queries padrão |
| `name` | varchar(128) | Nome de exibição |
| `isRoot` | boolean | Superadmin global da API. Default: `false` |
| `isActive` | boolean | Usuário ativo/inativo. Default: `true` |
| `userInviteId` | varchar(36) nullable | `userId` do admin que originou o convite. Propagado de `user_pre.userInviteId` no `POST /user-pre/confirm`. `null` para usuários criados diretamente via `POST /users` |
| `createdAt` | Date | Criação |
| `updatedAt` | Date | Última atualização |

Relação `OneToMany` com `user_instances` (vínculos com tenants).

## Flags de Permissão

- **`isRoot`**: flag global que concede acesso irrestrito a todos os endpoints protegidos por `RootGuard`. Independe de tenant — o superadmin enxerga tudo.
- **`roleBack` / `roleFront`**: não ficam no `user`, ficam em `user_instances` (por tenant). Veja o módulo `user-instance`.

## Endpoints

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/users` | JwtGuard + AdminGuard | Cria usuário diretamente (fluxo alternativo, sem convite) |
| `GET` | `/users` | JwtGuard + RootGuard | Lista todos os usuários |
| `GET` | `/users/notin` | JwtGuard + AdminGuard (token etapa 2) | Lista usuários convidados pelo admin autenticado (`userInviteId = req.user.userId`) que **ainda não** têm `user_instances` no `dbId` do token. Usado pelo front para vincular um convidado existente à instância atual sem novo convite |
| `GET` | `/users/get/me` | JwtGuard | Retorna o próprio usuário pelo JWT |
| `GET` | `/users/:id` | JwtGuard | Busca por userId |
| `PATCH` | `/users/:id` | JwtGuard | Atualiza dados (Root pode editar qualquer um; usuário só edita a si mesmo) |
| `PATCH` | `/users/active` | JwtGuard + AdminGuard | Ativa/inativa usuário pelo `userId`; propaga `isActive: false` para todos os `user_instances` ao inativar. **Bloqueio supervisor → admin** (ver Regras) |
| `DELETE` | `/users/:id` | JwtGuard + RootGuard | Remove usuário |

## Regras de Negócio

- Email e telefone devem ser únicos — validados no controller antes de delegar ao service.
- Senha deve ter mínimo 8 caracteres com letras e números (regex no controller: `/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$/`).
- Ao criar usuário, dispara email de boas-vindas (`TemplateType.WELCOME`).
- Ao atualizar senha via `PATCH`, o service reaplica o hash automaticamente.
- Ao inativar (`isActive = false`), o service propaga `isActive = false` para todos os `user_instances` do usuário.
- `isRoot` não é exposto no `CreateUserDto` — só pode ser definido manualmente no banco ou por um Root via `PATCH`.
- **`userInviteId`** é gravado apenas via o fluxo de convite (`user-pre.confirm` chama `userService.create(data, userPre.userInviteId)`). Em `POST /users` direto, o campo fica `null`. Não é exposto no `CreateUserDto` nem no `ResponseUserDto`.
- **Bloqueio supervisor → admin em `PATCH /users/active`:** se o solicitante não é `isRoot`, tem `roleBack = supervisor` e tem `dbId` no token (etapa 2), a chamada lança `403` quando o `user_instances` do alvo no mesmo `dbId` tem `roleback = admin`. Implementado consultando `UserInstanceService.findOneByUserAndDb(userId, dbId)` antes do `setActive`.

## DTOs

- **`CreateUserDto`**: email, phone (BR), password (min 8), name. Omite userId, isRoot, isActive, **userInviteId**, timestamps.
- **`UpdateUserDto`**: todos os campos de `CreateUserDto` como opcionais.
- **`SetActiveUserDto`**: `userId` (string, obrigatório) + `isActive` (boolean, obrigatório). Exclusivo da rota `PATCH /users/active`.
- **`ResponseUserDto`**: expõe `userId`, `email`, `phone`, `name`, `isRoot`, `isActive`. Exclui `password` e `userInviteId`.

## Métodos do Service

| Método | Descrição |
|---|---|
| `create(data, userInviteId?)` | Cria o usuário; grava `userInviteId ?? null`. O fluxo `user-pre.confirm` repassa `userPre.userInviteId`; chamadas diretas omitem o segundo argumento |
| `findInvitedNotInInstance(inviterUserId, dbId)` | Lista usuários cujo `userInviteId` é o solicitante e que **não** têm `user_instances` no `dbId` (subquery `NOT EXISTS`). Backing do `GET /users/notin` |
| `setActive(userId, isActive)` | Atualiza `isActive` no `user` e propaga para todos os `user_instances` |

## Dependências Internas

- `PasswordService` — hashing bcrypt de senhas.
- `AwsSenderService` — email de boas-vindas ao criar usuário.
- `UserInstanceEntity` — injetado diretamente para propagar inativação em cascata e para a subquery de `findInvitedNotInInstance`.
- `UserInstanceService` — injetado no **controller** para resolver `findOneByUserAndDb` no bloqueio supervisor → admin de `PATCH /users/active`.
