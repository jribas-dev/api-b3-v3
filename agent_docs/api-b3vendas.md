# API Contracts — Módulo b3vendas

> Módulo de domínio de **vendas** (banco do tenant).
>
> Base URL: `https://<host>/b3vendas`
>
> **Todos os endpoints exigem token de etapa 2** (com `dbId` no payload):
> ```
> Authorization: Bearer <accessToken-etapa2>
> ```
>
> Guards aplicados a toda a base:
> - `JwtGuard` — token JWT válido
> - `UserInstanceGuard` — token deve conter `dbId` (tenant selecionado)
> - `RolesFrontGuard` — a maioria das rotas permite `supervisor` e `saler`

---

## Índice

- [Contexto do Vendedor](#contexto-do-vendedor)
- [Clientes](#clientes)
- [Equipe de Vendas](#equipe-de-vendas)
- [Operações Fiscais](#operações-fiscais)
- [Produtos](#produtos)
- [Pedidos (Vendas)](#pedidos-vendas)
- [Itens do Pedido](#itens-do-pedido)
- [Formas e Condições de Pagamento](#formas-e-condições-de-pagamento)
- [Métricas de Desempenho](#métricas-de-desempenho)

---

## Contexto do Vendedor

Internamente, todos os endpoints resolvem o usuário autenticado para um **vendedor** cadastrado no banco do tenant. Se o usuário não estiver vinculado a nenhum vendedor, todos os endpoints retornam `403 Forbidden`.

O campo `idemp` (ID da empresa/emitente) **não está no token** — deve ser enviado em cada requisição pelo frontend. Isso permite operar em diferentes empresas sem trocar o token.

Para obter a lista de empresas disponíveis, chame `GET /tenant/emitentes` (documentado em `api-core.md`).

---

## Clientes

Base: `/b3vendas/clientes`

Gerencia clientes (tabela `cnt` no banco do tenant).

---

### `GET /b3vendas/clientes/buscar`

Busca clientes por texto (mínimo 2 caracteres, máximo 50). Retorna uma lista simplificada para autocomplete.

**Auth:** `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard`

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `q` | string | ❌ | Texto de busca (nome, razão social ou CNPJ/CPF). Mínimo 2 caracteres para acionar a busca |

**Resposta `200`:**

```jsonc
[
  {
    "id": 123,               // ID numérico do cliente no banco do tenant
    "razao": "Empresa ABC",  // Razão social
    "display": "Empresa ABC (12.345.678/0001-90)"  // String formatada para exibição em autocomplete
  }
]
```

---

### `GET /b3vendas/clientes/:id`

Retorna os dados completos de um cliente para uso no formulário de pedido.

**Auth:** `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard`

**Path params:**

| Param | Tipo | Descrição |
|---|---|---|
| `id` | integer | ID do cliente |

**Resposta `200`:**

```jsonc
{
  "id": 123,
  "tipopessoa": "J",                    // Tipo de pessoa: "F"=Física, "J"=Jurídica, "E"=Estatal, "R"=Rural
  "razao": "Empresa ABC Ltda",
  "docfed": "12345678000190",            // CNPJ ou CPF (só numeros) - pode ser null
  "docformatado": "12.345.678/0001-90",  // CNPJ ou CPF (formatado)
  "docest": "103.104.105.106",          // Inscrição Estadual ou RG (pode ser null)
  "email": "mail@test.com",            // Email Principal (pode ser null)
  "emailnfe": "nfe@test.com",         // Email Nota Fiscal (pode ser null)
  "emailcob": "cob@test.com",        // Email Cobrança (pode ser null)
  "site": "teste.com",               // Site do Cliente (pode ser null)
  "cep": "14035090",                 // CEP (pode ser null)
  "endereco": "Rua das Flores",      // Logradouro (pode ser null)
  "nroend": "100",                   // Número do endereço (pode ser null)
  "bairro": "Centro",                // Bairro (pode ser null)
  "cidade": "São Paulo",             // Cidade (pode ser null)
  "uf": "SP",                        // UF (pode ser null)
  "fone": "(11) 3333-3333",          // Telefone principal (pode ser null)
  "fone2": "(11) 93333-3333",        // Telefone secundário (pode ser null)
  "cel": "(11) 92222-3333",          // Telefone celular (pode ser null)
  "obsvenda": "Entregar no período da tarde",  // Observação exibida ao criar pedido (pode ser null)
  "idoper": 5,                       // Operação fiscal padrão do cliente (pode ser null)
  "idvende": 102                     // Vendedor do cliente (pode ser null)
}
```

---

### `POST /b3vendas/clientes`

Cria um novo cliente.

**Auth:** `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard`

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `tipopessoa` | string | ❌ | Tipo de pessoa: `F`=Física (padrão), `J`=Jurídica, `E`=Estatal, `R`=Rural |
| `razao` | string | ✅ | Razão social ou nome (2–100 caracteres) |
| `fantasia` | string | ❌ | Nome fantasia (máx. 60 caracteres) |
| `docfed` | string | ❌ | CNPJ ou CPF (máx. 20 caracteres) |
| `docest` | string | ❌ | Inscrição estadual (máx. 20 caracteres) |
| `email` | string | ❌ | E-mail do cliente |
| `emailnfe` | string | ❌ | E-mail do cliente para NFe|
| `emailcob` | string | ❌ | E-mail do cliente para Cobrança|
| `site` | string | ❌ | Site (máx. 120 caracteres) |
| `cep` | string | ❌ | CEP (máx. 10 caracteres) |
| `endereco` | string | ❌ | Logradouro (máx. 120 caracteres) |
| `nroend` | string | ❌ | Número (máx. 10 caracteres) |
| `bairro` | string | ❌ | Bairro (máx. 60 caracteres) |
| `cidade` | string | ❌ | Cidade (máx. 60 caracteres) |
| `uf` | string | ❌ | UF (máx. 2 caracteres, ex: `SP`) |
| `fone` | string | ❌ | Telefone principal (máx. 20 caracteres) |
| `fone2` | string | ❌ | Telefone secundário (máx. 20 caracteres) |
| `cel` | string | ❌ | Celular (máx. 20 caracteres) |
| `obsvenda` | string | ❌ | Observação exibida na tela de venda (máx. 255 caracteres) |
| `idoper` | integer | ❌ | ID da operação fiscal padrão do cliente (mínimo: 1) |
| `idvende` | integer | ❌ | ID do vendedor do cliente (mínimo: 1) |

**Resposta `201`:** objeto do cliente criado.

---

### `PATCH /b3vendas/clientes/:id`

Atualiza dados de um cliente. Todos os campos são opcionais.

**Auth:** `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard`

**Path params:** `id` (integer)

**Body:** qualquer subconjunto dos campos de `POST /b3vendas/clientes`.

**Resposta `200`:** cliente atualizado.

---

### `DELETE /b3vendas/clientes/:id`

Remove um cliente.

**Auth:** `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard` com role `supervisor`

**Path params:** `id` (integer)

**Resposta `200`:** resultado da remoção.

---

### `GET /b3vendas/clientes/rede-sp`

Lista os clientes do vendedor autenticado que são elegíveis para a rede SP: ativos, com UF = `SP` ou UF nula, e com tabela de preços configurada (`idtab IS NOT NULL`).

**Auth:** `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard` (roles: `supervisor` ou `saler`)

**Resposta `200`:**

```jsonc
[
  {
    "id": 123,
    "nome": "Empresa ABC",              // COALESCE(fantasia, razao)
    "docfed": "12.345.678/0001-90",     // CNPJ/CPF formatado (pode ser null)
    "email": "contato@abc.com",         // pode ser null
    "fone": "(11) 3333-3333",           // pode ser null
    "cel": "(11) 99999-9999",           // pode ser null
    "cidade": "São Paulo"               // pode ser null
  }
]
```

---

### `GET /b3vendas/clientes/tabela`

Retorna o catálogo de produtos com preços e impostos pré-calculados (IPI e ICMS-ST) para um cliente e operação fiscal específicos. Usa a tabela de preços vinculada ao cliente (`cnt.idtab → prdtabvalor`). Retorna apenas produtos ativos, vendáveis e não-serviço.

**Auth:** `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard` (roles: `supervisor` ou `saler`)

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `idOper` | integer | ✅ | ID da operação fiscal |
| `idCli` | integer | ✅ | ID do cliente |

**Resposta `200`:**

```jsonc
[
  {
    "operacao": "Venda de Mercadoria",  // Nome da operação; "NÃO CONFIGURADO" se não vinculada
    "nometab": "Tabela SP",             // Nome da tabela de preços do cliente
    "ufbase": "SP",                     // UF de referência (fixo)
    "id": 456,                          // ID do produto
    "codigo": "SKU-001",               // Código do produto (pode ser null)
    "ref": "REF-XYZ",                  // Referência (pode ser null)
    "barras": "7891234567890",         // Código de barras (pode ser null)
    "nome": "Produto XYZ",
    "unidade": "UN",                   // Unidade de medida (pode ser null)
    "venda": 89.90,                    // Preço de venda (tabela do cliente ou padrão do produto)
    "ivast": 12.00,                    // Alíquota de ICMS-ST aplicável (%)
    "vicmsst": 5.42,                   // Valor de ICMS-ST por unidade
    "ipisaliq": 5.00,                  // Alíquota de IPI (%)
    "vipi": 4.50                       // Valor de IPI por unidade
  }
]
```

> Todos os campos de valor (`venda`, `ivast`, `vicmsst`, `ipisaliq`, `vipi`) são retornados como `number`. O cálculo de ST considera `icmsiva`, `icmsaliq` e `icmsredu` da tabela `impostos`; operações com `finalidade = 'C'` zeram ST e `ivast`.

---

## Equipe de Vendas

### `GET /b3vendas/equipe`

Lista a equipe de vendas visível para o usuário autenticado. O comportamento varia conforme a role:

- **`supervisor`**: retorna o próprio supervisor + todos os vendedores subordinados (via tabela `cntequipe`).
- **`saler`**: retorna apenas o próprio vendedor.

**Auth:** `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard` (roles: `supervisor` ou `saler`)

**Resposta `200`:**

```jsonc
[
  {
    "id": 10,               // ID do vendedor no banco do tenant (cnt.id)
    "razao": "Carlos Silva", // Nome do vendedor
    "cel": "(11) 99999-9999", // Celular (pode ser null)
    "fax": "(11) 98888-8888", // WhatsApp (campo legado reaproveitado; pode ser null)
    "liderado": 0           // 0 = é o próprio usuário autenticado; 1 = é um subordinado
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

> O array vem ordenado: o próprio usuário aparece primeiro (`liderado = 0`), depois os subordinados em ordem alfabética.

---

### `GET /b3vendas/equipe/sem-equipe`

Lista todos os vendedores (`cntclass.comissionado`) que **não pertencem a nenhuma equipe** (não aparecem como `idcntliderado` em `cntequipe`), excluindo o próprio usuário autenticado. Usado para selecionar quem adicionar à equipe.

**Auth:** `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard` (role: `supervisor`)

**Resposta `200`:**

```jsonc
[
  {
    "id": 22,
    "razao": "Marcos Ferreira",
    "cel": "(11) 97777-7777",
    "fax": null,
    "liderado": 0
  }
]
```

> Ordenado por `razao ASC`. O campo `liderado` sempre vale `0` (ainda não é subordinado de ninguém).

---

### `POST /b3vendas/equipe`

Adiciona um vendedor como subordinado do supervisor autenticado na tabela `cntequipe`. O supervisor autenticado torna-se `idcntlider`; o vendedor informado torna-se `idcntliderado`.

**Auth:** `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard` (role: `supervisor`)

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `idcntliderado` | integer | ✅ | ID do vendedor a adicionar (`cnt.id`). Deve ser diferente do próprio usuário |

**Respostas:**

| Status | Descrição |
|---|---|
| `201 Created` | Vínculo criado com sucesso (sem corpo) |
| `400 Bad Request` | `idcntliderado` é igual ao próprio usuário |
| `409 Conflict` | Vendedor já pertence a esta equipe |

---

### `DELETE /b3vendas/equipe/:id`

Remove um vendedor da equipe do supervisor autenticado. O parâmetro `:id` é o `cnt.id` do vendedor a ser removido (`idcntliderado`).

**Auth:** `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard` (role: `supervisor`)

**Path params:**

| Param | Tipo | Descrição |
|---|---|---|
| `id` | integer | ID do vendedor subordinado (`cnt.id`) |

**Respostas:**

| Status | Descrição |
|---|---|
| `204 No Content` | Vínculo removido com sucesso |
| `404 Not Found` | Vínculo não existe nesta equipe |

---

## Operações Fiscais

### `GET /b3vendas/operacoes`

Lista as operações fiscais disponíveis para uma empresa. Usado para preencher o seletor de tipo de operação ao criar um pedido.

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `idemp` | integer | ✅ | ID da empresa (emitente) no banco do tenant |

**Resposta `200`:**

```jsonc
[
  {
    "id": 5,
    "operacao": "Venda de Mercadoria",  // Descrição da operação
    "subtipo": "N",    // Tipo fiscal: N=Normal, T=Transferência, B=Bonificação, G=Garantia
    "cfopnormal": "5102",  // CFOP para operação sem ST
    "cfopst": "5403"       // CFOP para operação com substituição tributária
  }
]
```

---

## Produtos

Base: `/b3vendas/produtos`

---

### `GET /b3vendas/produtos/buscar`

Busca produtos por texto (mínimo 2 caracteres). Retorna lista simplificada para autocomplete.

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `q` | string | ❌ | Texto de busca (nome, código ou descrição). Mínimo 2 caracteres |

**Resposta `200`:**

```jsonc
[
  {
    "id": 456,
    "nome": "Produto XYZ",
    "display": "Produto XYZ (SKU-001)"  // String formatada para autocomplete
  }
]
```

---

### `GET /b3vendas/produtos/:id/preco`

Retorna o preço unitário e o CFOP de um produto para um cliente e operação específicos. Aplica a tabela de preços personalizada do cliente, com fallback para o preço padrão do produto.

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Path params:** `id` (integer — ID do produto)

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `idCli` | integer | ✅ | ID do cliente (usado para resolver a tabela de preços) |
| `idOper` | integer | ✅ | ID da operação fiscal (determina o CFOP retornado) |

**Resposta `200`:**

```jsonc
{
  "cfop": "5102",    // CFOP aplicável ao item (baseado na operação e tributação)
  "custo": 45.80,    // Custo do produto (para margem de contribuição)
  "vunit": 89.90     // Preço de venda unitário
}
```

---

### `POST /b3vendas/produtos/:id/calc-imposto`

Calcula IPI e ICMS-ST sobre um subtotal para um produto e operação. Use antes de adicionar o item ao pedido para informar os impostos corretamente.

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Path params:** `id` (integer — ID do produto)

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `subtotal` | number | ✅ | Valor base para cálculo (qty × preço unitário). Deve ser positivo |
| `idOper` | integer | ✅ | ID da operação fiscal (mínimo: 1) |

**Resposta `200`:**

```jsonc
{
  "ipi": 4.50,    // Valor do IPI calculado
  "st": 12.30,    // Valor do ICMS-ST calculado
  "total": 16.80  // ipi + st
}
```

---

## Pedidos (Vendas)

Base: `/b3vendas/pedidos`

### Máquina de estados da venda (`tipo`)

| Valor | Estado | Pode adicionar/remover itens? |
|---|---|---|
| `O` | Aberto / Rascunho | ✅ Sim |
| `P` | Pendente | ❌ Não |
| `V` | Validado | ❌ Não |

---

### `POST /b3vendas/pedidos`

Cria um novo pedido em estado aberto (`tipo = 'O'`).

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `rctipo` | string | ✅ | Tipo de movimentação: `O`=Orçamento, `P`=Pedido, `V`=Venda |
| `rcfat` | string | ✅ | Modalidade de faturamento: `F`=Faturado, `E`=Entregue |
| `idCli` | integer | ✅ | ID do cliente (mínimo: 1) |
| `idOper` | integer | ✅ | ID da operação fiscal (mínimo: 1) |
| `idemp` | integer | ✅ | ID da empresa emitente (mínimo: 1) |

**Resposta `201`:**

```jsonc
{
  "id": 1001,           // ID do pedido criado
  "tipo": "O",          // Estado inicial
  "idcli": 123,
  "razaoCliente": "Empresa ABC",
  "dthremissao": "2026-04-23T14:30:00.000Z",
  "vlrtotal": 0         // Zerado ao criar; atualizado conforme itens são adicionados
}
```

---

### `GET /b3vendas/pedidos/editaveis`

Lista os pedidos abertos (`tipo = 'O'`) do vendedor autenticado para uma empresa. Retorna os pedidos dos últimos 5 dias.

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `idemp` | integer | ✅ | ID da empresa emitente (mínimo: 1) |

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

---

### `GET /b3vendas/pedidos/fechados`

Lista os pedidos fechados (`tipo IN ('P','V')`) do vendedor autenticado para uma empresa. Retorna os pedidos dos últimos 30 dias.

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `idemp` | integer | ✅ | ID da empresa emitente (mínimo: 1) |

**Resposta `200`:** array com o mesmo shape de `GET /pedidos/editaveis`.

---

### `GET /b3vendas/pedidos/:id`

Retorna os detalhes completos de um pedido, incluindo todos os itens.

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Path params:** `id` (integer — ID do pedido)

**Resposta `200`:**

```jsonc
{
  "id": 1001,
  "idcli": 123,
  "razaoCliente": "Empresa ABC Ltda",
  "idoper": 5,
  "fiscal": "N",         // Subtipo fiscal da operação
  "tipo": "O",           // Estado atual: O, P ou V
  "vlrbruto": 500.00,    // Valor bruto dos itens
  "desconto": 0.00,      // Desconto total
  "acrescimo": 0.00,     // Acréscimo total
  "st": 12.30,           // Total de ICMS-ST
  "ipi": 4.50,           // Total de IPI
  "vlrtotal": 516.80,    // Total geral (vlrbruto + st + ipi + ... - descontos)
  "obsinter": null,      // Observação interna (preenchida ao fechar)
  "idForma": null,       // ID da forma de pagamento (preenchido ao fechar)
  "idCond": null,        // ID da condição de pagamento (preenchido ao fechar)
  "itens": [
    {
      "seq": 1,           // Sequência do item no pedido
      "idprod": 456,      // ID do produto
      "nomeProduto": "Produto XYZ",
      "qtde": 2.000,      // Quantidade
      "unitario": 89.90,  // Preço unitário
      "total": 179.80     // qtde × unitario
    }
  ]
}
```

---

### `POST /b3vendas/pedidos/:id/fechar`

Fecha um pedido aberto: registra a forma de pagamento e transita o estado conforme `rctipo` original.

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Path params:** `id` (integer — ID do pedido)

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `idForma` | integer | ✅ | ID da forma de pagamento (mínimo: 1). Obter de `GET /pedidos/:id/formas-disponiveis` |
| `idCond` | integer | ✅ | ID da condição de pagamento (mínimo: 1). Obter de `GET /pedidos/:id/condicoes-disponiveis` |
| `obsInter` | string | ❌ | Observação interna (máx. 255 caracteres) |

**Resposta `200`:** pedido fechado com estado atualizado.

---

## Itens do Pedido

Base: `/b3vendas/pedidos/:id/itens`

Gerencia os itens de um pedido aberto (`tipo = 'O'`). Após cada alteração, os totais do pedido são recalculados automaticamente.

---

### `POST /b3vendas/pedidos/:id/itens`

Adiciona um item ao pedido.

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Path params:** `id` (integer — ID do pedido)

**Body (JSON):**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `idProd` | integer | ✅ | ID do produto (mínimo: 1) |
| `qtde` | number | ✅ | Quantidade (mínimo: 0.001) |
| `vunit` | number | ✅ | Preço unitário (mínimo: 0). Obtido de `GET /produtos/:id/preco` |
| `custo` | number | ✅ | Custo do produto (mínimo: 0). Obtido de `GET /produtos/:id/preco` |
| `cfop` | string | ✅ | CFOP do item (máx. 5 caracteres). Obtido de `GET /produtos/:id/preco` |
| `vST` | number | ✅ | Valor do ICMS-ST (mínimo: 0). Obtido de `POST /produtos/:id/calc-imposto` |
| `vIPI` | number | ✅ | Valor do IPI (mínimo: 0). Obtido de `POST /produtos/:id/calc-imposto` |
| `tabela` | number | ✅ | Número da tabela de preços aplicada (mínimo: 0) |
| `obsprod` | string | ❌ | Observação sobre o item (máx. 60 caracteres) |

**Resposta `201`:** item criado e pedido com totais atualizados.

---

### `DELETE /b3vendas/pedidos/:id/itens/:seq`

Remove um item do pedido. Os totais são recalculados automaticamente.

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Path params:**

| Param | Tipo | Descrição |
|---|---|---|
| `id` | integer | ID do pedido |
| `seq` | integer | Sequência do item (campo `seq` retornado em `GET /pedidos/:id`) |

**Resposta `204`:** sem corpo.

---

## Formas e Condições de Pagamento

---

### `GET /b3vendas/pedidos/:id/formas-disponiveis`

Lista as formas de pagamento disponíveis para um pedido específico.

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Path params:** `id` (integer — ID do pedido)

**Resposta `200`:**

```jsonc
[
  {
    "id": 1,
    "nome": "Dinheiro"
  },
  {
    "id": 2,
    "nome": "Cartão de Crédito"
  }
]
```

---

### `GET /b3vendas/pedidos/:id/condicoes-disponiveis`

Lista as condições de pagamento disponíveis para um pedido específico.

**Auth:** `JwtGuard` + `UserInstanceGuard`

**Path params:** `id` (integer — ID do pedido)

**Resposta `200`:** array com shape similar a formas de pagamento (id + nome/descrição da condição).

---

## Métricas de Desempenho

Base: `/b3vendas/metricas`

Endpoints para acompanhamento do desempenho do vendedor autenticado. O escopo é resolvido pela `roleFront`:

- **`saler`** — só vê os próprios dados (`venda.idvend = vendId` ou `cnt.idvende = vendId`).
- **`supervisor`** — vê os próprios dados **e** os dos vendedores subordinados (via `cntequipe.idcntlider = vendId`).

Qualquer outro `roleFront` recebe `403 Forbidden`.

**Auth (todos os endpoints):** `JwtGuard` + `UserInstanceGuard` + `RolesFrontGuard` (roles: `supervisor` ou `saler`).

### Critério de venda considerada

Para os endpoints `vendas-semanais`, `vendas-mensais` e `top-clientes-ativos`, somente vendas que satisfaçam **todas** as condições abaixo entram na agregação:

```
venda.tipo    = 'V'   (validada)
venda.subtipo = 'N'   (normal — exclui transferência/bonificação/garantia)
venda.baixado = 1     (efetivamente concluída)
```

> O endpoint `clientes-inativos` ignora esse filtro: considera **qualquer** linha em `venda` (independentemente de `tipo`/`subtipo`/`baixado`) ao avaliar atividade.

---

### `GET /b3vendas/metricas/vendas-semanais`

Total de vendas (em R$) agrupado por **semana ISO**, cobrindo as últimas **12 semanas**. Buckets sem vendas vêm com valor `0` para garantir um eixo X completo.

**Resposta `200`:**

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

---

### `GET /b3vendas/metricas/vendas-mensais`

Total de vendas (em R$) agrupado por mês (`YYYY-MM`), cobrindo os últimos **12 meses**. Buckets sem vendas vêm com valor `0`.

**Resposta `200`:**

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

Top **15 clientes** com maior valor total comprado nos **últimos 90 dias**, em ordem decrescente. Apresenta duas séries alinhadas: valor monetário e número de pedidos.

**Resposta `200`:**

```jsonc
{
  "chartType": "bar_h",
  "labels": ["H B FULLER BRASIL LTDA", "CONSUMIDOR FINAL", "CRISLOG", "..."],
  "series": [
    { "name": "Valor (R$)", "data": [4549.00, 2064.32, 1380.00] },
    { "name": "Pedidos",    "data": [1, 1, 1] }
  ]
}
```

> O label de cada cliente é `COALESCE(cnt.fantasia, cnt.razao)`. Pedidos é a contagem de vendas do cliente no período (sob o critério da seção acima).

---

### `GET /b3vendas/metricas/clientes-inativos`

Lista de clientes vinculados ao vendedor (`cnt.idvende`) que **não tiveram nenhuma venda** (qualquer `tipo`/`subtipo`/`baixado`) nos **últimos 60 dias**. Apenas clientes com `cnt.ativo = 1`. Inclui clientes que nunca venderam (sem registros em `venda`).

**Resposta `200`:**

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
    "ultimaVenda": "2025-11-24T17:15:20.000Z",  // MAX(venda.dthremissao) global do cliente; null se nunca vendeu
    "idvende": 233                              // ID do vendedor responsável pelo cliente
  }
]
```

> Resultado ordenado por `nome` (ASC). `ultimaVenda` é a última data registrada **em qualquer venda** do cliente — útil para distinguir "nunca comprou" de "comprou há muito tempo".

---

## Fluxo Completo de Criação de Pedido

```
1. GET  /tenant/emitentes
        → obter idemp da empresa

2. GET  /b3vendas/equipe
        → carregar contexto do vendedor (pode omitir se o frontend já tem)

3. GET  /b3vendas/operacoes?idemp=<N>
        → listar operações disponíveis para a empresa

4. GET  /b3vendas/clientes/buscar?q=<texto>
        → selecionar cliente (autocomplete)

5. GET  /b3vendas/clientes/:id
        → carregar dados do cliente (endereço, obsvenda, operação padrão)

6. POST /b3vendas/pedidos
        → criar pedido com { rctipo, rcfat, idCli, idOper, idemp }

7. Para cada produto:
   a. GET  /b3vendas/produtos/buscar?q=<texto>
   b. GET  /b3vendas/produtos/:id/preco?idCli=<N>&idOper=<N>
           → obter { cfop, custo, vunit }
   c. POST /b3vendas/produtos/:id/calc-imposto
           → calcular { ipi, st }
   d. POST /b3vendas/pedidos/:id/itens
           → adicionar item com todos os campos calculados

8. GET  /b3vendas/pedidos/:id/formas-disponiveis
        → listar formas de pagamento

9. GET  /b3vendas/pedidos/:id/condicoes-disponiveis
        → listar condições

10. POST /b3vendas/pedidos/:id/fechar
         → fechar com { idForma, idCond, obsInter? }
```
