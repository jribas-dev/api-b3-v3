# Módulo `auth` — Especificação (SDD)

## Responsabilidade

Servidor de autorização da API. Gerencia todo o ciclo de vida de autenticação: login em duas etapas, emissão e renovação de tokens JWT, logout com blacklist, proteção contra força bruta e redefinição de senha por e-mail.

---

## Estrutura de Arquivos

```
src/auth/
├── auth.module.ts
├── auth.controller.ts           # POST /auth/login, /auth/instance, /auth/refresh, /auth/logout
├── auth.service.ts
├── jwt/
│   ├── jwt.payload.interface.ts # Contrato do payload JWT
│   └── jwt.strategy.ts          # Passport strategy — valida token + verifica blacklist
├── guards/
│   ├── jwt.guard.ts             # Valida assinatura + blacklist
│   ├── user-instance.guard.ts   # Exige dbId no payload (token de instância)
│   ├── roles-back.guard.ts      # RBAC backend; @AllowRoot() permite superadmin
│   ├── roles-front.guard.ts     # RBAC frontend
│   └── root.guard.ts            # Exclusivo ao superadmin (isRoot === true)
├── decorators/
│   ├── roles-back.decorator.ts  # @RolesBack(...roles)
│   └── roles-front.decorator.ts # @RolesFront(...roles)
├── black-list/
│   ├── black-list.module.ts
│   ├── black-list.entity.ts     # Tabela: token_blacklist
│   └── black-list.service.ts
├── refresh-token/
│   ├── refresh-token.entity.ts  # Tabela: token_refresh
│   └── refresh-token.service.ts
├── login-attempt/
│   └── login-attempt.service.ts # Rate-limiting em memória (Map)
├── password/
│   └── password.service.ts      # bcrypt, saltRounds=12
└── reset-password/
    ├── reset-password.controller.ts  # POST /auth/reset-password, GET /check, POST /update
    ├── reset-password.entity.ts      # Tabela: token_reset
    └── reset-password.service.ts
```

---

## Fluxo de Autenticação em Duas Etapas

```
[Cliente]
  │
  ├─ POST /auth/login  { email, password }
  │       ↓  verifica rate-limit → valida credenciais → bcrypt compare
  │       ← { accessToken (JWT 30 min, payload: sub/email/isRoot), tokenType, expiresIn }
  │
  ├─ POST /auth/instance  { dbId }   [Authorization: Bearer <accessToken step-1>]
  │       ↓  JwtGuard → valida UserInstance (userId + dbId)
  │       ↓  verifica VERSAO_DB do tenant ≥ MIN_TENANT_DB (env, default 2.38)
  │       ↓  se versão insuficiente → 403 Forbidden (token NÃO emitido)
  │       ↓  emite token com escopo
  │       ← { isActive, accessToken (JWT 180 min, payload completo), refreshToken, tokenType, expiresIn }
  │
  ├─ POST /auth/refresh  { refreshToken }
  │       ↓  valida token_refresh (não revogado, não expirado) → gera novo par
  │       ← { isActive, accessToken, refreshToken, tokenType, expiresIn }
  │
  └─ POST /auth/logout   [Authorization: Bearer <accessToken step-2>]
          ↓  JwtGuard + UserInstanceGuard → insere token na blacklist até expiresAt
          ← { message: 'Logout realizado com sucesso' }
```

---

## Payload JWT

### Etapa 1 — Token de login (30 min)

| Campo   | Tipo    | Descrição               |
|---------|---------|-------------------------|
| `sub`   | string  | `userId` (CUID2)        |
| `email` | string  | E-mail do usuário       |
| `isRoot`| boolean | Superadmin global       |

### Etapa 2 — Token de instância (180 min)

Herda os campos acima e acrescenta:

| Campo          | Tipo       | Descrição                          |
|----------------|------------|------------------------------------|
| `instanceName` | string     | Nome da instância tenant           |
| `dbId`         | string     | ID da instância (discriminador)    |
| `roleBack`     | RoleBack   | Role de acesso backend             |
| `roleFront`    | RoleFront  | Role de acesso frontend            |

---

## Guards — Regras de Aplicação

| Guard               | Pré-requisito no token | Comportamento ao falhar  |
|---------------------|------------------------|--------------------------|
| `JwtGuard`          | Assinatura válida + não na blacklist | 401 Unauthorized |
| `UserInstanceGuard` | `dbId` presente (token etapa 2) | 403 Forbidden |
| `RolesBackGuard`    | `roleBack` ∈ roles declaradas OU `isRoot && @AllowRoot()` | 403 Forbidden |
| `RolesFrontGuard`   | `roleFront` ∈ roles declaradas | 403 Forbidden |
| `RootGuard`         | `isRoot === true` | 403 Forbidden |

**Ordem típica em endpoints protegidos:**
```ts
@UseGuards(JwtGuard, UserInstanceGuard, RolesBackGuard)
@RolesBack(RoleBack.ADMIN, RoleBack.MANAGER)
```

---

## Proteção contra Força Bruta (`LoginAttemptService`)

