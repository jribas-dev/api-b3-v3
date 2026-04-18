# CLAUDE.md

Este arquivo fornece orientações ao Claude Code (claude.ai/code) ao trabalhar com o código deste repositório. Ele apresenta a **visão geral do projeto** e aponta para a documentação detalhada de cada módulo.

## Comandos

```bash
npm install          # Instala as dependências
npm run start:dev    # Executa com hot reload (desenvolvimento)
npm run build        # Compila TypeScript → dist/
npm run start:prod   # Executa o build de produção compilado
npm run lint         # ESLint com auto-correção
npm run format       # Formatação com Prettier
```

## Tests

Até o momento nenhum test runner está configurado neste projeto.

---

## Visão Geral da Arquitetura

REST API em **NestJS 11 / Node.js 22 / TypeScript** com três responsabilidades principais:

1. **Authorization Server** — login JWT em duas etapas (login → seleção de instance → token com escopo), refresh tokens rotativos, blacklist para logout, proteção contra força bruta, reset de senha por e-mail.
2. **Resource Server Multi-Tenant** — cada *instance* é um tenant com seu próprio banco MySQL. Módulos de domínio (ex: `b3vendas`) conectam dinamicamente ao banco do tenant via `TenantModule`.
3. **Serviços de Infraestrutura** — arquivos no AWS S3, e-mails transacionais via AWS SES, catálogo de scripts SQL e pacotes de sistema.

### Diagrama de Alto Nível

```
┌──────────────────────────────────────────────────────────┐
│ AppModule (banco principal — usuários, tenants, tokens)  │
│                                                          │
│  ┌──────────┐   ┌───────────────┐   ┌──────────────┐     │
│  │   auth   │   │  user-domain  │   │    infra     │     │
│  └──────────┘   └───────────────┘   └──────────────┘     │
│                                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │                    tenant                          │  │
│  │  (factory de DataSource por dbId — compartilhado)  │  │
│  └────────────────────────────────────────────────────┘  │
│                         ▼                                │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Módulos de domínio (banco do tenant)              │  │
│  │  ┌───────────┐  ┌───────────┐  ┌──────────────┐    │  │
│  │  │ b3vendas  │  │  b3dash*  │  │ b3financeiro*│    │  │
│  │  └───────────┘  └───────────┘  └──────────────┘    │  │
│  │  (* — planejados)                                  │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

---

## Módulos

| Módulo | Responsabilidade | Documentação |
|---|---|---|
| [`auth`](src/auth/CLAUDE.md) | Login em 2 etapas, JWT, refresh tokens, blacklist, reset de senha, RBAC via guards | [src/auth/CLAUDE.md](src/auth/CLAUDE.md) |
| [`user-domain`](src/user-domain/CLAUDE.md) | Agregador: `user`, `user-instance`, `user-pre`, `instance` | [src/user-domain/CLAUDE.md](src/user-domain/CLAUDE.md) |
| [`tenant`](src/tenant/CLAUDE.md) | Factory + cache de DataSources por tenant; `CfgService` para parâmetros do tenant | [src/tenant/CLAUDE.md](src/tenant/CLAUDE.md) |
| [`b3vendas`](src/b3vendas/CLAUDE.md) | Domínio de vendas: clientes, produtos, pedidos, impostos (IPI/ICMS-ST) | [src/b3vendas/CLAUDE.md](src/b3vendas/CLAUDE.md) |
| [`infra`](src/infra/CLAUDE.md) | Agregador: `aws-s3`, `aws-ses`, `sql-files`, `sys-files` | [src/infra/CLAUDE.md](src/infra/CLAUDE.md) |

### Sub-módulos de `user-domain`

| Sub-módulo | Tabelas | Documentação |
|---|---|---|
| `instance` | `instance` | [src/user-domain/instance/CLAUDE.md](src/user-domain/instance/CLAUDE.md) |
| `user` | `user` | [src/user-domain/user/CLAUDE.md](src/user-domain/user/CLAUDE.md) |
| `user-instance` | `user_instances` | [src/user-domain/user-instance/CLAUDE.md](src/user-domain/user-instance/CLAUDE.md) |
| `user-pre` | `user_pre`, `user_pre_instances` | [src/user-domain/user-pre/CLAUDE.md](src/user-domain/user-pre/CLAUDE.md) |

### Sub-módulos de `infra`

| Sub-módulo | Prefixo REST | Documentação |
|---|---|---|
| `aws-s3` | `/infra/aws-s3` | [src/infra/aws-s3/CLAUDE.md](src/infra/aws-s3/CLAUDE.md) |
| `aws-ses` | `/infra/aws-ses` | [src/infra/aws-ses/CLAUDE.md](src/infra/aws-ses/CLAUDE.md) |
| `sql-files` | `/sql-files` | [src/infra/sql-files/CLAUDE.md](src/infra/sql-files/CLAUDE.md) |
| `sys-files` | `/sys-files` | [src/infra/sys-files/CLAUDE.md](src/infra/sys-files/CLAUDE.md) |

---

## Estrutura de Diretórios

```
src/
├── app.module.ts           # Módulo raiz — compõe todos os demais
├── main.ts                 # Bootstrap NestJS
├── config.schema.ts        # Validação Joi de variáveis de ambiente
├── auth/                   # Servidor de autorização
├── user-domain/            # Usuários, tenants e vínculos
├── tenant/                 # Factory multi-tenant de DataSources
├── b3vendas/               # Domínio de vendas (tenant-scoped)
└── infra/                  # Serviços transversais (S3, SES, arquivos)
```

---

## Conceitos Transversais

### Multi-tenancy

- **Banco principal** — usuários, tenants (tabela `instance`), tokens, arquivos de sistema.
- **Banco por tenant** — dados de domínio (`cliente`, `venda`, `prd`, etc.). Cada `instance` tem `dbHost` + `dbName` próprios.
- O [`TenantModule`](src/tenant/CLAUDE.md) resolve o `dbId` em um `DataSource` cacheado. Módulos de domínio injetam `TenantService` para obter o repositório no banco correto.

### Autenticação em Duas Etapas

```
POST /auth/login     { email, password }        → JWT (30 min, sem escopo)
POST /auth/instance  { dbId }                   → JWT (180 min) + refreshToken
                                                   payload inclui: instanceId, roleBack, roleFront
