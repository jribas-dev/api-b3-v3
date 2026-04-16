# Módulo: user

## Responsabilidade

Gerencia os **usuários ativos da API**. Um usuário só chega aqui após concluir o fluxo de convite do `user-pre`. É a entidade central de autenticação e autorização da aplicação.

## Entidade: `user`

| Campo | Tipo | Descrição |
|---|---|---|
| `userId` | string (CUID2) | PK — gerado via `@BeforeInsert()` com `createId()` |
| `email` | varchar(128) unique | Login principal |
| `phone` | varchar(128) nullable | Telefone BR |
| `password` | varchar(300) select:false | Hash bcrypt — nunca retornado em queries padrão |
| `name` | varchar(128) | Nome de exibição |
| `isRoot` | boolean | Superadmin global da API. Default: `false` |
| `isActive` | boolean | Usuário ativo/inativo. Default: `true` |
| `createdAt` | Date | Criação |
| `updatedAt` | Date | Última atualização |

Relação `OneToMany` com `user_instances` (vínculos com tenants).

## Flags de Permissão

- **`isRoot`**: flag global que concede acesso irrestrito a todos os endpoints protegidos por `RootGuard`. Independe de tenant — o superadmin enxerga tudo.
- **`roleBack` / `roleFront`**: não ficam no `user`, ficam em `user_instances` (por tenant). Veja o módulo `user-instance`.

## Endpoints

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/users` | JwtGuard | Cria usuário diretamente (fluxo alternativo, sem convite) |
| `GET` | `/users` | JwtGuard + RootGuard | Lista todos os usuários |
| `GET` | `/users/get/me` | JwtGuard | Retorna o próprio usuário pelo JWT |
| `GET` | `/users/:id` | JwtGuard | Busca por userId |
| `PATCH` | `/users/:id` | JwtGuard | Atualiza dados (Root pode editar qualquer um; usuário só edita a si mesmo) |
| `DELETE` | `/users/:id` | JwtGuard + RootGuard | Remove usuário |

## Regras de Negócio

- Email e telefone devem ser únicos — validados no controller antes de delegar ao service.
- Senha deve ter mínimo 8 caracteres com letras e números (regex no controller: `/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$/`).
- Ao criar usuário, dispara email de boas-vindas (`TemplateType.WELCOME`).
- Ao atualizar senha via `PATCH`, o service reaplica o hash automaticamente.
- Ao inativar (`isActive = false`), o service propaga `isActive = false` para todos os `user_instances` do usuário.
- `isRoot` não é exposto no `CreateUserDto` — só pode ser definido manualmente no banco ou por um Root via `PATCH`.

## DTOs

- **`CreateUserDto`**: email, phone (BR), password (min 8), name. Omite userId, isRoot, isActive, timestamps.
- **`UpdateUserDto`**: todos os campos de `CreateUserDto` como opcionais.
- **`ResponseUserDto`**: exclui `password` da resposta (via `class-transformer`).

## Dependências Internas

- `PasswordService` — hashing bcrypt de senhas.
- `AwsSenderService` — email de boas-vindas ao criar usuário.
- `UserInstanceEntity` — injetado diretamente para propagar inativação em cascata.