- Estado em memória (`Map<identifier, AttemptInfo>`) — não persiste entre reinicializações.
- Identificador: `IP::User-Agent`.
- Limite: **5 tentativas** antes do bloqueio.
- Duração do bloqueio: **1 hora**.
- Avisos progressivos nas tentativas 3 e 4.
- Tentativa bem-sucedida zera o contador.

> **Limitação conhecida:** o estado é volátil. Em múltiplas instâncias ou após restart, o contador é zerado. Para ambientes de produção com escala horizontal, substituir por solução persistente (Redis).

---

## Refresh Token (`token_refresh`)

| Coluna       | Tipo    | Descrição                               |
|--------------|---------|-----------------------------------------|
| `id`         | int (PK)| Auto-increment                          |
| `token`      | string  | 64 bytes aleatórios em hex (128 chars)  |
| `userInstance` | FK    | Cascata ON DELETE                       |
| `isRevoked`  | boolean | `false` padrão; `true` após uso/logout  |
| `expiresAt`  | Date    | 7 dias + 1 hora a partir da emissão     |
| `createdAt`  | Date    | Automático                              |

**Rotação:** a cada `/auth/refresh`, o token antigo é revogado (`isRevoked = true`) e um novo par é emitido.

---

## Blacklist de Tokens (`token_blacklist`)

| Coluna      | Tipo    | Descrição                               |
|-------------|---------|-----------------------------------------|
| `id`        | int (PK)| Auto-increment                          |
| `token`     | string  | JWT completo (max 512 chars, indexado)  |
| `expiresAt` | Date    | Expiração original do JWT               |
| `createdAt` | Date    | Automático                              |

- Tokens são inseridos no logout com o `expiresAt` original do JWT.
- `JwtStrategy.validate()` consulta a blacklist a cada requisição autenticada.
- Limpeza de tokens expirados: `BlacklistService.cleanupExpired()` (deve ser chamado por job agendado — não há scheduler configurado atualmente).

---

## Reset de Senha (`token_reset`)

**Fluxo:**
```
POST /auth/reset-password  { email }
  → gera token (176 chars hex) → salva em token_reset (TTL 1h)
  → envia e-mail via SES com link: FRONTEND_URL/auth/reset-password/?token=&email=

GET /auth/reset-password/check?token=&email=
  → valida existência + expiração
  ← { isValid, name, email }

POST /auth/reset-password/update  { token, email, password }
  → revalida token → faz hash bcrypt da nova senha → salva → deleta registro token_reset
  ← { passwordUpdated, name, email }
```

**Entidade `token_reset`:**

| Coluna     | Tipo    | Descrição                         |
|------------|---------|-----------------------------------|
| `id`       | int (PK)| Auto-increment                    |
| `token`    | string  | 88 bytes hex (176 chars), único   |
| `user`     | FK      | Cascata ON DELETE                 |
| `expiresAt`| Date    | 1 hora após criação               |

---

## Serviços Internos

| Serviço               | Responsabilidade                                              |
|-----------------------|---------------------------------------------------------------|
| `AuthService`         | Orquestra validate, login, loginInstance, refresh, logout     |
| `PasswordService`     | `hashPassword` / `comparePasswords` via bcrypt (salt 12)      |
| `RefreshTokenService` | `generate` / `validate` / `revoke`                           |
| `BlacklistService`    | `addToken` / `isBlacklisted` / `cleanupExpired`              |
| `LoginAttemptService` | `getIdentifier` / `shouldBlock` / `registerFailure` / `resetAttempts` |
| `ResetPasswordService`| `requestPasswordReset` / `checkToken` / `updatePassword`     |

---

## Dependências Externas

- **`UserService`** — busca usuário por e-mail, retorna hash da senha.
- **`UserInstanceService`** — `findValid(userId, dbId)` para validar vínculo User↔Instance.
- **`AwsSenderService`** — envia e-mail de reset via SES com template `TemplateType.PASSWORD_RESET`.
- **`CfgService`** (TenantModule) — lê `VERSAO_DB` da tabela `cfg` do tenant para validação de versão mínima.

---

## Invariantes e Regras de Negócio

1. Credenciais inválidas **nunca** informam qual campo está errado (mensagem genérica `'Credenciais inválidas'`).
2. O token de etapa 1 não concede acesso a recursos de tenant — apenas à rota `/auth/instance`.
3. Somente tokens de etapa 2 (`dbId` presente) passam pelo `UserInstanceGuard`.
4. `isRoot` no payload concede bypass em guards que declaram `@AllowRoot()`; `RootGuard` exige exclusivamente `isRoot === true`.
5. O refresh token é de uso único — sempre revogado após rotação.
6. Tokens na blacklist são rejeitados na `JwtStrategy`, mesmo que a assinatura seja válida.
7. Reset de senha expira em 1 hora; o registro é deletado após uso bem-sucedido.
8. Na etapa 2, a versão do banco do tenant (`cfg.VERSAO_DB`) é verificada contra `MIN_TENANT_DB` (env, default `2.38`). Versão inferior → **403 Forbidden**, token não emitido. Se `VERSAO_DB` não existir na tabela `cfg`, o acesso é permitido (graceful degradation para tenants não migrados).
