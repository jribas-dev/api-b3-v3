# Módulo sql-files

Gerencia scripts SQL versionados por sistema, permitindo upload, consulta e download de arquivos `.sql` armazenados como blob binário no banco de dados. Suporta dois tipos de release: **FULL** (carga completa do schema) e **UPDATE** (script incremental de atualização).

## Responsabilidades

- Armazenar scripts SQL como `longblob` na tabela `sql_files`.
- Controlar versões (`versaoDb`) por sistema (`idSystem`) e tipo (`tipo`).
- Permitir que clientes consultem quais updates precisam aplicar a partir de uma versão base.
- Retornar o binário do script em Base64 para download pelo cliente.

## Estrutura de Arquivos

```
sql-files/
├── dto/
│   ├── create-sql-file.dto.ts    # Payload de criação (multipart/form-data)
│   ├── update-sql-file.dto.ts    # PartialType de CreateSqlFileDto
│   ├── response-sql-file.dto.ts  # Resposta pública (exclui o blob script)
│   └── download-sql-file.ts      # Resposta de download (idSql + sqlData base64)
├── entities/
│   └── sql-file.entity.ts        # Tabela sql_files
├── enums/
│   └── sql-files-tipo.enum.ts    # SqlFilesTipo: UPDATE='U' | FULL='F'
├── sql-files.controller.ts
├── sql-files.service.ts
└── sql-files.module.ts
```

## Entidade — `sql_files`

| Coluna     | Tipo                   | Descrição                                    |
|------------|------------------------|----------------------------------------------|
| `idSql`    | `int` PK auto-inc      | Identificador do registro                    |
| `idSystem` | `int` FK → `sistemas`  | Sistema ao qual o script pertence            |
| `tipo`     | `enum('U','F')`        | `U` = UPDATE incremental, `F` = FULL release |
| `versaoDb` | `decimal(9,3)`         | Versão do banco de dados do script           |
| `script`   | `longblob`             | Binário do arquivo SQL (não retornado por padrão via `select: false`) |
| `obs`      | `varchar(255)`         | Observação/descrição opcional                |
| `dthrSql`  | `timestamp`            | Data/hora do registro (preenchida no service)|

A coluna `script` tem `select: false` — só é carregada explicitamente via `getSQLBinary()`.

### Relacionamento

`SqlFilesEntity` → `ManyToOne` → `SystemsEntity` (`sistemas.idSystem`), com `onUpdate: CASCADE` e `onDelete: CASCADE`.

## Enum `SqlFilesTipo`

```typescript
enum SqlFilesTipo {
  UPDATE = 'U',  // Script incremental de atualização
  FULL   = 'F',  // Release completo do schema
}
```

## Endpoints

Todos os endpoints exigem `JwtGuard`. Endpoints de escrita exigem adicionalmente `RootGuard` (superadmin).

| Método   | Rota                                        | Guard            | Descrição                                              |
|----------|---------------------------------------------|------------------|--------------------------------------------------------|
| `POST`   | `/sql-files`                                | Root             | Upload de novo script (multipart, campo `sqlFile`, max 10 MB) |
| `GET`    | `/sql-files`                                | Root             | Lista todos os registros (sem blob)                    |
| `GET`    | `/sql-files/system/:id/bydays/:days`        | Root             | Scripts do sistema nos últimos N dias                  |
| `GET`    | `/sql-files/:id`                            | JWT              | Busca registro por `idSql`                             |
| `GET`    | `/sql-files/system/:id/updates/:version`    | JWT              | Updates com `versaoDb > version` (tipo=UPDATE, ASC)    |
| `GET`    | `/sql-files/system/:id`                     | JWT              | Último FULL release do sistema                         |
| `GET`    | `/sql-files/download/:id`                   | JWT              | Download do script em Base64 (`DownloadSqlFileDto`)    |
| `PATCH`  | `/sql-files/:id`                            | Root             | Atualiza metadados do registro                         |
| `DELETE` | `/sql-files/:id`                            | Root             | Remove o registro                                      |

> **Atenção à ordem das rotas no controller:** rotas estáticas como `/download/:id` e `/system/:id` devem preceder `/:id` para evitar conflitos de matching do NestJS.

## DTOs

### `CreateSqlFileDto`
Estende `OmitType(SqlFilesEntity, ['idSql', 'dthrSql'])`. O campo `script` (Buffer) **não** vem do body JSON — é injetado pelo controller a partir do arquivo Multer (`file.buffer`) após a validação de tamanho (max 10 MB). Os campos `idSystem` e `versaoDb` usam `@Transform` para converter string → number (necessário em `multipart/form-data`).

### `ResponseSqlFileDto`
Usa `@Exclude()` + `@Expose()` para expor apenas: `idSql`, `idSystem`, `tipo`, `versaoDb`, `obs`, `dthrSql` (convertido para ISO string). O `script` (blob) nunca é exposto.

### `DownloadSqlFileDto`
Retorna `{ idSql, sqlData }` onde `sqlData` é o binário do script codificado em **Base64**.

## Lógica de Negócio Principal

### `getReleasesFrom(systemId, fromVersion)`
Retorna todos os scripts do tipo `UPDATE` com `versaoDb > fromVersion`, ordenados por versão crescente. Usado por clientes para obter a sequência de updates a aplicar.

### `getLastFullRelease(systemId)`
Usa `MAX(versaoDb)` via QueryBuilder para localizar o FULL release mais recente do sistema.

### `getSQLBinary(idSql)`
Busca apenas a coluna `script` (explícito, pois `select: false`) e retorna o `Buffer` para o controller serializar em Base64.

## Dependências do Módulo

```typescript
TypeOrmModule.forFeature([SystemsEntity, SqlFilesEntity])
```

`SystemsEntity` é importada de `src/infra/common/system.entity.ts` (entidade compartilhada entre `sql-files` e `sys-files`).
