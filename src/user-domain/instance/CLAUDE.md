# Módulo: instance

Responsável pelo CRUD das instâncias (tenants). Cada instância representa um tenant com suas próprias coordenadas de banco de dados.

## Entidade: `InstanceEntity`

Tabela: `instance`

| Campo          | Tipo      | Padrão | Descrição                                    |
|----------------|-----------|--------|----------------------------------------------|
| `dbId`         | string    | CUID2  | PK gerada via `@BeforeInsert()` com CUID2    |
| `name`         | string    | —      | Nome de exibição da instância                |
| `dbName`       | string    | —      | Nome do banco de dados do tenant             |
| `dbHost`       | string    | —      | Host do banco de dados do tenant             |
| `maxCompanies` | number    | `1`    | Limite de empresas permitidas na instância   |
| `maxUsers`     | number    | `2`    | Limite de usuários permitidos na instância   |
| `isActive`     | boolean   | `true` | Se a instância está ativa                    |
| `createdAt`    | Date      | auto   | Timestamp de criação (`select: false`)       |
| `updatedAt`    | Date      | auto   | Timestamp de atualização (`select: false`)   |

**Relações:**
- `OneToMany` → `UserInstanceEntity` (usuários vinculados à instância)
- `OneToMany` → `UserPreInstanceEntity` (usuários pré-cadastrados vinculados à instância)

## Endpoints

Todos os endpoints exigem `JwtGuard` + `RootGuard` (acesso restrito ao superadmin).

| Método  | Rota             | Descrição                        | Status |
|---------|------------------|----------------------------------|--------|
| `POST`  | `/instances`     | Cria uma nova instância          | 201    |
| `GET`   | `/instances`     | Lista todas as instâncias        | 200    |
| `GET`   | `/instances/:id` | Busca uma instância pelo `dbId`  | 200    |
| `PATCH` | `/instances/:id` | Atualiza campos da instância     | 200    |

Não existe endpoint de `DELETE` — instâncias são desativadas via `isActive: false`.

## DTOs

- **`CreateInstanceDto`** — estende `OmitType(InstanceEntity, ['dbId', 'createdAt', 'updatedAt'])` com validações `class-validator`.
- **`UpdateInstanceDto`** — `PartialType(CreateInstanceDto)`, todos os campos opcionais.
- **`ResponseInstanceDto`** — usa `@Exclude()` / `@Expose()` via `class-transformer`; expõe apenas `dbId`, `name`, `dbName`, `dbHost`, `maxCompanies`, `maxUsers`, `isActive`. Omite `createdAt` e `updatedAt`.

## Comportamento de Negócio

- **Desativação em cascata:** ao atualizar `isActive` para `false`, o service automaticamente atualiza todos os registros `UserInstanceEntity` associados para `isActive: false`.
- **IDs:** gerados via CUID2 no hook `@BeforeInsert()` — nunca auto-increment.
- **`createdAt` / `updatedAt`** têm `select: false` — não são retornados nas queries padrão.
- **BuiltIn users anexados na criação:** após persistir a instância, o `create` busca os usuários BuiltIn por email e cria um `user_instances` para cada um no novo `dbId`. Se o usuário BuiltIn não existir no banco, é ignorado silenciosamente.

  | Email | `roleback` | `rolefront` | `idBackendUser` |
  |---|---|---|---|
  | `admin@b3erp.com.br` | `admin` | `[admin, supersaler, inventory, buyer]` | `1` |
  | `super@b3erp.com.br` | `supervisor` | `[admin, supersaler, inventory]` | `2` |

## Arquivos

```
src/instance/
├── entities/instance.entity.ts
├── dto/
│   ├── create-instance.dto.ts
│   ├── update-instance.dto.ts
│   └── response-instance.dto.ts
├── instance.controller.ts
├── instance.service.ts
└── instance.module.ts
```
