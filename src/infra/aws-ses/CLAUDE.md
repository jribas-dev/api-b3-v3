# Specs — Módulo `infra/aws-ses`

> NestJS 11 / Node.js 22 · TypeScript · AWS SDK v3 (`@aws-sdk/client-sesv2`) · Handlebars

---

## Visão Geral

O módulo `AwsSesModule` tem duas responsabilidades distintas:

1. **Gerenciamento de identidades SES** — registra, verifica e remove identidades de domínio ou e-mail no AWS SES v2, mantendo um espelho local na tabela `account_ses`.
2. **Envio de e-mails transacionais** — compila templates Handlebars (`.hbs`) e despacha via `SendEmailCommand`. Exposto através do sub-módulo `AwsSenderModule`.

---

## Estrutura de Arquivos

```
aws-ses/
├── aws-ses.module.ts          # Módulo raiz — importa AwsSenderModule, registra AccountSESEntity
├── aws-ses.controller.ts      # Endpoints REST (prefixo: /infra/aws-ses)
├── aws-ses.service.ts         # Lógica de identidades SES + espelho account_ses
├── entities/
│   └── account-ses.entity.ts  # Tabela account_ses (PK: identity string)
├── dto/
│   ├── check-identity.dto.ts         # Query: identity (domínio ou e-mail)
│   ├── create-domain-identity.dto.ts # Body: domain
│   ├── create-email-identity.dto.ts  # Body: emailAddress
│   └── list-identidies.dto.ts        # Query: pageSize, nextToken
├── factories/
│   └── ses-client.factory.ts  # Provider SES_CLIENT (SESv2Client via ConfigService)
├── filter/
│   └── ses-exception.filter.ts # Captura SESv2ServiceException → HTTP 400/404/409/500
└── sender/
    ├── sender.module.ts        # Sub-módulo; exporta AwsSenderService
    ├── sender.service.ts       # sendTemplateEmail / sendEmail
    ├── enums/
    │   └── template-type.enum.ts      # WELCOME | PASSWORD_RESET | NEWUSER_CALL
    ├── factories/
    │   └── template-factory.service.ts # Resolve handler pelo TemplateType
    ├── handlers/
    │   ├── welcome.handler.ts          # Contexto: { name }
    │   ├── password-reset.handler.ts   # Contexto: { name, resetLink }
    │   └── newuser-call.handler.ts     # Contexto: { name, newUserLink }
    ├── interfaces/
    │   └── template-handler.interface.ts # Interface TemplateHandler<TContext>
    └── layouts/
        ├── welcome.hbs
        ├── password-reset.hbs
        └── newuser-call.hbs
```

---

## Endpoints REST

Base: `POST|GET|DELETE /infra/aws-ses`  
Guard global: `JwtGuard` (JWT com escopo completo)  
Filter global: `SesExceptionFilter`

| Método | Rota | Guard extra | Descrição |
|---|---|---|---|
| `POST` | `/new/domain` | — | Cria identidade de domínio no SES; retorna registros CNAME para DKIM |
| `POST` | `/new/email` | — | Cria identidade de e-mail no SES; status inicial `PENDING` |
| `GET` | `/identities/check` | — | Consulta status de verificação de uma identidade; sincroniza `account_ses` |
| `DELETE` | `/identities/delete` | — | Remove identidade do SES e da tabela `account_ses` |
| `GET` | `/list` | `RootGuard` | Lista todas as identidades SES paginadas (somente superadmin) |

### Lógica de idempotência em `POST /new/domain` e `POST /new/email`

Antes de criar, o controller verifica se a identidade já existe em `account_ses`. Se existir, retorna o status atual via `checkIdentityStatus` em vez de tentar criar novamente.

---

## Entity `AccountSESEntity`

Tabela: `account_ses`

| Coluna | Tipo | Descrição |
|---|---|---|
| `identity` | `varchar(255)` PK | Domínio ou endereço de e-mail registrado |
| `checked` | `boolean` (default `false`) | `true` quando a verificação SES retornou `SUCCESS` |

> Não usa CUID2 — a PK é a própria string da identidade (domínio ou e-mail).

---

## Factory `SesClientFactory`

Token de injeção: `SES_CLIENT`

Instancia `SESv2Client` lendo as variáveis de ambiente:

| Variável | Uso |
|---|---|
| `AWS_REGION` | Região do cliente SES |
| `AWS_SDK_KEY` | `accessKeyId` |
| `AWS_SDK_SECRET` | `secretAccessKey` |

O mesmo factory é registrado tanto em `AwsSesModule` quanto em `AwsSenderModule`.

---

## Sub-módulo `AwsSenderModule`

Exporta apenas `AwsSenderService`. Não possui controller próprio — é consumido por outros módulos que injetam `AwsSenderService`.

### `AwsSenderService`

Dois métodos públicos:

```typescript
// Fluxo completo com template
sendTemplateEmail<TContext>(to, subject, templateType: TemplateType, context: TContext): Promise<void>

// Envio direto de HTML arbitrário
sendEmail(recipient, subject, htmlBody): Promise<{ statusCode, messageId, recipient, subject }>
```

- O remetente é lido de `SES_FROM_EMAIL`; fallback hardcoded: `passport@3b3.com.br`.
- O `FromEmailAddress` é formatado como `"B3Erp Software" <endereço>`.

### `TemplateFactory`

Resolve o handler correto via `switch` no `TemplateType`. Lança `Error` para tipos desconhecidos.

### Handlers de Template

Cada handler implementa `TemplateHandler<TContext>`:
- Lê o arquivo `.hbs` correspondente em `../layouts/` usando `fs.readFileSync` + `path.join(__dirname, ...)`.
- Compila com `handlebars.compile` e retorna HTML como string.

| Handler | Template | Contexto |
|---|---|---|
| `WelcomeHandler` | `welcome.hbs` | `{ name: string }` |
| `PasswordResetHandler` | `password-reset.hbs` | `{ name: string, resetLink: string }` |
| `NewUserCallHandler` | `newuser-call.hbs` | `{ name: string, newUserLink: string }` |

---

## Filter `SesExceptionFilter`

Captura exceções do tipo `SESv2ServiceException` e mapeia para HTTP:

| Nome da exceção AWS | HTTP |
|---|---|
| `NotFoundException` | 404 |
| `AlreadyExistsException` | 409 |
| `ValidationException` | 400 |
| Qualquer outro | 500 |

Resposta: `{ errorCode, message, awsRequestId }`.

---

## Como adicionar um novo tipo de e-mail

1. Criar o layout `src/infra/aws-ses/sender/layouts/<nome>.hbs`.
2. Definir a interface de contexto e criar o handler em `handlers/<nome>.handler.ts` implementando `TemplateHandler<TContext>`.
3. Adicionar o valor no enum `TemplateType` (`sender/enums/template-type.enum.ts`).
4. Registrar o handler como provider em `AwsSenderModule` e injetá-lo no construtor de `TemplateFactory`.
5. Adicionar o `case` correspondente no `switch` de `TemplateFactory.getHandler`.

> O `nest-cli.json` já está configurado para copiar arquivos `.hbs` para `dist/` no build.
