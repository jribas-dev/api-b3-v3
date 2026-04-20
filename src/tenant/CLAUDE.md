# tenant

Módulo compartilhado de nível raiz que fornece **acesso multi-tenant ao banco de dados**. Não expõe endpoints próprios — é consumido por todos os módulos de domínio (`b3vendas`, futuros `b3dash`, `b3financeiro`, etc.) que precisam se conectar dinamicamente ao banco de cada tenant.

## Responsabilidade

- Resolver o `InstanceEntity` (do banco principal) para obter as coordenadas de conexão do tenant.
- Criar, cachear e reutilizar `DataSource` TypeORM por tenant (uma conexão por `dbId`).
- Gerenciar o ciclo de vida dos pools: criação lazy, eviction manual e shutdown gracioso.
- Expor leitura de parâmetros de configuração por tenant via tabela `cfg`.

## Estrutura de Arquivos

```
src/tenant/
├── tenant.module.ts          # Módulo raiz — providers globais para toda a app
├── tenant.service.ts         # Factory + cache de DataSources por dbId
├── cfg.service.ts            # Leitura de parâmetros tenant-scoped (tabela cfg)
├── tenant-entities.ts        # Registro central de entities tenant (TENANT_ENTITIES)
└── entities/
    └── cfg.entity.ts         # Entity da tabela cfg
```

## TenantService

### API Pública

| Método | Assinatura | Descrição |
|---|---|---|
| `getDataSource` | `(dbId: string) => Promise<DataSource>` | Retorna DataSource do cache ou cria nova conexão. Sempre inicializada. |
| `evictDataSource` | `(dbId: string) => Promise<void>` | Remove do cache e destrói a conexão. Usar após mudança de config do tenant. |
| `onModuleDestroy` | `() => Promise<void>` | Hook NestJS — fecha **todas** as conexões no shutdown (via `Promise.allSettled`). |

### Estratégia de Cache

```
Map<dbId, DataSource>
```

| Aspecto | Detalhe |
|---|---|
| Lookup | `connections.get(dbId)` |
| Hit válido | `cached?.isInitialized === true` → retorna cached |
| Hit stale | `isInitialized === false` → loga warning, deleta, recria |
| Miss | Consulta `InstanceEntity` no banco principal → cria DataSource → cacheia |
| TTL | **Nenhum** — vive enquanto o processo estiver ativo |
| Thread-safety | Garantida pelo event loop single-thread do Node.js |

### Configuração do DataSource

A conexão por tenant combina:
- **Host e database:** do registro `InstanceEntity` (`dbHost`, `dbName`) — banco principal.
- **Porta, usuário e senha:** compartilhados via `ConfigService` (`DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`).
- **Pool:**

```typescript
extra: {
  connectionLimit: inst.maxUsers,   // por-tenant (campo InstanceEntity.maxUsers)
  waitForConnections: true,         // enfileira ao invés de falhar
  queueLimit: 0,                    // fila sem limite
}
```

- **Entities:** o array `TENANT_ENTITIES` (ver abaixo) — registradas em cada DataSource criada.
- **synchronize:** sempre `false` no tenant (schema é governado pelo script do produto, não pela aplicação).

### Ciclo de Vida

1. **Boot da aplicação:** `TenantModule` é instanciado; nenhuma conexão é criada.
2. **Primeira chamada para um `dbId`:** lazy-creation — query em `InstanceEntity` + `new DataSource().initialize()`.
3. **Chamadas subsequentes:** cache hit imediato.
4. **Mudança de config do tenant:** chamar `evictDataSource(dbId)` para forçar recriação na próxima chamada.
5. **Shutdown (SIGTERM):** `onModuleDestroy` fecha todas via `ds.destroy()` em paralelo e limpa o Map.

## CfgService

Expõe leitura de parâmetros da tabela `cfg` do tenant.

### Interface `CfgValue`

```typescript
export interface CfgValue {
  valor: string;
  descricao: string | null;
}
```

### Métodos

| Método | Comportamento |
|---|---|
| `get(dbId, param)` | Retorna `CfgValue`. Lança `NotFoundException` se o parâmetro não existir. |
| `find(dbId, param)` | Retorna `CfgValue \| null`. Não lança. |

**Sem cache:** cada chamada executa query no banco do tenant. Se for chamado em hot paths, considerar cache por camada superior.

### Entity `CfgEntity` — tabela `cfg`

