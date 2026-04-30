# Módulo: user-domain

Módulo agregador que encapsula todos os sub-módulos relacionados a **usuários e tenants**. Não expõe endpoints próprios — sua função é importar e re-exportar os 4 sub-módulos para o `AppModule`, mantendo o domínio de usuários coeso e isolado do restante da aplicação.

## Sub-módulos

| Sub-módulo | Tabelas | Responsabilidade |
|---|---|---|
| [`instance`](./instance/CLAUDE.md) | `instance` | CRUD de tenants (instâncias). Acesso restrito ao superadmin (`RootGuard`). |
| [`user`](./user/CLAUDE.md) | `user` | CRUD de usuários ativos. Ponto central de autenticação. |
| [`user-instance`](./user-instance/CLAUDE.md) | `user_instances` | Tabela de junção User↔Instance com roles RBAC por tenant. |
| [`user-pre`](./user-pre/CLAUDE.md) | `user_pre`, `user_pre_instances` | Fluxo de convite/pré-cadastro. Registro temporário que migra para `user` ao confirmar. |

## Relações entre os sub-módulos

```
instance (tenant)
  ├── user_instances  ←── user (usuário ativo)
  └── user_pre_instances ←── user_pre (convite pendente)
```

- `user_instances` é a tabela de junção central — um usuário pode estar vinculado a múltiplos tenants, cada um com `roleBack` e `roleFront` (array de `RoleFrontEnum`) independentes.
- `user_pre` é efêmero: ao concluir o convite, seus dados migram para `user` + `user_instances` e o registro é deletado.
- Inativação em cascata: desativar um `user` propaga `isActive: false` para todos os seus `user_instances`; desativar uma `instance` propaga o mesmo para todos os seus `user_instances`.

## Fluxo de criação de usuário

```
Convite (user-pre)                      Direto (user)
───────────────────                     ──────────────────
POST /user-pre/create                   POST /users
  └─ Cria user_pre + user_pre_instances   └─ Cria user diretamente
  └─ Envia email de convite

GET /user-pre/check?email=&token=
  └─ Valida token (público)

POST /user-pre/confirm
  └─ Cria user
  └─ Cria user_instances (por tenant)
  └─ Deleta user_pre
  └─ Envia email de boas-vindas
```

## Uso no fluxo de autenticação

O `auth` module consome este domínio em dois momentos:
1. **`POST /auth/login`** — valida credenciais consultando `UserEntity` pelo email.
2. **`POST /auth/instance`** — chama `UserInstanceService.findValid(userId, dbId)` para confirmar o vínculo ativo e compor o JWT com escopo (`instanceId`, `roleBack`, `roleFront`).

## Estrutura de arquivos

```
src/user-domain/
├── user-domain.module.ts       # Agrega e re-exporta os 4 sub-módulos
├── instance/                   # CRUD de tenants
├── user/                       # CRUD de usuários ativos
├── user-instance/              # Vínculos User↔Tenant + RBAC
└── user-pre/                   # Fluxo de convite/pré-cadastro
```
