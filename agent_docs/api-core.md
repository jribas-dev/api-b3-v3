# API Contracts — Core (Banco Principal)

> Módulos: `auth`, `user-domain`, `tenant`, `infra`, `app`
>
> Base URL: `https://<host>`
>
> Todos os endpoints autenticados exigem o header:
> ```
> Authorization: Bearer <accessToken>
> ```

---

## Índice

- [Autenticação](#autenticação)
- [Gerenciamento de Sessões](#gerenciamento-de-sessões)
- [Reset de Senha](#reset-de-senha)
- [Sessão e Enums](#sessão-e-enums)
- [Usuários](#usuários)
- [Instâncias (Tenants)](#instâncias-tenants)
- [Vínculos Usuário-Instância](#vínculos-usuário-instância)
- [Pré-cadastro (Convite)](#pré-cadastro-convite)
- [Tenant](#tenant)
- [Infra — AWS S3](#infra--aws-s3)
- [Infra — AWS SES](#infra--aws-ses)
- [Infra — SQL Files](#infra--sql-files)
- [Infra — Sys Files](#infra--sys-files)

---

## Referência de Guards

| Guard | O que exige | Resposta ao falhar |
|---|---|---|
| `JwtGuard` | Token JWT válido no header `Authorization` | `401 Unauthorized` |
| `UserInstanceGuard` | Token de **etapa 2** (campo `dbId` no payload — usuário selecionou um tenant) | `403 Forbidden` |
| `AdminGuard` | `isRoot = true` **OU** `roleBack ∈ {admin, supervisor}` **OU** `roleFront` (array) contém `admin` | `403 Forbidden` |
| `RootGuard` | `isRoot = true` (superadmin global) | `403 Forbidden` |
| `RolesFrontGuard` | `roleFront` (array) do token **intersecta** com o conjunto exigido pelo endpoint | `403 Forbidden` |
| `RolesBackGuard` | `roleBack` do token pertence ao conjunto exigido | `403 Forbidden` |

---

## Autenticação

### Fluxo em duas etapas

```
1. POST /auth/login      → token de acesso (etapa 1, sem escopo de tenant)
2. POST /auth/instance   → token de acesso (etapa 2, com dbId + roles)
```

O token de etapa 2 é o necessário para acessar qualquer endpoint de domínio.

---

### `POST /auth/login`

Valida credenciais e retorna token de etapa 1. Protegido contra força bruta por IP+email (bloqueio após 5 tentativas, duração 1 hora).

**Auth:** nenhuma

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `email` | string | ✅ | E-mail do usuário (formato válido) |
| `password` | string | ✅ | Senha (mínimo 8 caracteres) |

**Resposta `200`:**

```jsonc
{
  "isActive": true,           // booleano — indica se a conta está ativa
  "accessToken": "eyJ...",    // JWT etapa 1 (validade 30 min)
  "tokenType": "Bearer",
  "expiresIn": 1800           // segundos
}
```

**Erros comuns:**

| Status | Motivo |
|---|---|
| `401` | Credenciais inválidas ou conta bloqueada por força bruta |

---

### `POST /auth/instance`

Seleciona um tenant e retorna o token de etapa 2 com roles. Máximo 10 chamadas por minuto por IP.

**Auth:** `JwtGuard` (token etapa 1)

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `dbId` | string | ✅ | ID da instância/tenant (obtido em `GET /user-instances/user/:userId`) |
| `deviceName` | string | ❌ | Nome do dispositivo (máx. 255 chars). Se omitido, o `User-Agent` do header é usado como fallback |

**Resposta `200`:**

```jsonc
{
  "isActive": true,
  "accessToken": "eyJ...",    // JWT etapa 2 (validade 180 min)
  "refreshToken": "a3b9...",  // token opaco (64 bytes hex), validade 7 dias
  "tokenType": "Bearer",
  "expiresIn": 10800
}
```

**Payload do JWT (etapa 2):**

| Campo | Tipo | Descrição |
|---|---|---|
| `sub` | string | `userId` (CUID2) |
| `email` | string | E-mail do usuário |
| `isRoot` | boolean | Superadmin global |
| `dbId` | string | ID do tenant selecionado |
| `instanceName` | string | Nome da instância |
| `roleBack` | string | Role no BackOffice: `admin \| supervisor \| user \| notallow` |
| `roleFront` | string[] | Array de papéis no Web App, valores de `RoleFrontEnum`: `admin \| supersaler \| saler \| inventory \| buyer \| notallow`. Pode acumular múltiplos papéis (ex.: `["admin","supersaler"]`); `saler` e `supersaler` não podem coexistir |

**Erros comuns:**

| Status | Motivo |
|---|---|
| `403` | Vínculo inativo, ou versão do banco do tenant abaixo do mínimo (`MIN_TENANT_DB`) |

---

### `POST /auth/refresh`

Renova o par de tokens. O `refreshToken` anterior é invalidado (uso único — rotação automática). O `deviceName` é preservado automaticamente do token anterior.

**Auth:** nenhuma

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `refreshToken` | string | ✅ | Refresh token recebido em `/auth/instance` ou na última chamada a `/auth/refresh` |

**Resposta `200`:**

```jsonc
{
  "isActive": true,
  "accessToken": "eyJ...",
  "refreshToken": "c7d2...",  // novo refresh token
  "tokenType": "Bearer",
  "expiresIn": 10800
}
```

**Erros comuns:**

| Status | Motivo |
|---|---|
| `401` | Token inválido, expirado ou já utilizado |

---

### `POST /auth/logout`

Invalida o token atual (insere na blacklist).

**Auth:** `JwtGuard` + `UserInstanceGuard` (token etapa 2)

**Body:** nenhum

**Resposta `200`:**

```jsonc
{ "message": "Logout realizado com sucesso" }
```

---

## Gerenciamento de Sessões

### `GET /auth/sessions`

Lista as sessões ativas (refresh tokens não revogados e não expirados) do usuário autenticado.

**Auth:** `JwtGuard` (token etapa 1 ou 2)

**Body:** nenhum

**Resposta `200`:**

```jsonc
{
  "sessions": [
    {
      "deviceName": "Chrome on Windows",  // string | null
      "expiresAt": "2026-05-15T14:30:00.000Z"
    }
  ]
}
```

---

### `DELETE /auth/sessions`

Revoga todos os refresh tokens ativos do usuário autenticado.

**Auth:** `JwtGuard` (token etapa 1 ou 2)

**Body:** nenhum

**Resposta `200`:**

```jsonc
{
  "message": "Sessões revogadas com sucesso",
  "count": 3   // número de tokens revogados
}
```

---

## Reset de Senha

### `POST /auth/reset-password`

Inicia o fluxo de recuperação de senha. Envia e-mail com link de reset. Máximo 5 chamadas por minuto por IP.

**Auth:** nenhuma

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `email` | string | ✅ | E-mail cadastrado do usuário |

**Resposta `200`:** sem corpo (o e-mail é enviado independentemente de o usuário existir — evita enumeração de contas).

---

### `GET /auth/reset-password/check`

Valida o token de reset antes de exibir o formulário de nova senha.

**Auth:** nenhuma

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `token` | string | ✅ | Token recebido no link do e-mail |
| `email` | string | ✅ | E-mail do usuário |

**Resposta `200`:**

```jsonc
{
  "isValid": true,        // false se token expirado ou inválido
  "name": "João Silva",   // presente apenas quando isValid = true
  "email": "joao@..."     // presente apenas quando isValid = true
}
```

---

### `POST /auth/reset-password/update`

Conclui a troca de senha. O token é excluído após uso bem-sucedido. Máximo 5 chamadas por minuto por IP.

**Auth:** nenhuma

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `token` | string | ✅ | Token recebido no link do e-mail |
| `email` | string | ✅ | E-mail do usuário |
| `password` | string | ✅ | Nova senha (mínimo 8 caracteres) |

**Resposta `200`:**

```jsonc
{
  "passwordUpdated": true,
  "name": "João Silva",
  "email": "joao@..."
}
```

---

## Sessão e Enums

### `GET /backend/session`

Retorna os dados do usuário autenticado a partir do payload do JWT.

**Auth:** `JwtGuard`

**Resposta `200`:**

```jsonc
{
  "userId": "cuid2string",
  "email": "user@example.com",
  "isRoot": false,
  "dbId": "cuid2string",         // null/undefined se token etapa 1
  "instanceName": "Empresa X",   // null/undefined se token etapa 1
  "roleBack": "user",            // null/undefined se token etapa 1
  "roleFront": ["saler"]         // RoleFrontEnum[] — null/undefined se token etapa 1
}
```

---

### `GET /backend/enums/:enum`

Retorna os valores possíveis de um enum da aplicação.

**Auth:** `JwtGuard`

**Path params:**

| Param | Valores aceitos | Descrição |
|---|---|---|
| `enum` | `roleback` | Valores possíveis de `RoleBack` |
| `enum` | `rolefront` | Valores possíveis de `RoleFrontEnum` (cada vínculo pode acumular vários) |

**Resposta `200`:**

```jsonc
// GET /backend/enums/roleback
["admin", "supervisor", "user", "notallow"]

// GET /backend/enums/rolefront
["admin", "supersaler", "saler", "inventory", "buyer", "notallow"]
```

---

## Usuários

Base: `/users` — `JwtGuard` em todos os endpoints.

---

### `POST /users`

Cria um novo usuário.

**Auth:** `JwtGuard` + `AdminGuard`

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `name` | string | ✅ | Nome completo |
| `email` | string | ✅ | E-mail (único no sistema) |
| `phone` | string | ✅ | Telefone no formato brasileiro, ex: `+5511999999999` |
| `password` | string | ✅ | Senha (mínimo 8 caracteres) |

**Resposta `201`:**

```jsonc
{
  "userId": "cuid2string",
  "name": "João Silva",
  "email": "joao@example.com",
  "phone": "+5511999999999",
  "isRoot": false,
  "isActive": true
}
```

---

### `GET /users`

Lista todos os usuários do sistema.

**Auth:** `JwtGuard` + `RootGuard`

**Resposta `200`:** array de objetos com o mesmo shape de `POST /users`.

---

### `GET /users/notin`

Lista todos os usuários **convidados pelo admin autenticado** (`user.userInviteId = req.user.userId`) que **ainda não possuem vínculo (`user_instances`) com a instância atual** (`req.user.dbId`). Útil para o front oferecer um seletor "vincular usuário já convidado a esta instância" sem repetir o fluxo de convite.

**Auth:** `JwtGuard` + `AdminGuard` (e token de etapa 2 — exige `dbId` no payload)

**Body:** nenhum

**Resposta `200`:** array de `ResponseUserDto` (mesmo shape de `POST /users`).

**Erros comuns:**

| Status | Motivo |
|---|---|
| `403` | Token sem permissão de admin, ou token de etapa 1 (sem `dbId`) |

---

### `GET /users/get/me`

Retorna os dados do usuário autenticado.

**Auth:** `JwtGuard`

**Resposta `200`:** mesmo shape de `POST /users`.

---

### `GET /users/:id`

Retorna dados de um usuário específico.

**Auth:** `JwtGuard`

**Path params:**

| Param | Tipo | Descrição |
|---|---|---|
| `id` | string (CUID2) | ID do usuário |

**Resposta `200`:** mesmo shape de `POST /users`.

---

### `PATCH /users/:id`

Atualiza dados do usuário. Todos os campos são opcionais.

**Auth:** `JwtGuard`

**Path params:** `id` (CUID2 do usuário)

**Body (JSON) — todos opcionais:**

| Campo | Tipo | Descrição |
|---|---|---|
| `name` | string | Novo nome |
| `email` | string | Novo e-mail |
| `phone` | string | Novo telefone |
| `password` | string | Nova senha (mínimo 8 caracteres) |
| `isActive` | boolean | Usuário Ativo |


**Resposta `200`:** usuário atualizado (mesmo shape de `POST /users`).

---

### `PATCH /users/active`

Ativa ou inativa um usuário. Ao inativar, propaga `isActive: false` para todos os vínculos `user_instances` do usuário.

**Auth:** `JwtGuard` + `AdminGuard`

> **Bloqueio supervisor → admin:** se o solicitante **não é `isRoot`**, tem `roleBack = supervisor` e possui `dbId` no token (etapa 2), a chamada é rejeitada com `403` quando o `user_instances` do alvo no mesmo `dbId` tem `roleback = admin`. Supervisores podem alterar usuários com qualquer outra role no tenant em que atuam, mas não podem mexer em administradores.

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `userId` | string (CUID2) | ✅ | ID do usuário a alterar |
| `isActive` | boolean | ✅ | `true` para ativar, `false` para inativar |

**Resposta `200`:** usuário atualizado (mesmo shape de `POST /users`).

**Erros comuns:**

| Status | Motivo |
|---|---|
| `404` | Usuário não encontrado |
| `403` | Token sem permissão de admin, ou supervisor tentando alterar um administrador no tenant atual |

---

### `DELETE /users/:id`

Remove um usuário.

**Auth:** `JwtGuard` + `RootGuard`

**Path params:** `id` (CUID2 do usuário)

**Resposta `200`:**

```jsonc
{ "message": "Usuário removido com sucesso" }
```

---

## Instâncias (Tenants)

Base: `/instances` — todos os endpoints exigem `JwtGuard` + `RootGuard`.

---

### `POST /instances`

Cria uma nova instância (tenant).

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `name` | string | ✅ | Nome da instância/empresa |
| `dbName` | string | ✅ | Nome do banco de dados MySQL do tenant |
| `dbHost` | string | ✅ | Host do servidor MySQL do tenant |
| `maxCompanies` | integer | ✅ | Número máximo de empresas (emitentes) |
| `maxUsers` | integer | ✅ | Número máximo de usuários |
| `isActive` | boolean | ✅ | Se a instância está ativa |

**Resposta `201`:**

```jsonc
{
  "id": "cuid2string",
  "name": "Empresa X",
  "dbName": "empresa_x",
  "dbHost": "mysql.server.com",
  "maxCompanies": 5,
  "maxUsers": 20,
  "isActive": true
}
```

---

### `GET /instances`

Lista todas as instâncias.

**Resposta `200`:** array com o mesmo shape de `POST /instances`.

---

### `GET /instances/:id`

Retorna uma instância específica.

**Path params:** `id` (CUID2 da instância)

**Resposta `200`:** mesmo shape de `POST /instances`.

---

### `PATCH /instances/:id`

Atualiza uma instância. Todos os campos são opcionais (PartialType do CreateInstanceDto).

**Path params:** `id` (CUID2 da instância)

**Body:** qualquer subconjunto dos campos de `POST /instances`.

**Resposta `200`:** instância atualizada.

---

## Vínculos Usuário-Instância

Base: `/user-instances` — `JwtGuard` em todos os endpoints.

Gerencia a relação entre um usuário e um tenant, incluindo as roles RBAC de cada vínculo.

---

### `POST /user-instances`

Cria um vínculo entre usuário e tenant.

**Auth:** `JwtGuard` + `AdminGuard`

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `userId` | string | ✅ | CUID2 do usuário |
| `dbId` | string | ✅ | CUID2 da instância/tenant |
| `roleback` | string | ✅ | Role no BackOffice: `admin \| supervisor \| user \| notallow` |
| `rolefront` | string[] | ✅ | Array de papéis no Web App, **não vazio**. Valores: `admin \| supersaler \| saler \| inventory \| buyer \| notallow`. Regra: `saler` e `supersaler` não podem coexistir no mesmo vínculo (`400 Bad Request` em caso contrário) |
| `idBackendUser` | integer | ❌ | ID do usuário no sistema legado do tenant (BackOffice desktop) |

**Resposta `201`:** objeto `ResponseUserInstanceDto` (mesmo shape de `GET /user-instances/:id`).

> Persistência: `rolefront` é gravado como string CSV (ex.: `"admin,supersaler"`) e convertido para array via transformer. A API sempre o retorna como array.
> O service força `isActive: true` na criação — o campo no body é ignorado.

---

### `GET /user-instances/user/:userId`

Lista todos os tenants vinculados a um usuário, ordenados pelo nome da instância (`ASC`).

**Auth:** `JwtGuard` (usuário só pode ver seus próprios vínculos, exceto `isRoot` que vê qualquer um)

**Path params:** `userId` (CUID2 do usuário)

**Resposta `200`:** array de `ResponseUserInstanceDto`, com dados da instância embutidos:

```jsonc
[
  {
    "id": 42,
    "userId": "cuid2string",
    "dbId": "cuid2string",
    "idBackendUser": null,
    "roleback": "user",
    "rolefront": ["saler"],
    "isActive": true,
    "instanceName": "Empresa X",
    "instanceDbName": "empresa_x",
    "instanceDbHost": "mysql.server.com"
  }
]
```

**Erros comuns:**

| Status | Motivo |
|---|---|
| `403` | Usuário tentando acessar vínculos de outro `userId` sem ser `isRoot` |
| `404` | Nenhum vínculo encontrado para o `userId` |

---

### `GET /user-instances/db/:dbId`

Lista todos os usuários vinculados a um tenant. Por padrão retorna apenas os campos do vínculo (`ResponseUserInstanceDto`). O parâmetro `include` enriquece a resposta com dados do `user` **ou** da `instance` (mutuamente exclusivos).

**Auth:** `JwtGuard` + `AdminGuard`

**Path params:** `dbId` (CUID2 da instância)

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `include` | `user` \| `database` | ❌ | Quando `user`: adiciona um objeto `user` ao vínculo com `{ email, phone, name, isRoot, isActive }`. Quando `database`: adiciona um objeto `database` com `{ name, maxCompanies, maxUsers, isActive }` da instância. Qualquer outro valor retorna `400 Bad Request` |

**Resposta `200`:** array de objetos. Cada item é um `ResponseUserInstanceDto` e — quando `include` é informado — recebe a propriedade adicional correspondente:

```jsonc
// include=user
[
  {
    "id": 42,
    "userId": "cuid2string",
    "dbId": "cuid2string",
    "idBackendUser": null,
    "roleback": "user",
    "rolefront": ["saler"],
    "isActive": true,
    "instanceName": "Empresa X",
    "instanceDbName": "empresa_x",
    "instanceDbHost": "mysql.server.com",
    "user": {
      "email": "joao@example.com",
      "phone": "+5511999999999",
      "name": "João Silva",
      "isRoot": false,
      "isActive": true
    }
  }
]

// include=database
[
  {
    "id": 42,
    "userId": "cuid2string",
    "dbId": "cuid2string",
    "idBackendUser": null,
    "roleback": "user",
    "rolefront": ["saler"],
    "isActive": true,
    "instanceName": "Empresa X",
    "instanceDbName": "empresa_x",
    "instanceDbHost": "mysql.server.com",
    "database": {
      "name": "Empresa X",
      "maxCompanies": 5,
      "maxUsers": 20,
      "isActive": true
    }
  }
]
```

**Erros comuns:**

| Status | Motivo |
|---|---|
| `400` | `include` informado com valor diferente de `user` ou `database` |
| `404` | Nenhum vínculo encontrado para o `dbId` |

---

### `GET /user-instances/:id`

Retorna um vínculo específico pelo `id` numérico.

**Auth:** `JwtGuard` (usuário só pode ver seu próprio vínculo — comparação direta `req.user.userId === userInstance.userId`)

**Path params:** `id` (integer)

**Resposta `200`:** `ResponseUserInstanceDto`.

**Erros comuns:**

| Status | Motivo |
|---|---|
| `403` | Vínculo pertence a outro usuário |
| `404` | Vínculo não encontrado |

---

### `PATCH /user-instances/:id`

Atualiza roles ou status de ativação de um vínculo.

**Auth:** `JwtGuard` + `AdminGuard`

> **Bloqueio supervisor → admin:** se o solicitante **não é `isRoot`** e tem `roleBack = supervisor`, a chamada é rejeitada com `403` quando o vínculo alvo (`existing.roleback`) é `admin`. Supervisores podem atualizar qualquer vínculo de role `user`/`supervisor`/`notallow`, mas não podem mexer em administradores.

**Path params:** `id` (integer)

**Body (JSON) — todos opcionais:**

| Campo | Tipo | Descrição |
|---|---|---|
| `roleback` | string | Nova role no BackOffice |
| `rolefront` | string[] | Novo array de papéis no Web App (`RoleFrontEnum[]`, não vazio). Sujeito à mesma regra de exclusividade `saler` × `supersaler` |
| `isActive` | boolean | Ativar/desativar o vínculo |

**Resposta `200`:** vínculo atualizado (`ResponseUserInstanceDto`).

**Erros comuns:**

| Status | Motivo |
|---|---|
| `403` | Supervisor tentando alterar um vínculo cujo `roleback` é `admin` |
| `404` | Vínculo não encontrado |

---

### `DELETE /user-instances/:id`

Remove um vínculo usuário-instância.

**Auth:** `JwtGuard` + `AdminGuard`

> **Bloqueio supervisor → admin:** mesma regra do `PATCH` — supervisores não podem remover vínculos com `roleback = admin` (`403 Forbidden`).

**Path params:** `id` (integer)

**Resposta `200`:**

```jsonc
{ "message": "Usuário X Instância deletada com sucesso" }
```

**Erros comuns:**

| Status | Motivo |
|---|---|
| `403` | Supervisor tentando remover um vínculo cujo `roleback` é `admin` |
| `404` | Vínculo não encontrado |

---

## Pré-cadastro (Convite)

Fluxo de convite para novos usuários sem conta prévia.

```
POST /user-pre/create     → cria convite e envia e-mail
GET  /user-pre/my-invites → admin lista convites enviados por ele
POST /user-pre/resend     → reenvia e-mail (mantém token)
POST /user-pre/regenerate → gera novo token + nova expiração e reenvia
GET  /user-pre/check      → frontend valida token do link (público)
POST /user-pre/confirm    → cria conta e vínculo(s) definitivos (público)
```

> Token: `randomBytes(88).toString('hex')` — 176 caracteres. Validade: **12 horas**.
>
> Se o e-mail já tem `user` ativo → `401`. Se já existe `user_pre` válido → `401`. Se já existe `user_pre` expirado → o registro antigo é deletado e um novo convite é criado.

---

### `POST /user-pre/create`

Cria um convite (pré-cadastro) e envia e-mail ao convidado. O `userId` do admin autenticado é gravado como `userInviteId`.

**Auth:** `JwtGuard` + `AdminGuard`

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `email` | string | ✅ | E-mail do convidado (formato válido). Único — não pode existir em `user` ou em `user_pre` válido |
| `dblist` | `RelationUserPreDto[]` | ✅ | Lista (≥ 1) de tenants aos quais o usuário será vinculado ao confirmar. Cada item descreve um vínculo com suas roles |

#### `RelationUserPreDto` (cada item de `dblist`)

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `dbId` | string | ✅ | CUID2 da instância/tenant ao qual o usuário será vinculado ao confirmar |
| `roleBack` | string (enum) | ✅ | Papel no BackOffice. Valores: `admin \| supervisor \| user \| notallow` |
| `roleFront` | string[] | ✅ | Array **não vazio** de papéis no Web App. Valores: `admin \| supersaler \| saler \| inventory \| buyer \| notallow`. Pode acumular múltiplos papéis (ex.: `["admin","supersaler"]`). Regra: `saler` e `supersaler` **não podem coexistir** no mesmo vínculo (`400 Bad Request` em caso contrário) |
| `idBackendUser` | integer \| null | ❌ | ID do usuário no sistema legado do tenant (BackOffice desktop). Se omitido ou `null`, fica nulo |

> ⚠️ A nomenclatura aqui é `roleBack` / `roleFront` (camelCase). Após o `confirm`, esses dados são copiados para `user_instances` cujos campos são `roleback` / `rolefront` (lowercase).

**Exemplo de body:**

```jsonc
{
  "email": "novo.usuario@empresa.com.br",
  "dblist": [
    {
      "dbId": "cuid2string-tenant-a",
      "roleBack": "user",
      "roleFront": ["saler"],
      "idBackendUser": 102
    },
    {
      "dbId": "cuid2string-tenant-b",
      "roleBack": "admin",
      "roleFront": ["admin", "supersaler"]
    }
  ]
}
```

**Resposta `201`:**

```jsonc
{
  "userPreId": 17,
  "email": "novo.usuario@empresa.com.br",
  "token": "a3c1...e9f0",                  // 176 chars hex
  "expiresAt": "2026-05-09T02:30:00.000Z", // agora + 12h
  "userInviteId": "cuid2string-admin"      // userId do admin autenticado
}
```

**Erros comuns:**

| Status | Motivo |
|---|---|
| `401` | E-mail já existe em `user` ou em `user_pre` válido (não-expirado) |
| `403` | Token sem permissão de admin |

---

### `GET /user-pre/my-invites`

Lista todos os convites enviados pelo admin autenticado (filtra por `userInviteId = req.user.userId`). Retorna apenas os metadados do convite — não inclui as instâncias (`user_pre_instances`).

**Auth:** `JwtGuard` + `AdminGuard`

**Resposta `200`:**

```jsonc
[
  {
    "userPreId": 17,
    "email": "novo.usuario@empresa.com.br",
    "token": "a3c1...e9f0",
    "expiresAt": "2026-05-09T02:30:00.000Z",
    "userInviteId": "cuid2string-admin"
  }
]
```

---

### `POST /user-pre/resend`

Reenvia o e-mail de convite **sem alterar o token nem a expiração**. Útil quando o convidado simplesmente perdeu o e-mail e o token ainda é válido.

**Auth:** `JwtGuard` + `AdminGuard`

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `email` | string | ✅ | E-mail do convite a reenviar |

**Resposta `204 No Content`:** sem corpo.

**Erros comuns:**

| Status | Motivo |
|---|---|
| `404` | Não há convite pendente para este e-mail |

---

### `POST /user-pre/regenerate`

Gera **novo token** (e nova `expiresAt = agora + 12h`) para um convite existente e reenvia o e-mail. Usado quando o token original expirou ou foi comprometido.

**Auth:** `JwtGuard` + `AdminGuard`

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `email` | string | ✅ | E-mail do convite a regenerar |

**Resposta `204 No Content`:** sem corpo.

**Erros comuns:**

| Status | Motivo |
|---|---|
| `404` | Não há convite para este e-mail |

---

### `GET /user-pre/check`

Valida o par `email + token` do link de convite (chamado pelo frontend antes de exibir o formulário de confirmação). Se o token estiver expirado, **o registro `user_pre` é deletado** e a chamada retorna `401` — após isso, é necessário um novo `regenerate` (ou novo `create`).

**Auth:** nenhuma

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `email` | string | ✅ | E-mail do convidado |
| `token` | string | ✅ | Token recebido no link do e-mail |

**Resposta `200`:** registro `user_pre` correspondente:

```jsonc
{
  "userPreId": 17,
  "email": "novo.usuario@empresa.com.br",
  "token": "a3c1...e9f0",
  "expiresAt": "2026-05-09T02:30:00.000Z",
  "userInviteId": "cuid2string-admin"
}
```

**Erros comuns:**

| Status | Motivo |
|---|---|
| `404` | Par `email + token` não encontrado |
| `401` | Token expirado (registro foi deletado nesta chamada) |

---

### `POST /user-pre/confirm`

Finaliza o cadastro:
1. Revalida o token (mesmas regras de `GET /user-pre/check`).
2. Verifica que o `user.email` do body é igual ao `check.email` (anti-tampering).
3. Cria o `user` definitivo (com hash de senha + e-mail de boas-vindas).
4. Para cada `user_pre_instances` registrado no convite, cria um `user_instances` com `isActive: true` (copiando `dbId`, `idBackendUser`, `roleback`, `rolefront`).
5. Deleta o registro `user_pre` (cascateia para `user_pre_instances`).

**Auth:** nenhuma

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `user` | `CreateUserDto` | ✅ | Dados do novo usuário: `name`, `email`, `phone`, `password` (mesmo shape de `POST /users`) |
| `check` | `CheckUserPreDto` | ✅ | `{ email, token }` — credenciais do convite |

> Apesar de declarados `@IsOptional()` no DTO, ambos os blocos são efetivamente obrigatórios — sua ausência gera erro no service.

**Exemplo de body:**

```jsonc
{
  "user": {
    "name": "João Silva",
    "email": "novo.usuario@empresa.com.br",
    "phone": "+5511999999999",
    "password": "SenhaSegura1"
  },
  "check": {
    "email": "novo.usuario@empresa.com.br",
    "token": "a3c1...e9f0"
  }
}
```

**Resposta `201`:** `ResponseUserDto` (sem o campo `password`):

```jsonc
{
  "userId": "cuid2string",
  "name": "João Silva",
  "email": "novo.usuario@empresa.com.br",
  "phone": "+5511999999999",
  "isRoot": false,
  "isActive": true
}
```

**Erros comuns:**

| Status | Motivo |
|---|---|
| `401` | `user.email ≠ check.email`, ou token inválido/expirado |
| `404` | Convite não encontrado |

---

## Tenant

### `GET /tenant/emitentes`

Lista as empresas (emitentes) disponíveis para o tenant do usuário autenticado. Usado pelo frontend para montar o seletor de empresa antes de chamar endpoints de domínio.

**Auth:** `JwtGuard` + `UserInstanceGuard` (token etapa 2)

**Resposta `200`:**

```jsonc
[
  {
    "id": 1,          // integer — ID da empresa no banco do tenant (idemp)
    "nome": "Empresa Principal Ltda",
    "docfed": "12.345.678/0001-90"  // CNPJ
  }
]
```

---

### `GET /tenant/cfg`

Retorna o valor e a descrição de um parâmetro de configuração da tabela `cfg` do banco do tenant autenticado.

**Auth:** `JwtGuard` + `UserInstanceGuard` (token etapa 2)

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `param` | string | ✅ | Nome do parâmetro (chave na tabela `cfg`) |

**Resposta `200`:**

```jsonc
{
  "valor": "SELECT ...",                       // valor armazenado
  "descricao": "Condição SQL para operações"   // pode ser null
}
```

**Erros comuns:**

| Status | Motivo |
|---|---|
| `404` | Parâmetro não encontrado no banco do tenant |

---

### `GET /tenant/usu/backoffice`

Lista os usuários do sistema legado do tenant (tabela `usu`) **da empresa solicitada** (`idemp`) que ainda **não** estão vinculados a um usuário da API (`usu.userId IS NULL`) e que estão **ativos** (`NOT usu.inativo`). Usado pelo back-office para popular o seletor de vínculo entre um usuário da API e uma conta do legado.

**Auth:** `JwtGuard` + `UserInstanceGuard` + `AdminGuard` (token etapa 2)

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `idemp` | integer | ✅ | ID da empresa (emitente) no banco do tenant. Deve pertencer ao usuário autenticado (validado via `usuemp` em `EmpService.listEmitentes`) — caso contrário, retorna `403 Forbidden` |

**Filtro SQL aplicado:**

```sql
SELECT u.id, u.login
FROM usu u
INNER JOIN usuemp ue ON ue.idusu = u.id
WHERE u.userId IS NULL
  AND NOT u.inativo
  AND ue.idcnt = ?      -- idemp
ORDER BY u.login
```

**Resposta `200`:**

```jsonc
[
  { "id": 12, "login": "carlos.silva" },
  { "id": 27, "login": "maria.santos" }
]
```

> A resposta é um array simples (sem paginação e sem `total`). Útil para popular um `<select>` no front durante o vínculo de um novo usuário da API a uma conta do legado da empresa em foco.

**Erros comuns:**

| Status | Motivo |
|---|---|
| `403` | `idemp` não pertence ao usuário autenticado, ou token sem permissão de admin |

---

### `PATCH /tenant/usu/:id`

Self-service: o usuário autenticado atualiza os dados básicos do **seu próprio** registro `usu` no legado. O update só prossegue se o `usu` informado em `:id` tiver `userId = body.userId = req.user.userId`.

**Auth:** `JwtGuard` + `UserInstanceGuard` (token etapa 2)

**Path params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `id` | integer | ✅ | ID do registro `usu` no banco do tenant |

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `userId` | string | ✅ | `userId` (CUID2) do solicitante. **Deve ser idêntico ao `userId` do token** — caso contrário, retorna `403 Forbidden`. Serve como confirmação explícita de que o usuário está atualizando o próprio registro; o valor não é gravado novamente |
| `nome` | string | ❌ | Novo nome (máx. 60 chars) |
| `email` | string | ❌ | Novo e-mail (formato válido, máx. 100 chars) |
| `telefone` | string | ❌ | Novo telefone (máx. 60 chars) |

> Apenas os campos enviados em `nome`, `email`, `telefone` são alterados. Campos ausentes não são tocados. Se nenhum dos três for enviado, a chamada é no-op (sem `UPDATE`).

**Exemplo de body:**

```jsonc
{
  "userId": "cuid2string-do-token",
  "nome": "João da Silva",
  "email": "joao@empresa.com.br",
  "telefone": "+5511999998888"
}
```

**Resposta `204 No Content`:** sem corpo.

**Erros comuns:**

| Status | Motivo |
|---|---|
| `403` | `body.userId` diferente do `userId` do token |
| `404` | Não existe `usu` com `id = :id AND userId = body.userId` no banco do tenant |

---

## Infra — AWS S3

Base: `/infra/aws-s3` — `JwtGuard` em todos os endpoints.

---

### `POST /infra/aws-s3/uploadfile/local`

Upload de arquivo para o servidor local (pasta `UPLOAD_PATH`).

**Auth:** `JwtGuard`

**Body:** `multipart/form-data`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `file` | binary | ✅ | Arquivo (máximo 150 MB) |
| `folderName` | string | ✅ | Caminho da pasta de destino (somente alfanumérico, `_`, `-`, `/`) |
| `fileName` | string | ✅ | Nome do arquivo de destino (somente alfanumérico, `_`, `-`, `/`, `.`) |
| `bucket` | string | ❌ | Nome do bucket (ignorado neste endpoint, mas aceito pelo DTO) |

**Resposta `201`:** resultado do upload com o caminho gerado.

---

### `POST /infra/aws-s3/uploadfile`

Upload de arquivo para o AWS S3 (bucket público).

**Auth:** `JwtGuard`

**Body:** `multipart/form-data` — mesmos campos de `uploadfile/local`, com `bucket` opcional.

**Resposta `201`:** resultado com URL pública do S3.

---

### `POST /infra/aws-s3/uploadfile/private`

Upload de arquivo para o AWS S3 (bucket privado).

**Auth:** `JwtGuard`

**Body:** `multipart/form-data` — mesmos campos, `bucket` obrigatório.

**Resposta `201`:** resultado com chave S3 do objeto privado.

---

### `DELETE /infra/aws-s3/deletefile/local`

Remove um arquivo do servidor local.

**Auth:** `JwtGuard`

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `folderName` | string | ✅ | Pasta do arquivo |
| `fileName` | string | ✅ | Nome do arquivo |

**Resposta `200`:** resultado da remoção.

---

### `DELETE /infra/aws-s3/deletefile`

Remove um arquivo do AWS S3.

**Auth:** `JwtGuard`

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `folderName` | string | ✅ | Pasta (prefixo S3) |
| `fileName` | string | ✅ | Nome do arquivo |
| `bucket` | string | ✅ | Nome do bucket S3 |

**Resposta `200`:** resultado da remoção.

---

## Infra — AWS SES

Base: `/infra/aws-ses` — `JwtGuard` em todos os endpoints.

Gerencia identidades verificadas no AWS SES (domínios e e-mails remetentes).

---

### `POST /infra/aws-ses/new/domain`

Registra um domínio como identidade SES.

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `domain` | string | ✅ | Domínio a verificar (ex: `empresa.com.br`) |

**Resposta `201`:** status da identidade criada.

---

### `POST /infra/aws-ses/new/email`

Registra um e-mail como identidade SES (envia e-mail de verificação à caixa).

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `emailAddress` | string | ✅ | Endereço de e-mail a verificar |

**Resposta `201`:** status da identidade criada.

---

### `GET /infra/aws-ses/identities/check`

Verifica o status de verificação de uma identidade SES.

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `identity` | string | ✅ | E-mail ou domínio a consultar |

**Resposta `200`:** status de verificação da identidade.

---

### `DELETE /infra/aws-ses/identities/delete`

Remove uma identidade SES.

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `identity` | string | ✅ | E-mail ou domínio a remover |

**Resposta `200`:** resultado da remoção.

---

### `GET /infra/aws-ses/list`

Lista todas as identidades SES cadastradas. Com paginação cursor-based.

**Auth:** `JwtGuard` + `RootGuard`

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `pageSize` | integer (1–1000) | ❌ | Quantidade de itens por página (default da AWS SES) |
| `nextToken` | string | ❌ | Token de cursor para próxima página (retornado na resposta anterior) |

**Resposta `200`:** lista de identidades com `nextToken` para paginação.

---

## Infra — SQL Files

Base: `/sql-files` — `JwtGuard` em todos os endpoints.

Catálogo de scripts SQL de atualização do banco do tenant.

---

### `POST /sql-files`

Cadastra um novo arquivo SQL.

**Auth:** `JwtGuard` + `RootGuard`

**Body:** `multipart/form-data`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `sqlFile` | binary | ✅ | Arquivo `.sql` (máximo 10 MB) |
| `idSystem` | number | ✅ | ID do sistema ao qual o script pertence |
| `tipo` | string (enum) | ✅ | Tipo do script: valores de `SqlFilesTipo` |
| `versaoDb` | number | ✅ | Versão do banco que o script implementa (ex: `2.39`) |
| `obs` | string | ❌ | Observação sobre o script |

**Resposta `201`:** registro do arquivo criado.

---

### `GET /sql-files`

Lista todos os arquivos SQL cadastrados.

**Auth:** `JwtGuard` + `RootGuard`

**Resposta `200`:** array de `SqlFile`.

---

### `GET /sql-files/:id`

Retorna metadados de um arquivo SQL específico.

**Auth:** `JwtGuard`

**Path params:** `id` (integer)

**Resposta `200`:** objeto `SqlFile`.

---

### `GET /sql-files/download/:id`

Retorna o conteúdo do arquivo SQL em base64.

**Auth:** `JwtGuard`

**Path params:** `id` (integer)

**Resposta `200`:**

```jsonc
{
  "idSql": 7,
  "sqlData": "Q1JFQVRFIFRA..."  // conteúdo do .sql em base64
}
```

---

### `GET /sql-files/system/:id/updates/:version`

Retorna os scripts de atualização incremental a partir de uma versão.

**Auth:** `JwtGuard`

**Path params:**

| Param | Tipo | Descrição |
|---|---|---|
| `id` | integer | ID do sistema |
| `version` | string/number | Versão base do tenant (scripts > esta versão são retornados) |

**Resposta `200`:** array de `SqlFile` ordenado por versão.

---

### `GET /sql-files/system/:id`

Retorna o último release completo (full) do sistema.

**Auth:** `JwtGuard`

**Path params:** `id` (integer — ID do sistema)

**Resposta `200`:** objeto `SqlFile` do último full.

---

### `GET /sql-files/system/:id/bydays/:days`

Retorna arquivos SQL criados nos últimos N dias para um sistema.

**Auth:** `JwtGuard` + `RootGuard`

**Path params:**

| Param | Tipo | Descrição |
|---|---|---|
| `id` | integer | ID do sistema |
| `days` | integer | Quantidade de dias para olhar para trás |

**Resposta `200`:** array de `SqlFile`.

---

### `PATCH /sql-files/:id`

Atualiza metadados de um arquivo SQL.

**Auth:** `JwtGuard` + `RootGuard`

**Path params:** `id` (integer)

**Body:** qualquer subconjunto dos campos de `POST /sql-files` (exceto o arquivo binário).

**Resposta `200`:** registro atualizado.

---

### `DELETE /sql-files/:id`

Remove um arquivo SQL.

**Auth:** `JwtGuard` + `RootGuard`

**Path params:** `id` (integer)

**Resposta `200`:** resultado da remoção.

---

## Infra — Sys Files

Base: `/sys-files` — `JwtGuard` em todos os endpoints.

Catálogo de pacotes de sistema (instaladores, atualizações de aplicativo).

---

### `POST /sys-files`

Cadastra um novo pacote de sistema.

**Auth:** `JwtGuard` + `RootGuard`

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `tipo` | string (enum) | ✅ | Tipo do pacote: valores de `SysFilesTipo` |
| `versao` | number | ✅ | Versão do pacote (ex: `3.5`) |
| `fileName` | string | ✅ | Nome do arquivo |
| `idSystem` | integer | ❌ | ID do sistema ao qual o pacote pertence |
| `url` | string | ❌ | URL pública de download |
| `s3Key` | string | ❌ | Chave S3 para download privado |

**Resposta `201`:** registro criado.

---

### `GET /sys-files`

Lista todos os pacotes de sistema.

**Auth:** `JwtGuard` + `RootGuard`

**Resposta `200`:** array de `SysFile`.

---

### `GET /sys-files/:idfile`

Retorna um pacote específico.

**Auth:** `JwtGuard`

**Path params:** `idfile` (integer)

**Resposta `200`:** objeto `SysFile`.

---

### `GET /sys-files/system/:id/releases/:version/:versionDb`

Retorna releases menores (minor) disponíveis para um sistema a partir de uma versão.

**Auth:** `JwtGuard`

**Path params:**

| Param | Tipo | Descrição |
|---|---|---|
| `id` | integer | ID do sistema |
| `version` | string/number | Versão atual do app instalado |
| `versionDb` | string/number | Versão atual do banco do tenant |

**Resposta `200`:** array de `SysFile`.

---

### `GET /sys-files/system/:id/fullpack/:versionDb`

Retorna o pacote completo (full release) mais recente para um sistema.

**Auth:** `JwtGuard`

**Path params:**

| Param | Tipo | Descrição |
|---|---|---|
| `id` | integer | ID do sistema |
| `versionDb` | string/number | Versão do banco do tenant |

**Resposta `200`:** objeto `SysFile`.

---

### `GET /sys-files/system/:id/bydays/:days`

Retorna pacotes publicados nos últimos N dias.

**Auth:** `JwtGuard` + `RootGuard`

**Path params:**

| Param | Tipo | Descrição |
|---|---|---|
| `id` | integer | ID do sistema |
| `days` | integer | Quantidade de dias para olhar para trás |

**Resposta `200`:** array de `SysFile`.

---

### `PATCH /sys-files/:id`

Atualiza metadados de um pacote.

**Auth:** `JwtGuard` + `RootGuard`

**Path params:** `id` (integer)

**Body:** qualquer subconjunto dos campos de `POST /sys-files`.

**Resposta `200`:** registro atualizado.

---

### `DELETE /sys-files/:id`

Remove um pacote.

**Auth:** `JwtGuard` + `RootGuard`

**Path params:** `id` (integer)

**Resposta `200`:** resultado da remoção.
