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
| `AdminGuard` | `isRoot = true` **OU** `roleBack ∈ {admin, supervisor}` **OU** `roleFront = supervisor` | `403 Forbidden` |
| `RootGuard` | `isRoot = true` (superadmin global) | `403 Forbidden` |
| `RolesFrontGuard` | `roleFront` do token pertence ao conjunto exigido pelo endpoint | `403 Forbidden` |
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
| `roleFront` | string | Role no Web App: `supervisor \| saler \| buyer \| notallow` |

**Erros comuns:**

| Status | Motivo |
|---|---|
| `403` | Vínculo inativo, ou versão do banco do tenant abaixo do mínimo (`MIN_TENANT_DB`) |

---

### `POST /auth/refresh`

Renova o par de tokens. O `refreshToken` anterior é invalidado (uso único — rotação automática).

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
  "roleFront": "saler"           // null/undefined se token etapa 1
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
| `enum` | `rolefront` | Valores possíveis de `RoleFront` |

**Resposta `200`:**

```jsonc
// GET /backend/enums/roleback
["admin", "supervisor", "user", "notallow"]

// GET /backend/enums/rolefront
["supervisor", "saler", "buyer", "notallow"]
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

**Resposta `200`:** usuário atualizado (mesmo shape de `POST /users`).

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

**Auth:** `JwtGuard` + `RootGuard`

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `userId` | string | ✅ | CUID2 do usuário |
| `dbId` | string | ✅ | CUID2 da instância/tenant |
| `roleback` | string | ✅ | Role no BackOffice: `admin \| supervisor \| user \| notallow` |
| `rolefront` | string | ✅ | Role no Web App: `supervisor \| saler \| buyer \| notallow` |
| `idBackendUser` | integer | ❌ | ID do usuário no sistema legado do tenant (BackOffice desktop) |

**Resposta `201`:**

```jsonc
{
  "id": 42,
  "userId": "cuid2string",
  "dbId": "cuid2string",
  "roleback": "user",
  "rolefront": "saler",
  "idBackendUser": null,
  "isActive": true
}
```

---

### `GET /user-instances/user/:userId`

Lista todos os tenants vinculados a um usuário.

**Auth:** `JwtGuard` (usuário só pode ver seus próprios vínculos, exceto `isRoot`)

**Path params:** `userId` (CUID2 do usuário)

**Resposta `200`:** array de vínculos com o shape de `POST /user-instances`, incluindo dados da instância embutidos.

---

### `GET /user-instances/db/:dbId`

Lista todos os usuários vinculados a um tenant.

**Auth:** `JwtGuard` + `RootGuard`

**Path params:** `dbId` (CUID2 da instância)

**Resposta `200`:** array de vínculos.

---

### `GET /user-instances/:id`

Retorna um vínculo específico pelo `id` numérico.

**Auth:** `JwtGuard` (usuário só pode ver seus próprios vínculos, exceto `isRoot`)

**Path params:** `id` (integer)

**Resposta `200`:** mesmo shape de `POST /user-instances`.

---

### `PATCH /user-instances/:id`

Atualiza roles ou status de ativação de um vínculo.

**Auth:** `JwtGuard` + `RootGuard`

**Path params:** `id` (integer)

**Body (JSON) — todos opcionais:**

| Campo | Tipo | Descrição |
|---|---|---|
| `roleback` | string | Nova role no BackOffice |
| `rolefront` | string | Nova role no Web App |
| `isActive` | boolean | Ativar/desativar o vínculo |

**Resposta `200`:** vínculo atualizado.

---

### `DELETE /user-instances/:id`

Remove um vínculo usuário-instância.

**Auth:** `JwtGuard` + `RootGuard`

**Path params:** `id` (integer)

**Resposta `200`:**

```jsonc
{ "message": "Vínculo removido com sucesso" }
```

---

## Pré-cadastro (Convite)

Fluxo de convite para novos usuários sem conta prévia.

```
POST /user-pre/create → envia convite por e-mail
GET  /user-pre/check  → frontend valida token do link
POST /user-pre/confirm → cria conta e vínculo(s) definitivos
```

---

### `POST /user-pre/create`

Cria um convite (pré-cadastro) e envia e-mail ao convidado.

**Auth:** `JwtGuard` + `AdminGuard`

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `email` | string | ❌ | E-mail do convidado |
| `dblist` | array | ❌ | Lista de instâncias às quais o usuário será vinculado ao confirmar |

**Resposta `201`:** objeto `UserPre` criado.

---

### `GET /user-pre/check`

Valida o token do link de convite (exibido antes do formulário de confirmação).

**Auth:** nenhuma

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `email` | string | ✅ | E-mail do convidado |
| `token` | string | ✅ | Token do link de convite |

**Resposta `200`:** resultado da validação do token.

---

### `POST /user-pre/confirm`

Finaliza o cadastro: cria o usuário definitivo, cria os vínculos de instância e remove o registro de pré-cadastro.

**Auth:** nenhuma

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `user` | object | ❌ | Dados para criar o usuário (mesmo shape de `CreateUserDto`) |
| `check` | object | ❌ | Dados de validação do token |

**Resposta `200`:** resultado da confirmação.

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
