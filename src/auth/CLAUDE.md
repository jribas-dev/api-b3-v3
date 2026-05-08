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
│   ├── admin.guard.ts           # isRoot OU roleBack ∈ {admin, supervisor} OU roleFront = supervisor
│   ├── roles-back.guard.ts      # RBAC backend dinâmico via @RolesBack(...)
│   ├── roles-front.guard.ts     # RBAC frontend dinâmico via @RolesFront(...)
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
| `roleBack`     | RoleBack         | Role de acesso backend             |
| `roleFront`    | RoleFrontEnum[]  | Lista de roles de acesso frontend  |

---

## Guards — Regras de Aplicação

Existem cinco guards canônicos mais o `RootGuard` (caso especial para operações root-exclusivas):

| Guard               | Pré-requisito no token | Comportamento ao falhar  |
|---------------------|------------------------|--------------------------|
| `JwtGuard`          | Assinatura válida + não na blacklist (etapa 1 ou 2) | 401 Unauthorized |
| `UserInstanceGuard` | `dbId` presente (token etapa 2 — usuário selecionou tenant) | 403 Forbidden |
| `AdminGuard`        | `isRoot === true` OU `roleBack ∈ {admin, supervisor}` OU `roleFront` contém `admin` | 403 Forbidden |
| `RolesBackGuard`    | `roleBack` ∈ roles declaradas via `@RolesBack(...)` (dinâmico) | 403 Forbidden |
| `RolesFrontGuard`   | `roleFront` (array) intersecta com roles declaradas via `@RolesFront(...)` (dinâmico) | 403 Forbidden |
| `RootGuard`         | `isRoot === true` (restrição máxima) | 403 Forbidden |

### Uso canônico de cada guard

- **`JwtGuard`** — aplicar a toda rota autenticada (etapa 1 ou 2).
- **`UserInstanceGuard`** — somar ao `JwtGuard` quando a rota exige tenant selecionado (acesso a `dbId`/roles).
- **`AdminGuard`** — rotas administrativas que aceitam root global **ou** administradores do tenant (admin/supervisor backend, ou `admin` presente no array `roleFront`). Substitui o padrão antigo de `@RolesBack(ADMIN, SUPER) + @AllowRoot()`.
- **`RolesBackGuard`** + `@RolesBack(...)` — testar dinamicamente se `roleBack` do usuário pertence ao conjunto declarado. **Não** faz bypass para root; se a rota deve permitir root, use `AdminGuard` ou inclua-o em guards compostos.
- **`RolesFrontGuard`** + `@RolesFront(...)` — idem para `roleFront`, mas como `roleFront` é array, o guard aprova quando há **interseção** entre os papéis do usuário e os declarados.
- **`RootGuard`** — rotas restritas exclusivamente ao superadmin global (CRUD de instances, user-instances, sys-files, sql-files etc.).

**Ordem típica em endpoints protegidos:**
```ts
// Rota administrativa do tenant (aceita root)
@UseGuards(JwtGuard, AdminGuard)

// Rota com RBAC dinâmico por roleBack
@UseGuards(JwtGuard, UserInstanceGuard, RolesBackGuard)
@RolesBack(RoleBack.ADMIN, RoleBack.SUPER)

// Rota com RBAC dinâmico por roleFront
@UseGuards(JwtGuard, UserInstanceGuard, RolesFrontGuard)
@RolesFront(RoleFrontEnum.SUPERSALER, RoleFrontEnum.SALER)

// Rota root-exclusiva
@UseGuards(JwtGuard, RootGuard)
```

---

## Proteção contra Força Bruta (`LoginAttemptService`)

- Persistência em MySQL (tabela `login_attempts`, coluna `identifier` única, tamanho 320).
- Identificador: `IP::email` (email normalizado — `trim()` + `toLowerCase()`).
  - O IP é lido de `req.ip` (respeita `trust proxy` quando configurado) com fallback para `req.socket.remoteAddress`.
  - O email vem do `LoginDto` da requisição (a tentativa em andamento), **não** do usuário autenticado.
- Limite: **5 tentativas** antes do bloqueio.
- Duração do bloqueio: **1 hora**.
- Avisos progressivos nas tentativas 3 e 4.
- Tentativa bem-sucedida zera o contador (apenas do par IP+email correspondente).

