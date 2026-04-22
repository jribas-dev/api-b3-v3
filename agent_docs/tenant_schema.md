# Tenant Schema — B3ERP (versão 2.38)

Esquema completo do banco de dados de tenant (MySQL 8.0, InnoDB/utf8mb3).  
Origem: `b3erp.dsv` — exportado pelo HeidiSQL 12.4 do servidor `db01.b3infra.com.br`.  
Chave de compatibilidade: `VERSAO_DB >= 2.38` (verificada em `cfg.param = 'VERSAO_DB'`).

> **Observação sobre IDs:** todas as tabelas deste banco usam **IDs numéricos inteiros auto-increment** (legado), **não** CUID2 como nas tabelas do banco principal da aplicação.

---

## Índice de Domínios

| # | Grupo | Tabelas |
|---|---|---|
| 1 | [Core — Usuários e Empresas](#1-core--usuários-e-empresas) | `usu`, `usuemp`, `usugrupo`, `usurole`, `usurolemnu`, `usulogin`, `usuagenda` |
| 2 | [Clientes e Contatos (`cnt`)](#2-clientes-e-contatos-cnt) | `cnt`, `cntclass`, `cntclasses`, `cntgrupo`, `cntgrupohist`, `cntobs`, `cntref`, `cntend`, `cntconta`, `cntcontabaixa`, `cntcontato`, `cntcc`, `cntrestricaolog`, `cntativolog`, `cntrota`, `cntsocios`, `cntcnae`, `cntcnaes`, `cntcli_setor`, `cntemp_setor`, `cntequipe` |
| 3 | [Vendas](#3-vendas) | `venda`, `vendaitem`, `vendacaixa`, `vendacartao`, `vendadev`, `vendadevitem`, `vendafiscal`, `vendahist`, `vendaitemhist`, `vendajunta`, `vendalote`, `vendalotemanu`, `vendaoper`, `vendaos`, `vendaparc`, `vendaretido`, `vendasat`, `vendatrib`, `vendatroco` |
| 4 | [Operações Fiscais](#4-operações-fiscais) | `operacoes`, `cfop`, `formapg`, `condpg` |
| 5 | [Produtos](#5-produtos) | `prd`, `prdgrupo`, `prdsubgrupo`, `prdtab`, `prdtabvalor`, `prdimposto`, `impostos`, `impostouf`, `impostoloja`, `impostoretido`, `prdimg`, `prdinfo`, `prdaplic`, `prdeqp`, `prdfor`, `prdgrade`, `prdvar`, `prdlote`, `prdserial`, `prdsku`, `prdskusaldo`, `prdminmax`, `prdobs`, `prdorigem`, `prdpacote`, `prdpedref`, `prdmarkup`, `prdsaldo`, `fabricante`, `prdicmscst`, `prdipicst`, `prdpiscst` |
| 6 | [Estoque e Movimentos](#6-estoque-e-movimentos) | `estoque`, `estoqueh010`, `estoqueheader`, `estoquek200`, `estoquek200Mes`, `estoquek280`, `mov`, `movdi`, `movnfe`, `movparc`, `movprd`, `movprecohist`, `movrr` |
| 7 | [Financeiro — Receber e Pagar](#7-financeiro--receber-e-pagar) | `ctareceber`, `ctareceberlog`, `ctapag`, `ctapagclass`, `ctapagfor`, `ctapagp`, `ctapagrateio`, `finmov`, `finlancto`, `findestino`, `finespecie`, `finhist` |
| 8 | [Caixa / PDV](#8-caixa--pdv) | `caixa`, `caixaentrada`, `caixasaida`, `caixafecha`, `caixacartao`, `caixatroco`, `operadora`, `pdv`, `pdvcfg` |
| 9 | [Cobrança Bancária](#9-cobrança-bancária) | `cobcfg`, `cobcomando`, `cobretorno`, `cobtitulo`, `cobtituloalt`, `cobtituloaltlog`, `cobtitulodespesa`, `cobtitulolog` |
| 10 | [Documentos Fiscais](#10-documentos-fiscais) | `docnfe`, `docnfce`, `docnfse`, `doccte`, `docmdfe`, `docevento`, `doceventocte`, `doceventomdfe`, `docdist`, `doccfg`, `fat` |
| 11 | [CT-e e MDF-e](#11-ct-e-e-mdf-e) | `cte`, `ctecarga`, `ctecfg`, `ctedocnfe`, `ctepercur`, `cteprest`, `mdfe`, `mdfecarga`, `mdfecfg`, `mdfecnt`, `mdfedescarga`, `mdfedocs`, `mdfepercur`, `mdfereboque` |
| 12 | [Compras](#12-compras) | `cpedido`, `cprod`, `cordem` |
| 13 | [Ordem de Serviço (OS)](#13-ordem-de-serviço-os) | `os`, `ositem`, `oskm` |
| 14 | [PCP — Produção](#14-pcp--produção) | `pcpcfg`, `pcpformu`, `pcpmitem`, `pcpop`, `pcpopmp`, `pcpprecohist`, `pcpproc`, `pcpvitem` |
| 15 | [CRM](#15-crm) | `crmevento`, `crmlog`, `crmreg`, `crmtpev` |
| 16 | [Contratos](#16-contratos) | `contrato`, `contratoobs`, `contratotipo` |
| 17 | [Pagamento Fornecedor (TED/PIX)](#17-pagamento-fornecedor-tedpix) | `pagfor`, `pagforcfg`, `pagforcnt`, `pagforcta`, `pagforret`, `pagforretorno` |
| 18 | [RH e DP](#18-rh-e-dp) | `cntfunc`, `cntfunc_aci`, `cntfunc_ates`, `cntfunc_cargo`, `cntfunc_dep`, `cntfunc_exa`, `cntfunc_ferias`, `cntfunc_hist`, `cntfunc_ocorr`, `cntfunc_posto`, `cntfunc_qhoras`, `cntfunc_turno`, `diasu`, `feriados`, `tb_docs`, `tb_evento`, `tb_frases`, `tb_justi`, `tb_treino` |
| 19 | [SPED](#19-sped) | `spedcfg`, `spedcontrib`, `spedfiscal` |
| 20 | [Tributação Auxiliar](#20-tributação-auxiliar) | `tribAliq`, `tribAnexos`, `tribClass`, `tribCst`, `tribIndOper`, `ibpt`, `impostouf` |
| 21 | [Configuração e Menu](#21-configuração-e-menu) | `cfg`, `mnu`, `mnuagenda`, `mnucampos`, `mnudash`, `mnugrid`, `mnuradios`, `mnurel`, `mnurelbin`, `mnurelconst`, `mnurelparam`, `mnurelradios`, `monitorcfg`, `formgrid`, `log`, `mailcfg`, `empses` |
| 22 | [Integrações API](#22-integrações-api) | `api_3b3`, `api_frenet`, `api_mlb` |
| 23 | [Dashboard Widgets](#23-dashboard-widgets) | `wg_angulargauge`, `wg_column2d`, `wg_livre`, `wg_msline`, `wg_pie2d`, `wg_symbol`, `wg_ticker`, `wg_urls` |
| 24 | [Logística](#24-logística) | `romaneio`, `romaneioitem`, `romaneiopost`, `romaneiotot`, `rota`, `cntrota` |

---

## 1. Core — Usuários e Empresas

### `usu` — Usuários do tenant

```sql
CREATE TABLE `usu` (
  `id`              int unsigned NOT NULL AUTO_INCREMENT,
  `userId`          varchar(60) DEFAULT NULL,   -- vincula ao userId do banco principal
  `login`           varchar(60) DEFAULT NULL,
  `senha`           varchar(255) DEFAULT NULL,
  `nome`            varchar(60) DEFAULT NULL,
  `email`           varchar(100) DEFAULT NULL,
  `telefone`        varchar(60) DEFAULT NULL,
  `inativo`         bit(1) NOT NULL DEFAULT b'0',
  `caixa`           bit(1) NOT NULL DEFAULT b'0',
  `agendaliberada`  bit(1) NOT NULL DEFAULT b'0',
  `dashboard`       bit(1) NOT NULL DEFAULT b'0',
  `dtadd`           timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `idvend`          int unsigned DEFAULT NULL,  -- FK → cnt (vendedor vinculado)
  `assinatura`      mediumblob,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_unique_userId` (`userId`)
)
```

> `userId` é o elo de ligação com o banco principal: `SellerContextService` busca `usu` pelo `userId` proveniente do JWT para resolver `usuId` e `vendId`.

### `usuemp` — Usuário × Empresa

```sql
CREATE TABLE `usuemp` (
  `idusu`  int unsigned NOT NULL,  -- FK → usu
  `idcnt`  int unsigned NOT NULL,  -- FK → cnt (empresa)
  PRIMARY KEY (`idusu`, `idcnt`)
)
```

### `usugrupo` — Grupos de Permissão

```sql
CREATE TABLE `usugrupo` (
  `id`     int unsigned NOT NULL AUTO_INCREMENT,
  `grupo`  varchar(60) NOT NULL,
  `acesso` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_u_role` (`grupo`)
)
```

### `usurole` — Usuário × Grupo

```sql
CREATE TABLE `usurole` (
  `idusu`      int unsigned NOT NULL,
  `idusugrupo` int unsigned NOT NULL,
  PRIMARY KEY (`idusu`, `idusugrupo`)
)
```

### `usurolemnu` — Permissão por Menu

```sql
CREATE TABLE `usurolemnu` (
  `id`        int unsigned NOT NULL AUTO_INCREMENT,
  `idmnu`     smallint NOT NULL,       -- FK → mnu
  `idusu`     int unsigned DEFAULT NULL,
  `idrole`    int unsigned DEFAULT NULL,
  `permissao` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`)
)
```

### `usulogin` — Sessões ativas do tenant (legado)

```sql
CREATE TABLE `usulogin` (
  `idusu`      int unsigned NOT NULL,
  `token`      varchar(255) NOT NULL,
  `idcnt`      int unsigned NOT NULL,   -- FK → cnt (empresa)
  `validade`   timestamp NOT NULL,
  `dthrlogin`  timestamp NOT NULL,
  `tenancy`    varchar(128) DEFAULT NULL,
  PRIMARY KEY (`idusu`, `token`)
)
```

---

## 2. Clientes e Contatos (`cnt`)

### `cnt` — Tabela central de contatos (clientes, fornecedores, empresas, vendedores)

É a tabela mais central do banco. Representa qualquer entidade (cliente, fornecedor, funcionário, empresa filial). O campo `idemp` em outras tabelas sempre aponta para um `cnt` com papel de empresa.

```sql
CREATE TABLE `cnt` (
  `id`              int unsigned NOT NULL AUTO_INCREMENT,
  `tipopessoa`      enum('F','J','E','R') NOT NULL DEFAULT 'F',  -- Física/Jurídica/Estrangeiro/Rural
  `tipoestatal`     enum('X','1','2','3','4') NOT NULL DEFAULT 'X',
  `razao`           varchar(120) NOT NULL,
  `fantasia`        varchar(120) DEFAULT NULL,
  `docfed`          varchar(30) DEFAULT NULL,   -- CPF/CNPJ
  `docest`          varchar(30) DEFAULT NULL,   -- IE
  `docestemi`       date DEFAULT NULL,
  `docestorgao`     varchar(10) DEFAULT NULL,
  `im`              varchar(30) DEFAULT NULL,   -- Inscrição Municipal
  `email`           varchar(120) DEFAULT NULL,
  `site`            varchar(120) DEFAULT NULL,
  `imagem`          mediumblob,
  `dtnascto`        date DEFAULT NULL,
  `sexo`            enum('F','M') DEFAULT NULL,
  `nomepai`         varchar(120) DEFAULT NULL,
  `nomemae`         varchar(120) DEFAULT NULL,
  `estadocivil`     enum('S','C','D','A','V','E') DEFAULT NULL,
  `nomeconj`        varchar(120) DEFAULT NULL,
  `limite`          decimal(18,2) DEFAULT NULL,
  `prazopagto`      smallint DEFAULT NULL,
  `taxafrete`       decimal(12,2) DEFAULT NULL,
  `taxacob`         decimal(12,2) DEFAULT NULL,
  `ativo`           bit(1) DEFAULT b'1',
  `restricao`       bit(1) DEFAULT b'0',
  `dthradd`         timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `cep`             varchar(12) DEFAULT NULL,
  `endereco`        varchar(120) DEFAULT NULL,
  `nroend`          varchar(30) DEFAULT NULL,
  `bairro`          varchar(120) DEFAULT NULL,
  `compl`           varchar(120) DEFAULT NULL,
  `referencia`      varchar(120) DEFAULT NULL,
  `cidade`          varchar(120) DEFAULT NULL,
  `uf`              varchar(10) DEFAULT NULL,
  `fone`            varchar(20) DEFAULT NULL,
  `fone2`           varchar(20) DEFAULT NULL,
  `cel`             varchar(20) DEFAULT NULL,
  `fax`             varchar(20) DEFAULT NULL,
  `obs`             varchar(400) DEFAULT NULL,
  `codpais`         smallint DEFAULT '1058',    -- Brasil
  `respnome`        varchar(120) DEFAULT NULL,
  `respdocfed`      varchar(30) DEFAULT NULL,
  `docestrangeiro`  varchar(30) DEFAULT NULL,
  `codmunicipio`    varchar(15) DEFAULT NULL,
  `codmunservico`   varchar(15) DEFAULT NULL,
  `emailorc`        varchar(240) DEFAULT NULL,
  `emailnfe`        varchar(240) DEFAULT NULL,
  `emailcob`        varchar(240) DEFAULT NULL,
  `idtab`           smallint unsigned DEFAULT NULL,  -- FK → prdtab (tabela de preços)
  `idgrupo`         smallint DEFAULT NULL,           -- FK → cntgrupo
  `idcomi`          smallint unsigned DEFAULT NULL,  -- FK → comi (comissão)
  `idforma`         smallint unsigned DEFAULT NULL,  -- FK → formapg (forma padrão)
  `idcond`          smallint unsigned DEFAULT NULL,  -- FK → condpg (condição padrão)
  `idoper`          smallint unsigned DEFAULT NULL,  -- FK → operacoes (operação padrão)
  `obsvenda`        varchar(400) DEFAULT NULL,
  `idvende`         int unsigned DEFAULT NULL,       -- FK → cnt (vendedor padrão)
  `inforastro`      bit(1) DEFAULT b'0',
  `negativado`      bit(1) DEFAULT b'0',
  `txdesconto`      decimal(12,2) DEFAULT NULL,
  `diacorrido`      bit(1) DEFAULT NULL,
  `reduestatal`     decimal(12,3) DEFAULT NULL,
  PRIMARY KEY (`id`)
)
```

### Tabelas satélite de `cnt` (catálogo resumido)

| Tabela | PK | Descrição |
|---|---|---|
| `cntativolog` | `id` | Log de ativação/inativação de cnt |
| `cntcc` | `idcnt` | Centro de custo do contato |
| `cntclass` | `id` | Definição de classes de contato |
| `cntclasses` | `id` | Vínculo contato × classes |
| `cntcli_setor` | `idcnt, idsetor` | Setores do cliente |
| `cntcnae` | `cnae` | Cadastro de CNAEs |
| `cntcnaes` | `idcnt, cnae` | CNAEs vinculados ao contato |
| `cntconta` | `id` | Contas bancárias do contato |
| `cntcontabaixa` | `idconta, idmov` | Baixas de contas |
| `cntcontato` | `id` | Contatos adicionais (pessoa de contato) |
| `cntemp_setor` | `idemp, idsetor` | Setores da empresa |
| `cntend` | `id` | Endereços adicionais |
| `cntequipe` | `id` | Equipes |
| `cntfunc` | `id` | Funcionários |
| `cntgrupo` | `id` | Grupos de clientes |
| `cntgrupohist` | `id` | Histórico de grupo do cliente |
| `cntobs` | `id` | Observações adicionais |
| `cntref` | `idcnt, seq` | Referências comerciais |
| `cntrestricaolog` | `id` | Log de restrições |
| `cntrota` | `idcnt, idrota` | Rota do cliente |
| `cntsocios` | `idcnt, seq` | Sócios da empresa |

---

## 3. Vendas

### `venda` — Pedidos e Vendas

```sql
CREATE TABLE `venda` (
  `id`             int unsigned NOT NULL AUTO_INCREMENT,
  `dthremissao`    timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idoper`         smallint unsigned NOT NULL DEFAULT '1',  -- FK → operacoes
  `fiscal`         varchar(1) NOT NULL DEFAULT 'F',         -- 'F' fiscal / 'E' estimativa
  `tipo`           varchar(1) NOT NULL DEFAULT 'V',         -- 'O' aberto / 'P' pendente / 'V' validado
  `subtipo`        enum('N','T','B','G') NOT NULL DEFAULT 'N',
  `vlrbruto`       decimal(16,3) NOT NULL DEFAULT '0.000',
  `acrescimo`      decimal(12,3) NOT NULL DEFAULT '0.000',
  `desconto`       decimal(12,3) NOT NULL DEFAULT '0.000',
  `frete`          decimal(12,3) NOT NULL DEFAULT '0.000',
  `seguro`         decimal(12,3) NOT NULL DEFAULT '0.000',
  `outros`         decimal(12,3) NOT NULL DEFAULT '0.000',
  `deducoes`       decimal(12,3) NOT NULL DEFAULT '0.000',
  `st`             decimal(12,3) NOT NULL DEFAULT '0.000',  -- ICMS-ST total
  `ipi`            decimal(12,3) NOT NULL DEFAULT '0.000',
  `vlrtotal`       decimal(16,3) NOT NULL DEFAULT '0.000',
  `idcli`          int unsigned DEFAULT NULL,    -- FK → cnt (cliente)
  `idvend`         int unsigned DEFAULT NULL,    -- FK → cnt (vendedor, isolamento)
  `idemp`          int unsigned DEFAULT NULL,    -- FK → cnt (empresa)
  `idcaixa`        int unsigned DEFAULT NULL,    -- FK → caixa
  `obs`            varchar(400) DEFAULT NULL,
  `baixado`        bit(1) NOT NULL DEFAULT b'0',
  `faturado`       bit(1) NOT NULL DEFAULT b'0',
  `idcontrato`     int unsigned DEFAULT NULL,    -- FK → contrato
  `isento`         decimal(12,3) NOT NULL DEFAULT '0.000',
  `pedidoref`      varchar(40) DEFAULT NULL,
  `bloqueio`       bit(1) NOT NULL DEFAULT b'0',
  `motivobloq`     varchar(200) DEFAULT NULL,
  `autorizado`     bit(1) NOT NULL DEFAULT b'0',
  `idusuautoriza`  int unsigned DEFAULT NULL,    -- FK → usu
  `tipofrete`      enum('F','C','T','P','3','X') NOT NULL DEFAULT 'X',
  `idcntend`       int unsigned DEFAULT NULL,    -- FK → cntend (endereço de entrega)
  `idlog`          int unsigned DEFAULT NULL,    -- FK → cnt
  `formaentrega`   varchar(60) DEFAULT NULL,
  `prazoentrega`   varchar(45) DEFAULT NULL,
  `dataentrega`    date DEFAULT NULL,
  `solicitante`    varchar(80) DEFAULT NULL,
  `docfedcfe`      varchar(20) DEFAULT NULL,
  `emiticfe`       tinyint NOT NULL DEFAULT '0',
  `msgerrocfe`     varchar(120) DEFAULT NULL,
  `idcomi`         smallint unsigned DEFAULT NULL,  -- FK → comi
  `plataforma`     varchar(20) DEFAULT 'ERP',       -- origem: 'SALESFORCE', 'ERP', etc.
  `processo`       varchar(20) DEFAULT NULL,        -- 'B3PED.exe', 'B3PDV.exe', etc.
  `ultimousu`      int unsigned DEFAULT NULL,       -- FK → usu
  `obsinter`       varchar(255) DEFAULT NULL,
  `totdevo`        decimal(12,3) DEFAULT '0.000',
  PRIMARY KEY (`id`)
)
```

**Máquina de estados `tipo`:**
- `'O'` — Aberto/Rascunho (editável)
- `'P'` — Pendente
- `'V'` — Validado/Confirmado

**Fórmula do total:**
```
vlrtotal = vlrbruto + acrescimo + st + ipi + frete + seguro + outros - desconto - deducoes
```

### `vendaitem` — Itens do Pedido

```sql
CREATE TABLE `vendaitem` (
  `idvenda`   int unsigned NOT NULL,   -- FK → venda (CASCADE)
  `seq`       smallint unsigned NOT NULL,
  `idprod`    int NOT NULL,            -- FK → prd
  `sku`       varchar(45) DEFAULT NULL,-- FK → prdsku
  `qtde`      decimal(10,3) NOT NULL DEFAULT '0.000',
  `custo`     decimal(12,3) NOT NULL DEFAULT '0.000',   -- custo no momento
  `unitario`  decimal(12,3) NOT NULL DEFAULT '0.000',   -- preço unitário
  `desconto`  decimal(10,2) NOT NULL DEFAULT '0.00',
  `acrescimo` decimal(10,2) NOT NULL DEFAULT '0.00',
  `bruto`     decimal(12,2) NOT NULL DEFAULT '0.00',    -- qtde × unitario
  `total`     decimal(12,2) NOT NULL DEFAULT '0.00',    -- bruto + acrescimo - desconto
  `margem`    decimal(12,4) NOT NULL DEFAULT '0.0000',
  `frete`     decimal(12,3) NOT NULL DEFAULT '0.000',
  `seguro`    decimal(12,3) NOT NULL DEFAULT '0.000',
  `outros`    decimal(12,3) NOT NULL DEFAULT '0.000',
  `deducoes`  decimal(12,3) NOT NULL DEFAULT '0.000',
  `st`        decimal(12,3) NOT NULL DEFAULT '0.000',   -- ICMS-ST do item
  `ipi`       decimal(12,3) NOT NULL DEFAULT '0.000',
  `cfop`      varchar(5) NOT NULL DEFAULT '5102',
  `qtdedev`   decimal(10,3) NOT NULL DEFAULT '0.000',   -- qtde devolvida
  `servico`   bit(1) NOT NULL DEFAULT b'0',
  `seqpedref` varchar(30) DEFAULT NULL,
  `estoque`   tinyint NOT NULL DEFAULT '0',
  `vlrtab`    decimal(12,3) NOT NULL DEFAULT '0.000',   -- preço da tabela usado
  `obsprd`    varchar(60) DEFAULT NULL,
  `comtroca`  bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idvenda`, `seq`)
)
```

### `vendacaixa` — Pagamento da Venda

```sql
CREATE TABLE `vendacaixa` (
  `idvenda`  int unsigned NOT NULL,     -- FK → venda (CASCADE DELETE)
  `idforma`  smallint unsigned NOT NULL,-- FK → formapg (CASCADE DELETE)
  `seq`      tinyint unsigned NOT NULL,
  `idcaixa`  int unsigned DEFAULT NULL, -- FK → caixa
  `valor`    decimal(12,2) NOT NULL,
  `idcond`   smallint unsigned DEFAULT NULL, -- FK → condpg
  `operacao` varchar(1) NOT NULL DEFAULT 'I', -- 'I' entrada / 'D' débito
  `baixado`  bit(1) NOT NULL DEFAULT b'1',
  `vchave`   varchar(60) DEFAULT NULL,
  PRIMARY KEY (`idvenda`, `idforma`, `seq`)
)
```

### Tabelas satélite de `venda` (catálogo resumido)

| Tabela | PK | Descrição |
|---|---|---|
| `vendacartao` | `idvenda, idforma, seq, parc` | Parcelas de cartão da venda |
| `vendadev` | `iddev` | Cabeçalho de devolução |
| `vendadevitem` | `iddev, seq` | Itens da devolução |
| `vendafiscal` | `idvenda` | Dados fiscais da NF-e emitida |
| `vendahist` | `idhist` | Histórico de estados da venda |
| `vendaitemhist` | `idhist` | Histórico de itens (preços, qtde) |
| `vendajunta` | `idvenda, idvjunta` | Junção de vendas |
| `vendalote` | `idvenda, seq, idlote` | Lotes dos itens |
| `vendalotemanu` | `idvenda, seq, idlote` | Lotes manuais |
| `vendaoper` | `idvenda` | Dados de operação (entrega, frete) |
| `vendaos` | `idvenda, idos` | OS vinculada à venda |
| `vendaparc` | `idvenda, seq` | Parcelas financeiras da venda |
| `vendaretido` | `idvenda` | Impostos retidos |
| `vendasat` | `idvenda` | Dados do SAT (NFC-e SAT) |
| `vendatrib` | `idvenda` | Tributação da venda |
| `vendatroco` | `idvenda, idforma, seq` | Troco da venda |

---

## 4. Operações Fiscais

### `operacoes` — Tipos de Operação Fiscal

```sql
CREATE TABLE `operacoes` (
  `id`              smallint unsigned NOT NULL AUTO_INCREMENT,
  `operacao`        varchar(60) NOT NULL,
  `saidaentrada`    enum('0','1') NOT NULL DEFAULT '1',   -- '0' entrada / '1' saída
  `cclass`          varchar(8) DEFAULT NULL,              -- FK → tribClass
  `cfopnormal`      varchar(5) NOT NULL DEFAULT '5102',
  `cfopst`          varchar(5) NOT NULL DEFAULT '5405',
  `cfopservico`     varchar(5) NOT NULL DEFAULT '5949',
  `tipocompragov`   enum('X','1','2') NOT NULL DEFAULT 'X',
  `indpresenca`     enum('1','2','3','4','5','9') NOT NULL DEFAULT '9',
  `finalidade`      enum('C','R','I','T','F','U','D','G','V','O') NOT NULL DEFAULT 'C',
  `subtipo`         enum('N','T','B','G') NOT NULL DEFAULT 'N',
  `finoutros`       enum('N','P','A','C','D') NOT NULL DEFAULT 'N',
  `opercom`         enum('X','B','C','E') NOT NULL DEFAULT 'X',
  `movestoque`      bit(1) NOT NULL DEFAULT b'0',
  `intermunicipal`  bit(1) NOT NULL DEFAULT b'0',
  `interestatual`   bit(1) NOT NULL DEFAULT b'0',
  `internacional`   bit(1) NOT NULL DEFAULT b'0',
  `dadosadicionais` varchar(244) DEFAULT NULL,
  `descontoserv`    enum('I','C') NOT NULL DEFAULT 'I',
  `idemp`           int unsigned DEFAULT NULL,   -- FK → cnt (null = compartilhada)
  `ckdoacao`        bit(1) NOT NULL DEFAULT b'0',
  `ckintermedio`    bit(1) NOT NULL DEFAULT b'0',
  `cnpjintermedio`  varchar(20) DEFAULT NULL,
  `nomeintermedio`  varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`)
)
```

> `idemp = NULL` significa operação compartilhada por todas as empresas do tenant.  
> `VWEBOPERCOND` em `cfg` injeta cláusula SQL extra no filtro de operações (ver `CfgService`).

### `formapg` — Formas de Pagamento

```sql
CREATE TABLE `formapg` (
  `id`       smallint unsigned NOT NULL AUTO_INCREMENT,
  `nmforma`  varchar(60) NOT NULL,
  `operacao` varchar(1) NOT NULL,   -- 'I' entrada / 'D' débito
  `inativo`  bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`)
)
```

### `condpg` — Condições de Pagamento

```sql
CREATE TABLE `condpg` (
  `idcond`      smallint unsigned NOT NULL AUTO_INCREMENT,
  `nomecond`    varchar(80) NOT NULL,
  `parcelas`    smallint NOT NULL,
  `juros`       decimal(12,3) NOT NULL DEFAULT '0.000',
  `multa`       decimal(12,3) NOT NULL DEFAULT '0.000',
  `periodo`     varchar(1) NOT NULL DEFAULT 'M',   -- M=mensal, Q=quinzenal, etc.
  `entrada`     bit(1) NOT NULL DEFAULT b'0',
  `mesmodia`    bit(1) NOT NULL DEFAULT b'0',
  `diautil`     bit(1) NOT NULL DEFAULT b'1',
  `inativo`     bit(1) NOT NULL DEFAULT b'0',
  `diavenc`     tinyint DEFAULT NULL,
  `diasconfig`  varchar(120) DEFAULT NULL,
  PRIMARY KEY (`idcond`)
)
```

### `cfop` — Tabela de CFOPs

```sql
CREATE TABLE `cfop` (
  `cfop`  varchar(5) NOT NULL,
  `nome`  varchar(190) NOT NULL,
  PRIMARY KEY (`cfop`)
)
```

---

## 5. Produtos

### `prd` — Catálogo de Produtos

```sql
CREATE TABLE `prd` (
  `id`           int NOT NULL AUTO_INCREMENT,
  `codigo`       varchar(30) DEFAULT NULL,       -- código interno
  `ref`          varchar(30) DEFAULT NULL,       -- referência
  `refpar`       varchar(100) DEFAULT NULL,
  `barras`       varchar(30) DEFAULT NULL,       -- EAN-13
  `barrasdun`    varchar(30) DEFAULT NULL,
  `isbn`         varchar(30) DEFAULT NULL,
  `nome`         varchar(100) NOT NULL,
  `nomeredu`     varchar(29) DEFAULT NULL,       -- nome reduzido (PDV)
  `ncm`          varchar(8) NOT NULL DEFAULT '99999999',
  `cest`         varchar(7) DEFAULT NULL,
  `nbs`          varchar(15) DEFAULT NULL,
  `cclass`       varchar(8) NOT NULL DEFAULT '000001',  -- FK → tribClass
  `unidade`      varchar(3) NOT NULL DEFAULT 'UN',
  `idsubgrupo`   int DEFAULT NULL,               -- FK → prdsubgrupo
  `custo`        decimal(12,3) NOT NULL DEFAULT '0.000',
  `custoa`       decimal(12,3) NOT NULL DEFAULT '0.000', -- custo atacado
  `customedio`   decimal(12,6) NOT NULL DEFAULT '0.000000',
  `custoultimo`  decimal(12,6) NOT NULL DEFAULT '0.000000',
  `margem`       decimal(10,4) NOT NULL DEFAULT '0.0000',
  `margemb`      decimal(10,4) NOT NULL DEFAULT '0.0000',
  `margemmin`    decimal(10,4) NOT NULL DEFAULT '0.0000',
  `venda`        decimal(12,3) NOT NULL DEFAULT '0.000',  -- preço varejo
  `vendab`       decimal(12,3) NOT NULL DEFAULT '0.000',  -- preço atacado
  `saldoatu`     decimal(9,3) NOT NULL DEFAULT '0.000',
  `saldomin`     decimal(9,3) NOT NULL DEFAULT '0.000',
  `saldomax`     decimal(9,3) NOT NULL DEFAULT '0.000',
  `pesob`        decimal(12,4) NOT NULL DEFAULT '0.0000', -- peso bruto
  `pesol`        decimal(12,4) NOT NULL DEFAULT '0.0000', -- peso líquido
  `altura`       decimal(12,3) NOT NULL DEFAULT '0.000',
  `largura`      decimal(12,3) NOT NULL DEFAULT '0.000',
  `comprimento`  decimal(12,3) NOT NULL DEFAULT '0.000',
  `volume_m3`    decimal(12,4) NOT NULL DEFAULT '0.0000',
  `volume_cm3`   decimal(12,4) NOT NULL DEFAULT '0.0000',
  `tipoestoque`  enum('X','Z') NOT NULL DEFAULT 'X',
  `serial`       bit(1) NOT NULL DEFAULT b'0',
  `lote`         bit(1) NOT NULL DEFAULT b'0',
  `sku`          bit(1) NOT NULL DEFAULT b'0',
  `ativo`        bit(1) NOT NULL DEFAULT b'1',
  `controla`     bit(1) NOT NULL DEFAULT b'1',   -- controla estoque
  `balanca`      bit(1) NOT NULL DEFAULT b'0',
  `podevender`   bit(1) NOT NULL DEFAULT b'1',
  `podecomprar`  bit(1) NOT NULL DEFAULT b'1',
  `servico`      bit(1) NOT NULL DEFAULT b'0',
  `revenda`      bit(1) NOT NULL DEFAULT b'1',
  `consumo`      bit(1) NOT NULL DEFAULT b'0',
  `embalagem`    bit(1) NOT NULL DEFAULT b'0',
  `materia`      bit(1) NOT NULL DEFAULT b'0',   -- matéria prima
  `acabado`      bit(1) NOT NULL DEFAULT b'0',   -- produto acabado
  `manipulado`   bit(1) NOT NULL DEFAULT b'0',
  `prdcontrolado` bit(1) NOT NULL DEFAULT b'0',  -- sujeito a controle (farmácia)
  `usado`        bit(1) NOT NULL DEFAULT b'0',
  `receita`      mediumtext,
  `qtdvenda`     decimal(12,4) NOT NULL DEFAULT '0.0000',
  `unqtdvenda`   varchar(3) DEFAULT NULL,
  `qtdatacado`   decimal(12,4) NOT NULL DEFAULT '0.0000',
  `qtdreceita`   decimal(12,4) NOT NULL DEFAULT '0.0000',
  `origem`       varchar(2) NOT NULL DEFAULT '0',   -- FK → prdorigem
  `cenqipi`      varchar(10) DEFAULT NULL,
  `codselo`      varchar(20) DEFAULT NULL,
  `idfabricante` smallint unsigned DEFAULT '1',     -- FK → fabricante
  `dtcad`        timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dtultcp`      date DEFAULT NULL,
  `diasrepo`     smallint NOT NULL DEFAULT '0',
  `localiza`     varchar(60) DEFAULT NULL,
  `dthrvarejo`   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dthratacado`  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `diasvenc`     smallint NOT NULL DEFAULT '0',
  `codbene`      varchar(20) DEFAULT NULL,
  `idprdbase`    int DEFAULT NULL,                  -- FK → prd (produto base/pai)
  PRIMARY KEY (`id`)
)
```

**Índices importantes para busca:** `prd_idx_nome (nome)`, `prd_idx_barras (barras)`, `prd_idx_codref (codigo, ref)`.

### `impostos` — Regras de Tributação

```sql
CREATE TABLE `impostos` (
  `id`          int NOT NULL AUTO_INCREMENT,
  `descricao`   varchar(60) NOT NULL,
  `icmscst`     varchar(3) NOT NULL DEFAULT '41',    -- FK → prdicmscst
  `modbc`       enum('0','1','2','3') DEFAULT '3',   -- modalidade base de cálculo ICMS
  `icmsaliq`    decimal(8,4) NOT NULL DEFAULT '0.0000',
  `icmsredu`    decimal(8,4) NOT NULL DEFAULT '0.0000',
  `modbcst`     enum('0','1','2','3','4','5') DEFAULT '4',
  `icmsiva`     decimal(8,4) NOT NULL DEFAULT '0.0000',  -- IVA para cálculo ST
  `icmspdif`    decimal(8,4) NOT NULL DEFAULT '0.0000',  -- diferimento ICMS
  `icmsecf`     varchar(10) NOT NULL DEFAULT 'II',
  `piscst`      varchar(3) NOT NULL DEFAULT '08',    -- FK → prdpiscst
  `pisaliq`     decimal(8,4) NOT NULL DEFAULT '0.0000',
  `pisvalor`    decimal(9,4) NOT NULL DEFAULT '0.0000',
  `cofinscst`   varchar(3) NOT NULL DEFAULT '08',    -- FK → prdpiscst
  `cofinsaliq`  decimal(8,4) NOT NULL DEFAULT '0.0000',
  `cofinsvalor` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `ipicst`      varchar(3) NOT NULL DEFAULT '53',    -- FK → prdipicst
  `ipialiq`     decimal(8,4) NOT NULL DEFAULT '0.0000',
  `ipivalor`    decimal(8,4) NOT NULL DEFAULT '0.0000',
  `codLCP116`   varchar(10) DEFAULT NULL,
  `codTribMun`  varchar(30) DEFAULT NULL,
  `issaliq`     decimal(8,4) NOT NULL DEFAULT '0.0000',
  `obsnf`       varchar(244) DEFAULT NULL,
  PRIMARY KEY (`id`)
)
```

### `prdimposto` — Produto × Imposto × Operação (junção)

```sql
CREATE TABLE `prdimposto` (
  `idprd`       int NOT NULL,             -- FK → prd (CASCADE DELETE)
  `idoperacao`  smallint unsigned NOT NULL,-- FK → operacoes
  `idimposto`   int NOT NULL,             -- FK → impostos
  PRIMARY KEY (`idprd`, `idoperacao`)     -- nota: sem idimposto na PK
)
```

> Esta tabela resolve qual regra de imposto (`impostos`) um produto (`prd`) usa em cada operação (`operacoes`). A API usa `prdimposto` para calcular IPI e ST via `TaxCalculatorService`.

### `prdtab` — Tabelas de Preço

```sql
CREATE TABLE `prdtab` (
  `id`      smallint unsigned NOT NULL AUTO_INCREMENT,
  `nometab` varchar(60) NOT NULL,
  `perc`    decimal(10,4) NOT NULL DEFAULT '0.0000',   -- percentual varejo
  `percb`   decimal(10,4) NOT NULL DEFAULT '0.0000',   -- percentual atacado
  PRIMARY KEY (`id`)
)
```

### `prdtabvalor` — Preços por Tabela de Cliente

```sql
CREATE TABLE `prdtabvalor` (
  `idtab`   smallint unsigned NOT NULL,  -- FK → prdtab (CASCADE DELETE)
  `idprod`  int NOT NULL,               -- FK → prd (CASCADE DELETE)
  `valor`   decimal(12,3) NOT NULL DEFAULT '0.000',   -- preço varejo da tabela
  `valorb`  decimal(12,3) NOT NULL DEFAULT '0.000',   -- preço atacado da tabela
  PRIMARY KEY (`idtab`, `idprod`)
)
```

> Precedência de preço: `prdtabvalor.valor` (pelo `cnt.idtab` do cliente) → `prd.venda` (padrão).

### Tabelas satélite de `prd` (catálogo resumido)

| Tabela | PK | Descrição |
|---|---|---|
| `fabricante` | `id` | Fabricantes dos produtos |
| `prdaplic` | `idprd, ideqp` | Aplicações do produto (equipamentos) |
| `prdeqp` | `ideqp` | Equipamentos |
| `prdfor` | `idprd, idforn, seq` | Fornecedores do produto |
| `prdgrade` | `idgrade` | Grades de variação (cor/tamanho) |
| `prdgrupo` | `id` | Grupos de produto |
| `prdicmscst` | `cst` | CSTs do ICMS |
| `prdimg` | `id` | Imagens do produto |
| `prdinfo` | `idprd` | Descrição longa / SEO |
| `prdipicst` | `cst` | CSTs do IPI |
| `prdlote` | `idlote` | Lotes de produto |
| `prdmarkup` | `idprd, idemp` | Markup por empresa |
| `prdminmax` | `idprd, idemp` | Mín/Máx de estoque por empresa |
| `prdobs` | `idprd` | Observações do produto |
| `prdorigem` | `origem` | Origens (0=nacional, etc.) |
| `prdpacote` | `id` | Kits/pacotes |
| `prdpedref` | `idprd, idpedref` | Pedido de referência |
| `prdpiscst` | `cst` | CSTs do PIS/COFINS |
| `prdsaldo` | `idprd, idemp` | Saldo por empresa |
| `prdserial` | `id` | Números de série |
| `prdsku` | `sku` | SKUs de variação |
| `prdskusaldo` | `sku, idemp` | Saldo de SKU por empresa |
| `prdsubgrupo` | `id` | Subgrupos de produto |
| `prdvar` | `idvar` | Variações de grade |
| `ibpt` | `ncm, uf, ex, tipo` | Tabela IBPT de alíquotas |
| `impostoloja` | `idemp, idimposto` | Imposto por loja/empresa |
| `impostoretido` | `id` | Impostos retidos na fonte |
| `impostouf` | `idimposto, uf` | Alíquota ICMS por UF |

---

## 6. Estoque e Movimentos

| Tabela | PK | Descrição |
|---|---|---|
| `estoque` | `idmov, seq, idprd` | Saldo de estoque por movimento |
| `estoqueh010` | `idprd, idemp, dtref` | Histórico H010 (SPED) |
| `estoqueheader` | `id` | Cabeçalho de inventário |
| `estoquek200` | `id` | Bloco K200 (saldo) |
| `estoquek200Mes` | `id` | K200 mensal |
| `estoquek280` | `id` | Bloco K280 (correção) |
| `mov` | `idmov` | Cabeçalho do movimento de estoque |
| `movdi` | `idmov, seq` | Distribuição de imposto por item do mov |
| `movnfe` | `idmov` | NF-e vinculada ao movimento |
| `movparc` | `idmov, seq` | Parcelas financeiras do movimento |
| `movprd` | `idmov, seq` | Itens do movimento (produto) |
| `movprecohist` | `idmov, seq, tipo, idprd` | Histórico de preço no movimento |
| `movrr` | `idrr, idopen, idclose` | Operações de remessa/retorno |

---

## 7. Financeiro — Receber e Pagar

| Tabela | PK | Descrição |
|---|---|---|
| `ctareceber` | `idreceber` | Títulos a receber |
| `ctareceberlog` | `idlog` | Log de alterações em títulos |
| `ctapag` | `idpagar` | Contas a pagar |
| `ctapagclass` | `idpagar, idclass` | Classificações da conta a pagar |
| `ctapagfor` | `id` | Formas de pagamento de contas |
| `ctapagp` | `idpagar, seq` | Parcelas de contas a pagar |
| `ctapagrateio` | `idpagar, idcc` | Rateio por centro de custo |
| `findestino` | `id` | Destinos financeiros (contas bancárias) |
| `finespecie` | `id` | Espécies de lançamento |
| `finhist` | `id` | Históricos de lançamento |
| `finlancto` | `idlancto` | Lançamentos financeiros |
| `finmov` | `idmov` | Movimentos financeiros |

---

## 8. Caixa / PDV

| Tabela | PK | Descrição |
|---|---|---|
| `caixa` | `id` | Sessão de caixa |
| `caixaentrada` | `identracx, seq` | Entradas do caixa |
| `caixasaida` | `idsaidacx, seq` | Saídas do caixa |
| `caixafecha` | `idcaixa, seq` | Fechamento do caixa por forma |
| `caixacartao` | `identracx, seq, parc` | Cartões na entrada |
| `caixatroco` | `identracx, idcaixa` | Troco |
| `cheques` | `idcaixa, seq, banco, agencia, conta, nrocheque` | Cheques recebidos |
| `operadora` | `id` | Operadoras de cartão |
| `pdv` | `id` | Ponto de venda |
| `pdvcfg` | (composta) | Configurações do PDV |

---

## 9. Cobrança Bancária

| Tabela | PK | Descrição |
|---|---|---|
| `cobcfg` | `id` | Configuração de cobrança bancária |
| `cobcomando` | `id` | Comandos de remessa |
| `cobretorno` | `id` | Retornos bancários |
| `cobtitulo` | `id` | Títulos de cobrança |
| `cobtituloalt` | `id` | Alterações de título |
| `cobtituloaltlog` | `id` | Log de alterações |
| `cobtitulodespesa` | `id` | Despesas de cobrança |
| `cobtitulolog` | `id` | Log geral de títulos |

---

## 10. Documentos Fiscais

| Tabela | PK | Descrição |
|---|---|---|
| `docnfe` | `id` | NF-e emitidas |
| `docnfce` | `id` | NFC-e emitidas |
| `docnfse` | `id` | NFS-e emitidas |
| `doccte` | `id` | CT-e vinculados |
| `docmdfe` | `id` | MDF-e vinculados |
| `docevento` | `id` | Eventos de NF-e |
| `doceventocte` | `id` | Eventos de CT-e |
| `doceventomdfe` | `id` | Eventos de MDF-e |
| `docdist` | `id` | Distribuição DFe (NF-e de terceiros) |
| `doccfg` | `idcfg` | Configurações do emissor fiscal |
| `fat` | `idfat` | Faturamento (duplicatas / parcelas de NF) |

---

## 11. CT-e e MDF-e

| Tabela | PK | Descrição |
|---|---|---|
| `cte` | `idcte` | CT-e |
| `ctecarga` | `idcte, seq` | Carga do CT-e |
| `ctecfg` | `idemp` | Configuração do CT-e |
| `ctedocnfe` | `idcte, idnfe` | NF-e no CT-e |
| `ctepercur` | `idcte, seq` | Percurso do CT-e |
| `cteprest` | `idcte, seq` | Prestação de serviço CT-e |
| `mdfe` | `idmdfe` | MDF-e |
| `mdfecarga` | `idmdfe, seq` | Carga do MDF-e |
| `mdfecfg` | `idemp` | Configuração do MDF-e |
| `mdfecnt` | `idmdfe, idcnt` | Contatos do MDF-e |
| `mdfedescarga` | `idmdfe, seq` | Descargas do MDF-e |
| `mdfedocs` | `idmdfe, seq, iddoc` | Documentos do MDF-e |
| `mdfepercur` | `idmdfe, seq` | Percurso do MDF-e |
| `mdfereboque` | `idmdfe, seq` | Reboques do MDF-e |

---

## 12. Compras

| Tabela | PK | Descrição |
|---|---|---|
| `cpedido` | `id` | Pedido de compra |
| `cprod` | `idpedido, seq` | Itens do pedido de compra |
| `cordem` | `id` | Ordem de compra |

---

## 13. Ordem de Serviço (OS)

| Tabela | PK | Descrição |
|---|---|---|
| `os` | `id` | Ordem de Serviço |
| `ositem` | `idos, seq` | Itens da OS |
| `oskm` | `idos` | Quilometragem da OS |

---

## 14. PCP — Produção

| Tabela | PK | Descrição |
|---|---|---|
| `pcpcfg` | `idemp` | Configuração PCP |
| `pcpformu` | `id` | Fórmulas de produção |
| `pcpmitem` | `id` | Itens de fórmula |
| `pcpop` | `id` | Ordens de produção |
| `pcpopmp` | `idop, seq` | Matéria-prima da OP |
| `pcpprecohist` | `idop, seq` | Histórico de custo da OP |
| `pcpproc` | `id` | Processos de produção |
| `pcpvitem` | `id` | Itens produzidos |

---

## 15. CRM

| Tabela | PK | Descrição |
|---|---|---|
| `crmevento` | `id` | Eventos/interações com clientes |
| `crmlog` | `id` | Log do CRM |
| `crmreg` | `id` | Registros de CRM |
| `crmtpev` | `id` | Tipos de evento CRM |

---

## 16. Contratos

| Tabela | PK | Descrição |
|---|---|---|
| `contrato` | `idcontrato` | Contratos com clientes |
| `contratoobs` | `id` | Observações do contrato |
| `contratotipo` | `id` | Tipos de contrato |

---

## 17. Pagamento Fornecedor (TED/PIX)

| Tabela | PK | Descrição |
|---|---|---|
| `pagfor` | `id` | Lote de pagamento a fornecedor |
| `pagforcfg` | `id` | Configuração do pagamento |
| `pagforcnt` | `id` | Contatos do pagamento |
| `pagforcta` | `id` | Contas do pagamento |
| `pagforret` | `id` | Retorno do pagamento |
| `pagforretorno` | `id` | Arquivo de retorno |

---

## 18. RH e DP

| Tabela | PK | Descrição |
|---|---|---|
| `cntfunc` | `id` | Ficha do funcionário |
| `cntfunc_aci` | `id` | Acidentes de trabalho |
| `cntfunc_ates` | `id` | Atestados médicos |
| `cntfunc_cargo` | `id` | Cargos |
| `cntfunc_dep` | `id` | Dependentes |
| `cntfunc_exa` | `id` | Exames médicos |
| `cntfunc_ferias` | `id` | Férias |
| `cntfunc_hist` | `id` | Histórico funcional |
| `cntfunc_ocorr` | `id` | Ocorrências |
| `cntfunc_posto` | `id` | Postos de trabalho |
| `cntfunc_qhoras` | `id` | Quadro de horas |
| `cntfunc_turno` | `id` | Turnos |
| `diasu` | `iddiasu` | Dias úteis |
| `feriados` | `data, uf` | Feriados |
| `tb_docs` | `id` | Documentos RH |
| `tb_evento` | `id` | Eventos da folha |
| `tb_frases` | `id` | Frases padrão |
| `tb_justi` | `id` | Justificativas |
| `tb_treino` | `id` | Treinamentos |

---

## 19. SPED

| Tabela | PK | Descrição |
|---|---|---|
| `spedcfg` | `id` | Configuração SPED |
| `spedcontrib` | `id` | SPED Contribuições |
| `spedfiscal` | `id` | SPED Fiscal |

---

## 20. Tributação Auxiliar

| Tabela | PK | Descrição |
|---|---|---|
| `tribAliq` | `id` | Alíquotas Simples Nacional |
| `tribAnexos` | `id` | Anexos do Simples Nacional |
| `tribClass` | `classTrib` | Classe tributária (link prd/operacoes) |
| `tribCst` | `id` | CSTs de referência |
| `tribIndOper` | `id` | Indicador de operação tributária |
| `ibpt` | `ncm, uf, ex, tipo` | Tabela IBPT |
| `impostouf` | `idimposto, uf` | Alíquota ICMS por UF |

---

## 21. Configuração e Menu

### `cfg` — Parâmetros dinâmicos do tenant

```sql
CREATE TABLE `cfg` (
  `param`     varchar(60) NOT NULL,
  `descricao` varchar(250) DEFAULT NULL,
  `valor`     varchar(120) NOT NULL,
  PRIMARY KEY (`param`)
)
```

**Chaves relevantes para a API:**

| `param` | Descrição |
|---|---|
| `VERSAO_DB` | Versão do schema do tenant (ex: `2.38`) |
| `VWEBOPERCOND` | Cláusula SQL extra para filtro de operações (`OperacaoService`) |

### `log` — Auditoria de Operações

```sql
CREATE TABLE `log` (
  `idlog`    int unsigned NOT NULL AUTO_INCREMENT,
  `idusu`    int unsigned NOT NULL,  -- FK → usu
  `idsup`    int unsigned NOT NULL,  -- FK → usu (supervisor)
  `quando`   datetime NOT NULL,
  `operacao` varchar(280) DEFAULT NULL,
  `idemp`    int unsigned NOT NULL DEFAULT '1',  -- FK → cnt
  PRIMARY KEY (`idlog`)
)
```

### Demais tabelas de configuração (catálogo)

| Tabela | PK | Descrição |
|---|---|---|
| `mnu` | `id` | Itens de menu |
| `mnuagenda` | `id` | Agendamentos de menu |
| `mnucampos` | `id` | Campos de grid configuráveis |
| `mnudash` | `id` | Dashboard do menu |
| `mnugrid` | `id` | Configuração de grids |
| `mnuradios` | `id` | Rádios de menu |
| `mnurel` | `id` | Relatórios |
| `mnurelbin` | `id` | Binários de relatório |
| `mnurelconst` | `id` | Constantes de relatório |
| `mnurelparam` | `id` | Parâmetros de relatório |
| `mnurelradios` | `id` | Rádios de relatório |
| `monitorcfg` | `id` | Configuração de monitoramento |
| `formgrid` | `id` | Grids de formulário |
| `mailcfg` | `idmail` | Configuração de e-mail SMTP |
| `empses` | `idemp` | Sessão da empresa |
| `centrocusto` | `idcc` | Centros de custo |
| `comi` | `id` | Tabelas de comissão |
| `comiforma` | `id` | Formas de comissão |
| `comigrupo` | `id` | Grupos de comissão |
| `comimargem` | `id` | Margens de comissão |

---

## 22. Integrações API

| Tabela | PK | Descrição |
|---|---|---|
| `api_3b3` | `idusu, idemp` | Tokens OAuth para API B3 |
| `api_frenet` | `idemp` | Credenciais Frenet (frete) |
| `api_mlb` | `idusu, idemp` | Tokens OAuth Mercado Livre |

---

## 23. Dashboard Widgets

| Tabela | PK | Descrição |
|---|---|---|
| `wg_angulargauge` | `id` | Widget gauge angular |
| `wg_column2d` | `id` | Widget coluna 2D |
| `wg_livre` | `id` | Widget livre |
| `wg_msline` | `id` | Widget linha multi-série |
| `wg_pie2d` | `id` | Widget pizza 2D |
| `wg_symbol` | `id` | Widget símbolo |
| `wg_ticker` | `id` | Widget ticker |
| `wg_urls` | `id` | Widget URLs |

---

## 24. Logística

| Tabela | PK | Descrição |
|---|---|---|
| `romaneio` | `id` | Romaneio de entrega |
| `romaneioitem` | `idromaneio, seq` | Itens do romaneio |
| `romaneiopost` | `id` | Postagens do romaneio |
| `romaneiotot` | `idromaneio, idusu` | Totais por usuário |
| `rota` | `id` | Rotas de entrega |
| `cntrota` | `idcnt, idrota` | Rota do cliente |

---

## Funções e Stored Procedures

| Nome | Tipo | Descrição |
|---|---|---|
| `format_abrev` | FUNCTION | Abrevia nome para até 60 chars |
| `format_docfed` | FUNCTION | Formata CPF/CNPJ |
| `func_cobstat` | FUNCTION | Status de cobrança |
| `func_dthr` | FUNCTION | Formata data/hora |
| `func_getnfe` | FUNCTION | Retorna chave NF-e de uma venda |
| `func_getnfse` | FUNCTION | Retorna chave NFS-e |
| `func_movto_prd` | FUNCTION | Tipo de movimento do produto |
| `func_receb_situ` | FUNCTION | Situação de recebimento |
| `func_saldodia` | FUNCTION | Saldo estoque no dia |
| `func_saldodiasku` | FUNCTION | Saldo estoque SKU no dia |
| `func_tipomov` | FUNCTION | Tipo do movimento |
| `func_valoricms` | FUNCTION | Calcula valor ICMS |
| `func_venda_compo` | FUNCTION | Composição da venda |
| `func_venda_impostoprd` | FUNCTION | Imposto do produto na venda |
| `func_venda_operacaoprd` | FUNCTION | Operação fiscal do produto |
| `raise` | PROCEDURE | Lança sinal de erro SQL |

---

## Diagrama de Relacionamentos — Módulo de Vendas (b3vendas)

```
usu ──── idvend ──→ cnt (vendedor)
                     │
cnt (cliente) ←── idcli │ idvend ──→ venda ←── venda.idemp ──→ cnt (empresa)
cnt.idtab ──→ prdtab             │
                                 ├── vendaitem ──→ prd
                                 │                 └── prdimposto ──→ impostos
                                 │                 └── prdtabvalor ←── prdtab
                                 │
                                 └── vendacaixa ──→ formapg
                                                └── condpg
                                                └── caixa

operacoes ←── venda.idoper
operacoes ←── prdimposto.idoperacao
cfg ──── VWEBOPERCOND ──→ OperacaoService (filtro SQL extra)
cfg ──── VERSAO_DB ──→ verificado no login (MIN_TENANT_DB)
```

---

## Contagem de Objetos

| Tipo | Quantidade |
|---|---|
| Tabelas | 253 |
| Funções SQL | 13 |
| Stored Procedures | 1 |
| Engine | InnoDB (MySQL 8.0) |
| Charset | utf8mb3 |
| Versão do Schema | 2.38 |
