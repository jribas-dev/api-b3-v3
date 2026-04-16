# Specs — Sub-módulo `infra/sys-files`

> NestJS 11 / Node.js 22 · TypeScript · TypeORM

---

## Visão Geral

O sub-módulo `SysFilesModule` gerencia o catálogo de arquivos de sistema (instaladores, pacotes de atualização) distribuídos para clientes. Cada registro representa um arquivo publicado para um sistema específico (`idSystem`), com versão, tipo e localização (URL / S3 key).

Dois tipos de pacote são suportados via `SysFilesTipo`:

- **UPDATE (`U`)** — pacote incremental de atualização de versão.
- **FULL (`F`)** — pacote completo/instalador.

Na criação de um registro, a `versaoDb` é preenchida automaticamente a partir do maior `versaoDb` registrado no `SqlFilesModule` para o mesmo sistema e tipo correspondente.

---

## Estrutura de Arquivos

```
src/infra/sys-files/
├── sys-files.module.ts              # Importa TypeORM (SysFilesEntity, SqlFilesEntity, SystemsEntity)
├── sys-files.controller.ts          # 7 endpoints REST
├── sys-files.service.ts             # Lógica de negócio + integração com SqlFilesService
├── dto/
│   ├── create-sys-file.dto.ts       # Campos para criação (omite idFile, dthrFile, versaoDb)
│   ├── update-sys-file.dto.ts       # PartialType de CreateSysFileDto
│   └── response-sys-file.dto.ts    # Campos expostos na resposta (Exclude/Expose)
├── entities/
│   └── sys-file.entity.ts           # Tabela `sys_files`, PK int auto-increment
└── enums/
    └── sys-files-tipo.enum.ts       # UPDATE = 'U' | FULL = 'F'
```

---

## Endpoints

Base path: `/sys-files`

| Método | Rota | Guard | Descrição |
|--------|------|-------|-----------|
| `POST` | `/sys-files` | `RootGuard` | Cria registro de arquivo de sistema |
| `GET` | `/sys-files` | `RootGuard` | Lista todos os registros |
| `GET` | `/sys-files/:idfile` | `JwtGuard` | Busca registro por ID numérico |
| `GET` | `/sys-files/system/:id/releases/:version/:versionDb` | `JwtGuard` | Releases incrementais disponíveis para atualização |
| `GET` | `/sys-files/system/:id/fullpack/:versionDb` | `JwtGuard` | Pacote full compatível com versão do DB |
| `GET` | `/sys-files/system/:id/bydays/:days` | `RootGuard` | Registros criados nos últimos N dias |
| `PATCH` | `/sys-files/:id` | `RootGuard` | Atualiza campos de um registro |
| `DELETE` | `/sys-files/:id` | `RootGuard` | Remove registro por ID |

> Todos os endpoints exigem autenticação JWT (`JwtGuard` aplicado no nível do controller). `RootGuard` adiciona a restrição de superadmin sobre o `JwtGuard`.

---

### POST `/sys-files`

Body JSON (`CreateSysFileDto`):

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `idSystem` | `number \| null` | não | FK para `sistemas.idSystem` |
| `tipo` | `SysFilesTipo` (`'U'` \| `'F'`) | sim | Tipo do pacote |
| `versao` | `number` | sim | Versão do arquivo (decimal 9,3) |
| `fileName` | `string` | sim | Nome do arquivo |
| `url` | `string \| null` | não | URL pública de acesso |
| `s3Key` | `string \| null` | não | Chave do objeto no S3 |

Campos preenchidos automaticamente pelo service:

| Campo | Origem |
|-------|--------|
| `dthrFile` | `new Date()` no momento da criação |
| `versaoDb` | `SqlFilesService.getMaxVersionByType(idSystem, tipoSql)` — mapeamento: `UPDATE→SqlFilesTipo.UPDATE`, `FULL→SqlFilesTipo.FULL` |

Resposta de sucesso: `ResponseSysFileDto` com status `201`.

---

### GET `/sys-files/system/:id/releases/:version/:versionDb`

Retorna registros do tipo `UPDATE` para o sistema `id` onde:
- `versao > :version` (versão do cliente)
- `versaoDb <= :versionDb` (compatível com a versão do banco do cliente)
- Ordenados por `versao ASC`

Lança `NotFoundException` se nenhum resultado for encontrado.

---

### GET `/sys-files/system/:id/fullpack/:versionDb`

Retorna registros do tipo `FULL` para o sistema `id` onde:
- `versaoDb <= :versionDb`
- Ordenados por `versao DESC`

Lança `NotFoundException` se nenhum resultado for encontrado.

---

### GET `/sys-files/system/:id/bydays/:days`

Retorna registros criados nos últimos `:days` dias para o sistema `id`:
- Filtro: `dthrFile >= (hoje - days)`

Lança `NotFoundException` se nenhum resultado for encontrado.

---

## Entity — `SysFilesEntity`

