# Módulo: user-pre

## Responsabilidade

Gerencia o **pré-cadastro de usuários por convite**. É uma etapa temporária — o registro aqui não representa um usuário ativo na API. Ao concluir o cadastro, os dados são migrados para `user` e `user-instances`, e o registro `user_pre` é deletado.

## Fluxo de Convite

```
Admin/Root convida (POST /user-pre/create)
  └─ Registra quem enviou o convite (userInviteId = userId do admin)
  └─ Cria user_pre (token hex 176 chars, expira em 12h)
  └─ Cria user_pre_instances (uma por tenant)
  └─ Envia email com link: FRONTEND_URL/user-pre/confirm/?token=&email=

Convidado clica no link → frontend valida (GET /user-pre/check?email=&token=)
  └─ Verifica existência e expiração
  └─ Se expirado: deleta o registro → admin pode regenerar via POST /user-pre/regenerate

Convidado preenche telefone e senha (POST /user-pre/confirm)
  └─ Valida token novamente
  └─ Cria UserEntity (user.service.create)
  └─ Cria UserInstanceEntity para cada tenant pré-configurado
  └─ Deleta o registro user_pre (e user_pre_instances por CASCADE)
  └─ Dispara email de boas-vindas (TemplateType.WELCOME)
```

## Entidades

### `user_pre`
| Campo | Tipo | Descrição |
|---|---|---|
| `userPreId` | int (auto) | PK |
| `email` | varchar(128) unique | Email do convidado |
| `token` | varchar unique | `randomBytes(88).toString('hex')` — 176 chars |
| `expiresAt` | Date | Agora + 12 horas |
| `userInviteId` | varchar(36) nullable | `userId` do admin que enviou o convite (imutável após insert) |
| `createdAt` | Date | Auditoria |

### `user_pre_instances`
Espelho de `user_instances` para o período de pré-cadastro.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | int (auto) | PK |
| `userPreId` | int | FK → user_pre |
| `dbId` | string | FK → instance (tenant) |
| `idBackendUser` | int \| null | ID do usuário no sistema legado do tenant |
| `roleback` | RoleBack enum | Papel no BackOffice |
| `rolefront` | RoleFront (`RoleFrontEnum[]`) | Papéis no Web (CSV no banco, array em memória) |

## Endpoints

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `POST` | `/user-pre/create` | JwtGuard + AdminGuard | Cria convite; grava `userInviteId` do admin autenticado |
| `GET` | `/user-pre/check` | Público | Valida token antes de exibir o formulário |
| `POST` | `/user-pre/confirm` | Público | Conclui cadastro |
| `GET` | `/user-pre/my-invites` | JwtGuard + AdminGuard | Lista convites enviados pelo admin autenticado (sem instâncias) |
| `POST` | `/user-pre/resend` | JwtGuard + AdminGuard | Reenvia e-mail de convite (token inalterado) |
| `POST` | `/user-pre/regenerate` | JwtGuard + AdminGuard | Gera novo token (+ nova expiração de 12h) e reenvia e-mail |

### Bodies

**POST /user-pre/resend** e **POST /user-pre/regenerate**
```json
{ "email": "usuario@exemplo.com" }
```
Retornam **204 No Content**. Lançam **404** se o email não tiver convite pendente.

## Métodos do Service

| Método | Descrição |
|---|---|
| `create(data, userInviteId)` | Cria o pré-cadastro e envia o e-mail de convite |
| `sendInviteEmail(email, token)` | *(privado)* Monta a URL e envia o e-mail via `NEWUSER_CALL` |
| `checkUserPre(data)` | Valida email + token; rejeita ou deleta se expirado |
| `confirmUser(data, check)` | Migra o pré-cadastro para `user` + `user_instances` |
| `findMyInvites(userId)` | Retorna todos os convites onde `userInviteId = userId` |
| `resendInvite(email)` | Reenvia e-mail com token atual |
| `regenerateToken(email)` | Substitui token e `expiresAt`, depois reenvia e-mail |

## Regras de Negócio

- Se o email já existe em `user`, rejeita com 401 (usuário já ativo).
- Se já existe um `user_pre` com o mesmo email:
  - Ainda válido → rejeita (não permite duplicate invite).
  - Expirado → deleta o antigo e cria novo convite.
- `userInviteId` é preenchido no insert e nunca alterado.
- O `confirm` valida que o `email` do body corresponde ao `email` do token.
- Ao confirmar, os `user_pre_instances` são copiados exatamente para `user_instances` com `isActive: true`.

## Dependências Internas

- `UserService` — cria o usuário definitivo.
- `UserInstanceService` — vincula o usuário aos tenants.
- `AwsSenderService` — envia email de convite (`NEWUSER_CALL`) e boas-vindas (`WELCOME`).
