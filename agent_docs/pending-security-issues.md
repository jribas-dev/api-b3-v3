# Pendências de Segurança

> Itens identificados na auditoria de 2026-04-22 que **não foram implementados** neste ciclo.
> Cada item tem decisão registrada, risco documentado e opções de solução para o próximo ciclo.

---

## C1 — Guard comentado em `POST /auth/refresh`

**Arquivo:** `src/auth/auth.controller.ts` linha 64  
**Status:** Aguardando decisão  
**Severidade original:** CRITICAL

### Situação atual

O endpoint `POST /auth/refresh` tem os guards `JwtGuard` e `UserInstanceGuard` comentados:

```typescript
@Post('refresh')
// @UseGuards(JwtGuard, UserInstanceGuard)  // GUARDS COMENTADOS
@HttpCode(HttpStatus.OK)
async refresh(@Body() body: { refreshToken: string }) {
  return this.authService.refresh(body.refreshToken);
}
```

### Risco

Qualquer pessoa sem autenticação pode chamar este endpoint com um refresh token válido (obtido por vazamento ou interceptação) e gerar novos access tokens indefinidamente.

### Análise do comportamento atual

O `AuthService.refresh()` já valida internamente:
- O refresh token existe no banco
- Não está revogado (`isRevoked === false`)
- Não está expirado (`expiresAt > now`)

Então o risco real depende de um atacante conseguir obter um refresh token válido.

### Opções de solução

**Opção A (recomendada):** Descomentar os guards. O `JwtGuard` valida que o requisitante tem um access token válido; `UserInstanceGuard` garante que é um token de instância. O refresh seria então chamado com o access token atual para obter um novo par — padrão normal de rotação.

**Opção B:** Remover os guards mas adicionar rate limiting estrito (ex: 3 req/min por IP) como mitigação parcial.

**Opção C:** Manter como está, aceitando o risco em prol de simplicidade de fluxo (ex: frontend não quer armazenar 2 tokens).

### Como corrigir (Opção A)

```typescript
@Post('refresh')
@UseGuards(JwtGuard, UserInstanceGuard)
@HttpCode(HttpStatus.OK)
async refresh(@Body() body: { refreshToken: string }) {
  return this.authService.refresh(body.refreshToken);
}
```

---

## H4 — `synchronize: true` no banco principal em produção

**Arquivo:** `src/app.module.ts` linha 32  
**Status:** Aguardando definição de estratégia de migration  
**Severidade original:** HIGH

### Situação atual

```typescript
synchronize: true, // cuidado: use false em produção!
```

### Risco

Em produção, o TypeORM aplica alterações de schema automaticamente a cada startup. Alterações nas entities (colunas renomeadas, removidas, tipos alterados) podem causar:
- Perda de dados silenciosa
- Erros de inicialização que derrubam o serviço
- Corrupção de schema se houver divergência entre código e banco

### Opções de solução

**Opção A (recomendada):** Condicionar ao ambiente:
```typescript
synchronize: config.get('APP_ENVIRONMENT') !== 'production',
```

**Opção B:** Desligar permanentemente e usar migrations TypeORM explícitas (arquivo `.migration.ts` gerado por `typeorm migration:generate`).

**Opção C:** Manter para desenvolvimento mas garantir via CI/CD que `APP_ENVIRONMENT=production` está setado em produção (Opção A simplificada).

### Pré-requisito

Antes de desligar `synchronize`, garantir que o schema do banco principal em produção está em sincronia com as entities atuais. Rodar com `synchronize: true` uma única vez em staging para validar.

---

## M1 — CORS desabilitado

**Arquivo:** `src/main.ts` linhas 22-29 (comentadas)  
**Status:** Aguardando confirmação da URL do frontend  
**Severidade original:** MEDIUM

### Situação atual

```typescript
// app.enableCors({
//   origin: origin,
//   methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
//   preflightContinue: false,
// });
```

