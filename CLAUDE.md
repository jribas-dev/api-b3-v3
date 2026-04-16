# CLAUDE.md

Este arquivo fornece orientações ao Claude Code (claude.ai/code) ao trabalhar com o código deste repositório.

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

## Visão Geral da Arquitetura

Esta é uma REST API **NestJS 11 / Node.js 22** escrita em TypeScript com dois papéis principais:

1. **Authorization Server** — login baseado em JWT com refresh tokens rotativos, autenticação em múltiplas etapas (login → seleção de instance → token com escopo), blacklist de tokens para logout e proteção contra força bruta via rastreamento de tentativas de login.
2. **Resource Server** — acesso a recursos multi-tenant, gerenciamento de arquivos no AWS S3, envio de e-mails via AWS SES.

### Fluxo de Autenticação em Múltiplas Etapas

O login é um processo de duas etapas:
1. `POST /auth/login` — valida as credenciais e retorna um JWT de curta duração contendo apenas o `userId`.
2. `POST /auth/instance` — o usuário seleciona uma instance tenant; retorna um JWT com escopo (30 min) + refresh token (180 min) que inclui `instanceId`, `roleBack` e `roleFront`.

Os guards aplicam esse fluxo: `JwtAuthGuard` valida o token, `RoleBackGuard` / `RoleFrontGuard` verificam os roles RBAC, e `RootGuard` restringe endpoints exclusivos ao superadmin.

### Multi-tenancy

O módulo `instance` gerencia os registros de tenant. Cada instance possui suas próprias coordenadas de conexão com o banco de dados (`db_host`, `db_port`, `db_database`). O `TenantModule` (`src/tenant/`) é um módulo **compartilhado no nível raiz** que fornece a factory de conexão tenant para todos os módulos de domínio (`b3vendas`, `b3dash`, `b3financeiro`, etc.). Os módulos de domínio importam `TenantModule` para se conectar dinamicamente ao banco de dados do tenant via `TenantService`.

### Estrutura de Módulos

```
src/
├── auth/           # Login, refresh, logout, reset-password, black-list, guards, JWT strategy
├── user/           # CRUD de usuários
├── user-instance/  # Mapeamento User↔Instance com enums RoleBack/RoleFront
├── user-pre/       # Usuários pré-cadastrados/convidados
├── instance/       # Gerenciamento de instancias tenant
├── tenant/         # TenantModule/TenantService — factory de DataSource compartilhada entre módulos de domínio
├── b3vendas/       # Módulo de domínio; usa TenantModule para conectar ao DB do tenant
├── infra/
│   ├── aws-s3/     # Upload/download/delete no S3 + presigned URLs
│   ├── aws-ses/    # E-mail via SES com templates Handlebars
│   ├── sys-files/  # Rastreamento de arquivos do sistema
│   └── sql-files/  # Gerenciamento de arquivos SQL
└── config.schema.ts  # Validação Joi de todas as variáveis de ambiente
```

### Estratégia de ID das Entities

Todas as entities geram IDs usando CUID2 (`@paralleldrive/cuid2`) em um hook `@BeforeInsert()` — não utilizam auto-increment. Não espere IDs numéricos ou UUID.

### Templates de E-mail

Os layouts de e-mail são arquivos Handlebars (`.hbs`) em `src/infra/aws-ses/sender/layouts/`. O `nest-cli.json` copia esses arquivos para `dist/` durante o build. Adicionar um novo tipo de e-mail requer: um arquivo de layout, um handler em `handlers/` e uma nova entrada em `TemplateTypeEnum`.

### Variáveis de Ambiente

Todas as variáveis obrigatórias são validadas na inicialização via Joi (`src/config.schema.ts`). Copie `.env.sample` para `.env` antes de executar localmente. Grupos principais:

| Grupo | Variáveis |
|---|---|
| App | `APP_ENVIRONMENT`, `APP_NAME`, `APP_PORT` |
| Database | `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `DB_DATABASE` |
| JWT | `JWT_SECRET` |
| AWS | `AWS_REGION`, `AWS_SDK_KEY`, `AWS_SDK_SECRET`, `S3_BUCKET_NAME`, `SES_FROM_EMAIL` |
| URLs | `UPLOAD_PATH`, `STATIC_URL`, `FRONTEND_URL`, `BACKEND_URL` |

### Sincronização do TypeORM

`synchronize: true` é usado em desenvolvimento — alterações no schema são aplicadas automaticamente na inicialização. **Deve ser `false` em produção.** Não há arquivos de migration; alterações no schema em produção exigem migrations explícitas do TypeORM.

### Deploy

O `deploy.sh` gerencia os deploys de produção: git pull → npm install → nest build → reinicialização do PM2. O PM2 gerencia o processo. Execute `node dist/main` como ponto de entrada em produção. **Retirado do repositório remoto.**
