# API Contracts — Módulo b3vendas

> Domínio de **vendas** sobre o banco do tenant.
>
> Base URL: `https://<host>/b3vendas`
>
> **Todos os endpoints exigem token de etapa 2** (com `dbId` no payload):
> ```
> Authorization: Bearer <accessToken-etapa2>
> ```
>
> Guards aplicados em toda a base:
> - `JwtGuard` — token JWT válido + não revogado.
> - `UserInstanceGuard` — token deve conter `dbId` (tenant selecionado).
> - `RolesFrontGuard` (somente em endpoints anotados) — `roleFront` é um **array** (`RoleFrontEnum[]`); o guard aprova quando há interseção com os papéis exigidos.

---

## Índice

- [Conceitos transversais](#conceitos-transversais)
- [Clientes](#clientes)
- [Equipe de Vendas](#equipe-de-vendas)
- [Operações Fiscais](#operações-fiscais)
- [Produtos](#produtos)
- [Pedidos](#pedidos)
- [Itens do Pedido](#itens-do-pedido)
- [Formas e Condições de Pagamento](#formas-e-condições-de-pagamento)
- [Métricas de Desempenho](#métricas-de-desempenho)
- [Fluxo Completo de Criação de Pedido](#fluxo-completo-de-criação-de-pedido)
- [Estados / Enums de Referência](#estados--enums-de-referência)

---

## Conceitos transversais

### Contexto do Vendedor

Toda chamada resolve internamente o `userId` do JWT para um **vendedor** cadastrado no banco do tenant (`usu.userId → usu.idvend → cnt`). Se não houver vínculo, **403 Forbidden**.

A partir desse `vendId`, o backend filtra:

- **Clientes**: `cnt.idvende = vendId` (busca, rede-sp, métricas, alteração).
- **Pedidos**: `venda.idvend = vendId` (listagens e ações).
- Exceção: o "Consumidor Final" (`cnt.id = 99`) sempre aparece em `GET /clientes/buscar`.

### `idemp` e multi-empresa

`idemp` (ID da empresa emitente) **não está no token**. Cada chamada que precisa dele recebe via **query string** (listagens) ou **body** (criação de pedido). Use `GET /tenant/emitentes` (em `api-core.md`) para obter as empresas disponíveis ao usuário.

### Papéis (`RoleFrontEnum`)

Apenas `supersaler` e `saler` interagem com `b3vendas`. Demais papéis (`admin`, `inventory`, `buyer`, `notallow`) são bloqueados pelos guards.

| Papel | Escopo |
|---|---|
| `supersaler` | Vê e altera dados de toda a equipe. Único papel autorizado a criar/alterar/remover clientes e gerenciar equipe. |
| `saler` | Vê e altera apenas seus próprios dados. |

> **Exclusividade:** `saler` e `supersaler` não coexistem no mesmo vínculo (validação no `BeforeInsert`/`BeforeUpdate` de `user_instances`). Onde a precedência importa, **`supersaler` vence `saler`** (avaliados via `.includes()`).

---

## Clientes

Base: `/b3vendas/clientes` — gerencia a tabela `cnt` do tenant.

---

### `GET /b3vendas/clientes/buscar`

Autocomplete de cliente. Mínimo de **2 caracteres** em `q`. Filtra por clientes ativos do vendedor autenticado e **inclui sempre o id 99 (Consumidor Final)**.

**Auth:** `JwtGuard + UserInstanceGuard`.

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `q` | string | ✅ (mín. 2) | Texto: razão social, CNPJ/CPF (`docfed`) ou ID. Match case-insensitive em `razao` e literal em `docfed`/`id`. |

**Resposta `200`:**

```jsonc
[
  {
    "id": 123,
    "razao": "Empresa ABC Ltda",
    "display": "[00123] Empresa ABC Ltda"
  }
]
```

`display` segue o formato `[id-com-5-dígitos] razao`.

**Erros:** `400` se `q` tem menos de 2 caracteres; `403` se o usuário não é vendedor no tenant.

---

### `GET /b3vendas/clientes/:id`

Detalhes completos do cliente para uso em formulário de pedido.

**Auth:** `JwtGuard + UserInstanceGuard`.

**Resposta `200`:**

```jsonc
{
  "id": 123,
  "tipopessoa": "J",                    // F=Física, J=Jurídica, E=Estatal, R=Rural
  "razao": "Empresa ABC Ltda",
  "fantasia": null,
  "docfed": "12345678000190",            // só dígitos (pode ser null)
  "docformatado": "12.345.678/0001-90",  // formatado pela função SQL format_docfed
  "docest": "103.104.105.106",           // I.E. ou RG (pode ser null)
  "email": "contato@abc.com",
  "emailnfe": "nfe@abc.com",
  "emailcob": "cob@abc.com",
  "site": "abc.com",
  "cep": "14035090",
  "endereco": "Rua das Flores",
  "nroend": "100",
  "bairro": "Centro",
  "cidade": "São Paulo",
  "uf": "SP",
  "fone": "(11) 3333-3333",
  "fone2": null,
  "cel": "(11) 92222-3333",
  "obsvenda": "Entregar à tarde",        // exibida no formulário de pedido
  "idoper": 5,                           // operação fiscal padrão (pode ser null)
  "idvende": 102                         // vendedor responsável (pode ser null)
}
```

**Erros:** `404` se o cliente não existir ou estiver inativo.

> Observação: este endpoint **não** verifica se o cliente está vinculado ao vendedor — apenas se está ativo.

---

### `POST /b3vendas/clientes`

Cria um novo cliente. `idvende` default = vendedor logado; `ativo = true` automático. **Não há verificação de duplicidade de `docfed`** — o frontend é responsável.

**Auth:** `JwtGuard + UserInstanceGuard + RolesFrontGuard` (role: `supersaler`).

**Body:**

| Campo | Tipo | Obrigatório | Limite |
|---|---|---|---|
| `tipopessoa` | enum | ❌ (default `F`) | `F`/`J`/`E`/`R` |
| `razao` | string | ✅ | 2–100 |
| `fantasia` | string | ❌ | máx. 60 |
| `docfed` | string | ❌ | máx. 20 |
| `docest` | string | ❌ | máx. 20 |
| `email` / `emailnfe` / `emailcob` | string (email) | ❌ | máx. 120 |
| `site` | string | ❌ | máx. 120 |
| `cep` | string | ❌ | máx. 10 |
| `endereco` | string | ❌ | máx. 120 |
| `nroend` | string | ❌ | máx. 10 |
| `bairro` / `cidade` | string | ❌ | máx. 60 |
| `uf` | string | ❌ | máx. 2 |
| `fone` / `fone2` / `cel` | string | ❌ | máx. 20 |
| `obsvenda` | string | ❌ | máx. 255 |
| `idoper` | int (≥1) | ❌ | — |
| `idvende` | int (≥1) | ❌ | — |

**Resposta `201`:** mesmo shape de `GET /b3vendas/clientes/:id`.

---

### `PATCH /b3vendas/clientes/:id`

Atualiza dados do cliente. Todos os campos são opcionais. **O cliente deve estar vinculado ao vendedor autenticado** (`cnt.idvende = vendId`) — caso contrário, `403`.

**Auth:** `JwtGuard + UserInstanceGuard + RolesFrontGuard` (role: `supersaler`).

**Body:** qualquer subconjunto dos campos de `POST /b3vendas/clientes`.

**Resposta `200`:** cliente atualizado.

**Erros:** `403` se o cliente é de outro vendedor; `404` se não existe / inativo.

---

### `DELETE /b3vendas/clientes/:id`

**Hard delete** (linha removida fisicamente).

**Auth:** `JwtGuard + UserInstanceGuard + RolesFrontGuard` (role: `supersaler`).

**Resposta `200`:** `{ "id": 123 }`.

**Erros:** `404` se o cliente não existe.

> Nota: a remoção **não** valida o vínculo com o vendedor (diferente do `PATCH`). Use com cuidado.

---

### `GET /b3vendas/clientes/rede-sp`

Clientes elegíveis para a "rede SP": ativos, com tabela de preços (`idtab IS NOT NULL`) e UF = `SP` ou nula.

**Auth:** `JwtGuard + UserInstanceGuard + RolesFrontGuard` (roles: `supersaler` ou `saler`).

**Resposta `200`:**

```jsonc
[
  {
    "id": 123,
    "nome": "Empresa ABC",              // COALESCE(fantasia, razao)
    "docfed": "12.345.678/0001-90",     // formatado (pode ser null)
    "email": "contato@abc.com",         // pode ser null
    "fone": "(11) 3333-3333",           // pode ser null
    "cel": "(11) 99999-9999",           // pode ser null
    "cidade": "São Paulo"               // pode ser null
  }
]
```

---

### `GET /b3vendas/clientes/tabela`

Catálogo do cliente: produtos da **tabela de preços do cliente** com IPI e ICMS-ST pré-calculados em SQL para a operação informada.

> Implementação faz `INNER JOIN prdtabvalor` — se o cliente não tem `idtab`, ou se um produto não está na tabela do cliente, ele não aparece.

**Auth:** `JwtGuard + UserInstanceGuard + RolesFrontGuard` (roles: `supersaler` ou `saler`).

**Query params:**

| Param | Tipo | Obrigatório |
|---|---|---|
| `idOper` | int | ✅ |
| `idCli` | int | ✅ |

**Filtros aplicados:** `prd.ativo`, `prd.podevender`, `NOT prd.servico`, `prdtabvalor.valor > 0`. `operacoes.finalidade IN ('C','R','I')`. Quando `operacoes.finalidade = 'C'` (consumo), `ivast` e `vicmsst` são forçados a `0`.

**Resposta `200`:**

```jsonc
[
  {
    "operacao": "Venda de Mercadoria",  // ou "NÃO CONFIGURADO" se a operação não estiver vinculada ao prdimposto
    "nometab": "Tabela SP",             // nome da tabela de preços do cliente
    "ufbase": "SP",                     // sempre "SP" (constante)
    "id": 456,
    "codigo": "SKU-001",                // pode ser null
    "ref": "REF-XYZ",                   // pode ser null
    "barras": "7891234567890",          // pode ser null
    "nome": "Produto XYZ",
    "unidade": "UN",                    // pode ser null
    "venda": 89.90,                     // COALESCE(prdtabvalor.valor, prd.venda)
    "ivast": 12.00,                     // alíquota efetiva de ICMS-ST (%)
    "vicmsst": 5.42,                    // valor de ICMS-ST por unidade
    "ipisaliq": 5.00,                   // alíquota de IPI (%)
    "vipi": 4.50                        // valor de IPI por unidade
  }
]
```

> Todos os campos numéricos são retornados como `number`. `vicmsst` é calculado considerando `icmsiva`, `icmsaliq` e `icmsredu` da tabela `impostos`.

---

## Equipe de Vendas

Base: `/b3vendas/equipe` — gerencia `cntequipe` (`idcntlider, idcntliderado` ambos referenciando `cnt.id`).

---

### `GET /b3vendas/equipe`

Lista a equipe visível ao vendedor autenticado.

**Auth:** `JwtGuard + UserInstanceGuard + RolesFrontGuard` (roles: `supersaler` ou `saler`).

Comportamento por papel (`.includes()` no array `roleFront`):

- **`supersaler`** — retorna o próprio vendedor (`liderado=0`) seguido dos subordinados (`liderado=1`). Ordenação: `liderado ASC, razao ASC`. SUPERSALER vence SALER se ambos estiverem presentes.
- **`saler`** — retorna apenas a si mesmo (uma única linha com `liderado=0`).
- Outros — `403`.

**Resposta `200`:**

```jsonc
[
  {
    "id": 10,
    "razao": "Carlos Silva",
    "cel": "(11) 99999-9999",   // pode ser null
    "fax": "(11) 98888-8888",   // WhatsApp (campo legado reaproveitado; pode ser null)
    "liderado": 0
  },
  {
    "id": 15,
    "razao": "Ana Lima",
    "cel": null,
    "fax": null,
    "liderado": 1
  }
]
```

---

### `GET /b3vendas/equipe/sem-equipe`

Lista todos os vendedores (`cntclass.comissionado`) que **não pertencem a nenhuma equipe** — não aparecem como `idcntliderado` em `cntequipe` — e excluindo o próprio supervisor. Usado para popular a UI de "adicionar à equipe".

**Auth:** `JwtGuard + UserInstanceGuard + RolesFrontGuard` (role: `supersaler`).

**Resposta `200`:** array com o mesmo shape de `GET /b3vendas/equipe`. `liderado` sempre vale `0`. Ordenado por `razao ASC`.

---

### `POST /b3vendas/equipe`

Adiciona um vendedor como subordinado do supervisor autenticado. Cria linha em `cntequipe` com `idcntlider = vendId-do-supervisor` e `idcntliderado = body.idcntliderado`.

**Auth:** `JwtGuard + UserInstanceGuard + RolesFrontGuard` (role: `supersaler`).

**Body:**

| Campo | Tipo | Obrigatório |
|---|---|---|
| `idcntliderado` | int (positivo) | ✅ |

**Respostas:**

| Status | Quando |
|---|---|
| `201` | Vínculo criado (sem corpo) |
| `400` | `idcntliderado` igual ao próprio supervisor |
| `409` | Vínculo já existe |

---

### `DELETE /b3vendas/equipe/:id`

Remove o vínculo `(supervisor, idcntliderado=:id)` em `cntequipe`.

**Auth:** `JwtGuard + UserInstanceGuard + RolesFrontGuard` (role: `supersaler`).

**Respostas:**

| Status | Quando |
|---|---|
| `204` | Vínculo removido (sem corpo) |
| `404` | Vínculo não existe nesta equipe |

---

## Operações Fiscais

### `GET /b3vendas/operacoes`

Lista as operações fiscais de **saída** disponíveis para a empresa informada. Aplica também um filtro adicional configurável por tenant via `cfg.VWEBOPERCOND` (cláusula SQL).

**Auth:** `JwtGuard + UserInstanceGuard`.

**Query params:**

| Param | Tipo | Obrigatório |
|---|---|---|
| `idemp` | int (≥1) | ✅ |

**Filtros internos:**

```
saidaentrada = '1'         -- apenas saída
<filtro de cfg.VWEBOPERCOND> -- cláusula SQL adicional do tenant
(idemp IS NULL OR idemp = 0 OR idemp = :idemp)
```

Ordenação por `operacao ASC`.

**Resposta `200`:**

```jsonc
[
  {
    "id": 5,
    "operacao": "Venda de Mercadoria",
    "subtipo": "N",       // N=Normal, T=Transferência, B=Bonificação, G=Garantia
    "cfopnormal": "5102",
    "cfopst": "5403"
  }
]
```

---

## Produtos

Base: `/b3vendas/produtos`.

---

### `GET /b3vendas/produtos/buscar`

Autocomplete de produto. Mínimo de **2 caracteres**. Se `q` for inteiramente numérico, busca por `id` exato; caso contrário, faz `UPPER(nome) LIKE '%<q>%'`. Limite 50 resultados.

**Auth:** `JwtGuard + UserInstanceGuard`.

**Filtros fixos:** `NOT prd.consumo`, `prd.ativo`, `prd.podevender`, `(prd.acabado OR prd.revenda)`.

**Query params:**

| Param | Tipo | Obrigatório |
|---|---|---|
| `q` | string | ✅ (mín. 2) |

**Resposta `200`:**

```jsonc
[
  {
    "id": 456,
    "nome": "Produto XYZ",
    "display": "[00456] Produto XYZ"   // [id-com-5-dígitos] nome
  }
]
```

**Erros:** `400` se `q` tem menos de 2 caracteres.

---

### `GET /b3vendas/produtos/:id/preco`

Retorna preço unitário, custo e CFOP do produto para o cliente e operação informados.

**Auth:** `JwtGuard + UserInstanceGuard`.

**Lógica:**

- **CFOP**: se `prdimposto` × `impostos.icmsiva > 0` → `operacoes.cfopst`. Senão → `operacoes.cfopnormal`. Se não há `prdimposto`, fallback para `operacoes.cfopnormal` direto.
- **Preço (`vunit`)**: se cliente tem tabela (`cnt.idtab`) e existe `prdtabvalor.valor > 0` → valor da tabela. Senão → `prd.venda`.
- **`custo`**: vem direto de `prd.custo`.

**Path params:** `id` (int) — ID do produto.

**Query params:**

| Param | Tipo | Obrigatório |
|---|---|---|
| `idCli` | int | ✅ |
| `idOper` | int | ✅ |

**Resposta `200`:**

```jsonc
{
  "cfop": "5102",
  "custo": 45.80,
  "vunit": 89.90
}
```

**Erros:** `404` se o produto não existir.

---

### `POST /b3vendas/produtos/:id/calc-imposto`

Calcula IPI e ICMS-ST sobre um subtotal. Use **antes** de `POST /pedidos/:id/itens` para informar `vST` e `vIPI`.

**Auth:** `JwtGuard + UserInstanceGuard`.

**Body:**

| Campo | Tipo | Obrigatório |
|---|---|---|
| `subtotal` | number (positivo) | ✅ |
| `idOper` | int (≥1) | ✅ |

**Comportamento:**

- Se não houver regra `prdimposto` para o par (produto, operação): retorna `{ ipi: 0, st: 0, total: round(subtotal) }`.
- Se houver: calcula via `TaxCalculatorService` com base em `impostos.{icmsaliq, icmsredu, icmsiva, ipialiq}`.

**Resposta `200`:**

```jsonc
{
  "ipi": 4.50,
  "st": 12.30,
  "total": 16.80
}
```

> ⚠️ **Diferença entre fontes de cálculo**: O cálculo de IPI realizado pelo `TaxCalculatorService` aplica a alíquota com uma multiplicação adicional, enquanto o SQL de `GET /clientes/tabela` usa a fórmula tradicional `subtotal × ipialiq / 100`. As duas fontes podem retornar valores divergentes para o mesmo produto. Use o valor de `POST /produtos/:id/calc-imposto` como referência para gravar o item, já que é a fonte usada pela API ao processar o pedido.

---

## Pedidos

Base: `/b3vendas/pedidos` — gerencia a tabela `venda` e seu pagamento (`vendacaixa`).

### Estados (`venda.tipo`)

| Valor | Significado | Itens editáveis? |
|---|---|---|
| `O` | Aberto / rascunho | ✅ Sim |
| `P` | Pendente | ❌ Não |
| `V` | Validado | ❌ Não |

> ⚠️ **`POST /pedidos/:id/fechar` não altera `tipo`.** O fechamento apenas registra o pagamento (`vendacaixa`) e a venda permanece em `'O'`. A transição de estado para `'P'`/`'V'` ocorre fora desta API (via cliente legado / processos internos).

### Subtipos (`venda.subtipo`)

`N` (Normal), `T` (Transferência), `B` (Bonificação), `G` (Garantia). Definido automaticamente a partir de `operacoes.subtipo` no momento da criação.

### Regime fiscal (`venda.fiscal`, mapeado de `rcfat`)

`F` = Fiscal (movimenta tributação) | `E` = Estimativa (sem efeito fiscal).

---

### `POST /b3vendas/pedidos`

Cria um pedido novo. O backend preenche automaticamente:

- `idvend = vendId-do-vendedor-logado`
- `ultimousu = usuId`
- `idcomi = cnt[id=vendId].idcomi` (vendedor → comissionado)
- `subtipo = operacoes[idOper].subtipo` (default `'N'`)
- `plataforma = 'SALESFORCE'`, `processo = 'B3PED.exe'`
- `dthremissao` via `@CreateDateColumn` (timestamp atual)

> ⚠️ **`tipo` recebe diretamente o `rctipo` do body** — não há transformação para `'O'`. Em fluxo normal, envie `rctipo: "O"` para criar como rascunho editável.

**Auth:** `JwtGuard + UserInstanceGuard`.

**Body:**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `rctipo` | enum | ✅ | `O` (orçamento) / `P` (pedido) / `V` (venda). Grava em `venda.tipo`. |
| `rcfat` | enum | ✅ | `F` (Fiscal) / `E` (Estimativa). Grava em `venda.fiscal`. |
| `idCli` | int (≥1) | ✅ | ID do cliente |
| `idOper` | int (≥1) | ✅ | ID da operação fiscal |
| `idemp` | int (≥1) | ✅ | ID da empresa emitente |

**Resposta `201`:**

```jsonc
{ "id": 1001 }
```

> Para visualizar o estado completo após criar, chame `GET /b3vendas/pedidos/:id`.

---

### `GET /b3vendas/pedidos/editaveis`

Pedidos abertos (`tipo='O'`) do vendedor para a empresa, dos **últimos 5 dias**.

**Auth:** `JwtGuard + UserInstanceGuard`.

**Query params:** `idemp` (int ≥1, obrigatório).

**Resposta `200`:**

```jsonc
[
  {
    "id": 1001,
    "idcli": 123,
    "razaoCliente": "Empresa ABC Ltda",
    "dthremissao": "2026-04-23T14:30:00.000Z",
    "tipo": "O",
    "vlrtotal": 550.00
  }
]
```

Ordenado por `id DESC`.

---

### `GET /b3vendas/pedidos/fechados`

Pedidos com `tipo IN ('P','V')` do vendedor para a empresa, dos **últimos 30 dias**.

**Auth:** `JwtGuard + UserInstanceGuard`.

**Query params:** `idemp` (int ≥1, obrigatório).

**Resposta `200`:** array com o mesmo shape de `GET /b3vendas/pedidos/editaveis`.

---

### `GET /b3vendas/pedidos/:id`

Detalhe completo do pedido — venda, itens, cliente e pagamento.

**Auth:** `JwtGuard + UserInstanceGuard`.

**Acesso:** o pedido **deve estar vinculado ao vendedor autenticado** (`venda.idvend = vendId`); caso contrário `403`.

**Resposta `200`:**

```jsonc
{
  "id": 1001,
  "idcli": 123,
  "razaoCliente": "Empresa ABC Ltda",
  "idoper": 5,
  "fiscal": "F",
  "tipo": "O",
  "vlrbruto": 500.00,
  "desconto": 0,
  "acrescimo": 0,
  "st": 12.30,
  "ipi": 4.50,
  "vlrtotal": 516.80,
  "obsinter": null,
  "idForma": null,        // do vendacaixa (se já fechado)
  "idCond": null,
  "itens": [
    {
      "seq": 1,
      "idprod": 456,
      "nomeProduto": "Produto XYZ",
      "qtde": 2.000,
      "unitario": 89.90,
      "total": 179.80
    }
  ],
  "cliente": {            // null se idcli for null
    "id": 123,
    "tipopessoa": "J",
    "razao": "Empresa ABC Ltda",
    "fantasia": null,
    "docfed": "12345678000190",
    "docformatado": "12.345.678/0001-90",
    // ... demais campos do ResponseClienteInfoDto
    "idoper": 5,
    "idvende": 102
  }
}
```

**Erros:** `404` se o pedido não existir; `403` se for de outro vendedor.

---

### `POST /b3vendas/pedidos/:id/fechar`

Registra o pagamento do pedido em `vendacaixa`. Em uma transação:

1. `DELETE FROM vendacaixa WHERE idvenda = :id` (apaga registros prévios).
2. `INSERT vendacaixa (idvenda=:id, idforma=:idForma, seq=1, valor=venda.vlrtotal, idcond=:idCond, operacao=formapg.operacao, baixado=1)`.
3. Se `obsInter` foi enviado, `UPDATE venda SET obsinter = :obsInter WHERE id = :id`.

**Não altera `venda.tipo`.**

**Auth:** `JwtGuard + UserInstanceGuard`. Pedido deve estar vinculado ao vendedor (`403` caso contrário) e em `tipo='O'` (`400` caso contrário).

**Body:**

| Campo | Tipo | Obrigatório |
|---|---|---|
| `idForma` | int (≥1) | ✅ — obter de `GET /pedidos/:id/formas-disponiveis` |
| `idCond` | int (≥1) | ✅ — obter de `GET /pedidos/:id/condicoes-disponiveis` |
| `obsInter` | string | ❌ (máx. 255) |

**Resposta `200`:**

```jsonc
{ "id": 1001, "vlrtotal": 516.80 }
```

**Erros:** `400` se a venda não está em `'O'`; `403` se for de outro vendedor; `404` se não existe; `404` se `idForma` não existe na tabela `formapg`.

---

## Itens do Pedido

Base: `/b3vendas/pedidos/:id/itens`.

Após cada operação, o backend recalcula automaticamente os totais da venda mestre (vlrbruto, desconto, acrescimo, st, ipi, vlrtotal) a partir dos itens. **Apenas pedidos em `tipo='O'`** aceitam mudanças nos itens (`400` caso contrário).

---

### `POST /b3vendas/pedidos/:id/itens`

Adiciona um item ao pedido. O backend calcula `seq = MAX(seq) + 1` automaticamente. `bruto` e `total` ficam iguais a `qtde × vunit`. `desconto` e `acrescimo` do item ficam zerados.

**Auth:** `JwtGuard + UserInstanceGuard`. Vinculado ao vendedor + tipo `'O'`.

**Body:**

| Campo | Tipo | Obrigatório | Origem recomendada |
|---|---|---|---|
| `idProd` | int (≥1) | ✅ | — |
| `qtde` | number (≥0.001) | ✅ | — |
| `vunit` | number (≥0) | ✅ | `GET /produtos/:id/preco` |
| `custo` | number (≥0) | ✅ | `GET /produtos/:id/preco` |
| `cfop` | string (máx. 5) | ✅ | `GET /produtos/:id/preco` |
| `vST` | number (≥0) | ✅ | `POST /produtos/:id/calc-imposto` |
| `vIPI` | number (≥0) | ✅ | `POST /produtos/:id/calc-imposto` |
| `tabela` | number (≥0) | ✅ | `idtab` da tabela aplicada |
| `obsprod` | string | ❌ (máx. 60) | — |

**Resposta `201`:**

```jsonc
{ "seq": 1 }
```

---

### `DELETE /b3vendas/pedidos/:id/itens/:seq`

Remove o item de sequência `seq`. Recalcula totais.

**Auth:** `JwtGuard + UserInstanceGuard`. Vinculado ao vendedor + tipo `'O'`.

**Resposta `204`:** sem corpo.

**Erros:** `404` se o item não existe; `400` se o pedido não está em `'O'`; `403` se for de outro vendedor.

---

## Formas e Condições de Pagamento

As listas retornadas combinam:

1. A forma/condição **padrão** do cliente (`cnt.idforma`, `cnt.idcond`).
2. O **histórico** — formas/condições já usadas em pedidos anteriores do mesmo cliente (via `vendacaixa`).

A união é deduplicada e ordenada por id ASC. Se o pedido não tem cliente (`idcli IS NULL`), o array volta vazio.

---

### `GET /b3vendas/pedidos/:id/formas-disponiveis`

**Auth:** `JwtGuard + UserInstanceGuard`. Pedido deve ser do vendedor autenticado.

**Resposta `200`:**

```jsonc
[
  { "id": 1, "nome": "Dinheiro" },
  { "id": 2, "nome": "Cartão de Crédito" }
]
```

---

### `GET /b3vendas/pedidos/:id/condicoes-disponiveis`

**Auth:** `JwtGuard + UserInstanceGuard`. Pedido deve ser do vendedor autenticado.

**Resposta `200`:**

```jsonc
[
  { "id": 1, "nome": "À vista" },
  { "id": 4, "nome": "30/60/90 dias" }
]
```

---

## Métricas de Desempenho

Base: `/b3vendas/metricas` — quatro endpoints `GET` de leitura agregada sobre `venda` e `cnt`.

**Auth (todos):** `JwtGuard + UserInstanceGuard + RolesFrontGuard` (roles: `supersaler` ou `saler`, decorator no controller).

### Query params obrigatórios (todos os endpoints)

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `idemp` | int (≥1) | ✅ | ID da empresa emitente. Deve estar vinculada ao usuário autenticado via `usuemp`; caso contrário `403`. |
| `idvende` | int (≥1) | ✅ | ID do vendedor cujos dados serão exibidos. Se diferente do vendedor logado, exige perfil `supersaler` e o vendedor solicitado deve pertencer à equipe; caso contrário `403`. |
| `join` | boolean | ❌ | Exclusivo de `supersaler`. Quando `true`, expande o escopo para **toda a equipe** do supervisor logado (vendedor próprio + subordinados), ignorando `idvende` como filtro de escopo. Um `saler` que envie `join=true` recebe `403`. |

### Escopo (resolução de `vendIds`)

| Situação | `vendIds` resultante |
|---|---|
| `join=true` (supersaler) | `[vendId_logado, ...subordinados]` — equipe completa |
| `join` ausente / `false` | `[idvende]` — somente o vendedor solicitado |

A lista é deduplicada via `Set` e injetada nas queries via placeholders dinâmicos `IN (?, ?, ...)`. O filtro `v.idemp = idemp` é aplicado em todas as queries.

### Checagens de autorização

1. **Acesso à empresa:** `idemp` deve estar em `usuemp` do usuário conectado (`userId → usu → usuemp`).
2. **Acesso ao vendedor:** se `idvende ≠ vendId_logado` → deve ser `supersaler` **e** `idvende` deve estar em `cntequipe` como subordinado.
3. **Uso de `join`:** somente `supersaler` pode enviar `join=true`.

### Critério de "venda considerada"

Para os endpoints de gráfico (`vendas-semanais`, `vendas-mensais`, `top-clientes-ativos`), apenas vendas que satisfaçam **todas** as condições abaixo entram na agregação:

```
venda.tipo    = 'V'   (validada)
venda.subtipo = 'N'   (normal — exclui transferência/bonificação/garantia)
venda.baixado = 1     (efetivamente concluída)
```

> O endpoint `clientes-inativos` **ignora** esse filtro: usa **qualquer** linha em `venda` (independentemente de `tipo`/`subtipo`/`baixado`) ao avaliar atividade.

---

### `GET /b3vendas/metricas/vendas-semanais`

Total vendido (R$) por **semana ISO**, cobrindo as últimas **12 semanas**. Buckets sem vendas vêm com valor `0` (eixo X completo). Filtrado por `idemp` e escopo de `vendIds`.

```jsonc
{
  "chartType": "line",
  "labels": [
    "2026-W07", "2026-W08", "2026-W09", "2026-W10",
    "2026-W11", "2026-W12", "2026-W13", "2026-W14",
    "2026-W15", "2026-W16", "2026-W17", "2026-W18"
  ],
  "series": [
    { "name": "Vendas (R$)", "data": [0, 2626.48, 0, 0, 0, 0, 10.00, 61.50, 0, 0, 0, 0] }
  ]
}
```

> Backend: `GROUP BY YEARWEEK(dthremissao, 1)`. Labels (`YYYY-Www`) geradas em TypeScript.

---

### `GET /b3vendas/metricas/vendas-mensais`

Total vendido (R$) por mês (`YYYY-MM`), cobrindo os últimos **12 meses**. Buckets sem vendas vêm com `0`.

```jsonc
{
  "chartType": "line",
  "labels": [
    "2025-05", "2025-06", "2025-07", "2025-08", "2025-09", "2025-10",
    "2025-11", "2025-12", "2026-01", "2026-02", "2026-03", "2026-04"
  ],
  "series": [
    { "name": "Vendas (R$)", "data": [205.15, 0, 2445.63, 245.06, 0, 6334.50, 6608.29, 1810.77, 3815.65, 11546.70, 10.00, 61.50] }
  ]
}
```

---

### `GET /b3vendas/metricas/top-clientes-ativos`

Top **15 clientes** por valor total comprado nos últimos **90 dias**, em ordem decrescente. Apresenta duas séries alinhadas: valor monetário e número de pedidos.

```jsonc
{
  "chartType": "bar_h",
  "labels": ["H B FULLER BRASIL LTDA", "CONSUMIDOR FINAL", "CRISLOG"],
  "series": [
    { "name": "Valor (R$)", "data": [4549.00, 2064.32, 1380.00] },
    { "name": "Pedidos",    "data": [1, 1, 1] }
  ]
}
```

> Label = `COALESCE(cnt.fantasia, cnt.razao)`. `Pedidos` = `COUNT(*)` de vendas no período sob o critério "venda considerada".

---

### `GET /b3vendas/metricas/clientes-inativos`

Lista de clientes vinculados ao vendedor (`cnt.idvende IN (vendIds)`) que **não tiveram nenhuma venda** (qualquer `tipo`/`subtipo`/`baixado`) nos **últimos 60 dias**. Apenas `cnt.ativo = 1`. Inclui clientes que nunca venderam.

```jsonc
[
  {
    "id": 115,
    "nome": "AMANDA BIANCHINI BERTOLETTI",     // COALESCE(fantasia, razao)
    "docfed": "222.222.222-22",                 // CPF/CNPJ formatado (pode ser null)
    "email": "cliente@exemplo.com",             // pode ser null
    "fone": "(11) 3333-3333",                   // pode ser null
    "cel": "(11) 99999-9999",                   // pode ser null
    "cidade": "Rio Claro",                      // pode ser null
    "uf": "SP",                                 // pode ser null
    "ultimaVenda": "2025-11-24T17:15:20.000Z",  // ISO 8601 ou null
    "idvende": 233                              // vendedor responsável pelo cliente
  }
]
```

Ordenado por `nome ASC`. `ultimaVenda` é `MAX(venda.dthremissao)` global do cliente (qualquer status) — útil para distinguir "nunca comprou" (`null`) de "comprou há muito tempo".

---

## Fluxo Completo de Criação de Pedido

```
1. GET  /tenant/emitentes
        → escolher idemp da empresa

2. GET  /b3vendas/operacoes?idemp=<N>
        → escolher operação (idOper, subtipo, cfop)

3. GET  /b3vendas/clientes/buscar?q=<texto>      (autocomplete)
   GET  /b3vendas/clientes/:id                   (detalhes)
        → idCli + endereço + obsvenda

4. POST /b3vendas/pedidos
        body: { rctipo: 'O', rcfat: 'F'|'E', idCli, idOper, idemp }
        → { id }

5. Para cada item:
   a. GET  /b3vendas/produtos/buscar?q=<texto>
   b. GET  /b3vendas/produtos/:id/preco?idCli=<N>&idOper=<N>
           → { cfop, custo, vunit }
   c. POST /b3vendas/produtos/:id/calc-imposto
           body: { subtotal: qtde*vunit, idOper }
           → { ipi, st, total }
   d. POST /b3vendas/pedidos/:id/itens
           body: { idProd, qtde, vunit, custo, cfop, vST: st, vIPI: ipi, tabela, obsprod? }
           → { seq }

6. GET  /b3vendas/pedidos/:id/formas-disponiveis
   GET  /b3vendas/pedidos/:id/condicoes-disponiveis

7. POST /b3vendas/pedidos/:id/fechar
        body: { idForma, idCond, obsInter? }
        → { id, vlrtotal }
```

> **Atenção:** após `fechar`, a venda **continua em `tipo='O'`**. A transição para `'P'`/`'V'` ocorre fora desta API.

---

## Estados / Enums de Referência

### `venda.tipo`

| Valor | Significado |
|---|---|
| `O` | Orçamento aberto / rascunho |
| `P` | Pedido pendente |
| `V` | Venda confirmada |

### `venda.subtipo` (também `operacoes.subtipo`)

| Valor | Significado |
|---|---|
| `N` | Normal |
| `T` | Transferência |
| `B` | Bonificação |
| `G` | Garantia |

### `venda.fiscal` (recebido como `rcfat` no POST)

| Valor | Significado |
|---|---|
| `F` | Fiscal |
| `E` | Estimativa |

### `cnt.tipopessoa`

| Valor | Significado |
|---|---|
| `F` | Pessoa Física |
| `J` | Pessoa Jurídica |
| `E` | Estatal |
| `R` | Rural |

### `RoleFrontEnum` — papéis usados pelo módulo

| Valor | Acesso a `b3vendas` |
|---|---|
| `supersaler` | Total — gerencia equipe e CRUD de clientes |
| `saler` | Próprios dados — sem CRUD de clientes |
| outros (`admin`, `inventory`, `buyer`, `notallow`) | Bloqueado |

---

## Tabela Consolidada de Endpoints

| Método | Rota | Roles |
|---|---|---|
| GET | `/b3vendas/clientes/buscar?q=` | qualquer |
| GET | `/b3vendas/clientes/rede-sp` | supersaler/saler |
| GET | `/b3vendas/clientes/tabela?idOper=&idCli=` | supersaler/saler |
| GET | `/b3vendas/clientes/:id` | qualquer |
| POST | `/b3vendas/clientes` | supersaler |
| PATCH | `/b3vendas/clientes/:id` | supersaler |
| DELETE | `/b3vendas/clientes/:id` | supersaler |
| GET | `/b3vendas/equipe` | supersaler/saler |
| GET | `/b3vendas/equipe/sem-equipe` | supersaler |
| POST | `/b3vendas/equipe` | supersaler |
| DELETE | `/b3vendas/equipe/:id` | supersaler |
| GET | `/b3vendas/operacoes?idemp=` | qualquer |
| GET | `/b3vendas/produtos/buscar?q=` | qualquer |
| GET | `/b3vendas/produtos/:id/preco?idCli=&idOper=` | qualquer |
| POST | `/b3vendas/produtos/:id/calc-imposto` | qualquer |
| POST | `/b3vendas/pedidos` | qualquer |
| GET | `/b3vendas/pedidos/editaveis?idemp=` | qualquer |
| GET | `/b3vendas/pedidos/fechados?idemp=` | qualquer |
| GET | `/b3vendas/pedidos/:id` | qualquer |
| GET | `/b3vendas/pedidos/:id/formas-disponiveis` | qualquer |
| GET | `/b3vendas/pedidos/:id/condicoes-disponiveis` | qualquer |
| POST | `/b3vendas/pedidos/:id/fechar` | qualquer |
| POST | `/b3vendas/pedidos/:id/itens` | qualquer |
| DELETE | `/b3vendas/pedidos/:id/itens/:seq` | qualquer |
| GET | `/b3vendas/metricas/vendas-semanais?idemp=&idvende=[&join=]` | supersaler/saler |
| GET | `/b3vendas/metricas/vendas-mensais?idemp=&idvende=[&join=]` | supersaler/saler |
| GET | `/b3vendas/metricas/top-clientes-ativos?idemp=&idvende=[&join=]` | supersaler/saler |
| GET | `/b3vendas/metricas/clientes-inativos?idemp=&idvende=[&join=]` | supersaler/saler |

> "qualquer" = autenticado com token de etapa 2 e vínculo ativo a um vendedor no tenant.