POST /auth/refresh   { refreshToken }           → rotação (novo par)
POST /auth/logout                               → blacklist do JWT atual
```

Guards aplicados em ordem:
1. `JwtGuard` — valida assinatura + checa blacklist
2. `UserInstanceGuard` — exige `dbId` no payload (token etapa 2)
3. `RolesBackGuard` / `RolesFrontGuard` — RBAC
4. `RootGuard` — superadmin exclusivo

Detalhes em [src/auth/CLAUDE.md](src/auth/CLAUDE.md).

### Estratégia de ID das Entities

- **Banco principal:** entities geram IDs via **CUID2** (`@paralleldrive/cuid2`) em hook `@BeforeInsert()` — não há auto-increment nem UUID.
- **Banco do tenant:** entities legadas usam **IDs numéricos inteiros** (ver [`b3vendas`](src/b3vendas/CLAUDE.md)).

### Templates de E-mail

Arquivos Handlebars (`.hbs`) em `src/infra/aws-ses/sender/layouts/`. O `nest-cli.json` copia esses arquivos para `dist/` durante o build. Adicionar um novo template exige: arquivo de layout, handler em `handlers/` e entrada em `TemplateTypeEnum`. Detalhes em [src/infra/aws-ses/CLAUDE.md](src/infra/aws-ses/CLAUDE.md).

### Sincronização do TypeORM

- **Banco principal:** `synchronize: true` em desenvolvimento — schema aplicado na inicialização. Deve ser `false` em produção.
- **Banco do tenant:** `synchronize: false` sempre — schema governado por scripts versionados (ver `sql-files`).
- Não há arquivos de migration; alterações em produção exigem migrations explícitas.

---

## Variáveis de Ambiente

Todas as variáveis obrigatórias são validadas na inicialização via Joi ([`src/config.schema.ts`](src/config.schema.ts)). Copie `.env.sample` para `.env` antes de executar localmente.

| Grupo | Variáveis |
|---|---|
| App | `APP_ENVIRONMENT`, `APP_NAME`, `APP_PORT` |
| Database (principal + tenant) | `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `DB_DATABASE` |
| JWT | `JWT_SECRET` |
| AWS | `AWS_REGION`, `AWS_SDK_KEY`, `AWS_SDK_SECRET`, `S3_BUCKET_NAME`, `SES_FROM_EMAIL` |
| URLs | `UPLOAD_PATH`, `STATIC_URL`, `FRONTEND_URL`, `BACKEND_URL` |

> `DB_HOST` é usado apenas pelo banco principal. Os bancos dos tenants são resolvidos a partir de `InstanceEntity.dbHost` — ver [src/tenant/CLAUDE.md](src/tenant/CLAUDE.md).

---

## Deploy

`deploy.sh` gerencia os deploys de produção: `git pull` → `npm install` → `nest build` → reinicialização do PM2. O PM2 gerencia o processo. Entrada em produção: `node dist/main`. **O script foi retirado do repositório remoto.**