Tabela: `sys_files`

| Coluna | Tipo SQL | TypeScript | Observações |
|--------|----------|------------|-------------|
| `idFile` | `int` PK auto-increment | `number` | Gerado pelo banco |
| `idSystem` | `int` nullable FK | `number \| null` | Referência a `sistemas.idSystem` |
| `tipo` | `enum('U','F')` | `SysFilesTipo` | Default `'U'` |
| `dthrFile` | `datetime` | `Date` | Default `CURRENT_TIMESTAMP` |
| `versao` | `decimal(9,3)` | `number` | Versão do arquivo |
| `versaoDb` | `decimal(9,3)` | `number` | Versão mínima do DB compatível |
| `fileName` | `varchar(256)` | `string` | Nome do arquivo |
| `url` | `varchar(400)` nullable | `string \| null` | URL pública |
| `s3Key` | `varchar(100)` nullable | `string \| null` | Chave no S3 |

Relacionamento: `@ManyToOne → SystemsEntity` com `CASCADE` em update e delete.

> **Atenção:** a PK `idFile` usa `@PrimaryGeneratedColumn` (int auto-increment), diferente do padrão CUID2 usado no restante da aplicação.

---

## DTOs

### `CreateSysFileDto`

Estende `OmitType(SysFilesEntity, ['idFile', 'dthrFile', 'versaoDb'])`.

Validações:

| Campo | Decorators |
|-------|-----------|
| `idSystem` | `@IsOptional` `@IsInt` |
| `tipo` | `@IsEnum(SysFilesTipo)` |
| `versao` | `@IsNotEmpty` `@IsNumber` |
| `fileName` | `@IsNotEmpty` `@IsString` |
| `url` | `@IsOptional` `@IsUrl` |
| `s3Key` | `@IsOptional` `@IsString` |

### `UpdateSysFileDto`

`PartialType(CreateSysFileDto)` — todos os campos opcionais.

### `ResponseSysFileDto`

Usa `@Exclude()` na classe e `@Expose()` por campo (whitelist). O campo `dthrFile` é transformado para ISO string via `@Transform`.

Campos expostos: `idFile`, `idSystem`, `tipo`, `dthrFile`, `versao`, `versaoDb`, `fileName`, `url`, `s3Key`.

---

## Service — `SysFilesService`

### Dependências injetadas

| Token | Tipo | Origem |
|-------|------|--------|
| `SysFilesRepository` | `Repository<SysFilesEntity>` | `@InjectRepository` |
| `SqlFilesService` | `SqlFilesService` | Provedor local |

### Métodos

| Método | Assinatura | Descrição |
|--------|-----------|-----------|
| `create` | `(dto) → Promise<ResponseSysFileDto>` | Resolve `versaoDb` via `SqlFilesService`, persiste e retorna |
| `findAll` | `() → Promise<ResponseSysFileDto[]>` | Lista todos; lança `NotFoundException` se vazio |
| `findOneById` | `(id: number) → Promise<ResponseSysFileDto>` | Busca por `idFile`; lança `NotFoundException` se não encontrado |
| `getReleases` | `(systemId, version, versionDb) → Promise<ResponseSysFileDto[]>` | Updates disponíveis acima da versão do cliente |
| `getFullRelease` | `(systemId, versionDb) → Promise<ResponseSysFileDto[]>` | Pacote full compatível com versão do DB |
| `findByDays` | `(idsystem, days) → Promise<ResponseSysFileDto[]>` | Registros criados nos últimos N dias |
| `update` | `(id, dto) → Promise<ResponseSysFileDto>` | Atualiza campos via `Object.assign`; garante que `dthrFile` seja `Date` |
| `remove` | `(id) → Promise<void>` | Deleta por `idFile`; lança `NotFoundException` se `affected === 0` |

---

## Módulo — `SysFilesModule`

Importa via `TypeOrmModule.forFeature`: `SystemsEntity`, `SysFilesEntity`, `SqlFilesEntity`.

Providers: `SysFilesService`, `SqlFilesService` (instanciado localmente — não importado de `SqlFilesModule`).

O módulo **não exporta** nenhum serviço.

---

## Regras e Restrições

- `versaoDb` nunca é informada pelo chamador — é sempre derivada do estado atual dos `SqlFiles` no momento da criação.
- O tipo `SysFilesTipo.UPDATE` corresponde a `SqlFilesTipo.UPDATE`; `SysFilesTipo.FULL` corresponde a `SqlFilesTipo.FULL`.
- Todos os endpoints de escrita e listagem global exigem `RootGuard` (superadmin). Leitura por ID e buscas de release exigem apenas `JwtGuard` com escopo completo.
- Não há paginação — `findAll` retorna todos os registros.
- `SqlFilesService` é instanciado dentro deste módulo (não via importação de `SqlFilesModule`); para remover o acoplamento implícito, seria necessário exportar `SqlFilesService` de `SqlFilesModule` e importar o módulo aqui.
