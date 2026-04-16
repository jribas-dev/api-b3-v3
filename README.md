<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

# API B3 v3

**Versão:** 1.1.1 &nbsp;|&nbsp; **Runtime:** Node.js 22 &nbsp;|&nbsp; **Framework:** NestJS 11 &nbsp;|&nbsp; **Linguagem:** TypeScript 5.9

API REST privada com dupla função: **Authorization Server** baseado em JWT com autenticação em múltiplas etapas, e **Resource Server** multi-tenant com integração AWS (S3 e SES).

---

## Sumário

1. [Visão Geral](#visão-geral)
2. [Stack Tecnológica](#stack-tecnológica)
3. [Arquitetura de Módulos](#arquitetura-de-módulos)
4. [Fluxo de Autenticação](#fluxo-de-autenticação)
5. [Controle de Acesso (RBAC)](#controle-de-acesso-rbac)
6. [Referência de Endpoints](#referência-de-endpoints)
7. [Multi-tenancy](#multi-tenancy)
8. [Templates de E-mail](#templates-de-e-mail)
9. [Variáveis de Ambiente](#variáveis-de-ambiente)
10. [Setup e Execução Local](#setup-e-execução-local)
11. [Build e Produção](#build-e-produção)
12. [Notas Importantes](#notas-importantes)

---

## Visão Geral

A aplicação opera em dois papéis simultâneos:

**Authorization Server**
- Login baseado em JWT com fluxo em duas etapas (credenciais → seleção de instância)
- Refresh tokens rotativos com revogação automática
- Blacklist de tokens para logout seguro
- Proteção contra força bruta via rastreamento de tentativas de login por IP/User-Agent
- Reset de senha com token de uso único e expiração de 1 hora
- Sistema de convite de usuários com pré-cadastro por token

**Resource Server**
- Acesso a recursos isolados por tenant (multi-tenant via instâncias)
- Upload e download de arquivos no AWS S3 com suporte a presigned URLs
- Gerenciamento de identidades e envio de e-mails via AWS SES
- Rastreamento interno de arquivos do sistema e scripts SQL

---

## Stack Tecnológica

| Camada | Tecnologia | Versão |
|--------|-----------|--------|
| Runtime | Node.js | 22 |
| Linguagem | TypeScript | ^5.9 |
| Framework | NestJS + Express | ^11 |
| ORM | TypeORM | ^0.3.28 |
| Banco de dados | MySQL / MariaDB (driver mysql2) | ^3.15 |
| Autenticação | Passport + passport-jwt | ^0.7 / ^4.0 |
| Hashing de senhas | bcrypt | ^6.0 |
| Configuração | @nestjs/config + Joi | ^4.0 / ^17.13 |
| Geração de IDs | @paralleldrive/cuid2 | ^2.3 |
| Validação de DTOs | class-validator + class-transformer | ^0.14 / ^0.5 |
| AWS S3 | @aws-sdk/client-s3 + s3-request-presigner | ^3.948 |
| AWS SES | @aws-sdk/client-sesv2 | ^3.950 |
| Templates de e-mail | Handlebars | ^4.7 |
| Upload de arquivos | Multer | ^2.0 |
| Utilitários de data | date-fns | ^4.1 |

---

## Arquitetura de Módulos

```
src/
├── main.ts                    # Bootstrap da aplicação (porta, pipes globais)
├── app.module.ts              # Módulo raiz (ConfigModule, TypeOrmModule, todos os módulos)
├── config.schema.ts           # Schema Joi de validação de variáveis de ambiente
│
├── auth/                      # Autenticação e autorização
│   ├── auth.controller.ts     # POST /auth/login, /instance, /refresh, /logout
│   ├── auth.service.ts        # Lógica de login, instância, refresh, logout
│   ├── jwt/                   # Estratégia Passport JWT + interface do payload
│   ├── guards/                # JwtGuard, RolesBackGuard, RolesFrontGuard, RootGuard, UserInstanceGuard
│   ├── decorators/            # @RolesBack(), @RolesFront(), @AllowRoot()
│   ├── black-list/            # Entidade e serviço de blacklist de tokens
│   ├── refresh-token/         # Entidade e serviço de refresh tokens rotativos
│   ├── password/              # Hash e comparação de senhas (bcrypt)
│   ├── login-attempt/         # Rastreamento de tentativas e bloqueio por IP
│   └── reset-password/        # Fluxo de reset de senha (3 endpoints públicos)
│
├── user-domain/               # Domínio de usuários e instâncias
│   ├── user/                  # CRUD de usuários
│   ├── instance/              # Gerenciamento de instâncias (tenants)
│   ├── user-instance/         # Mapeamento Usuário ↔ Instância com roles
│   └── user-pre/              # Pré-cadastro e convite de usuários
│
├── b3vendas/                  # Módulo de domínio de negócio (rotas multi-tenant)
│   ├── b3vendas.controller.ts # Endpoints com acesso ao banco do tenant
│   └── tenant/                # TenantService — factory de DataSource por tenant
│
└── infra/                     # Infraestrutura e serviços externos
    ├── aws-s3/                # Upload/download/exclusão no S3 + presigned URLs
    ├── aws-ses/               # Gerenciamento de identidades e envio de e-mails
    ├── sys-files/             # Rastreamento de arquivos do sistema
    └── sql-files/             # Gerenciamento de arquivos SQL
```

### Entidades principais e relacionamentos

```
User
  └── UserInstance (N) ─── Instance (1)
        ├── roleBack: RoleBack
        └── roleFront: RoleFront

UserPre
  └── UserPreInstance (N) ─── Instance (1)
```

Todas as entidades usam **CUID2** como chave primária (exceto `UserInstance`, que usa `id` inteiro auto-incrementado).

---

## Fluxo de Autenticação

O login é um processo em **duas etapas obrigatórias**:

### Etapa 1 — Login com credenciais

```
POST /auth/login
Body: { email, password }
```

- Verifica o bloqueio por tentativas excessivas (IP::User-Agent)
- Valida as credenciais com bcrypt
- Retorna um **JWT de curta duração (30 min)** contendo apenas `sub` (userId), `email` e `isRoot`

### Etapa 2 — Seleção de instância (tenant)

```
POST /auth/instance
Header: Authorization: Bearer <token_etapa_1>
Body: { dbId }
```

- Valida o vínculo ativo do usuário com a instância
- Retorna um **JWT com escopo completo (180 min)** + refresh token

**Payload do JWT após etapa 2:**

```json
{
  "sub": "cuid2_do_usuario",
  "email": "usuario@exemplo.com",
  "isRoot": false,
  "instanceName": "Nome da Instância",
  "dbId": "cuid2_da_instancia",
  "roleBack": "admin",
  "roleFront": "supervisor"
}
```

### Refresh de tokens

```
POST /auth/refresh
Body: { refreshToken }
```

- Valida o refresh token e o revoga
- Emite um novo par de tokens (rotação automática)

### Logout

```
POST /auth/logout
Header: Authorization: Bearer <token>
Guards: JwtGuard, UserInstanceGuard
```

- Insere o JWT atual na blacklist com sua data de expiração original
- `JwtStrategy` verifica a blacklist a cada requisição autenticada

### Reset de senha

| Método | Rota | Descrição |
|--------|------|-----------|
| `POST` | `/auth/reset-password` | Solicita reset; gera token hex (176 chars) com TTL de 1 hora e envia e-mail |
| `GET`  | `/auth/reset-password/check` | Valida token e e-mail antes de exibir o formulário |
| `POST` | `/auth/reset-password/update` | Aplica nova senha; invalida o token após uso |

### Hierarquia de Guards

```
JwtGuard               → valida assinatura JWT + verifica blacklist
  └── UserInstanceGuard  → exige campo dbId no payload (token pós-instância)
        ├── RootGuard          → exige isRoot === true
        └── RolesBackGuard     → exige roleBack ∈ roles permitidos (ou isRoot + @AllowRoot())
```

---

## Controle de Acesso (RBAC)

### RoleBack — Acesso ao BackOffice

| Valor | Descrição |
|-------|-----------|
| `admin` | Acesso administrativo completo ao BackOffice |
| `supervisor` | Acesso supervisionado ao BackOffice |
| `user` | Acesso padrão ao BackOffice |
| `notallow` | Sem acesso ao BackOffice |

### RoleFront — Acesso à aplicação web

| Valor | Descrição |
|-------|-----------|
| `supervisor` | Supervisor na aplicação web |
| `saler` | Vendedor |
| `buyer` | Comprador |
| `notallow` | Sem acesso à aplicação web |

### Decorators disponíveis

```typescript
@RolesBack(RoleBack.ADMIN, RoleBack.SUPER)  // Restringe por roleBack
@RolesFront(RoleFront.SUPERVISOR)           // Restringe por roleFront
@AllowRoot()                                // Permite superadmin mesmo sem o roleBack exigido
```

---

## Referência de Endpoints

### Auth (`/auth`)

| Método | Rota | Guards | Descrição |
|--------|------|--------|-----------|
| `POST` | `/auth/login` | — | Etapa 1: valida credenciais, retorna JWT curto |
| `POST` | `/auth/instance` | JwtGuard | Etapa 2: seleciona instância, retorna JWT completo + refresh |
| `POST` | `/auth/refresh` | — | Renova o par de tokens (rotação) |
| `POST` | `/auth/logout` | JwtGuard, UserInstanceGuard | Adiciona token à blacklist |
| `POST` | `/auth/reset-password` | — | Solicita reset de senha por e-mail |
| `GET`  | `/auth/reset-password/check` | — | Valida token de reset |
| `POST` | `/auth/reset-password/update` | — | Aplica nova senha com token válido |

### Usuários (`/users`)

| Método | Rota | Guards | Descrição |
|--------|------|--------|-----------|
| `POST`   | `/users` | JwtGuard | Cria novo usuário |
| `GET`    | `/users` | JwtGuard, RootGuard | Lista todos os usuários |
| `GET`    | `/users/get/me` | JwtGuard | Retorna o usuário autenticado |
| `GET`    | `/users/:id` | JwtGuard | Retorna usuário por ID |
| `PATCH`  | `/users/:id` | JwtGuard | Atualiza usuário (próprio ou root) |
| `DELETE` | `/users/:id` | JwtGuard, RootGuard | Remove usuário |

### Instâncias (`/instances`)

| Método | Rota | Guards | Descrição |
|--------|------|--------|-----------|
| `POST`  | `/instances` | JwtGuard, RootGuard | Cria instância (tenant) |
| `GET`   | `/instances` | JwtGuard, RootGuard | Lista todas as instâncias |
| `GET`   | `/instances/:id` | JwtGuard, RootGuard | Retorna instância por `dbId` |
| `PATCH` | `/instances/:id` | JwtGuard, RootGuard | Atualiza instância (desativar cascateia para user_instances) |

### Vínculos Usuário-Instância (`/user-instances`)

| Método | Rota | Guards | Descrição |
|--------|------|--------|-----------|
| `POST`   | `/user-instances` | JwtGuard, RootGuard | Cria vínculo com roles |
| `GET`    | `/user-instances/user/:userId` | JwtGuard | Lista vínculos do usuário (próprio ou root) |
| `GET`    | `/user-instances/db/:dbId` | JwtGuard, RootGuard | Lista usuários de uma instância |
| `GET`    | `/user-instances/:id` | JwtGuard | Retorna vínculo (somente o próprio usuário) |
| `PATCH`  | `/user-instances/:id` | JwtGuard, RootGuard | Atualiza roles do vínculo |
| `DELETE` | `/user-instances/:id` | JwtGuard, RootGuard | Remove vínculo |

### Pré-cadastro de Usuários (`/user-pre`)

| Método | Rota | Guards | Descrição |
|--------|------|--------|-----------|
| `POST` | `/user-pre/create` | JwtGuard, RolesBackGuard (admin/supervisor) | Cria convite de usuário com token |
| `GET`  | `/user-pre/check` | — | Valida token + e-mail do convite |
| `POST` | `/user-pre/confirm` | — | Finaliza o cadastro via convite |

### AWS S3 (`/infra/aws-s3`)

| Método | Rota | Guards | Descrição |
|--------|------|--------|-----------|
| `POST`   | `/infra/aws-s3/uploadfile/local` | JwtGuard | Upload de arquivo para armazenamento local no servidor |
| `POST`   | `/infra/aws-s3/uploadfile` | JwtGuard | Upload de arquivo para o bucket S3 |
| `DELETE` | `/infra/aws-s3/deletefile/local` | JwtGuard | Remove arquivo do armazenamento local |
| `DELETE` | `/infra/aws-s3/deletefile` | JwtGuard | Remove objeto do bucket S3 |

> Limite de upload: **150 MB**. Caminhos são sanitizados contra path traversal.

### AWS SES (`/infra/aws-ses`)

| Método | Rota | Guards | Descrição |
|--------|------|--------|-----------|
| `POST`   | `/infra/aws-ses/new/domain` | JwtGuard | Registra identidade de domínio (retorna registros DKIM) |
| `POST`   | `/infra/aws-ses/new/email` | JwtGuard | Registra identidade de e-mail |
| `GET`    | `/infra/aws-ses/identities/check` | JwtGuard | Verifica status de verificação de identidade |
| `DELETE` | `/infra/aws-ses/identities/delete` | JwtGuard | Remove identidade do SES |
| `GET`    | `/infra/aws-ses/list` | JwtGuard, RootGuard | Lista identidades cadastradas (paginado) |

### B3Vendas — Domínio multi-tenant (`/b3vendas`)

| Método | Rota | Guards | Descrição |
|--------|------|--------|-----------|
| `GET` | `/b3vendas/info/pessoa/:id` | JwtGuard, UserInstanceGuard | Busca registro de Pessoa no banco do tenant |

> Requer token pós-instância (etapa 2). O `dbId` do JWT determina qual banco de dados tenant será consultado.

---

## Multi-tenancy

Cada instância (tenant) possui seu próprio banco de dados. O isolamento é implementado da seguinte forma:

1. **`InstanceEntity`** (banco principal) armazena as credenciais de conexão de cada tenant: `dbHost`, `dbName`, além dos limites `maxCompanies` e `maxUsers`.

2. **`TenantService`** cria um `DataSource` TypeORM isolado por tenant na primeira requisição e armazena em cache (Map em memória). Conexões subsequentes reutilizam o DataSource cacheado.

3. O **JWT emitido na etapa 2** carrega o campo `dbId`, que identifica o tenant. Todos os controllers do módulo `b3vendas` extraem o `dbId` do `req.user` para obter o DataSource correto via `TenantService`.

```
JWT (dbId) → TenantService.getDataSource(dbId) → DataSource do tenant → Query
```

> `synchronize` está sempre `false` nos DataSources de tenant. Alterações de schema nos bancos dos tenants requerem migrations explícitas.

---

## Templates de E-mail

Os e-mails são renderizados com **Handlebars** (`.hbs`) antes do envio via AWS SES.

**Localização dos templates:** `src/infra/aws-ses/sender/layouts/`

| Template | Arquivo | Descrição |
|----------|---------|-----------|
| `WELCOME` | `welcome.hbs` | Boas-vindas ao novo usuário |
| `PASSWORD_RESET` | `password-reset.hbs` | Link para reset de senha |
| `NEWUSER_CALL` | `newuser-call.hbs` | Convite para novo usuário (user-pre) |

O `nest-cli.json` copia os arquivos `.hbs` para `dist/` durante o build. Para adicionar um novo tipo de e-mail é necessário:
1. Criar o arquivo `.hbs` em `layouts/`
2. Criar um handler em `src/infra/aws-ses/sender/handlers/`
3. Adicionar a entrada correspondente em `TemplateTypeEnum`

---

## Variáveis de Ambiente

Copie `.env.sample` para `.env` e preencha os valores. Todas as variáveis são validadas via Joi na inicialização — a aplicação não sobe se houver valores inválidos ou ausentes nos campos obrigatórios.

| Variável | Obrigatória | Descrição |
|----------|:-----------:|-----------|
| `APP_NAME` | Sim | Nome de exibição da aplicação |
| `APP_PORT` | Sim | Porta do servidor HTTP |
| `APP_ENVIRONMENT` | — | Ambiente (`development`, `production`) |
| `DB_HOST` | — | Host do banco de dados principal |
| `DB_PORT` | — | Porta do banco de dados principal |
| `DB_USERNAME` | Sim | Usuário do banco de dados |
| `DB_PASSWORD` | Sim | Senha do banco de dados |
| `DB_DATABASE` | — | Nome do banco de dados principal |
| `JWT_SECRET` | Sim | Chave secreta para assinatura dos JWTs |
| `AWS_REGION` | — | Região AWS (ex.: `us-east-1`) |
| `AWS_SDK_KEY` | Sim | AWS Access Key ID |
| `AWS_SDK_SECRET` | Sim | AWS Secret Access Key |
| `S3_BUCKET_NAME` | — | Nome do bucket S3 padrão |
| `SES_FROM_EMAIL` | — | Endereço de e-mail remetente (SES) |
| `UPLOAD_PATH` | — | Caminho local para uploads no servidor |
| `STATIC_URL` | — | URL base para assets estáticos |
| `FRONTEND_URL` | — | URL da aplicação frontend |
| `BACKEND_URL` | — | URL desta API |

---

## Setup e Execução Local

### Pré-requisitos

- **Node.js v22**
- **MySQL ou MariaDB** rodando localmente
- Arquivo `.env` configurado (veja seção anterior)

### Instalação

```bash
# Clone o repositório
git clone <url-do-repositorio>
cd api-b3-v3

# Copie e configure as variáveis de ambiente
cp .env.sample .env
# edite o .env com seus valores

# Instale as dependências
npm install
```

### Executando em desenvolvimento

```bash
npm run start:dev     # Hot reload (modo watch)
npm run start:debug   # Hot reload + debugging
```

A aplicação estará disponível em `http://localhost:<APP_PORT>`.

### Outros comandos úteis

```bash
npm run build         # Compila TypeScript → dist/
npm run lint          # ESLint com auto-correção
npm run format        # Formatação com Prettier
```

---

## Build e Produção

```bash
# Compilar o projeto
npm run build

# Executar o build compilado
node dist/main
# ou via PM2:
pm2 start dist/main.js --name api-b3-v3
```

O `nest-cli.json` está configurado para:
- Limpar o diretório `dist/` antes de cada build (`deleteOutDir: true`)
- Copiar os templates Handlebars (`.hbs`) para `dist/`
- Copiar a pasta `assets/` para `dist/assets/`

### Considerações para produção

- **TypeORM `synchronize`:** Definido como `true` em desenvolvimento (aplica alterações de schema automaticamente). **Deve ser `false` em produção.** Não há migrations configuradas — mudanças de schema em produção requerem migrations TypeORM explícitas.
- **CORS:** Desabilitado por padrão no `main.ts`. Habilite e configure conforme o ambiente.
- **PM2:** O deploy é gerenciado via `deploy.sh` (git pull → npm install → nest build → reinício do PM2).

---

## Notas Importantes

**Geração de IDs**
Todas as entidades usam **CUID2** (`@paralleldrive/cuid2`) como chave primária, gerado em hooks `@BeforeInsert()`. Não utilize IDs numéricos sequenciais ou UUIDs ao referenciar registros.

**Proteção contra força bruta**
`LoginAttemptService` rastreia falhas de login por identificador `IP::User-Agent`. Após atingir o limite de tentativas, o acesso é bloqueado temporariamente.

**Token Blacklist**
O logout insere o token na tabela `token_blacklist` com a expiração original. A `JwtStrategy` consulta a blacklist em cada requisição autenticada — tokens inválidos são rejeitados com `401 Unauthorized`.

**Refresh tokens rotativos**
Cada uso do `/auth/refresh` revoga o token anterior e emite um novo par. Tokens de refresh não utilizados expiram automaticamente.

**Testes**
Nenhum test runner está configurado neste projeto até o momento.
