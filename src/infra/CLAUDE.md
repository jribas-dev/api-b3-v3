# Specs — Módulo `infra`

> NestJS 11 / Node.js 22 · TypeScript

---

## Visão Geral

O módulo `infra` é um pacote organizacional que agrupa quatro sub-módulos de infraestrutura transversal. Cada sub-módulo é independente, possui controller e service próprios, e está detalhado em seu respectivo `CLAUDE.md`.

---

## Sub-módulos

| Sub-módulo | Prefixo REST | Responsabilidade |
|---|---|---|
| [`aws-s3`](aws-s3/CLAUDE.md) | `/infra/aws-s3` | Upload e deleção de arquivos — disco local ou bucket S3 com ACL `public-read` |
| [`aws-ses`](aws-ses/CLAUDE.md) | `/infra/aws-ses` | Gerenciamento de identidades SES e envio de e-mails transacionais via templates Handlebars |
| [`sql-files`](sql-files/CLAUDE.md) | `/sql-files` | Armazenamento e distribuição de scripts SQL versionados (releases FULL e UPDATE) |
| [`sys-files`](sys-files/CLAUDE.md) | `/sys-files` | Catálogo de pacotes de sistema (instaladores/updates) com vínculo às versões dos `sql-files` |

---

## Autenticação

Todos os endpoints exigem autenticação JWT com escopo completo (`JwtGuard`). Endpoints de escrita e listagem global exigem adicionalmente `RootGuard` (superadmin).

---

## Entidade Compartilhada

`SystemsEntity` (`src/infra/common/system.entity.ts`) é utilizada tanto por `sql-files` quanto por `sys-files` para referenciar a tabela `sistemas`.

---

## Dependências AWS

Os sub-módulos `aws-s3` e `aws-ses` compartilham as mesmas variáveis de ambiente:

| Variável | Uso |
|---|---|
| `AWS_REGION` | Região dos serviços AWS |
| `AWS_SDK_KEY` | `accessKeyId` das credenciais |
| `AWS_SDK_SECRET` | `secretAccessKey` das credenciais |
| `S3_BUCKET_NAME` | Bucket padrão para uploads S3 |
| `SES_FROM_EMAIL` | Remetente padrão dos e-mails |