### Racional do identificador composto

Usar apenas o IP causa falsos positivos em cenários comuns: redes corporativas, Wi-Fi público, proxies, NAT de operadora. Um atacante contra a conta `vitima@x.com` bloquearia todos os usuários que compartilham o mesmo IP. O identificador `IP::email`:

- Isola a tentativa ao par **origem × alvo**: diferentes usuários na mesma rede permanecem livres para logar.
- Mantém o bloqueio eficaz: ataques repetidos contra a mesma conta a partir da mesma origem são contidos em 5 tentativas.
- Não protege sozinho contra ataques distribuídos ou de enumeração (varredura de emails a partir do mesmo IP) — essas defesas dependem de outras camadas (WAF, `Throttle` no controller, monitoramento).

### API

```ts
getIdentifier(req: Request, email?: string): string  // retorna "ip::email"
shouldBlock(identifier): Promise<void>               // lança 401 se bloqueado
registerFailure(identifier): Promise<void>           // incrementa; bloqueia em 5
resetAttempts(identifier): Promise<void>             // chamado em login bem-sucedido
```

> **Observação operacional:** o `LoginAttemptService` não expõe rotina de limpeza de registros expirados. Registros com `blockedUntil` no passado continuam na tabela; reutilizando o mesmo par IP+email, o `shouldBlock` permite passar e `registerFailure` zera/atualiza o contador ao exceder. Considerar job agendado para purgar registros antigos se a tabela crescer.

---

## Refresh Token (`token_refresh`)

| Coluna       | Tipo    | Descrição                               |
|--------------|---------|-----------------------------------------|
| `id`         | int (PK)| Auto-increment                          |
| `token`      | string  | 64 bytes aleatórios em hex (128 chars)  |
| `userInstance` | FK    | Cascata ON DELETE                       |
| `isRevoked`  | boolean | `false` padrão; `true` após uso/logout  |
| `deviceName` | string \| null | Nome do dispositivo (máx. 255 chars); populado no `/auth/instance` (body ou fallback User-Agent) e preservado na rotação do `/auth/refresh` |
| `expiresAt`  | Date    | 7 dias + 1 hora a partir da emissão     |
| `createdAt`  | Date    | Automático                              |

**Rotação:** a cada `/auth/refresh`, o token antigo é revogado (`isRevoked = true`) e um novo par é emitido. O `deviceName` é preservado automaticamente do token anterior.

### Gerenciamento de Sessões

| Endpoint | Auth | Descrição |
|---|---|---|
| `GET /auth/sessions` | `JwtGuard` (etapa 1 ou 2) | Lista sessões ativas: retorna `{ sessions: [{ deviceName, expiresAt }] }` |
| `DELETE /auth/sessions` | `JwtGuard` (etapa 1 ou 2) | Revoga todos os refresh tokens ativos do usuário: retorna `{ message, count }` |

- Ambos os endpoints usam apenas `JwtGuard` — não exigem `UserInstanceGuard` pois filtram pelo `userId` do payload (`sub` → `userId`).
- `revokeAllByUserId` busca os IDs primeiro (`find`) e atualiza por `In([...ids])` para garantir compatibilidade com o TypeORM.

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
| `RefreshTokenService` | `generate` / `validate` / `revoke` / `findActiveByUserId` / `revokeAllByUserId` |
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
4. `isRoot` no payload concede acesso em `AdminGuard` e `RootGuard`; `RolesBackGuard` e `RolesFrontGuard` **não** aplicam bypass automático para root — rotas que devem permitir root + role específica devem compor `AdminGuard` ou declarar o root como caso separado.
5. O refresh token é de uso único — sempre revogado após rotação.
6. Tokens na blacklist são rejeitados na `JwtStrategy`, mesmo que a assinatura seja válida.
7. Reset de senha expira em 1 hora; o registro é deletado após uso bem-sucedido.
8. Na etapa 2, a versão do banco do tenant (`cfg.VERSAO_DB`) é verificada contra `MIN_TENANT_DB` (env, default `2.38`). Versão inferior → **403 Forbidden**, token não emitido. Se `VERSAO_DB` não existir na tabela `cfg`, o acesso é permitido (graceful degradation para tenants não migrados).