| Campo | Tipo DB | Descrição |
|---|---|---|
| `param` | varchar(60) PK | Nome do parâmetro |
| `descricao` | varchar(250) nullable | Descrição do parâmetro |
| `valor` | varchar(120) | Valor armazenado |

**Uso conhecido:** `OperacaoService` (b3vendas) lê `VWEBOPERCOND` para interpolar cláusula SQL dinâmica no filtro de operações permitidas por deployment. `SellerContextService` (b3vendas/shared) usa `TenantService` apenas para resolver `usuId` e `vendId` — `empId` foi removido do contexto e deve ser passado explicitamente pelo frontend.

## TENANT_ENTITIES

`tenant-entities.ts` exporta o array único com **todas** as entities registradas em conexões tenant. Deve ser mantido atualizado sempre que um novo módulo de domínio adicionar entities ao banco do tenant.

```typescript
export const TENANT_ENTITIES = [
  CfgEntity,

  // b3vendas
  ClienteEntity,
  VendaEntity,
  VendaCaixaEntity,
  VendaItemEntity,
  OperacaoEntity,
  ProdutoEntity,
  ProdutoImpostoEntity,
  ImpostoEntity,
  ProdutoTabValorEntity,
  FormaPagamentoEntity,
  CondicaoPagamentoEntity,
];
```

> **Atenção:** Todas as entities do tenant são registradas em **todas** as conexões, independentemente do módulo que fará uso delas. Ao adicionar uma nova entity tenant, importá-la aqui é obrigatório para que o repositório funcione.

## Estrutura do Módulo

```typescript
@Module({
  imports: [TypeOrmModule.forFeature([InstanceEntity])],  // banco principal
  providers: [TenantService, CfgService],
  exports: [TenantService, CfgService],
})
export class TenantModule {}
```

- Importa **apenas** `InstanceEntity` do banco principal (para resolver o dbId → coordenadas de conexão).
- Não é dinâmico (sem `forRoot` / `forFeature`).
- Exporta ambos os serviços para consumo por qualquer módulo da aplicação.

## Padrão de Consumo

```typescript
// Em qualquer service de módulo de domínio
constructor(
  private readonly tenantService: TenantService,
  private readonly cfgService: CfgService,
) {}

async algumaOperacao(dbId: string) {
  const ds = await this.tenantService.getDataSource(dbId);
  const repo = ds.getRepository(ClienteEntity);
  return repo.findBy({ ativo: true });
}

async lerConfig(dbId: string) {
  const cfg = await this.cfgService.find(dbId, 'VWEBOPERCOND');
  return cfg?.valor ?? '';
}
```

Para módulos que precisam compartilhar resolução tenant + serviços auxiliares (ex: `b3vendas`), o padrão é criar um `SharedModule` interno que reexporta `TenantModule`.

## Variáveis de Ambiente

| Variável | Uso |
|---|---|
| `DB_PORT` | Porta compartilhada entre todos os tenants |
| `DB_USERNAME` | Usuário MySQL compartilhado |
| `DB_PASSWORD` | Senha MySQL compartilhada |

> `DB_HOST` **não** é consumido pelo TenantService. O host vem do registro `InstanceEntity.dbHost` de cada tenant — permite multi-host por design.

## Decisões de Design

| Decisão | Justificativa |
|---|---|
| Lazy-loading | Evita criar conexões para tenants que não fazem requests no período. |
| Cache sem TTL | Conexões MySQL já possuem pool interno com `waitForConnections`; reciclar DataSource por tempo seria desperdício. |
| `synchronize: false` | Schema do banco tenant é gerenciado externamente (migrations manuais / scripts versionados). |
| Uma `TENANT_ENTITIES` global | Simplifica: qualquer módulo pode abrir repositório de qualquer entity. Custo: carga de metadata TypeORM em todas as conexões. |
| `onModuleDestroy` com `Promise.allSettled` | Garante tentativa de fechamento de todas as conexões mesmo que uma falhe. |

## Limitações Conhecidas

- **Sem invalidação automática:** se a config do tenant mudar em `InstanceEntity` (ex: `dbHost` ou `maxUsers`), a conexão cacheada continua usando os valores antigos. Chamar `evictDataSource(dbId)` manualmente.
- **Escala horizontal:** o cache é por-processo. Em múltiplas instâncias, cada processo mantém seu próprio pool — o `connectionLimit` efetivo é `maxUsers × nº-processos`.
- **Sem métricas/observabilidade:** não há logs estruturados ou contadores de hit/miss de cache.