### Risco

Sem CORS configurado, browsers bloqueiam requisições cross-origin legítimas do frontend. Ferramentas não-browser (curl, Postman, scripts maliciosos) não são afetadas pelo CORS — então **a ausência de CORS não é proteção de segurança**, mas a presença de uma allowlist garante que apenas origens conhecidas podem fazer chamadas via browser.

### Como corrigir

```typescript
// src/main.ts
app.enableCors({
  origin: config.get<string>('FRONTEND_URL'),
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  credentials: true,
  preflightContinue: false,
});
```

Variável `FRONTEND_URL` já existe no `.env.sample` e no schema Joi.

### Ação necessária

Confirmar a URL exata do frontend de produção antes de habilitar. Se houver múltiplos frontends (ex: app + admin), usar array:
```typescript
origin: ['https://app.dominio.com', 'https://admin.dominio.com'],
```

---

## M5 — Access token de instância com 3 horas de expiração

**Arquivo:** `src/auth/auth.service.ts` linha 131  
**Status:** Aguardando análise de impacto no fluxo do frontend  
**Severidade original:** MEDIUM

### Situação atual

```typescript
const accessToken = await this.jwtService.signAsync(payload, {
  expiresIn: '180m',  // 3 horas
});
```

### Risco

Um access token comprometido (ex: XSS, log leak) permanece válido por 3 horas. Padrão da indústria é 15-30 minutos, com renovação via refresh token.

### Impacto de reduzir

O frontend precisaria chamar `POST /auth/refresh` mais frequentemente para manter a sessão ativa. Se o frontend já implementa renovação automática de token, reduzir para 30 minutos é transparente para o usuário.

### Como corrigir

```typescript
// auth.service.ts — loginInstance()
const accessToken = await this.jwtService.signAsync(payload, {
  expiresIn: '30m',
});
// Ajustar expiresIn na resposta:
return {
  ...
  expiresIn: 1800,  // 30 minutos
};
```

```typescript
// auth.service.ts — refresh()
const newAccessToken = await this.jwtService.signAsync(payload, {
  expiresIn: '30m',
});
```

### Ação necessária

1. Verificar se o frontend implementa renovação automática (interceptor de 401 → refresh → retry)
2. Se sim: reduzir para `30m` imediatamente
3. Se não: implementar a renovação automática no frontend antes de reduzir o TTL

---

## M8 — Endpoints `findAll()` sem paginação

**Arquivos:**
- `src/user-domain/user/user.controller.ts` — `GET /users`
- `src/user-domain/instance/instance.controller.ts` — `GET /instances`
- `src/infra/sql-files/sql-files.controller.ts` — `GET /sql-files`
- `src/infra/sys-files/sys-files.controller.ts` — `GET /sys-files`

**Status:** Aguardando definição do modelo de paginação  
**Severidade original:** MEDIUM

### Risco

Com crescimento de dados, queries sem limite podem causar:
- Alto consumo de memória no servidor
- Timeout de resposta
- Degradação de performance para todos os usuários (DoS não intencional)

Atualmente mitigado pelo fato de que todos esses endpoints exigem `RootGuard` — apenas superadmins podem acioná-los.

### Opções de solução

**Opção A — Paginação por offset (mais simples):**
```typescript
// DTO de query
@IsOptional() @IsInt() @Min(0) @Type(() => Number)
skip?: number = 0;

@IsOptional() @IsInt() @Min(1) @Max(200) @Type(() => Number)
take?: number = 50;

// Service
return repo.findAndCount({ skip, take });
// Resposta: { data: [...], total, skip, take }
```

**Opção B — Limite fixo sem paginação:**
Adicionar `.limit(500)` nas queries como proteção mínima enquanto paginação não é implementada.

### Ação necessária

Definir o modelo de paginação padrão da API (offset vs cursor) e aplicar uniformemente em todos os endpoints de listagem.
