# Specs — Sub-módulo `infra/aws-s3`

> NestJS 11 / Node.js 22 · TypeScript · AWS SDK v3 (`@aws-sdk/client-s3`)

---

## Visão Geral

O sub-módulo `AwsS3Module` expõe endpoints para upload e deleção de arquivos em dois destinos distintos:

- **Local** — salva/remove arquivos no disco do servidor (pasta estática servida via `STATIC_URL`).
- **AWS S3** — envia/remove objetos em um bucket S3 com ACL `public-read`.

Todos os endpoints exigem autenticação JWT com escopo completo (`JwtGuard`).

---

## Estrutura de Arquivos

```
src/infra/aws-s3/
├── aws-s3.module.ts              # Registra AwsS3Service, AwsS3Controller e s3ClientFactory
├── aws-s3.controller.ts          # 4 endpoints REST (POST/DELETE × local/S3)
├── aws-s3.service.ts             # Lógica de upload/delete (disco e S3)
├── dto/
│   └── actions-file-object.dto.ts  # DTO com sanitização de path traversal
└── factories/
    └── s3-client.factory.ts      # Factory que injeta S3Client configurado
```

---

## Endpoints

Base path: `POST|DELETE /infra/aws-s3`  
Guard: `JwtGuard` (aplicado no nível do controller)  
Content-Type de upload: `multipart/form-data` (campo `file`)  
Limite de tamanho: **150 MB** por arquivo

| Método | Rota | Descrição |
|--------|------|-----------|
| `POST` | `/infra/aws-s3/uploadfile/local` | Salva arquivo no disco do servidor |
| `POST` | `/infra/aws-s3/uploadfile` | Envia arquivo para o bucket S3 |
| `DELETE` | `/infra/aws-s3/deletefile/local` | Remove arquivo do disco do servidor |
| `DELETE` | `/infra/aws-s3/deletefile` | Remove objeto do bucket S3 |

### POST `/uploadfile/local`

Campos `multipart/form-data`:

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `file` | File | sim | Arquivo a ser salvo |
| `folderName` | string | sim | Sub-pasta dentro de `UPLOAD_PATH` |
| `fileName` | string | não | Nome final do arquivo (usa o original se omitido) |

Resposta de sucesso:
```json
{
  "success": true,
  "message": "Arquivo enviado para servidor da aplicação",
  "filePath": "/caminho/absoluto/no/disco",
  "objectUrl": "https://<STATIC_URL>/<folderName>/<fileName>"
}
```

### POST `/uploadfile`

Campos `multipart/form-data`:

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `file` | File | sim | Arquivo a ser enviado |
| `folderName` | string | sim | Prefixo/pasta no bucket |
| `fileName` | string | sim | Nome do objeto no bucket |
| `bucket` | string | não | Bucket alternativo; usa `S3_BUCKET_NAME` se omitido |

Resposta de sucesso:
```json
{
  "success": true,
  "message": "Arquivo enviado com sucesso",
  "objectUrl": "https://<bucket>.s3.<region>.amazonaws.com/<folderName>/<fileName>",
  "ETag": "\"abc123...\""
}
```

> **Atenção:** objetos são enviados com `ACL: public-read`. Não utilize para dados sensíveis.

### DELETE `/deletefile/local`

Body JSON:

| Campo | Tipo | Obrigatório |
|-------|------|-------------|
| `folderName` | string | sim |
| `fileName` | string | sim |

Resposta de sucesso:
```json
{ "success": true, "message": "Arquivo deletado com sucesso" }
```

### DELETE `/deletefile`

Body JSON:

| Campo | Tipo | Obrigatório |
|-------|------|-------------|
| `folderName` | string | sim |
| `fileName` | string | sim |
| `bucket` | string | não |

Resposta de sucesso:
```json
{
  "success": true,
  "message": "Arquivo deletado com sucesso",
  "deletedKey": "<folderName>/<fileName>"
}
```

---

## DTO — `ActionsFileObjectDto`

Sanitização aplicada via `@Transform` antes da validação:

| Campo | Regra de sanitização |
|-------|----------------------|
| `folderName` | Remove `..`, caracteres fora de `[a-zA-Z0-9_\-/]`, barras duplicadas e barras no início/fim |
| `fileName` | Remove `..`, caracteres fora de `[a-zA-Z0-9_\-/.]`, substitui barras por hífens |
| `bucket` | Opcional, sem sanitização |

O regex `@Matches` rejeita valores que escapem da sanitização, prevenindo path traversal.

---

## Service — `AwsS3Service`

### Dependências injetadas

| Token | Tipo | Origem |
|-------|------|--------|
| `S3_CLIENT` | `S3Client` | `s3ClientFactory` |
| `ConfigService` | NestJS | `@nestjs/config` |

### Variáveis de ambiente consumidas

| Variável | Uso |
|----------|-----|
| `AWS_REGION` | Região do bucket; default `us-east-1` |
| `S3_BUCKET_NAME` | Bucket padrão quando `bucket` não é informado |
| `UPLOAD_PATH` | Caminho raiz no disco para uploads locais |
| `STATIC_URL` | URL base para montar `objectUrl` nos uploads locais |

### Métodos

| Método | Assinatura resumida | Descrição |
|--------|---------------------|-----------|
| `uploadLocal` | `(file, folder, fileName) → Promise` | Cria diretório se necessário (`mkdir -p`) e grava o buffer |
| `deleteLocal` | `(folder, fileName) → Promise` | Remove o arquivo via `fs.unlink` |
| `uploadAwsS3` | `(file, fullKey, bucket?) → Promise` | `PutObjectCommand` com `ACL: public-read` |
| `deleteAwsS3` | `(fullKey, bucket?) → Promise` | `DeleteObjectCommand` |

Erros do SDK S3 (`S3ServiceException`) são relançados como `InternalServerErrorException` com o `httpStatusCode` original.

---

## Factory — `s3ClientFactory`

Token de injeção: `S3_CLIENT`

Cria um `S3Client` com credenciais estáticas lidas de:

| Variável | Campo no SDK |
|----------|--------------|
| `AWS_REGION` | `region` |
| `AWS_SDK_KEY` | `credentials.accessKeyId` |
| `AWS_SDK_SECRET` | `credentials.secretAccessKey` |

---

## Regras e Restrições

- O módulo **não exporta** `AwsS3Service` — outros módulos não devem injetá-lo diretamente.
- O campo `key` no S3 é montado como `join(folderName, fileName)` com barras normalizadas para `/`.
- Não há presigned URLs neste módulo; todos os objetos são públicos por ACL.
- Não há listagem de objetos — operações suportadas são apenas upload e deleção.
- Para adicionar presigned URLs ou listagem, criar novos métodos no `AwsS3Service` e novos endpoints no `AwsS3Controller`.
