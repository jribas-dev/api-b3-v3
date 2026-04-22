-- --------------------------------------------------------
-- Servidor:                     db01.b3infra.com.br
-- Versão do servidor:           8.0.45-0ubuntu0.22.04.1 - (Ubuntu)
-- OS do Servidor:               Linux
-- HeidiSQL Versão:              12.4.0.6659
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Copiando estrutura para tabela b3erp.dsv.api_3b3
CREATE TABLE IF NOT EXISTS `api_3b3` (
  `idusu` int unsigned NOT NULL,
  `idemp` int unsigned NOT NULL,
  `clientid` varchar(255) NOT NULL,
  `secretkey` varchar(255) NOT NULL,
  `authcode` varchar(255) DEFAULT NULL,
  `accesstoken` varchar(255) DEFAULT NULL,
  `refreshtoken` varchar(255) DEFAULT NULL,
  `expiredate` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`idusu`,`idemp`),
  KEY `fk_api_3b3_emp_idx` (`idemp`),
  CONSTRAINT `fk_api_3b3_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_api_3b3_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.api_frenet
CREATE TABLE IF NOT EXISTS `api_frenet` (
  `idemp` int unsigned NOT NULL,
  `chave` varchar(255) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  PRIMARY KEY (`idemp`),
  CONSTRAINT `fk_apifrenet_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.api_mlb
CREATE TABLE IF NOT EXISTS `api_mlb` (
  `idusu` int unsigned NOT NULL,
  `idemp` int unsigned NOT NULL,
  `authcode` varchar(255) DEFAULT NULL,
  `userid` varchar(255) DEFAULT NULL,
  `accesstoken` varchar(255) DEFAULT NULL,
  `refreshtoken` varchar(255) DEFAULT NULL,
  `expiredate` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`idusu`,`idemp`),
  KEY `fk_api_mlb_emp_idx` (`idemp`),
  CONSTRAINT `fk_api_mlb_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_api_mlb_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.caixa
CREATE TABLE IF NOT EXISTS `caixa` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idusu` int unsigned NOT NULL,
  `vlrabertura` decimal(12,3) NOT NULL DEFAULT '0.000',
  `fechado` bit(1) NOT NULL DEFAULT b'0',
  `idpdv` smallint unsigned DEFAULT NULL,
  `idemp` int unsigned NOT NULL,
  `dataini` datetime DEFAULT CURRENT_TIMESTAMP,
  `datafim` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_caixa_usu1_idx` (`idusu`),
  KEY `fk_caixa_pdv1_idx` (`idpdv`),
  KEY `fk_caixa_cntemp_idx` (`idemp`),
  CONSTRAINT `fk_caixa_cntemp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixa_pdv1` FOREIGN KEY (`idpdv`) REFERENCES `pdv` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixa_usu1` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.caixacartao
CREATE TABLE IF NOT EXISTS `caixacartao` (
  `identracx` int unsigned NOT NULL,
  `seq` tinyint unsigned NOT NULL,
  `parc` tinyint unsigned NOT NULL,
  `operacao` varchar(1) NOT NULL,
  `idoperadora` smallint unsigned NOT NULL,
  `dtemi` date NOT NULL,
  `valortot` decimal(12,3) NOT NULL DEFAULT '0.000',
  `dtsaldo` date NOT NULL,
  `custofin` decimal(10,3) NOT NULL DEFAULT '0.000',
  `valorliq` decimal(12,3) NOT NULL DEFAULT '0.000',
  `idmov` int unsigned DEFAULT NULL,
  `nsu` varchar(18) DEFAULT NULL,
  `autoriza` varchar(12) DEFAULT NULL,
  PRIMARY KEY (`identracx`,`seq`,`parc`),
  KEY `fk_caixacartao_operadora_idx` (`idoperadora`),
  KEY `fk_caixacartao_finmov_idx` (`idmov`),
  CONSTRAINT `fk_caixacartao_caixaentrada` FOREIGN KEY (`identracx`, `seq`) REFERENCES `caixaentrada` (`identracx`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_caixacartao_finmov` FOREIGN KEY (`idmov`) REFERENCES `finmov` (`idmov`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixacartao_operadora` FOREIGN KEY (`idoperadora`) REFERENCES `operadora` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.caixaentrada
CREATE TABLE IF NOT EXISTS `caixaentrada` (
  `identracx` int unsigned NOT NULL,
  `seq` tinyint unsigned NOT NULL,
  `idcaixa` int unsigned NOT NULL,
  `idforma` smallint unsigned NOT NULL,
  `valor` decimal(12,2) NOT NULL,
  `operacao` varchar(1) NOT NULL DEFAULT 'I',
  `baixado` bit(1) NOT NULL DEFAULT b'1',
  `obs` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`identracx`,`seq`),
  KEY `fk_caixaentrada_caixa1_idx` (`idcaixa`),
  KEY `fk_caixaentrada_formapg1_idx` (`idforma`),
  CONSTRAINT `fk_caixaentrada_caixa1` FOREIGN KEY (`idcaixa`) REFERENCES `caixa` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixaentrada_formapg1` FOREIGN KEY (`idforma`) REFERENCES `formapg` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.caixafecha
CREATE TABLE IF NOT EXISTS `caixafecha` (
  `idcaixa` int unsigned NOT NULL,
  `seq` tinyint unsigned NOT NULL,
  `idforma` smallint unsigned NOT NULL,
  `valor` decimal(12,2) NOT NULL,
  `operacao` varchar(1) NOT NULL DEFAULT 'I',
  `idusu` int unsigned DEFAULT NULL,
  `obs` varchar(255) DEFAULT NULL,
  `valorfinal` decimal(12,2) DEFAULT '0.00',
  `valorcalc` decimal(12,2) DEFAULT '0.00',
  `diferenca` decimal(12,2) DEFAULT '0.00',
  `baixado` bit(1) NOT NULL DEFAULT b'0',
  `idmov` int unsigned DEFAULT NULL,
  `iddest` smallint unsigned DEFAULT NULL,
  `idespecie` smallint unsigned DEFAULT NULL,
  `idhist` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`idcaixa`,`seq`),
  KEY `fk_caixafecha_caixa1_idx` (`idcaixa`),
  KEY `fk_caixafecha_formapg1_idx` (`idforma`),
  KEY `fk_caixafecha_finmov_idx` (`idmov`),
  KEY `fk_caixafecha_findest_idx` (`iddest`),
  KEY `fk_caixafecha_finespecie_idx` (`idespecie`),
  KEY `fk_caixafecha_finhist_idx` (`idhist`),
  CONSTRAINT `fk_caixafecha_caixa1` FOREIGN KEY (`idcaixa`) REFERENCES `caixa` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixafecha_findest` FOREIGN KEY (`iddest`) REFERENCES `findestino` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixafecha_finespecie` FOREIGN KEY (`idespecie`) REFERENCES `finespecie` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixafecha_finhist` FOREIGN KEY (`idhist`) REFERENCES `finhist` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixafecha_finmov` FOREIGN KEY (`idmov`) REFERENCES `finmov` (`idmov`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixafecha_formapg1` FOREIGN KEY (`idforma`) REFERENCES `formapg` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.caixasaida
CREATE TABLE IF NOT EXISTS `caixasaida` (
  `idsaidacx` int unsigned NOT NULL,
  `seq` tinyint unsigned NOT NULL,
  `idcaixa` int unsigned NOT NULL,
  `idforma` smallint unsigned NOT NULL,
  `valor` decimal(12,2) NOT NULL,
  `operacao` varchar(1) NOT NULL DEFAULT 'I',
  `baixado` bit(1) NOT NULL DEFAULT b'1',
  `obs` varchar(255) DEFAULT NULL,
  `idmov` int unsigned DEFAULT NULL,
  `iddest` smallint unsigned DEFAULT NULL,
  `idespecie` smallint unsigned DEFAULT NULL,
  `idhist` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`idsaidacx`,`seq`),
  KEY `fk_caixasaida_caixa1_idx` (`idcaixa`),
  KEY `fk_caixasaida_formapg1_idx` (`idforma`),
  KEY `fk_caixasaida_finmov_idx` (`idmov`),
  KEY `fk_caixasaida_findestino_idx` (`iddest`),
  KEY `fk_caixasaida_finespecie_idx` (`idespecie`),
  KEY `fk_caixasaida_finhist_idx` (`idhist`),
  CONSTRAINT `fk_caixasaida_caixa1` FOREIGN KEY (`idcaixa`) REFERENCES `caixa` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixasaida_findestino` FOREIGN KEY (`iddest`) REFERENCES `findestino` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixasaida_finespecie` FOREIGN KEY (`idespecie`) REFERENCES `finespecie` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixasaida_finhist` FOREIGN KEY (`idhist`) REFERENCES `finhist` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixasaida_finmov` FOREIGN KEY (`idmov`) REFERENCES `finmov` (`idmov`) ON UPDATE CASCADE,
  CONSTRAINT `fk_caixasaida_formapg1` FOREIGN KEY (`idforma`) REFERENCES `formapg` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.caixatroco
CREATE TABLE IF NOT EXISTS `caixatroco` (
  `identracx` int unsigned NOT NULL,
  `idcaixa` int unsigned NOT NULL,
  `troco` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`identracx`,`idcaixa`),
  KEY `fk_caixatroco_caixa_idx` (`idcaixa`),
  CONSTRAINT `fk_caixatroco_caixa` FOREIGN KEY (`idcaixa`) REFERENCES `caixa` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_caixatroco_caixaentrada` FOREIGN KEY (`identracx`) REFERENCES `caixaentrada` (`identracx`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.centrocusto
CREATE TABLE IF NOT EXISTS `centrocusto` (
  `idcc` smallint unsigned NOT NULL AUTO_INCREMENT,
  `centrocusto` varchar(60) NOT NULL,
  `produtivo` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idcc`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cfg
CREATE TABLE IF NOT EXISTS `cfg` (
  `param` varchar(60) NOT NULL,
  `descricao` varchar(250) DEFAULT NULL,
  `valor` varchar(120) NOT NULL,
  PRIMARY KEY (`param`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cfop
CREATE TABLE IF NOT EXISTS `cfop` (
  `cfop` varchar(5) NOT NULL,
  `nome` varchar(190) NOT NULL,
  PRIMARY KEY (`cfop`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cheques
CREATE TABLE IF NOT EXISTS `cheques` (
  `idcaixa` int unsigned NOT NULL,
  `seq` tinyint unsigned NOT NULL,
  `banco` varchar(20) NOT NULL,
  `agencia` varchar(20) NOT NULL,
  `conta` varchar(30) NOT NULL,
  `nrocheque` varchar(40) NOT NULL,
  `valor` decimal(12,2) NOT NULL,
  `data` date NOT NULL,
  `depositado` bit(1) DEFAULT b'0',
  `compensado` bit(1) DEFAULT b'0',
  `devolucao1` bit(1) DEFAULT b'0',
  `devolucao2` bit(1) DEFAULT b'0',
  `iddest` smallint unsigned DEFAULT NULL,
  `idmov` int unsigned DEFAULT NULL,
  `baixado` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idcaixa`,`seq`,`banco`,`agencia`,`conta`,`nrocheque`),
  KEY `fk_cheques_findest_idx` (`iddest`),
  KEY `fk_cheques_finmov_idx` (`idmov`),
  CONSTRAINT `fk_cheques_caixafecha` FOREIGN KEY (`idcaixa`, `seq`) REFERENCES `caixafecha` (`idcaixa`, `seq`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cheques_findest` FOREIGN KEY (`iddest`) REFERENCES `findestino` (`id`),
  CONSTRAINT `fk_cheques_finmov` FOREIGN KEY (`idmov`) REFERENCES `finmov` (`idmov`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cnt
CREATE TABLE IF NOT EXISTS `cnt` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `tipopessoa` enum('F','J','E','R') NOT NULL DEFAULT 'F',
  `tipoestatal` enum('X','1','2','3','4') NOT NULL DEFAULT 'X',
  `razao` varchar(120) NOT NULL,
  `fantasia` varchar(120) DEFAULT NULL,
  `docfed` varchar(30) DEFAULT NULL,
  `docest` varchar(30) DEFAULT NULL,
  `docestemi` date DEFAULT NULL,
  `docestorgao` varchar(10) DEFAULT NULL,
  `im` varchar(30) DEFAULT NULL,
  `email` varchar(120) DEFAULT NULL,
  `site` varchar(120) DEFAULT NULL,
  `imagem` mediumblob,
  `dtnascto` date DEFAULT NULL,
  `sexo` enum('F','M') DEFAULT NULL,
  `nomepai` varchar(120) DEFAULT NULL,
  `nomemae` varchar(120) DEFAULT NULL,
  `estadocivil` enum('S','C','D','A','V','E') DEFAULT NULL,
  `nomeconj` varchar(120) DEFAULT NULL,
  `limite` decimal(18,2) DEFAULT NULL,
  `prazopagto` smallint DEFAULT NULL,
  `taxafrete` decimal(12,2) DEFAULT NULL,
  `taxacob` decimal(12,2) DEFAULT NULL,
  `ativo` bit(1) DEFAULT b'1',
  `restricao` bit(1) DEFAULT b'0',
  `dthradd` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `cep` varchar(12) DEFAULT NULL,
  `endereco` varchar(120) DEFAULT NULL,
  `nroend` varchar(30) DEFAULT NULL,
  `bairro` varchar(120) DEFAULT NULL,
  `compl` varchar(120) DEFAULT NULL,
  `referencia` varchar(120) DEFAULT NULL,
  `cidade` varchar(120) DEFAULT NULL,
  `uf` varchar(10) DEFAULT NULL,
  `fone` varchar(20) DEFAULT NULL,
  `fone2` varchar(20) DEFAULT NULL,
  `cel` varchar(20) DEFAULT NULL,
  `fax` varchar(20) DEFAULT NULL,
  `obs` varchar(400) DEFAULT NULL,
  `codpais` smallint DEFAULT '1058',
  `respnome` varchar(120) DEFAULT NULL,
  `respdocfed` varchar(30) DEFAULT NULL,
  `docestrangeiro` varchar(30) DEFAULT NULL,
  `codmunicipio` varchar(15) DEFAULT NULL,
  `codmunservico` varchar(15) DEFAULT NULL,
  `emailorc` varchar(240) DEFAULT NULL,
  `emailnfe` varchar(240) DEFAULT NULL,
  `emailcob` varchar(240) DEFAULT NULL,
  `idtab` smallint unsigned DEFAULT NULL,
  `idgrupo` smallint DEFAULT NULL,
  `idcomi` smallint unsigned DEFAULT NULL,
  `idforma` smallint unsigned DEFAULT NULL,
  `idcond` smallint unsigned DEFAULT NULL,
  `idoper` smallint unsigned DEFAULT NULL,
  `obsvenda` varchar(400) DEFAULT NULL,
  `idvende` int unsigned DEFAULT NULL,
  `inforastro` bit(1) DEFAULT b'0',
  `negativado` bit(1) DEFAULT b'0',
  `txdesconto` decimal(12,2) DEFAULT NULL,
  `diacorrido` bit(1) DEFAULT NULL,
  `reduestatal` decimal(12,3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_cnt_prdtab_idx` (`idtab`),
  KEY `fk_cnt_cntgrupo_idx` (`idgrupo`),
  KEY `fk_cnt_comi_idx` (`idcomi`),
  KEY `fk_cnt_formapg_idx` (`idforma`),
  KEY `fk_cnt_condpg_idx` (`idcond`),
  KEY `fk_cnt_cntvende_idx` (`idvende`),
  KEY `fk_cnt_operacoes_idx` (`idoper`),
  CONSTRAINT `fk_cnt_cntgrupo` FOREIGN KEY (`idgrupo`) REFERENCES `cntgrupo` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cnt_cntvende` FOREIGN KEY (`idvende`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cnt_comi` FOREIGN KEY (`idcomi`) REFERENCES `comi` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cnt_condpg` FOREIGN KEY (`idcond`) REFERENCES `condpg` (`idcond`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cnt_formapg` FOREIGN KEY (`idforma`) REFERENCES `formapg` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cnt_operacoes` FOREIGN KEY (`idoper`) REFERENCES `operacoes` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_cnt_prdtab` FOREIGN KEY (`idtab`) REFERENCES `prdtab` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=331 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntativolog
CREATE TABLE IF NOT EXISTS `cntativolog` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `ativo` bit(1) NOT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  `dthrlog` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_cntativolog_cnt_idx` (`idcnt`),
  CONSTRAINT `fk_cntativolog_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntcc
CREATE TABLE IF NOT EXISTS `cntcc` (
  `idcnt` int unsigned NOT NULL,
  `idcc` smallint unsigned NOT NULL,
  `classe` enum('C','D','I') NOT NULL DEFAULT 'C',
  PRIMARY KEY (`idcnt`),
  KEY `fk_cntcc_centrocusto_idx` (`idcc`),
  CONSTRAINT `fk_cntcc_centrocusto` FOREIGN KEY (`idcc`) REFERENCES `centrocusto` (`idcc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cntcc_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntclass
CREATE TABLE IF NOT EXISTS `cntclass` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descr` varchar(80) NOT NULL,
  `ativo` bit(1) NOT NULL DEFAULT b'0',
  `passivo` bit(1) NOT NULL DEFAULT b'0',
  `emitente` bit(1) NOT NULL DEFAULT b'0',
  `funcionario` bit(1) NOT NULL DEFAULT b'0',
  `comissionado` bit(1) NOT NULL DEFAULT b'0',
  `logistica` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntclasses
CREATE TABLE IF NOT EXISTS `cntclasses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `idclass` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_cntclasses_cntclass1_idx` (`idclass`),
  KEY `fk_cntclasses_cnt1_idx` (`idcnt`),
  CONSTRAINT `fk_cntclasses_cnt1` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cntclasses_cntclass1` FOREIGN KEY (`idclass`) REFERENCES `cntclass` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=260 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntcli_setor
CREATE TABLE IF NOT EXISTS `cntcli_setor` (
  `idsetor` int unsigned NOT NULL AUTO_INCREMENT,
  `idcli` int unsigned NOT NULL,
  `setor` varchar(60) NOT NULL,
  PRIMARY KEY (`idsetor`),
  KEY `fk_cntcli_setor_cnt_idx` (`idcli`),
  CONSTRAINT `fk_cntcli_setor_cnt` FOREIGN KEY (`idcli`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntcnae
CREATE TABLE IF NOT EXISTS `cntcnae` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `codcnae` varchar(20) NOT NULL,
  `descr` varchar(200) NOT NULL,
  `obrigaie` tinyint NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1305 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntcnaes
CREATE TABLE IF NOT EXISTS `cntcnaes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `idcnae` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_cntcnaes_cntcnae1_idx` (`idcnae`),
  KEY `fk_cntcnaes_cnt1_idx` (`idcnt`),
  CONSTRAINT `fk_cntcnaes_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cntcnaes_cntcnae` FOREIGN KEY (`idcnae`) REFERENCES `cntcnae` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntconta
CREATE TABLE IF NOT EXISTS `cntconta` (
  `idconta` int unsigned NOT NULL AUTO_INCREMENT,
  `idvenda` int unsigned DEFAULT NULL,
  `idforma` smallint unsigned DEFAULT NULL,
  `seq` tinyint unsigned DEFAULT NULL,
  `idcaixa` int unsigned DEFAULT NULL,
  `idcnt` int unsigned NOT NULL,
  `idemp` int unsigned NOT NULL,
  `dthr` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `obs` varchar(255) DEFAULT NULL,
  `dc` varchar(1) NOT NULL DEFAULT 'D',
  `valor` decimal(12,2) NOT NULL DEFAULT '0.00',
  `baixado` bit(1) DEFAULT b'0',
  `como` varchar(1) DEFAULT NULL,
  `identracx` int unsigned DEFAULT NULL,
  `idvendagerada` int unsigned DEFAULT NULL,
  PRIMARY KEY (`idconta`),
  KEY `fk_cntconta_cntcli_idx` (`idcnt`),
  KEY `fk_cntconta_cntemp_idx` (`idemp`),
  KEY `fk_cntconta_caixaentrada_idx` (`identracx`),
  KEY `fk_cntconta_venda_idx` (`idvendagerada`),
  KEY `fk_cntconta_vendacaixa_idx` (`idvenda`,`idforma`,`seq`),
  KEY `fk_cntconta_caixa_idx` (`idcaixa`),
  CONSTRAINT `fk_cntconta_caixa` FOREIGN KEY (`idcaixa`) REFERENCES `caixa` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cntconta_caixaentrada` FOREIGN KEY (`identracx`) REFERENCES `caixaentrada` (`identracx`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cntconta_cntcli` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cntconta_cntemp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cntconta_venda` FOREIGN KEY (`idvendagerada`) REFERENCES `venda` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cntconta_vendacaixa` FOREIGN KEY (`idvenda`, `idforma`, `seq`) REFERENCES `vendacaixa` (`idvenda`, `idforma`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntcontabaixa
CREATE TABLE IF NOT EXISTS `cntcontabaixa` (
  `idconta` int unsigned NOT NULL,
  `idvenda` int unsigned NOT NULL,
  PRIMARY KEY (`idconta`,`idvenda`),
  KEY `fk_cntcontabaixa_venda_idx` (`idvenda`),
  CONSTRAINT `fk_cntcontabaixa_conta` FOREIGN KEY (`idconta`) REFERENCES `cntconta` (`idconta`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cntcontabaixa_venda` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntcontato
CREATE TABLE IF NOT EXISTS `cntcontato` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `nome` varchar(120) DEFAULT NULL,
  `cargo` varchar(60) DEFAULT NULL,
  `ddd` varchar(8) DEFAULT NULL,
  `fone` varchar(20) DEFAULT NULL,
  `email` varchar(120) DEFAULT NULL,
  `dtnascto` date DEFAULT NULL,
  `obs` varchar(255) DEFAULT NULL,
  `dthradd` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_cntcontato_cnt_idx` (`idcnt`),
  CONSTRAINT `fk_cntcontato_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntemp_setor
CREATE TABLE IF NOT EXISTS `cntemp_setor` (
  `idsetor` smallint unsigned NOT NULL AUTO_INCREMENT,
  `setor` varchar(80) NOT NULL,
  `idemp` int unsigned NOT NULL,
  `idcc` smallint unsigned DEFAULT NULL,
  `lancaos` bit(1) NOT NULL DEFAULT b'0',
  `lancafin` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`idsetor`),
  KEY `fk_cntemp_setor_cnt_idx` (`idemp`),
  KEY `fk_cntemp_setor_cc_idx` (`idcc`),
  CONSTRAINT `fk_cntemp_setor_cc` FOREIGN KEY (`idcc`) REFERENCES `centrocusto` (`idcc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cntemp_setor_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntend
CREATE TABLE IF NOT EXISTS `cntend` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `descricao` varchar(60) DEFAULT NULL,
  `padrao` bit(1) NOT NULL DEFAULT b'0',
  `cep` varchar(12) DEFAULT NULL,
  `endereco` varchar(120) DEFAULT NULL,
  `nroend` varchar(30) DEFAULT NULL,
  `bairro` varchar(120) DEFAULT NULL,
  `compl` varchar(120) DEFAULT NULL,
  `referencia` varchar(120) DEFAULT NULL,
  `codibge` varchar(20) DEFAULT NULL,
  `cidade` varchar(120) DEFAULT NULL,
  `uf` varchar(10) DEFAULT NULL,
  `codpais` varchar(8) DEFAULT NULL,
  `pais` varchar(60) DEFAULT NULL,
  `obs` varchar(255) DEFAULT NULL,
  `dthradd` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_cntend_cnt1_idx` (`idcnt`),
  CONSTRAINT `fk_cntend_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntequipe
CREATE TABLE IF NOT EXISTS `cntequipe` (
  `idcntlider` int unsigned NOT NULL,
  `idcntliderado` int unsigned NOT NULL,
  PRIMARY KEY (`idcntlider`,`idcntliderado`),
  KEY `fk_cntequipe_cnt_idx` (`idcntliderado`),
  CONSTRAINT `fk_cntequipe_cnt` FOREIGN KEY (`idcntliderado`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cntequipe_cnt_super` FOREIGN KEY (`idcntlider`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntfunc
CREATE TABLE IF NOT EXISTS `cntfunc` (
  `idcnt` int unsigned NOT NULL,
  `idemp` int unsigned NOT NULL,
  `idsetor` smallint unsigned DEFAULT NULL,
  `nomeponto` varchar(30) DEFAULT NULL,
  `nomeredu` varchar(20) DEFAULT NULL,
  `naturalidade` varchar(50) DEFAULT NULL,
  `cnh` varchar(30) DEFAULT NULL,
  `nropis` varchar(30) DEFAULT NULL,
  `ctps` varchar(30) DEFAULT NULL,
  `serie` varchar(15) DEFAULT NULL,
  `reservista` varchar(30) DEFAULT NULL,
  `grauescola` varchar(30) DEFAULT NULL,
  `idcargo` int unsigned DEFAULT NULL,
  `funcao` varchar(50) DEFAULT NULL,
  `salariobase` decimal(12,2) DEFAULT '0.00',
  `situadi` enum('A','D','X') NOT NULL DEFAULT 'X',
  `dtadi` date DEFAULT NULL,
  `dtexamead` date DEFAULT NULL,
  `dtdemi` date DEFAULT NULL,
  `dtexamede` date DEFAULT NULL,
  `convenio` enum('F','I','X') NOT NULL DEFAULT 'X',
  `transporte` bit(1) NOT NULL DEFAULT b'0',
  `terceiro` bit(1) NOT NULL DEFAULT b'0',
  `idposto` int unsigned DEFAULT NULL,
  `idturno` int unsigned DEFAULT NULL,
  `situacao` varchar(1) NOT NULL DEFAULT 'X',
  `tpafasta` enum('1','2','3','4','X') NOT NULL DEFAULT 'X',
  `iniafasta` date DEFAULT NULL,
  `fimafasta` date DEFAULT NULL,
  PRIMARY KEY (`idcnt`,`idemp`),
  KEY `fk_cntfunc_emp_idx` (`idemp`),
  KEY `fk_cntfunc_empsetor_idx` (`idsetor`),
  KEY `fk_cntfunc_cargo_idx` (`idcargo`),
  KEY `fk_cntfunc_posto_idx` (`idposto`),
  KEY `fk_cntfunc_turno_idx` (`idturno`),
  CONSTRAINT `fk_cntfunc_cargo` FOREIGN KEY (`idcargo`) REFERENCES `cntfunc_cargo` (`idcargo`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cntfunc_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cntfunc_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cntfunc_empsetor` FOREIGN KEY (`idsetor`) REFERENCES `cntemp_setor` (`idsetor`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cntfunc_posto` FOREIGN KEY (`idposto`) REFERENCES `cntfunc_posto` (`idposto`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cntfunc_turno` FOREIGN KEY (`idturno`) REFERENCES `cntfunc_turno` (`idturno`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntfunc_aci
CREATE TABLE IF NOT EXISTS `cntfunc_aci` (
  `idemp` int unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `dtocorr` date NOT NULL,
  `nrocat` varchar(30) DEFAULT NULL,
  `texto` mediumtext,
  PRIMARY KEY (`idemp`,`idcnt`,`dtocorr`),
  CONSTRAINT `fk_cntfunc_aci_func` FOREIGN KEY (`idemp`, `idcnt`) REFERENCES `cntfunc` (`idemp`, `idcnt`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntfunc_ates
CREATE TABLE IF NOT EXISTS `cntfunc_ates` (
  `idemp` int unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `dtocorr` date NOT NULL,
  `diasafasta` smallint DEFAULT NULL,
  `localemi` varchar(60) DEFAULT NULL,
  `medico` varchar(60) DEFAULT NULL,
  `crm` varchar(20) DEFAULT NULL,
  `cid` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`idemp`,`idcnt`,`dtocorr`),
  CONSTRAINT `fk_cntfunc_ates_func` FOREIGN KEY (`idemp`, `idcnt`) REFERENCES `cntfunc` (`idemp`, `idcnt`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntfunc_cargo
CREATE TABLE IF NOT EXISTS `cntfunc_cargo` (
  `idcargo` int unsigned NOT NULL AUTO_INCREMENT,
  `cargo` varchar(60) NOT NULL,
  `cbo` varchar(20) DEFAULT NULL,
  `ocusin` enum('O','S') NOT NULL DEFAULT 'O',
  PRIMARY KEY (`idcargo`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntfunc_dep
CREATE TABLE IF NOT EXISTS `cntfunc_dep` (
  `iddep` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `nome` varchar(80) NOT NULL,
  `dtnascto` date NOT NULL,
  PRIMARY KEY (`iddep`),
  KEY `fk_cntfunc_dep_cnt_idx` (`idcnt`),
  CONSTRAINT `fk_cntfunc_dep_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntfunc_exa
CREATE TABLE IF NOT EXISTS `cntfunc_exa` (
  `idemp` int unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `dtexameper` date NOT NULL,
  PRIMARY KEY (`idemp`,`idcnt`,`dtexameper`),
  CONSTRAINT `cntfunc_exa_func` FOREIGN KEY (`idemp`, `idcnt`) REFERENCES `cntfunc` (`idemp`, `idcnt`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntfunc_ferias
CREATE TABLE IF NOT EXISTS `cntfunc_ferias` (
  `idemp` int unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `dtini` date NOT NULL,
  `dtfim` date DEFAULT NULL,
  PRIMARY KEY (`idemp`,`idcnt`,`dtini`),
  CONSTRAINT `fk_cntfunc_ferias_func` FOREIGN KEY (`idemp`, `idcnt`) REFERENCES `cntfunc` (`idemp`, `idcnt`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntfunc_hist
CREATE TABLE IF NOT EXISTS `cntfunc_hist` (
  `idfunchist` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `dthr` datetime NOT NULL,
  `loghist` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`idfunchist`),
  KEY `fkcntfunc_hist_cnt_idx` (`idcnt`),
  CONSTRAINT `fkcntfunc_hist_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntfunc_ocorr
CREATE TABLE IF NOT EXISTS `cntfunc_ocorr` (
  `idemp` int unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `dthrocorr` datetime NOT NULL,
  `texto` mediumtext,
  `advertido` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idemp`,`idcnt`,`dthrocorr`),
  CONSTRAINT `fk_cntfunc_ocorr_func` FOREIGN KEY (`idemp`, `idcnt`) REFERENCES `cntfunc` (`idemp`, `idcnt`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntfunc_posto
CREATE TABLE IF NOT EXISTS `cntfunc_posto` (
  `idposto` int unsigned NOT NULL AUTO_INCREMENT,
  `nomeposto` varchar(80) NOT NULL,
  PRIMARY KEY (`idposto`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntfunc_qhoras
CREATE TABLE IF NOT EXISTS `cntfunc_qhoras` (
  `idturno` int unsigned NOT NULL,
  `diasemana` tinyint unsigned NOT NULL,
  `hrini` time NOT NULL,
  `hrint1` time DEFAULT NULL,
  `hrint2` time DEFAULT NULL,
  `hrfim` time NOT NULL,
  PRIMARY KEY (`idturno`,`diasemana`,`hrini`),
  CONSTRAINT `fk_cntfunc_qhoras_turno` FOREIGN KEY (`idturno`) REFERENCES `cntfunc_turno` (`idturno`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntfunc_turno
CREATE TABLE IF NOT EXISTS `cntfunc_turno` (
  `idturno` int unsigned NOT NULL AUTO_INCREMENT,
  `idposto` int unsigned NOT NULL,
  `nometurno` varchar(80) NOT NULL,
  `feriadoutil` bit(1) NOT NULL DEFAULT b'0',
  `ativo` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`idturno`),
  KEY `fk_cntfunc_turno_posto_idx` (`idposto`),
  CONSTRAINT `fk_cntfunc_turno_posto` FOREIGN KEY (`idposto`) REFERENCES `cntfunc_posto` (`idposto`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntgrupo
CREATE TABLE IF NOT EXISTS `cntgrupo` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `descr` varchar(100) NOT NULL,
  `rating` tinyint NOT NULL DEFAULT '0',
  `dtadd` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntgrupohist
CREATE TABLE IF NOT EXISTS `cntgrupohist` (
  `idcnt` int unsigned NOT NULL,
  `idgrupo` smallint NOT NULL,
  `dthrhist` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idcnt`,`idgrupo`,`dthrhist`),
  KEY `fk_grupohist_cntgrupo_idx` (`idgrupo`),
  CONSTRAINT `fk_grupohist_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_grupohist_cntgrupo` FOREIGN KEY (`idgrupo`) REFERENCES `cntgrupo` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntobs
CREATE TABLE IF NOT EXISTS `cntobs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `obs` longtext,
  `dthrobs` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_cntobs_cnt_idx` (`idcnt`),
  CONSTRAINT `fk_cntobs_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntref
CREATE TABLE IF NOT EXISTS `cntref` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `tiporef` varchar(30) NOT NULL,
  `nome` varchar(80) DEFAULT NULL,
  `ddd` varchar(8) DEFAULT NULL,
  `fone` varchar(20) DEFAULT NULL,
  `obs` varchar(200) DEFAULT NULL,
  `dthradd` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_cntref_cnt_idx` (`idcnt`),
  CONSTRAINT `fk_cntref_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntrestricaolog
CREATE TABLE IF NOT EXISTS `cntrestricaolog` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `restricao` bit(1) NOT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  `dthrlog` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_cntrestricaolog_cnt_idx` (`idcnt`),
  CONSTRAINT `fk_cntrestricaolog_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntrota
CREATE TABLE IF NOT EXISTS `cntrota` (
  `idcnt` int unsigned NOT NULL,
  `idrota` int NOT NULL,
  PRIMARY KEY (`idcnt`,`idrota`),
  KEY `fk_cntrota_rota_idx` (`idrota`),
  CONSTRAINT `fk_cntrota_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cntrota_rota` FOREIGN KEY (`idrota`) REFERENCES `rota` (`idrota`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cntsocios
CREATE TABLE IF NOT EXISTS `cntsocios` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `nome` varchar(120) DEFAULT NULL,
  `docfed` varchar(45) DEFAULT NULL,
  `docest` varchar(45) DEFAULT NULL,
  `percsocial` varchar(45) DEFAULT NULL,
  `cep` varchar(12) DEFAULT NULL,
  `endereco` varchar(120) DEFAULT NULL,
  `nroend` varchar(30) DEFAULT NULL,
  `bairro` varchar(120) DEFAULT NULL,
  `compl` varchar(120) DEFAULT NULL,
  `referencia` varchar(120) DEFAULT NULL,
  `cidade` varchar(60) DEFAULT NULL,
  `uf` varchar(10) DEFAULT NULL,
  `pais` varchar(60) DEFAULT NULL,
  `dthradd` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_cntsocios_cnt_idx` (`idcnt`),
  CONSTRAINT `fk_cntsocios_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cobcfg
CREATE TABLE IF NOT EXISTS `cobcfg` (
  `idcfg` smallint unsigned NOT NULL AUTO_INCREMENT,
  `iddest` smallint unsigned NOT NULL,
  `descricao` varchar(80) DEFAULT NULL,
  `banco` smallint DEFAULT NULL,
  `agencia` varchar(10) DEFAULT NULL,
  `agenciadv` varchar(4) DEFAULT NULL,
  `conta` varchar(20) DEFAULT NULL,
  `contadv` varchar(4) DEFAULT NULL,
  `agenciacontadv` varchar(4) DEFAULT NULL,
  `numcorrespon` varchar(10) DEFAULT NULL,
  `carteira` varchar(10) DEFAULT NULL,
  `convenio` varchar(30) DEFAULT NULL,
  `codcedente` varchar(20) DEFAULT NULL,
  `variacao` varchar(20) DEFAULT NULL,
  `modalidade` varchar(20) DEFAULT NULL,
  `codtransmissao` varchar(30) DEFAULT NULL,
  `especiedoc` varchar(10) DEFAULT NULL,
  `especiemoeda` varchar(10) DEFAULT NULL,
  `aceite` bit(1) DEFAULT b'0',
  `homologacao` bit(1) DEFAULT b'0',
  `diasprot` smallint DEFAULT '0',
  `tipoprot` enum('0','1') DEFAULT '0' COMMENT '0 - corrido 1 - util',
  `layout` enum('0','1') DEFAULT '0' COMMENT '0 - C400 1 - C240',
  `envio` enum('1','2','3') DEFAULT '1' COMMENT '1 - Cedente 2 - Banco 3 - Banco Reemite',
  `tipocob` enum('0','1','2','3','4') DEFAULT '0' COMMENT '0 - Simples 1 - Vinculada 2 - Caucionada 3 - Descontada 4 - Vendor',
  `tipoprint` enum('0','1','2','3') DEFAULT '0' COMMENT '0 - Normal 1 - Carnê 2 - Fatura com Detalhes 3 - Fatura com Valores',
  `tipocarteira` enum('0','1','2') DEFAULT '0' COMMENT '0 - Simples 1 - Registrada 2 - Eletrônica',
  `arqseq` smallint unsigned NOT NULL DEFAULT '0',
  `orienta1` varchar(80) DEFAULT NULL,
  `orienta2` varchar(80) DEFAULT NULL,
  `layoutarq` varchar(20) DEFAULT NULL,
  `layoutlote` varchar(20) DEFAULT NULL,
  `diascomp` smallint NOT NULL DEFAULT '1',
  `nmarqpequeno` bit(1) NOT NULL DEFAULT b'0',
  `inativo` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idcfg`),
  KEY `fk_cobcfg_findestino_idx` (`iddest`),
  CONSTRAINT `fk_cobcfg_findestino` FOREIGN KEY (`iddest`) REFERENCES `findestino` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cobcomando
CREATE TABLE IF NOT EXISTS `cobcomando` (
  `idcfg` smallint unsigned NOT NULL,
  `descricao` varchar(60) DEFAULT NULL,
  `ocorrencia` varchar(10) NOT NULL,
  `instrucao1` varchar(10) DEFAULT NULL,
  `instrucao2` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`idcfg`,`ocorrencia`),
  CONSTRAINT `fk_cobcomando_cobcfg` FOREIGN KEY (`idcfg`) REFERENCES `cobcfg` (`idcfg`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cobretorno
CREATE TABLE IF NOT EXISTS `cobretorno` (
  `nmarq` varchar(60) NOT NULL,
  `dtarq` date NOT NULL,
  `idcfg` smallint unsigned NOT NULL,
  `cnome` varchar(60) DEFAULT NULL,
  `cdoc` varchar(20) DEFAULT NULL,
  `cag` varchar(20) DEFAULT NULL,
  `cconta` varchar(30) DEFAULT NULL,
  `seunro` varchar(30) DEFAULT NULL,
  `nrodoc` varchar(15) DEFAULT NULL,
  `carteira` varchar(10) DEFAULT NULL,
  `nossonum` varchar(30) NOT NULL,
  `ocorrencia` varchar(200) NOT NULL,
  `dtocorrencia` date DEFAULT NULL,
  `dtvencto` date DEFAULT NULL,
  `dtcredito` date DEFAULT NULL,
  `vdoc` decimal(15,2) DEFAULT NULL,
  `viof` decimal(15,2) DEFAULT NULL,
  `vabat` decimal(15,2) DEFAULT NULL,
  `vdesc` decimal(15,2) DEFAULT NULL,
  `vmora` decimal(15,2) DEFAULT NULL,
  `vdespesas` decimal(15,2) DEFAULT NULL,
  `vOuCred` decimal(15,2) DEFAULT NULL,
  `vOuDesp` decimal(15,2) DEFAULT NULL,
  `vrecebido` decimal(15,2) DEFAULT NULL,
  `confirmado` bit(1) DEFAULT b'0',
  `baixado` bit(1) DEFAULT b'0',
  `liquidado` bit(1) DEFAULT b'0',
  `idtitulo` int unsigned DEFAULT NULL,
  `motivos` text,
  `processado` bit(1) DEFAULT b'0',
  `idemp` int unsigned DEFAULT NULL,
  `idmovdespesa` int unsigned DEFAULT NULL,
  PRIMARY KEY (`nmarq`,`dtarq`,`idcfg`,`nossonum`,`ocorrencia`),
  KEY `fk_cobretorno_cobtitulo_idx` (`idtitulo`),
  KEY `fk_cobretorno_cobcfg_idx` (`idcfg`),
  KEY `fk_cobretorno_cnt_idx` (`idemp`),
  KEY `fk_cobretorno_finmov_idx` (`idmovdespesa`),
  CONSTRAINT `fk_cobretorno_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cobretorno_cobcfg` FOREIGN KEY (`idcfg`) REFERENCES `cobcfg` (`idcfg`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cobretorno_cobtitulo` FOREIGN KEY (`idtitulo`) REFERENCES `cobtitulo` (`idtitulo`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cobretorno_finmov` FOREIGN KEY (`idmovdespesa`) REFERENCES `finmov` (`idmov`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cobtitulo
CREATE TABLE IF NOT EXISTS `cobtitulo` (
  `idtitulo` int unsigned NOT NULL AUTO_INCREMENT,
  `idctarec` int unsigned NOT NULL,
  `idcfg` smallint unsigned NOT NULL,
  `dtcadastro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `impresso` bit(1) NOT NULL DEFAULT b'0',
  `nn` varchar(20) DEFAULT NULL,
  `nndv` varchar(5) DEFAULT NULL,
  `linha` varchar(60) DEFAULT NULL,
  `arqseq` smallint NOT NULL DEFAULT '0',
  `arqgerado` bit(1) NOT NULL DEFAULT b'0',
  `nmarq` varchar(60) DEFAULT NULL,
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  `idmov` int unsigned DEFAULT NULL,
  PRIMARY KEY (`idtitulo`),
  KEY `fk_cobtitulo_ctareceber_idx` (`idctarec`),
  KEY `fk_cobtitulo_cobcfg_idx` (`idcfg`),
  KEY `fk_cobtitulo_finmov_idx` (`idmov`),
  CONSTRAINT `fk_cobtitulo_cobcfg` FOREIGN KEY (`idcfg`) REFERENCES `cobcfg` (`idcfg`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cobtitulo_ctareceber` FOREIGN KEY (`idctarec`) REFERENCES `ctareceber` (`idctarec`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cobtitulo_finmov` FOREIGN KEY (`idmov`) REFERENCES `finmov` (`idmov`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=151 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cobtituloalt
CREATE TABLE IF NOT EXISTS `cobtituloalt` (
  `idalter` int NOT NULL AUTO_INCREMENT,
  `idtitulo` int unsigned NOT NULL,
  `idctarec` int unsigned NOT NULL,
  `tpalter` varchar(2) NOT NULL DEFAULT '00',
  `arqseq` smallint NOT NULL DEFAULT '0',
  `arqgerado` bit(1) NOT NULL DEFAULT b'0',
  `nmarq` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`idalter`),
  KEY `fk_cobtitualt_cobtitu_idx` (`idtitulo`),
  KEY `fk_cobtitualt_ctareceber_idx` (`idctarec`),
  CONSTRAINT `fk_cobtitualt_cobtitu` FOREIGN KEY (`idtitulo`) REFERENCES `cobtitulo` (`idtitulo`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cobtitualt_ctareceber` FOREIGN KEY (`idctarec`) REFERENCES `ctareceber` (`idctarec`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cobtituloaltlog
CREATE TABLE IF NOT EXISTS `cobtituloaltlog` (
  `idlog` int unsigned NOT NULL AUTO_INCREMENT,
  `idalter` int DEFAULT NULL,
  `idtitulo` int unsigned DEFAULT NULL,
  `idctarec` int unsigned DEFAULT NULL,
  `tpalter` varchar(2) DEFAULT NULL,
  `arqseq` smallint DEFAULT NULL,
  `arqgerado` bit(1) DEFAULT NULL,
  `nmarq` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`idlog`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cobtitulodespesa
CREATE TABLE IF NOT EXISTS `cobtitulodespesa` (
  `idtitulo` int unsigned NOT NULL,
  `idmov` int unsigned NOT NULL,
  `ocorrencia` varchar(200) NOT NULL,
  `dtocorr` date NOT NULL,
  PRIMARY KEY (`idtitulo`,`idmov`),
  KEY `fk_cobtitudesp_finmov_idx` (`idmov`),
  CONSTRAINT `fk_cobtitudesp_cobtitulo` FOREIGN KEY (`idtitulo`) REFERENCES `cobtitulo` (`idtitulo`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cobtitudesp_finmov` FOREIGN KEY (`idmov`) REFERENCES `finmov` (`idmov`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cobtitulolog
CREATE TABLE IF NOT EXISTS `cobtitulolog` (
  `idlog` int unsigned NOT NULL AUTO_INCREMENT,
  `idtitulo` int unsigned DEFAULT NULL,
  `idctarec` int unsigned DEFAULT NULL,
  `idcfg` smallint unsigned DEFAULT NULL,
  `dtcadastro` datetime DEFAULT NULL,
  `impresso` bit(1) DEFAULT NULL,
  `nn` varchar(20) DEFAULT NULL,
  `nndv` varchar(5) DEFAULT NULL,
  `linha` varchar(60) DEFAULT NULL,
  `arqseq` smallint DEFAULT NULL,
  `arqgerado` bit(1) DEFAULT NULL,
  `nmarq` varchar(60) DEFAULT NULL,
  `cancelado` bit(1) DEFAULT NULL,
  `idmov` int unsigned DEFAULT NULL,
  PRIMARY KEY (`idlog`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.comi
CREATE TABLE IF NOT EXISTS `comi` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `nomecomi` varchar(120) NOT NULL,
  `basecnf` decimal(8,3) NOT NULL DEFAULT '0.000',
  `basesnf` decimal(8,3) NOT NULL DEFAULT '0.000',
  `sopagos` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.comiforma
CREATE TABLE IF NOT EXISTS `comiforma` (
  `idcomi` smallint unsigned NOT NULL,
  `idforma` smallint unsigned NOT NULL,
  `perctot` decimal(8,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idcomi`,`idforma`),
  KEY `fk_comiforma_formapg_idx` (`idforma`),
  CONSTRAINT `fk_comiforma_comi` FOREIGN KEY (`idcomi`) REFERENCES `comi` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_comiforma_formapg` FOREIGN KEY (`idforma`) REFERENCES `formapg` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.comigrupo
CREATE TABLE IF NOT EXISTS `comigrupo` (
  `idcomi` smallint unsigned NOT NULL,
  `idsubgrupo` int NOT NULL,
  `perctot` decimal(8,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idcomi`,`idsubgrupo`),
  KEY `fk_comigrupo_prdsub_idx` (`idsubgrupo`),
  CONSTRAINT `fk_comigrupo_comi` FOREIGN KEY (`idcomi`) REFERENCES `comi` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_comigrupo_prdsub` FOREIGN KEY (`idsubgrupo`) REFERENCES `prdsubgrupo` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.comimargem
CREATE TABLE IF NOT EXISTS `comimargem` (
  `idcomi` smallint unsigned NOT NULL,
  `mgini` decimal(8,3) NOT NULL DEFAULT '0.000',
  `mgfim` decimal(8,3) NOT NULL DEFAULT '0.000',
  `perctot` decimal(8,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idcomi`,`mgini`),
  CONSTRAINT `fk_comimargem_comi` FOREIGN KEY (`idcomi`) REFERENCES `comi` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.condpg
CREATE TABLE IF NOT EXISTS `condpg` (
  `idcond` smallint unsigned NOT NULL AUTO_INCREMENT,
  `nomecond` varchar(80) NOT NULL,
  `parcelas` smallint NOT NULL,
  `juros` decimal(12,3) NOT NULL DEFAULT '0.000',
  `multa` decimal(12,3) NOT NULL DEFAULT '0.000',
  `periodo` varchar(1) NOT NULL DEFAULT 'M',
  `entrada` bit(1) NOT NULL DEFAULT b'0',
  `mesmodia` bit(1) NOT NULL DEFAULT b'0',
  `diautil` bit(1) NOT NULL DEFAULT b'1',
  `inativo` bit(1) NOT NULL DEFAULT b'0',
  `diavenc` tinyint DEFAULT NULL,
  `diasconfig` varchar(120) DEFAULT NULL,
  PRIMARY KEY (`idcond`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.contrato
CREATE TABLE IF NOT EXISTS `contrato` (
  `idcontrato` int unsigned NOT NULL AUTO_INCREMENT,
  `idcontratotipo` smallint unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `dtini` date NOT NULL,
  `dtfim` date DEFAULT NULL,
  `nrocontrato` varchar(60) DEFAULT NULL,
  `idforma` smallint unsigned NOT NULL,
  `idcond` smallint unsigned NOT NULL,
  `diavencto` tinyint NOT NULL DEFAULT '20',
  `idemp` int unsigned NOT NULL,
  `idvend` int unsigned DEFAULT NULL,
  `idvenda` int unsigned DEFAULT NULL,
  `gerado` bit(1) NOT NULL DEFAULT b'0',
  `prorrogado` smallint DEFAULT '0',
  `cancelado` bit(1) DEFAULT b'0',
  `valor` decimal(12,3) NOT NULL DEFAULT '0.000',
  `taxaini` decimal(12,3) NOT NULL DEFAULT '0.000',
  `obsvenda` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`idcontrato`),
  KEY `fk_contrato_tipo_idx` (`idcontratotipo`),
  KEY `fk_contrato_cnt1_idx` (`idcnt`),
  KEY `fk_contrato_cnt2_idx` (`idemp`),
  KEY `fk_contrato_cnt3_idx` (`idvend`),
  KEY `fk_contrato_formapg_idx` (`idforma`),
  KEY `fk_contrato_condpg_idx` (`idcond`),
  KEY `fk_contrato_venda_idx` (`idvenda`),
  CONSTRAINT `fk_contrato_cnt1` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_contrato_cnt2` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_contrato_cnt3` FOREIGN KEY (`idvend`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_contrato_condpg` FOREIGN KEY (`idcond`) REFERENCES `condpg` (`idcond`) ON UPDATE CASCADE,
  CONSTRAINT `fk_contrato_formapg` FOREIGN KEY (`idforma`) REFERENCES `formapg` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_contrato_tipo` FOREIGN KEY (`idcontratotipo`) REFERENCES `contratotipo` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_contrato_venda` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.contratoobs
CREATE TABLE IF NOT EXISTS `contratoobs` (
  `idobs` int unsigned NOT NULL AUTO_INCREMENT,
  `idcontrato` int unsigned NOT NULL,
  `dthrobs` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `obs` varchar(250) NOT NULL,
  PRIMARY KEY (`idobs`),
  KEY `idx_contrato_dthr` (`idcontrato`,`dthrobs`),
  CONSTRAINT `fk_contratoobs_contrato` FOREIGN KEY (`idcontrato`) REFERENCES `contrato` (`idcontrato`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.contratotipo
CREATE TABLE IF NOT EXISTS `contratotipo` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `periodo` decimal(10,3) NOT NULL DEFAULT '30.437',
  `taxaini` decimal(15,3) NOT NULL DEFAULT '0.000',
  `valor` decimal(15,3) NOT NULL DEFAULT '0.000',
  `prazo` tinyint NOT NULL DEFAULT '12',
  `valortotal` decimal(15,3) NOT NULL DEFAULT '0.000',
  `emitirnf` bit(1) NOT NULL DEFAULT b'0',
  `totalparcial` enum('T','P') NOT NULL DEFAULT 'T',
  `idprd` int NOT NULL,
  `maxprorrog` smallint NOT NULL DEFAULT '30',
  `multacancela` decimal(10,3) NOT NULL DEFAULT '10.000',
  `prepago` bit(1) NOT NULL DEFAULT b'0',
  `modelocontrato` longblob,
  PRIMARY KEY (`id`),
  KEY `fk_contratotipo_prd_idx` (`idprd`),
  CONSTRAINT `fk_contratotipo_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cordem
CREATE TABLE IF NOT EXISTS `cordem` (
  `idordem` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `dthremissao` datetime NOT NULL,
  `idusu` int unsigned NOT NULL,
  `finalidade` enum('F','U','X') NOT NULL DEFAULT 'X',
  `fechado` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idordem`),
  KEY `fk_cordem_cnt_idx` (`idemp`),
  KEY `fk_cordem_usu_idx` (`idusu`),
  CONSTRAINT `fk_cordem_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cordem_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cpedido
CREATE TABLE IF NOT EXISTS `cpedido` (
  `idpedido` int unsigned NOT NULL AUTO_INCREMENT,
  `idordem` int unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `formapg` varchar(60) DEFAULT NULL,
  `condpg` varchar(60) DEFAULT NULL,
  `obs` varchar(300) DEFAULT NULL,
  `tipofrete` enum('C','F','T','X') NOT NULL DEFAULT 'X',
  PRIMARY KEY (`idpedido`,`idordem`),
  KEY `fk_cpedido_cordem_idx` (`idordem`),
  KEY `fk_cpedido_cnt_idx` (`idcnt`),
  CONSTRAINT `fk_cpedido_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cpedido_cordem` FOREIGN KEY (`idordem`) REFERENCES `cordem` (`idordem`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cprod
CREATE TABLE IF NOT EXISTS `cprod` (
  `idordem` int unsigned NOT NULL,
  `idpedido` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `idprod` int NOT NULL,
  `qtde` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vunit` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vdesconto` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vprod` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vst` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vipi` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vfrete` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vseguro` decimal(12,3) NOT NULL DEFAULT '0.000',
  `voutros` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vtotal` decimal(12,3) NOT NULL DEFAULT '0.000',
  `chavenfe` varchar(60) DEFAULT NULL,
  `seqnfe` smallint DEFAULT NULL,
  PRIMARY KEY (`idordem`,`idpedido`,`seq`),
  KEY `fk_cprod_prd_idx` (`idprod`),
  KEY `idx_cprod_chaveseq` (`chavenfe`,`seqnfe`),
  CONSTRAINT `fk_cprod_cpedido` FOREIGN KEY (`idordem`, `idpedido`) REFERENCES `cpedido` (`idordem`, `idpedido`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cprod_prd` FOREIGN KEY (`idprod`) REFERENCES `prd` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.crmevento
CREATE TABLE IF NOT EXISTS `crmevento` (
  `uidev` varchar(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `idemp` int unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `idusu` int unsigned NOT NULL,
  `dthrev` datetime NOT NULL,
  `tpev` varchar(10) NOT NULL,
  `hist` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`uidev`),
  KEY `fk_crmevento_emp_idx` (`idemp`),
  KEY `fk_crmevento_cli_idx` (`idcnt`),
  KEY `fk_crmevento_usu_idx` (`idusu`),
  KEY `fk_crmevento_crmtpev_idx` (`tpev`),
  KEY `idx_crmevento_clidthr` (`idcnt`,`dthrev`),
  CONSTRAINT `fk_crmevento_cli` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_crmevento_crmtpev` FOREIGN KEY (`tpev`) REFERENCES `crmtpev` (`tpev`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_crmevento_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_crmevento_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.crmlog
CREATE TABLE IF NOT EXISTS `crmlog` (
  `uidlog` varchar(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `uidev` varchar(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `campo` varchar(50) NOT NULL,
  `oldvalue` varchar(300) DEFAULT NULL,
  `newvalue` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`uidlog`),
  KEY `fk_crmlog_crmevento_idx` (`uidev`),
  CONSTRAINT `fk_crmlog_crmevento` FOREIGN KEY (`uidev`) REFERENCES `crmevento` (`uidev`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.crmreg
CREATE TABLE IF NOT EXISTS `crmreg` (
  `uidreg` varchar(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `idemp` int unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `idusu` int unsigned NOT NULL,
  `dthrreg` datetime NOT NULL,
  `registro` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`uidreg`),
  KEY `fk_crmreg_emp_idx` (`idemp`),
  KEY `fk_crmreg_cli_idx` (`idcnt`),
  KEY `fk_crmreg_usu_idx` (`idusu`),
  CONSTRAINT `fk_crmreg_cli` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_crmreg_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_crmreg_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.crmtpev
CREATE TABLE IF NOT EXISTS `crmtpev` (
  `tpev` varchar(10) NOT NULL,
  `evento` varchar(80) NOT NULL,
  PRIMARY KEY (`tpev`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.ctapag
CREATE TABLE IF NOT EXISTS `ctapag` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nrodoc` varchar(40) NOT NULL,
  `parcelas` smallint NOT NULL,
  `idcnt` int unsigned DEFAULT NULL,
  `idemp` int unsigned NOT NULL,
  `dtemissao` date NOT NULL,
  `dtemidoc` date DEFAULT NULL,
  `dtinicio` date DEFAULT NULL,
  `valortotal` decimal(12,3) NOT NULL,
  `tipo` enum('F','V','A') NOT NULL,
  `classe` enum('C','D','I') NOT NULL,
  `obs` varchar(254) DEFAULT NULL,
  `fechado` bit(1) DEFAULT b'0',
  `boleto` bit(1) DEFAULT b'0',
  `idfunc` int unsigned DEFAULT NULL,
  `idsetor` smallint unsigned DEFAULT NULL,
  `idcc` smallint unsigned DEFAULT NULL,
  `idclass` smallint DEFAULT NULL,
  `iddest` smallint unsigned DEFAULT NULL,
  `docfedsaca` varchar(30) DEFAULT NULL,
  `nomesaca` varchar(40) DEFAULT NULL,
  `dthrcad` datetime DEFAULT NULL,
  `idusu` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ctapag_cnt1_idx` (`idcnt`),
  KEY `fk_ctapag_cnt2_idx` (`idemp`),
  KEY `fk_ctapag_func_idx` (`idfunc`),
  KEY `fk_ctapag_empsetor_idx` (`idsetor`),
  KEY `fk_ctapag_centrocusto_idx` (`idcc`),
  KEY `fk_ctapag_ctapagclass_idx` (`idclass`),
  KEY `fk_ctapag_findestino_idx` (`iddest`),
  KEY `fk_ctapag_usu_idx` (`idusu`),
  CONSTRAINT `fk_ctapag_centrocusto` FOREIGN KEY (`idcc`) REFERENCES `centrocusto` (`idcc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctapag_cnt1` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctapag_cnt2` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctapag_ctapagclass` FOREIGN KEY (`idclass`) REFERENCES `ctapagclass` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctapag_empsetor` FOREIGN KEY (`idsetor`) REFERENCES `cntemp_setor` (`idsetor`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctapag_findestino` FOREIGN KEY (`iddest`) REFERENCES `findestino` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctapag_func` FOREIGN KEY (`idfunc`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctapag_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.ctapagclass
CREATE TABLE IF NOT EXISTS `ctapagclass` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `despesa` varchar(80) NOT NULL,
  `analitico` bit(1) NOT NULL DEFAULT b'0',
  `idpai` smallint DEFAULT NULL,
  `xconta` tinyint NOT NULL DEFAULT '0',
  `codconta` varchar(50) DEFAULT NULL,
  `inativo` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `fk_ctapagclass_id_idpai_idx` (`idpai`),
  CONSTRAINT `fk_ctapagclass_id_idpai` FOREIGN KEY (`idpai`) REFERENCES `ctapagclass` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.ctapagfor
CREATE TABLE IF NOT EXISTS `ctapagfor` (
  `idcnt` int unsigned NOT NULL,
  `idclass` smallint NOT NULL,
  PRIMARY KEY (`idcnt`,`idclass`),
  KEY `fk_ctapagfor_ctapagclass_idx` (`idclass`),
  CONSTRAINT `fk_ctapagfor_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ctapagfor_ctapagclass` FOREIGN KEY (`idclass`) REFERENCES `ctapagclass` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.ctapagp
CREATE TABLE IF NOT EXISTS `ctapagp` (
  `idpag` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `boleto` bit(1) NOT NULL DEFAULT b'0',
  `nroboleto` varchar(60) DEFAULT NULL,
  `codbarras` varchar(60) DEFAULT NULL,
  `vencimento` date NOT NULL,
  `valorparc` decimal(12,3) NOT NULL,
  `juros` decimal(12,3) DEFAULT NULL,
  `multa` decimal(12,3) DEFAULT NULL,
  `valortotal` decimal(12,3) DEFAULT NULL,
  `pagamento` date DEFAULT NULL,
  `valorpago` decimal(12,3) DEFAULT NULL,
  `valordesc` decimal(12,3) DEFAULT NULL,
  `idmov` int unsigned DEFAULT NULL,
  `pagfor` bit(1) DEFAULT b'0',
  `idpagorigem` int unsigned DEFAULT NULL,
  `seqorigem` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`idpag`,`seq`),
  KEY `fk_ctapagp_finmov_idx` (`idmov`),
  KEY `fk_ctapagp_ctapagp_idx` (`idpagorigem`,`seqorigem`),
  CONSTRAINT `fk_ctapagp_ctapag` FOREIGN KEY (`idpag`) REFERENCES `ctapag` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ctapagp_ctapagp` FOREIGN KEY (`idpagorigem`, `seqorigem`) REFERENCES `ctapagp` (`idpag`, `seq`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ctapagp_finmov` FOREIGN KEY (`idmov`) REFERENCES `finmov` (`idmov`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.ctapagrateio
CREATE TABLE IF NOT EXISTS `ctapagrateio` (
  `idpag` int unsigned NOT NULL,
  `idemp` int unsigned NOT NULL,
  `perc` decimal(12,6) NOT NULL DEFAULT '0.000000',
  PRIMARY KEY (`idpag`,`idemp`),
  KEY `fk_ctapagrat_emp_idx` (`idemp`),
  CONSTRAINT `fk_ctapagrat_ctapag` FOREIGN KEY (`idpag`) REFERENCES `ctapag` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ctapagrat_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.ctareceber
CREATE TABLE IF NOT EXISTS `ctareceber` (
  `idctarec` int unsigned NOT NULL AUTO_INCREMENT,
  `idvenda` int unsigned NOT NULL,
  `idforma` smallint unsigned NOT NULL,
  `seq` tinyint unsigned NOT NULL,
  `idcaixa` int unsigned DEFAULT NULL,
  `parcela` smallint unsigned NOT NULL,
  `idcond` smallint unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `idemp` int unsigned NOT NULL,
  `emissao` date NOT NULL,
  `vencimento` date NOT NULL,
  `pagamento` date DEFAULT NULL,
  `valor` decimal(12,3) NOT NULL DEFAULT '0.000',
  `juros` decimal(12,3) DEFAULT '0.000',
  `multa` decimal(12,3) DEFAULT '0.000',
  `taxas` decimal(12,3) DEFAULT '0.000',
  `valortotal` decimal(12,3) DEFAULT '0.000',
  `valorpago` decimal(12,3) DEFAULT '0.000',
  `desconto` decimal(12,3) DEFAULT '0.000',
  `identracx` int unsigned DEFAULT NULL,
  `baixacob` bit(1) DEFAULT b'0',
  `idmov` int unsigned DEFAULT NULL,
  `obs` varchar(255) DEFAULT NULL,
  `anulada` bit(1) NOT NULL DEFAULT b'0',
  `perda` bit(1) NOT NULL DEFAULT b'0',
  `bonificado` bit(1) NOT NULL DEFAULT b'0',
  `idctaorigem` int unsigned DEFAULT NULL,
  `vencoriginal` date NOT NULL,
  `obsbaixa` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`idctarec`),
  KEY `fk_ctareceber_cliente_idx` (`idcnt`),
  KEY `fk_ctareceber_emp_idx` (`idemp`),
  KEY `fk_ctareceber_condpg_idx` (`idcond`),
  KEY `fk_ctareceber_caixaentrada_idx` (`identracx`),
  KEY `fk_ctareceber_finmov_idx` (`idmov`),
  KEY `fk_ctareceber_vendacaixa_idx` (`idvenda`,`idforma`,`seq`),
  KEY `fk_ctareceber_caixa_idx` (`idcaixa`),
  KEY `fk_ctareceber_baixaparcial_idx` (`idctaorigem`),
  CONSTRAINT `fk_ctareceber_baixaparcial` FOREIGN KEY (`idctaorigem`) REFERENCES `ctareceber` (`idctarec`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ctareceber_caixa` FOREIGN KEY (`idcaixa`) REFERENCES `caixa` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctareceber_caixaentrada` FOREIGN KEY (`identracx`) REFERENCES `caixaentrada` (`identracx`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctareceber_cliente` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctareceber_condpg` FOREIGN KEY (`idcond`) REFERENCES `condpg` (`idcond`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctareceber_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctareceber_finmov` FOREIGN KEY (`idmov`) REFERENCES `finmov` (`idmov`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ctareceber_vendacaixa` FOREIGN KEY (`idvenda`, `idforma`, `seq`) REFERENCES `vendacaixa` (`idvenda`, `idforma`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=675 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.ctareceberlog
CREATE TABLE IF NOT EXISTS `ctareceberlog` (
  `idlog` int unsigned NOT NULL AUTO_INCREMENT,
  `idctarec` int unsigned NOT NULL,
  `idvenda` int unsigned DEFAULT NULL,
  `idforma` smallint unsigned DEFAULT NULL,
  `seq` tinyint unsigned DEFAULT NULL,
  `idcaixa` int unsigned DEFAULT NULL,
  `parcela` smallint unsigned DEFAULT NULL,
  `idcond` smallint unsigned DEFAULT NULL,
  `idcnt` int unsigned DEFAULT NULL,
  `idemp` int unsigned DEFAULT NULL,
  `emissao` date DEFAULT NULL,
  `vencimento` date DEFAULT NULL,
  `pagamento` date DEFAULT NULL,
  `valor` decimal(12,3) DEFAULT NULL,
  `juros` decimal(12,3) DEFAULT NULL,
  `multa` decimal(12,3) DEFAULT NULL,
  `taxas` decimal(12,3) DEFAULT NULL,
  `valortotal` decimal(12,3) DEFAULT NULL,
  `valorpago` decimal(12,3) DEFAULT NULL,
  `desconto` decimal(12,3) DEFAULT NULL,
  `identracx` int unsigned DEFAULT NULL,
  `baixacob` bit(1) DEFAULT NULL,
  `idmov` int unsigned DEFAULT NULL,
  `obs` varchar(255) DEFAULT NULL,
  `anulada` bit(1) DEFAULT NULL,
  `perda` bit(1) DEFAULT NULL,
  `bonificado` bit(1) DEFAULT NULL,
  `idctaorigem` int unsigned DEFAULT NULL,
  `vencoriginal` date DEFAULT NULL,
  PRIMARY KEY (`idlog`)
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cte
CREATE TABLE IF NOT EXISTS `cte` (
  `idcte` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `dthremissao` datetime NOT NULL,
  `abrangencia` enum('M','E','P') NOT NULL DEFAULT 'M',
  `cfop` varchar(5) NOT NULL DEFAULT '5353',
  `operacao` varchar(80) NOT NULL DEFAULT 'Prestação Serviço de Transporte',
  `formapag` enum('A','P') NOT NULL DEFAULT 'P',
  `modal` enum('R','A','Q','F','D','M') NOT NULL DEFAULT 'R',
  `tipocte` varchar(1) NOT NULL DEFAULT '0',
  `tiposerv` varchar(1) NOT NULL DEFAULT '0',
  `codmunini` varchar(15) DEFAULT NULL,
  `muninicio` varchar(80) DEFAULT NULL,
  `ufinicio` varchar(10) DEFAULT NULL,
  `codmunfim` varchar(15) DEFAULT NULL,
  `munfim` varchar(80) DEFAULT NULL,
  `uffim` varchar(10) DEFAULT NULL,
  `retira` bit(1) NOT NULL DEFAULT b'0',
  `detretira` varchar(120) DEFAULT NULL,
  `idtoma` int unsigned DEFAULT NULL,
  `tipotoma` varchar(1) NOT NULL DEFAULT '0',
  `caracadi` varchar(120) DEFAULT NULL,
  `caracser` varchar(120) DEFAULT NULL,
  `nomeusu` varchar(120) DEFAULT NULL,
  `tipodata` varchar(1) NOT NULL DEFAULT '0',
  `dtprog` date DEFAULT NULL,
  `dtfim` date DEFAULT NULL,
  `tipohora` varchar(1) NOT NULL DEFAULT '0',
  `hrprog` time DEFAULT NULL,
  `hrfim` time DEFAULT NULL,
  `obs` varchar(400) DEFAULT NULL,
  `iddest` int unsigned DEFAULT NULL,
  `valortot` decimal(12,3) NOT NULL DEFAULT '0.000',
  `valorrec` decimal(12,3) NOT NULL DEFAULT '0.000',
  `simplesnacional` bit(1) NOT NULL DEFAULT b'0',
  `cst` varchar(3) DEFAULT NULL,
  `bcvalor` decimal(12,3) DEFAULT '0.000',
  `predu` decimal(8,4) DEFAULT '0.0000',
  `picms` decimal(8,4) DEFAULT '0.0000',
  `vicms` decimal(12,3) DEFAULT '0.000',
  `vcred` decimal(12,3) DEFAULT '0.000',
  `vcarga` decimal(12,3) DEFAULT '0.000',
  `prodpredo` varchar(120) DEFAULT NULL,
  `vaverbada` decimal(12,3) DEFAULT '0.000',
  `idcntend` int unsigned DEFAULT NULL,
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idcte`),
  KEY `fk_cte_cntemp_idx` (`idemp`),
  KEY `fk_cte_cnttoma_idx` (`idtoma`),
  KEY `fk_cte_cntdest_idx` (`iddest`),
  KEY `fk_cte_cfop_idx` (`cfop`),
  KEY `fk_cte_cndend_idx` (`idcntend`),
  CONSTRAINT `fk_cte_cfop` FOREIGN KEY (`cfop`) REFERENCES `cfop` (`cfop`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cte_cndend` FOREIGN KEY (`idcntend`) REFERENCES `cntend` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cte_cntdest` FOREIGN KEY (`iddest`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cte_cntemp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_cte_cnttoma` FOREIGN KEY (`idtoma`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.ctecarga
CREATE TABLE IF NOT EXISTS `ctecarga` (
  `idcte` int unsigned NOT NULL,
  `unid` varchar(20) NOT NULL,
  `tpmed` varchar(20) DEFAULT NULL,
  `qcarga` decimal(12,3) DEFAULT NULL,
  PRIMARY KEY (`idcte`,`unid`),
  CONSTRAINT `fk_ctecarga_cte` FOREIGN KEY (`idcte`) REFERENCES `cte` (`idcte`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.ctecfg
CREATE TABLE IF NOT EXISTS `ctecfg` (
  `idemp` int unsigned NOT NULL,
  `modelo` varchar(10) DEFAULT '57',
  `seriecte` varchar(10) DEFAULT '1',
  `seqcte` int DEFAULT '1',
  `tipoemissao` varchar(1) DEFAULT '1',
  `ambiente` varchar(1) DEFAULT '1',
  `tipocte` varchar(1) DEFAULT '0',
  `sslcte` varchar(1) DEFAULT '0',
  `seuemail` varchar(80) DEFAULT NULL,
  `assuntoemail` varchar(120) DEFAULT NULL,
  `ncopiasdacte` tinyint DEFAULT '1',
  `enviadacte` bit(1) DEFAULT b'1',
  `rntrc` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`idemp`),
  CONSTRAINT `fk_ctecfg_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.ctedocnfe
CREATE TABLE IF NOT EXISTS `ctedocnfe` (
  `idcte` int unsigned NOT NULL,
  `chavenfe` varchar(50) NOT NULL,
  PRIMARY KEY (`idcte`,`chavenfe`),
  CONSTRAINT `fk_ctedocnfe_cte` FOREIGN KEY (`idcte`) REFERENCES `cte` (`idcte`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.ctepercur
CREATE TABLE IF NOT EXISTS `ctepercur` (
  `idcte` int unsigned NOT NULL,
  `ufpercur` varchar(4) NOT NULL,
  PRIMARY KEY (`idcte`,`ufpercur`),
  CONSTRAINT `fk_ctepercur_cte` FOREIGN KEY (`idcte`) REFERENCES `cte` (`idcte`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.cteprest
CREATE TABLE IF NOT EXISTS `cteprest` (
  `idcte` int unsigned NOT NULL,
  `seq` tinyint NOT NULL,
  `nome` varchar(80) NOT NULL,
  `valor` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idcte`,`seq`),
  CONSTRAINT `fk_cteprest_cte` FOREIGN KEY (`idcte`) REFERENCES `cte` (`idcte`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.diasu
CREATE TABLE IF NOT EXISTS `diasu` (
  `ano` smallint NOT NULL,
  `mes` tinyint NOT NULL,
  `dletivo` date NOT NULL,
  `ativo` bit(1) NOT NULL DEFAULT b'0',
  `feriado` bit(1) NOT NULL DEFAULT b'0',
  `ddow` tinyint DEFAULT NULL,
  `dweek` tinyint DEFAULT NULL,
  PRIMARY KEY (`ano`,`mes`,`dletivo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.doccfg
CREATE TABLE IF NOT EXISTS `doccfg` (
  `idemp` int unsigned NOT NULL,
  `razao` varchar(120) DEFAULT NULL,
  `fantasia` varchar(120) DEFAULT NULL,
  `modelo` varchar(10) DEFAULT NULL,
  `seriedanfe` varchar(10) DEFAULT NULL,
  `serierps` varchar(10) DEFAULT NULL,
  `cnpj` varchar(20) DEFAULT NULL,
  `ie` varchar(20) DEFAULT NULL,
  `im` varchar(20) DEFAULT NULL,
  `cnaedanfe` varchar(20) DEFAULT NULL,
  `cnaerps` varchar(20) DEFAULT NULL,
  `dthrsaida` bit(1) DEFAULT b'0',
  `desconto` bit(1) DEFAULT b'0',
  `descontorps` bit(1) DEFAULT b'0',
  `cest` bit(1) DEFAULT b'0',
  `naodestacaipiisento` bit(1) DEFAULT b'1',
  `crt` varchar(1) DEFAULT '1',
  `incentivador` bit(1) DEFAULT b'0',
  `regimeespecial` varchar(1) DEFAULT '0',
  `logra` varchar(120) DEFAULT NULL,
  `nrologra` varchar(10) DEFAULT NULL,
  `complemento` varchar(60) DEFAULT NULL,
  `bairro` varchar(80) DEFAULT NULL,
  `cep` varchar(20) DEFAULT NULL,
  `cidade` varchar(60) DEFAULT NULL,
  `codcidade` varchar(20) DEFAULT NULL,
  `uf` varchar(20) DEFAULT NULL,
  `coduf` varchar(10) DEFAULT NULL,
  `pais` varchar(30) DEFAULT NULL,
  `codpais` varchar(10) DEFAULT NULL,
  `telefone` varchar(30) DEFAULT NULL,
  `ssldanfe` varchar(1) DEFAULT '0',
  `sslrps` varchar(1) DEFAULT '0',
  `tipoemissao` varchar(1) DEFAULT '1',
  `ambiente` varchar(1) DEFAULT 'P',
  `layoutrps` varchar(50) DEFAULT NULL,
  `usuarioweb` varchar(60) DEFAULT NULL,
  `senhaweb` varchar(60) DEFAULT NULL,
  `frasesecreta` varchar(240) DEFAULT NULL,
  `cnpjprefeitura` varchar(20) DEFAULT NULL,
  `seuemail` varchar(80) DEFAULT NULL,
  `assuntoemail` varchar(120) DEFAULT NULL,
  `cc1` varchar(80) DEFAULT NULL,
  `cc2` varchar(80) DEFAULT NULL,
  `ncopiasdanfe` tinyint DEFAULT '1',
  `ncopiasrps` tinyint DEFAULT '1',
  `logoempresa` mediumblob,
  `logoprefeitura` mediumblob,
  `logodagua` mediumblob,
  `cserie` varchar(60) DEFAULT NULL,
  `csubject` varchar(200) DEFAULT NULL,
  `cvalidade` date DEFAULT NULL,
  `csenha` varchar(60) DEFAULT NULL,
  `seqnfe` int NOT NULL DEFAULT '1',
  `seqrps` int NOT NULL DEFAULT '1',
  `seqnfce` int NOT NULL DEFAULT '1',
  `enviadanfe` bit(1) NOT NULL DEFAULT b'1',
  `enviarps` bit(1) NOT NULL DEFAULT b'1',
  `envianfce` bit(1) NOT NULL DEFAULT b'0',
  `enviaimpressora` bit(1) NOT NULL DEFAULT b'0',
  `impressora` smallint DEFAULT NULL,
  `docautorizado` varchar(20) DEFAULT NULL,
  `ultnsu` varchar(15) DEFAULT '0',
  `maxnsu` varchar(15) DEFAULT '0',
  `layoutnfse` varchar(1) NOT NULL DEFAULT '0',
  `layoutalter` varchar(1) NOT NULL DEFAULT '0',
  `metodo` varchar(1) NOT NULL DEFAULT '1',
  `vernacional` varchar(3) NOT NULL DEFAULT '000',
  `ativarRTC` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idemp`),
  CONSTRAINT `fk_doccfg_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.doccte
CREATE TABLE IF NOT EXISTS `doccte` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `idcte` int unsigned NOT NULL,
  `ncte` int unsigned NOT NULL,
  `serie` varchar(20) NOT NULL DEFAULT '1',
  `chavecte` varchar(50) NOT NULL,
  `complementar` bit(1) DEFAULT b'0',
  `aprovado` bit(1) NOT NULL DEFAULT b'0',
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  `denegado` bit(1) NOT NULL DEFAULT b'0',
  `inutilizada` bit(1) NOT NULL DEFAULT b'0',
  `dthraprovado` datetime DEFAULT NULL,
  `dthrcancelado` datetime DEFAULT NULL,
  `recibo` varchar(40) DEFAULT NULL,
  `protocolo` varchar(40) DEFAULT NULL,
  `digest` varchar(50) DEFAULT NULL,
  `xml` mediumblob,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chavecte_UNIQUE` (`chavecte`),
  KEY `fk_doccte_emp_idx` (`idemp`),
  KEY `fk_doccte_cte_idx` (`idcte`),
  CONSTRAINT `fk_doccte_cte` FOREIGN KEY (`idcte`) REFERENCES `cte` (`idcte`) ON UPDATE CASCADE,
  CONSTRAINT `fk_doccte_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.docdist
CREATE TABLE IF NOT EXISTS `docdist` (
  `idemp` int unsigned NOT NULL,
  `nsu` varchar(15) NOT NULL,
  `chave` varchar(50) NOT NULL,
  `numero` varchar(12) NOT NULL,
  `serie` varchar(3) NOT NULL,
  `nome` varchar(120) NOT NULL,
  `docfed` varchar(20) NOT NULL,
  `docest` varchar(20) DEFAULT NULL,
  `dthremi` datetime DEFAULT NULL,
  `dthrreceb` datetime DEFAULT NULL,
  `valor` decimal(15,3) NOT NULL DEFAULT '0.000',
  `protocolo` varchar(40) DEFAULT NULL,
  `digest` varchar(80) DEFAULT NULL,
  `tipo` enum('E','S','X') NOT NULL DEFAULT 'X',
  `situacao` enum('A','D','C','E','X') NOT NULL DEFAULT 'X',
  `binxml` mediumblob,
  `ciencia` enum('S','N','X') NOT NULL DEFAULT 'X',
  `realizado` enum('S','N','X') NOT NULL DEFAULT 'X',
  `executada` bit(1) NOT NULL DEFAULT b'0',
  `tipomov` tinyint DEFAULT NULL,
  `tipodoc` tinyint DEFAULT NULL,
  PRIMARY KEY (`nsu`,`idemp`),
  KEY `fk_docdist_cntemp_idx` (`idemp`),
  CONSTRAINT `fk_docdist_cntemp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.docevento
CREATE TABLE IF NOT EXISTS `docevento` (
  `chavenf` varchar(50) NOT NULL,
  `tpevento` varchar(30) NOT NULL,
  `nseqevento` smallint NOT NULL,
  `xevento` varchar(156) DEFAULT NULL,
  `dhregevento` datetime DEFAULT NULL,
  `nprot` varchar(30) DEFAULT NULL,
  `id` varchar(80) DEFAULT NULL,
  `tpamb` varchar(10) DEFAULT NULL,
  `veraplic` varchar(30) DEFAULT NULL,
  `corgao` smallint DEFAULT NULL,
  `cstat` smallint DEFAULT NULL,
  `xmotivo` varchar(255) DEFAULT NULL,
  `xml` mediumblob,
  `txtcce` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`tpevento`,`nseqevento`,`chavenf`)
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.doceventocte
CREATE TABLE IF NOT EXISTS `doceventocte` (
  `chavecte` varchar(50) NOT NULL,
  `tpevento` varchar(30) NOT NULL,
  `nseqevento` smallint NOT NULL,
  `xevento` varchar(156) DEFAULT NULL,
  `dhregevento` datetime DEFAULT NULL,
  `nprot` varchar(30) DEFAULT NULL,
  `id` varchar(80) DEFAULT NULL,
  `tpamb` varchar(10) DEFAULT NULL,
  `veraplic` varchar(30) DEFAULT NULL,
  `corgao` smallint DEFAULT NULL,
  `cstat` smallint DEFAULT NULL,
  `xmotivo` varchar(255) DEFAULT NULL,
  `xml` mediumblob,
  `txtcce` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`tpevento`,`nseqevento`,`chavecte`),
  KEY `fk_doceventocte_doccte_idx` (`chavecte`),
  CONSTRAINT `fk_doceventocte_doccte` FOREIGN KEY (`chavecte`) REFERENCES `doccte` (`chavecte`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.doceventomdfe
CREATE TABLE IF NOT EXISTS `doceventomdfe` (
  `chavemdfe` varchar(50) NOT NULL,
  `tpevento` varchar(30) NOT NULL,
  `nseqevento` smallint NOT NULL,
  `xevento` varchar(156) DEFAULT NULL,
  `dhregevento` datetime DEFAULT NULL,
  `nprot` varchar(30) DEFAULT NULL,
  `id` varchar(80) DEFAULT NULL,
  `tpamb` varchar(10) DEFAULT NULL,
  `veraplic` varchar(30) DEFAULT NULL,
  `corgao` smallint DEFAULT NULL,
  `cstat` smallint DEFAULT NULL,
  `xmotivo` varchar(255) DEFAULT NULL,
  `xml` mediumblob,
  `txtcce` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`tpevento`,`nseqevento`,`chavemdfe`),
  KEY `fk_doceventomdfe_docmdfe_idx` (`chavemdfe`),
  CONSTRAINT `fk_doceventomdfe_docmdfe` FOREIGN KEY (`chavemdfe`) REFERENCES `docmdfe` (`chavemdfe`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.docmdfe
CREATE TABLE IF NOT EXISTS `docmdfe` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `idmdfe` int unsigned NOT NULL,
  `nmdfe` int unsigned NOT NULL,
  `serie` varchar(20) NOT NULL DEFAULT '1',
  `chavemdfe` varchar(50) NOT NULL,
  `complementar` bit(1) DEFAULT b'0',
  `aprovado` bit(1) NOT NULL DEFAULT b'0',
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  `denegado` bit(1) NOT NULL DEFAULT b'0',
  `inutilizada` bit(1) NOT NULL DEFAULT b'0',
  `dthraprovado` datetime DEFAULT NULL,
  `dthrcancelado` datetime DEFAULT NULL,
  `recibo` varchar(40) DEFAULT NULL,
  `protocolo` varchar(40) DEFAULT NULL,
  `digest` varchar(50) DEFAULT NULL,
  `xml` mediumblob,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chavecte_UNIQUE` (`chavemdfe`),
  KEY `fk_docmdfe_cntemp_idx` (`idemp`),
  KEY `fk_docmdfe_mdfe_idx` (`idmdfe`),
  CONSTRAINT `fk_docmdfe_cntemp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_docmdfe_mdfe` FOREIGN KEY (`idmdfe`) REFERENCES `mdfe` (`idmdfe`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.docnfce
CREATE TABLE IF NOT EXISTS `docnfce` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `idvenda` int unsigned NOT NULL,
  `idnfce` int unsigned NOT NULL,
  `serie` varchar(20) NOT NULL DEFAULT '1',
  `chavenfce` varchar(50) NOT NULL,
  `aprovado` bit(1) NOT NULL DEFAULT b'0',
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  `inutilizada` bit(1) NOT NULL DEFAULT b'0',
  `dthraprovado` datetime DEFAULT NULL,
  `dthrcancelado` datetime DEFAULT NULL,
  `recibo` varchar(40) DEFAULT NULL,
  `protocolo` varchar(40) DEFAULT NULL,
  `digest` varchar(50) DEFAULT NULL,
  `xml` mediumblob,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chavenf_UNIQUE` (`chavenfce`),
  KEY `fk_docnfce_cnt_idx` (`idemp`),
  KEY `fk_docnfce_venda_idx` (`idvenda`),
  KEY `docnfce_idnfce_idx` (`idnfce`),
  CONSTRAINT `fk_docnfce_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_docnfce_venda` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.docnfe
CREATE TABLE IF NOT EXISTS `docnfe` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `idfat` int unsigned DEFAULT NULL,
  `idmov` int unsigned DEFAULT NULL,
  `idnfe` int unsigned NOT NULL,
  `serie` varchar(20) NOT NULL DEFAULT '1',
  `chavenf` varchar(50) NOT NULL,
  `complementar` bit(1) DEFAULT b'0',
  `aprovado` bit(1) NOT NULL DEFAULT b'0',
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  `denegado` bit(1) NOT NULL DEFAULT b'0',
  `inutilizada` bit(1) NOT NULL DEFAULT b'0',
  `dthraprovado` datetime DEFAULT NULL,
  `dthrcancelado` datetime DEFAULT NULL,
  `recibo` varchar(40) DEFAULT NULL,
  `protocolo` varchar(40) DEFAULT NULL,
  `digest` varchar(50) DEFAULT NULL,
  `xml` mediumblob,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chavenf_UNIQUE` (`chavenf`),
  KEY `fk_docnfe_mov_idx` (`idmov`),
  KEY `fk_docnfe_cnt_idx` (`idemp`),
  KEY `fk_docnfe_fat_idx` (`idfat`),
  KEY `docnfe_idnfe_idx` (`idnfe`),
  CONSTRAINT `fk_docnfe_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_docnfe_fat` FOREIGN KEY (`idfat`) REFERENCES `fat` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_docnfe_mov` FOREIGN KEY (`idmov`) REFERENCES `movnfe` (`idmovnfe`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.docnfse
CREATE TABLE IF NOT EXISTS `docnfse` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `idfat` int unsigned DEFAULT NULL,
  `nrorps` int unsigned NOT NULL,
  `serie` varchar(20) NOT NULL DEFAULT '1',
  `tipo` varchar(10) NOT NULL DEFAULT '1',
  `idnfse` int unsigned DEFAULT NULL,
  `aprovado` bit(1) NOT NULL DEFAULT b'0',
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  `dthraprovado` datetime DEFAULT NULL,
  `dthrcancelado` datetime DEFAULT NULL,
  `protocolo` varchar(40) DEFAULT NULL,
  `verificacao` varchar(60) DEFAULT NULL,
  `xml` mediumblob,
  `codcancela` varchar(20) DEFAULT NULL,
  `xmlacbr` mediumblob,
  PRIMARY KEY (`id`),
  KEY `fk_docnfse_cnt_idx` (`idemp`),
  KEY `fk_docnfse_fat_idx` (`idfat`),
  KEY `docnfse_idnfse_idx` (`idnfse`),
  CONSTRAINT `fk_docnfse_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_docnfse_fat` FOREIGN KEY (`idfat`) REFERENCES `fat` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.empses
CREATE TABLE IF NOT EXISTS `empses` (
  `idemp` int unsigned NOT NULL,
  `email` varchar(100) NOT NULL,
  `domain` varchar(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`idemp`,`domain`),
  CONSTRAINT `fk_empses_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.estoque
CREATE TABLE IF NOT EXISTS `estoque` (
  `idestoque` bigint unsigned NOT NULL AUTO_INCREMENT,
  `dthrestoque` datetime NOT NULL,
  `dthremissao` datetime NOT NULL,
  `idemp` int unsigned NOT NULL,
  `idusu` int unsigned NOT NULL,
  `idusucancela` int unsigned DEFAULT NULL,
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  `plataforma` varchar(20) DEFAULT 'ERP',
  `origem` varchar(50) DEFAULT NULL,
  `ida` int DEFAULT NULL,
  `idb` int DEFAULT NULL,
  `idc` int DEFAULT NULL,
  `idprd` int NOT NULL,
  `sku` varchar(45) DEFAULT NULL,
  `cfop` varchar(5) DEFAULT NULL,
  `fiscal` enum('E','F') NOT NULL DEFAULT 'F',
  `tipo` enum('B','E','S','X') NOT NULL DEFAULT 'X',
  `qtde` decimal(12,3) NOT NULL DEFAULT '0.000',
  `custo` decimal(12,3) NOT NULL DEFAULT '0.000',
  `idprdman` int DEFAULT NULL,
  PRIMARY KEY (`idestoque`),
  KEY `fk_estoque_cnt_idx` (`idemp`),
  KEY `fk_estoque_usu_idx` (`idusu`),
  KEY `fk_estoque_usu2_idx` (`idusucancela`),
  KEY `fk_estoque_prd_idx` (`idprd`),
  KEY `fk_estoque_prdsku_idx` (`sku`),
  KEY `idx_estoque_chaves` (`ida`,`idb`,`idc`),
  KEY `idx_estoque_origem` (`origem`,`ida`),
  KEY `fk_estoque_prdman_idx` (`idprdman`),
  CONSTRAINT `fk_estoque_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_estoque_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_estoque_prdman` FOREIGN KEY (`idprdman`) REFERENCES `prd` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_estoque_prdsku` FOREIGN KEY (`sku`) REFERENCES `prdsku` (`sku`) ON UPDATE CASCADE,
  CONSTRAINT `fk_estoque_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_estoque_usu2` FOREIGN KEY (`idusucancela`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=2994 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.estoqueh010
CREATE TABLE IF NOT EXISTS `estoqueh010` (
  `idh010` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `exercicio` smallint unsigned NOT NULL,
  `idprd` int NOT NULL,
  `sku` varchar(45) DEFAULT NULL,
  `unidade` varchar(5) DEFAULT NULL,
  `custo` decimal(12,2) DEFAULT '0.00',
  `iniciof` decimal(15,3) DEFAULT '0.000',
  `entradaf` decimal(15,3) DEFAULT '0.000',
  `saidaf` decimal(15,3) DEFAULT '0.000',
  `saldof` decimal(15,3) DEFAULT '0.000',
  `totalf` decimal(15,3) DEFAULT '0.000',
  `inicioe` decimal(15,3) DEFAULT '0.000',
  `entradae` decimal(15,3) DEFAULT '0.000',
  `saidae` decimal(15,3) DEFAULT '0.000',
  `saldoe` decimal(15,3) DEFAULT '0.000',
  `totale` decimal(15,3) DEFAULT '0.000',
  PRIMARY KEY (`idh010`),
  KEY `fk_estoqueh010_prd_idx` (`idprd`),
  KEY `idx_estoqueh010_01` (`exercicio`,`idprd`),
  KEY `fk_estoqueh010_cnt_idx` (`idemp`),
  CONSTRAINT `fk_estoqueh010_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_estoqueh010_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=2631 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.estoqueheader
CREATE TABLE IF NOT EXISTS `estoqueheader` (
  `exercicio` smallint NOT NULL,
  `idemp` int unsigned NOT NULL,
  `fechado` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`exercicio`,`idemp`),
  KEY `fk_estoqueheader_emp_idx` (`idemp`),
  CONSTRAINT `fk_estoqueheader_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.estoquek200
CREATE TABLE IF NOT EXISTS `estoquek200` (
  `idbalanco` int unsigned NOT NULL AUTO_INCREMENT,
  `dthrbalanco` datetime NOT NULL,
  `idemp` int unsigned NOT NULL,
  `idprd` int NOT NULL,
  `sku` varchar(45) DEFAULT NULL,
  `qtdecalcula` decimal(12,3) NOT NULL DEFAULT '0.000',
  `qtdecorreta` decimal(12,3) NOT NULL DEFAULT '0.000',
  `custobalanco` decimal(12,3) NOT NULL DEFAULT '0.000',
  `fiscal` enum('E','F') NOT NULL DEFAULT 'F',
  `autocorrige` bit(1) NOT NULL DEFAULT b'0',
  `baixado` bit(1) NOT NULL DEFAULT b'0',
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  `idusu` int unsigned NOT NULL,
  PRIMARY KEY (`idbalanco`),
  KEY `fk_estoquek200_cnt_idx` (`idemp`),
  KEY `fk_estoquek200_prd_idx` (`idprd`),
  KEY `fk_estoquek200_sku_idx` (`sku`),
  KEY `idx_estoquek200_dtbalanco` (`dthrbalanco`),
  KEY `fk_estoquek200_usu_idx` (`idusu`),
  CONSTRAINT `fk_estoquek200_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_estoquek200_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_estoquek200_sku` FOREIGN KEY (`sku`) REFERENCES `prdsku` (`sku`) ON UPDATE CASCADE,
  CONSTRAINT `fk_estoquek200_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2800 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.estoquek200Mes
CREATE TABLE IF NOT EXISTS `estoquek200Mes` (
  `idk200` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `mes` varchar(7) NOT NULL,
  `idprd` int NOT NULL,
  `sku` varchar(45) DEFAULT NULL,
  `unidade` varchar(5) DEFAULT NULL,
  `custo` decimal(12,2) DEFAULT '0.00',
  `saldof` decimal(15,3) DEFAULT '0.000',
  `totalf` decimal(15,3) DEFAULT '0.000',
  `saldoe` decimal(15,3) DEFAULT '0.000',
  `totale` decimal(15,3) DEFAULT '0.000',
  PRIMARY KEY (`idk200`),
  KEY `fk_k200Mes_emp_idx` (`idemp`),
  KEY `fk_k200Mes_prd_idx` (`idprd`),
  KEY `idx_k200Mes_01` (`idemp`,`mes`,`idprd`),
  CONSTRAINT `fk_k200Mes_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_k200Mes_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=334 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.estoquek280
CREATE TABLE IF NOT EXISTS `estoquek280` (
  `idcorrige` int unsigned NOT NULL AUTO_INCREMENT,
  `dtcorrige` date NOT NULL,
  `idemp` int unsigned NOT NULL,
  `idprd` int NOT NULL,
  `sku` varchar(45) DEFAULT NULL,
  `qtdemais` decimal(12,3) NOT NULL DEFAULT '0.000',
  `qtdemenos` decimal(12,3) NOT NULL DEFAULT '0.000',
  `fiscal` enum('E','F') NOT NULL DEFAULT 'F',
  `baixado` bit(1) NOT NULL DEFAULT b'0',
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  `idusu` int unsigned NOT NULL,
  PRIMARY KEY (`idcorrige`),
  KEY `fk_estoquek280_cnt_idx` (`idemp`),
  KEY `fk_estoquek280_prd_idx` (`idprd`),
  KEY `fk_estoquek280_prdsku_idx` (`sku`),
  KEY `fk_estoquek280_usu_idx` (`idusu`),
  CONSTRAINT `fk_estoquek280_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_estoquek280_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_estoquek280_prdsku` FOREIGN KEY (`sku`) REFERENCES `prdsku` (`sku`) ON UPDATE CASCADE,
  CONSTRAINT `fk_estoquek280_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.fabricante
CREATE TABLE IF NOT EXISTS `fabricante` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `fabricante` varchar(60) NOT NULL,
  `cnpj` varchar(20) DEFAULT NULL,
  `logo` blob COMMENT 'max 64kb',
  PRIMARY KEY (`id`)
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.fat
CREATE TABLE IF NOT EXISTS `fat` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `fatura` varchar(40) DEFAULT NULL,
  `idvenda` int unsigned NOT NULL,
  `idoper` smallint unsigned NOT NULL,
  `idemp` int unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `fiscal` varchar(1) NOT NULL DEFAULT 'F',
  `dthremissao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dthrsaidaentra` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dthrentrega` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `valorprod` decimal(12,3) NOT NULL DEFAULT '0.000',
  `valorserv` decimal(12,3) NOT NULL DEFAULT '0.000',
  `valorfat` decimal(12,3) NOT NULL DEFAULT '0.000',
  `valorfrete` decimal(12,3) NOT NULL DEFAULT '0.000',
  `valorseguro` decimal(12,3) NOT NULL DEFAULT '0.000',
  `valoroutros` decimal(12,3) NOT NULL DEFAULT '0.000',
  `dedufonte` decimal(12,3) NOT NULL DEFAULT '0.000',
  `valorst` decimal(12,3) NOT NULL DEFAULT '0.000',
  `valoripi` decimal(12,3) NOT NULL DEFAULT '0.000',
  `valortotal` decimal(12,3) NOT NULL DEFAULT '0.000',
  `idcntend` int unsigned DEFAULT NULL,
  `idlog` int unsigned DEFAULT NULL,
  `pesobruto` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pesoliquido` decimal(12,3) NOT NULL DEFAULT '0.000',
  `volume` varchar(40) DEFAULT NULL,
  `quantidade` decimal(12,3) NOT NULL DEFAULT '0.000',
  `especie` varchar(40) DEFAULT NULL,
  `marca` varchar(60) DEFAULT NULL,
  `pesoreal` decimal(12,3) NOT NULL DEFAULT '0.000',
  `fretereal` decimal(12,3) NOT NULL DEFAULT '0.000',
  `tipofrete` enum('F','C','T','P','3','X') NOT NULL DEFAULT 'X',
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `fk_fat_venda_idx` (`idvenda`),
  KEY `fk_fat_operacoes_idx` (`idoper`),
  KEY `fk_fat_idemp_idx` (`idemp`),
  KEY `fk_fat_idcntend_idx` (`idcntend`),
  KEY `fk_fat_idlog_idx` (`idlog`),
  KEY `fk_fat_idcnt_idx` (`idcnt`),
  CONSTRAINT `fk_fat_idcnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_fat_idcntend` FOREIGN KEY (`idcntend`) REFERENCES `cntend` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_fat_idemp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_fat_idlog` FOREIGN KEY (`idlog`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_fat_operacoes` FOREIGN KEY (`idoper`) REFERENCES `operacoes` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_fat_venda` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.feriados
CREATE TABLE IF NOT EXISTS `feriados` (
  `ano` smallint NOT NULL,
  `uf` varchar(5) NOT NULL,
  `dia` date NOT NULL,
  `nome` varchar(120) DEFAULT NULL,
  `tipo` varchar(120) DEFAULT NULL,
  `cobertura` varchar(120) DEFAULT NULL,
  `lei` varchar(120) DEFAULT NULL,
  `inativo` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`ano`,`dia`,`uf`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.findestino
CREATE TABLE IF NOT EXISTS `findestino` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `destino` varchar(60) NOT NULL,
  `idemp` int unsigned DEFAULT NULL,
  `limitecred` decimal(15,3) NOT NULL DEFAULT '0.000',
  `inativo` bit(1) NOT NULL DEFAULT b'0',
  `idvincula` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_findestino_idemp_idx` (`idemp`),
  KEY `fk_findestino_findestino_idx` (`idvincula`),
  CONSTRAINT `fk_findestino_findestino` FOREIGN KEY (`idvincula`) REFERENCES `findestino` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_findestino_idemp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.finespecie
CREATE TABLE IF NOT EXISTS `finespecie` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `especie` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.finhist
CREATE TABLE IF NOT EXISTS `finhist` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `historico` varchar(80) NOT NULL,
  `debcred` varchar(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.finlancto
CREATE TABLE IF NOT EXISTS `finlancto` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(120) NOT NULL,
  `dtemi` date NOT NULL,
  `valor` decimal(12,2) NOT NULL DEFAULT '0.00',
  `debdtsaldo` date DEFAULT NULL,
  `debidespecie` smallint unsigned DEFAULT NULL,
  `debidhist` smallint unsigned DEFAULT NULL,
  `debiddest` smallint unsigned DEFAULT NULL,
  `debidmov` int unsigned DEFAULT NULL,
  `credtsaldo` date DEFAULT NULL,
  `creidespecie` smallint unsigned DEFAULT NULL,
  `creidhist` smallint unsigned DEFAULT NULL,
  `creiddest` smallint unsigned DEFAULT NULL,
  `creidmov` int unsigned DEFAULT NULL,
  `baixado` bit(1) NOT NULL DEFAULT b'0',
  `idemp` int unsigned NOT NULL,
  `idusu` int unsigned NOT NULL,
  `dthrcadastro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_finlancto_emp_idx` (`idemp`),
  KEY `fk_finlancto_usu_idx` (`idusu`),
  KEY `fk_finlancto_finmov_cred_idx` (`creidmov`),
  KEY `fk_finlancto_finmov_deb_idx` (`debidmov`),
  KEY `fk_finlancto_findest_cred_idx` (`creiddest`),
  KEY `fk_finlancto_findest_deb_idx` (`debiddest`),
  KEY `fk_finlacnto_finhist_cred_idx` (`creidhist`),
  KEY `fk_finlancto_finespecie_cred_idx` (`creidespecie`),
  KEY `fk_finlancto_finespecie_deb_idx` (`debidespecie`),
  KEY `fk_finlancto_finhist_deb_idx` (`debidhist`),
  CONSTRAINT `fk_finlacnto_finhist_cred` FOREIGN KEY (`creidhist`) REFERENCES `finhist` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_finlancto_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_finlancto_findest_cred` FOREIGN KEY (`creiddest`) REFERENCES `findestino` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_finlancto_findest_deb` FOREIGN KEY (`debiddest`) REFERENCES `findestino` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_finlancto_finespecie_cred` FOREIGN KEY (`creidespecie`) REFERENCES `finespecie` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_finlancto_finespecie_deb` FOREIGN KEY (`debidespecie`) REFERENCES `finespecie` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_finlancto_finhist_deb` FOREIGN KEY (`debidhist`) REFERENCES `finhist` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_finlancto_finmov_cred` FOREIGN KEY (`creidmov`) REFERENCES `finmov` (`idmov`) ON UPDATE CASCADE,
  CONSTRAINT `fk_finlancto_finmov_deb` FOREIGN KEY (`debidmov`) REFERENCES `finmov` (`idmov`) ON UPDATE CASCADE,
  CONSTRAINT `fk_finlancto_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.finmov
CREATE TABLE IF NOT EXISTS `finmov` (
  `idmov` int unsigned NOT NULL AUTO_INCREMENT,
  `dataemi` date NOT NULL,
  `datasaldo` date NOT NULL,
  `debcred` varchar(1) NOT NULL,
  `idemp` int unsigned NOT NULL,
  `iddest` smallint unsigned NOT NULL,
  `idespecie` smallint unsigned NOT NULL,
  `idhist` smallint unsigned NOT NULL,
  `valor` decimal(15,2) NOT NULL,
  `databaixa` date DEFAULT NULL,
  `valorbaixa` decimal(15,2) DEFAULT NULL,
  `baixado` bit(1) NOT NULL DEFAULT b'0',
  `tborigem` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`idmov`),
  KEY `fk_finmov_finhist_idx` (`idhist`),
  KEY `fk_finmov_finesp_idx` (`idespecie`),
  KEY `fk_finmov_findest_idx` (`iddest`),
  KEY `idx_dataemi_debcred` (`dataemi`,`debcred`),
  KEY `idx_datasaldo_debcred` (`datasaldo`,`debcred`),
  KEY `fk_finmov_emp_idx` (`idemp`),
  CONSTRAINT `fk_finmov_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_finmov_findest` FOREIGN KEY (`iddest`) REFERENCES `findestino` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_finmov_finesp` FOREIGN KEY (`idespecie`) REFERENCES `finespecie` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_finmov_finhist` FOREIGN KEY (`idhist`) REFERENCES `finhist` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=595 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.formapg
CREATE TABLE IF NOT EXISTS `formapg` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `nmforma` varchar(60) NOT NULL,
  `operacao` varchar(1) NOT NULL,
  `inativo` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para função b3erp.dsv.format_abrev
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `format_abrev`(`vaux` VARCHAR(120)) RETURNS varchar(60) CHARSET utf8mb3
    SQL SECURITY INVOKER
BEGIN
declare xaux varchar(60) default '';
declare resta varchar(120) default '';
declare indice smallint default 0;
declare iabrev smallint default 0;
declare v1 smallint default 5;

set resta  = vaux;
set indice = locate(' ', vaux);
set xaux   = concat(substring(vaux, 1, 3), ' ');

while (indice > 0) and (v1 > 0) do
  set resta = trim(substring(resta, indice+1, char_length(resta)-indice));
  set iabrev = locate(' ', substring(resta, 1, 3));

  if iabrev in (0, 3) then
    set xaux = concat(xaux, replace(substring(resta, 1, 3), ' ', ''), ' ');
  else
    set xaux = concat(xaux, substring(resta, 1, 1), ' ');
  end if;

  set indice = locate(' ', resta);
  set v1 = v1 - 1;
end while;

return xaux;
END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.format_docfed
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `format_docfed`(doc VARCHAR(30)) RETURNS varchar(30) CHARSET utf8mb3
    SQL SECURITY INVOKER
BEGIN

return case char_length(doc) 
 when 11 then INSERT( INSERT( INSERT( doc, 10, 0, '-' ), 7, 0, '.' ), 4, 0, '.' )
 when 14 then INSERT( INSERT( INSERT( INSERT( doc, 13, 0, '-' ), 9, 0, '/' ), 6, 0, '.' ), 3, 0, '.' )
 else 'não informado'
end;

END//
DELIMITER ;

-- Copiando estrutura para tabela b3erp.dsv.formgrid
CREATE TABLE IF NOT EXISTS `formgrid` (
  `nmform` varchar(80) NOT NULL,
  `nmcomponent` varchar(120) NOT NULL,
  `cfggrid` blob,
  PRIMARY KEY (`nmform`,`nmcomponent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para função b3erp.dsv.func_cobstat
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_cobstat`(idcta int) RETURNS int
    SQL SECURITY INVOKER
BEGIN
declare cobstat int;

set cobstat = 0;

select 1 as stat from cobtitulo where idctarec=idcta and not cancelado limit 1 into cobstat;

select 2 as stat from ctareceber rec
inner join cobretorno ret on (ret.nrodoc=concat(rec.idvenda,'/',rec.parcela))
where rec.idctarec = idcta and ret.confirmado limit 1 into cobstat;

return cobstat;
END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.func_dthr
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_dthr`() RETURNS datetime
    SQL SECURITY INVOKER
BEGIN
  declare TZ varchar(30);
  declare DataHora DATETIME;
  
  SELECT @@global.time_zone into TZ;

  if TZ = 'UTC' then
    select date_add(NOW(), interval -3 hour) into DataHora;
  else
    select NOW() into DataHora;
  end if;
  
  return DataHora;
END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.func_getnfe
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_getnfe`(nrovenda int) RETURNS int
    SQL SECURITY INVOKER
BEGIN
declare nronfe int;

select docnfe.idnfe from fat
left outer join docnfe on (fat.id = docnfe.idfat)
where (fat.idvenda = nrovenda) and (not docnfe.cancelado) and (not docnfe.inutilizada) and (docnfe.aprovado) into nronfe;

return nronfe;
END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.func_getnfse
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_getnfse`(nrovenda int) RETURNS int
    SQL SECURITY INVOKER
BEGIN
declare nronfse int;

select docnfse.idnfse from fat
left outer join docnfse on (fat.id = docnfse.idfat)
where (fat.idvenda = nrovenda) and (not docnfse.cancelado) and (docnfse.aprovado) into nronfse;

return nronfse;
END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.func_movto_prd
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_movto_prd`(
	`XIDEMP` integer,
	`XIDPROD` integer,
	`XDATAINI` datetime,
	`XDATAFIM` datetime,
	`XFISCAL` enum('E', 'F', 'X'),
	`XTIPO` enum('E', 'S')
) RETURNS decimal(15,3)
    SQL SECURITY INVOKER
BEGIN
declare qtdeMovto decimal(15,3);
set qtdeMovto = 0;

    select coalesce(sum(qtde), 0) from estoque 
    where idemp=XIDEMP and idprd=XIDPROD and sku is null and if(XFISCAL='X', 1=1, fiscal=XFISCAL) and not cancelado
    and tipo=XTIPO and dthremissao between XDATAINI and XDATAFIM into qtdeMovto;

return qtdeMovto;
END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.func_receb_situ
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_receb_situ`(idcta int) RETURNS varchar(30) CHARSET utf8mb3
    SQL SECURITY INVOKER
BEGIN

declare xhoje date;
declare xven date;
declare xpag date;
declare xanu bit(1);
declare xboni bit(1);
declare xperda bit(1);
declare xpago decimal(12,3);
declare situ varchar(30);

set xhoje = cast(func_dthr() as date);

select vencimento, pagamento, valorpago, anulada, perda, bonificado from ctareceber
where (idctarec = idcta) into xven, xpag, xpago, xanu, xperda, xboni;

if (xanu = True) then
  set situ = 'ANULADA';
elseif (xperda = True) then
  set situ = 'PERDA_ADMITIDA';
elseif (xperda = True) then
  set situ = 'BONIFICADO';
elseif (xpag is not null) and (xpago > 0) then
  set situ = 'QUITADA';
elseif (xpag is null) and (xven < xhoje) then
  set situ = 'VENCIDA';
else
  set situ = 'A_VENCER';
end if;

return situ;
END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.func_saldodia
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_saldodia`(
	`XIDEMP` integer,
	`XIDPROD` integer,
	`XDATA` datetime,
	`XFISCAL` enum('E', 'F', 'X')
) RETURNS decimal(15,3)
    SQL SECURITY INVOKER
BEGIN
declare datak200 datetime;
declare qtdek200 decimal(15,3);
declare qtdeEntradas decimal(15,3);
declare qtdeSaidas decimal(15,3);
declare SaldoDia decimal(15,3);

set qtdek200 = 0;
set qtdeEntradas = 0;
set qtdeSaidas = 0;
set SaldoDia = 0;

if XFISCAL in ('E', 'F') then
   select dthrbalanco, coalesce(qtdecorreta, 0) from estoquek200 where
   idemp=XIDEMP and idprd=XIDPROD and fiscal=XFISCAL and sku is null and not cancelado and baixado and
   dthrbalanco in (
   select max(dthrbalanco) from estoquek200 where dthrbalanco<=XDATA 
   and idemp=XIDEMP and idprd=XIDPROD and fiscal=XFISCAL and sku is null and not cancelado and baixado
   ) into datak200, qtdek200;
   
   if (datak200 is null) then
      select dthrbalanco, coalesce(qtdecorreta, 0) from estoquek200 where
      idemp=XIDEMP and idprd=XIDPROD and fiscal=XFISCAL and sku is null and not cancelado and baixado and
      dthrbalanco in (
      select min(dthrbalanco) from estoquek200 where dthrbalanco>=XDATA 
      and idemp=XIDEMP and idprd=XIDPROD and fiscal=XFISCAL and sku is null and not cancelado and baixado
      ) into datak200, qtdek200;
      
      if (datak200 is null) then
         set datak200 = XDATA;
         set qtdek200 = 0.000;
      end if;
   end if;
else
   select max(dthrbalanco), sum(coalesce(qtdecorreta, 0)) from estoquek200 where
   idemp=XIDEMP and idprd=XIDPROD and sku is null and not cancelado and baixado and
   dthrbalanco in (
   select max(dthrbalanco) from estoquek200 where dthrbalanco<=XDATA 
   and idemp=XIDEMP and idprd=XIDPROD and sku is null and not cancelado and baixado
   ) into datak200, qtdek200;
   
   if (datak200 is null) then
      select min(dthrbalanco), sum(coalesce(qtdecorreta, 0)) from estoquek200 where
      idemp=XIDEMP and idprd=XIDPROD and sku is null and not cancelado and baixado and
      dthrbalanco in (
      select min(dthrbalanco) from estoquek200 where dthrbalanco>=XDATA 
      and idemp=XIDEMP and idprd=XIDPROD and sku is null and not cancelado and baixado
      ) into datak200, qtdek200;
      
      if (datak200 is null) then
         set datak200 = XDATA;
         set qtdek200 = 0.000;
      end if;
   end if;
end if;

-- achou balanço anterior
if ((datak200 <> XDATA) and (datak200 < XDATA)) then
	-- nessa situação subtrai saidas e soma entradas
    select coalesce(sum(qtde), 0) from estoque 
    where idemp=XIDEMP and idprd=XIDPROD and sku is null and if(XFISCAL='X', 1=1, fiscal=XFISCAL) and not cancelado
    and tipo='S' and dthrestoque between datak200 and XDATA into qtdeSaidas;
    
	select coalesce(sum(qtde), 0) from estoque 
    where idemp=XIDEMP and idprd=XIDPROD and sku is null and if(XFISCAL='X', 1=1, fiscal=XFISCAL) and not cancelado
    and tipo='E' and dthrestoque between datak200 and XDATA into qtdeEntradas;
    
    set SaldoDia = (qtdek200 + qtdeEntradas) - (qtdeSaidas); 
elseif ((datak200 <> XDATA) and (datak200 > XDATA)) then
	-- nessa situação soma saidas e subtrai entradas
    select coalesce(sum(qtde), 0) from estoque 
    where idemp=XIDEMP and idprd=XIDPROD and sku is null and if(XFISCAL='X', 1=1, fiscal=XFISCAL) and not cancelado
    and tipo='S' and dthrestoque between XDATA and datak200 into qtdeSaidas;
    
	select coalesce(sum(qtde), 0) from estoque 
    where idemp=XIDEMP and idprd=XIDPROD and sku is null and if(XFISCAL='X', 1=1, fiscal=XFISCAL) and not cancelado
    and tipo='E' and dthrestoque between XDATA and datak200 into qtdeEntradas;
    
    set SaldoDia = (qtdek200 + qtdeSaidas) - (qtdeEntradas);
else
	set SaldoDia = qtdek200;
end if;

return SaldoDia;
END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.func_saldodiasku
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_saldodiasku`(
	`XIDEMP` integer,
	`XIDPROD` integer,
	`XSKU` varchar(45),
	`XDATA` datetime,
	`XFISCAL` enum('E', 'F')
) RETURNS decimal(15,3)
    SQL SECURITY INVOKER
BEGIN
declare datak200 datetime;
declare qtdek200 decimal(15,3);
declare qtdeEntradas decimal(15,3);
declare qtdeSaidas decimal(15,3);
declare SaldoDia decimal(15,3);

set qtdek200 = 0;
set qtdeEntradas = 0;
set qtdeSaidas = 0;
set SaldoDia = 0;

select dthrbalanco, coalesce(qtdecorreta, 0) from estoquek200 where
idemp=XIDEMP and idprd=XIDPROD and fiscal=XFISCAL and sku=XSKU and not cancelado and baixado and
dthrbalanco in (
select max(dthrbalanco) from estoquek200 where dthrbalanco<=XDATA 
and idemp=XIDEMP and idprd=XIDPROD and fiscal=XFISCAL and sku=XSKU and not cancelado and baixado
) into datak200, qtdek200;

if (datak200 is null) then
	select dthrbalanco, coalesce(qtdecorreta, 0) from estoquek200 where
	idemp=XIDEMP and idprd=XIDPROD and fiscal=XFISCAL and sku=XSKU and not cancelado and baixado and
	dthrbalanco in (
	select min(dthrbalanco) from estoquek200 where dthrbalanco>=XDATA 
	and idemp=XIDEMP and idprd=XIDPROD and fiscal=XFISCAL and sku=XSKU and not cancelado and baixado
	) into datak200, qtdek200;
    
	if (datak200 is null) then
		set datak200 = XDATA;
        set qtdek200 = 0.000;
	end if;
end if;

-- achou balanço anterior
if ((datak200 <> XDATA) and (datak200 < XDATA)) then
	-- nessa situação subtrai saidas e soma entradas
    select coalesce(sum(qtde), 0) from estoque 
    where idemp=XIDEMP and idprd=XIDPROD and sku=XSKU and fiscal=XFISCAL and not cancelado
    and tipo='S' and dthremissao between datak200 and XDATA into qtdeSaidas;
    
	select coalesce(sum(qtde), 0) from estoque 
    where idemp=XIDEMP and idprd=XIDPROD and sku=XSKU and fiscal=XFISCAL and not cancelado
    and tipo='E' and dthremissao between datak200 and XDATA into qtdeEntradas;
    
    set SaldoDia = (qtdek200 + qtdeEntradas) - (qtdeSaidas); 
elseif ((datak200 <> XDATA) and (datak200 > XDATA)) then
	-- nessa situação soma saidas e subtrai entradas
    select coalesce(sum(qtde), 0) from estoque 
    where idemp=XIDEMP and idprd=XIDPROD and sku=XSKU and fiscal=XFISCAL and not cancelado
    and tipo='S' and dthremissao between XDATA and datak200 into qtdeSaidas;
    
	select coalesce(sum(qtde), 0) from estoque 
    where idemp=XIDEMP and idprd=XIDPROD and sku=XSKU and fiscal=XFISCAL and not cancelado
    and tipo='E' and dthremissao between XDATA and datak200 into qtdeEntradas;
    
    set SaldoDia = (qtdek200 + qtdeSaidas) - (qtdeEntradas);
else
	set SaldoDia = qtdek200;
end if;

return SaldoDia;
END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.func_tipomov
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_tipomov`(
	`itipo` TINYINT
) RETURNS varchar(120) CHARSET utf8mb3
    SQL SECURITY INVOKER
BEGIN
declare xaux varchar(120) default '09 - Outras Movimentações';

return case itipo
  when 0 then concat(lpad(itipo, 2, '0'), ' - ', 'Compras (Comercialização / Industrialização)')
  when 1 then concat(lpad(itipo, 2, '0'), ' - ', 'Compras (Uso / Consumo / Ativo Imobilizado)')
  when 2 then concat(lpad(itipo, 2, '0'), ' - ', 'Devoluções (Item Adquirido)')
  when 3 then concat(lpad(itipo, 2, '0'), ' - ', 'Devoluções (Item Vendido)')
  when 4 then concat(lpad(itipo, 2, '0'), ' - ', 'Devoluções (Item Garantia)')
  when 5 then concat(lpad(itipo, 2, '0'), ' - ', 'Devoluções (Item Descarte)')
  when 6 then concat(lpad(itipo, 2, '0'), ' - ', 'Remessa / Tranferências (Saída)')
  when 7 then concat(lpad(itipo, 2, '0'), ' - ', 'Retorno / Tranferências (Entrada)')
  when 8 then concat(lpad(itipo, 2, '0'), ' - ', 'Remessa / Retorno (não movimenta estoque)')
  else xaux
end;
END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.func_valoricms
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_valoricms`(nrovenda int, seqvenda smallint) RETURNS decimal(12,3)
    SQL SECURITY INVOKER
BEGIN
declare vicms decimal(12,3);

select
cast(coalesce(if(c.icmsredu = 0, 
(a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) * (coalesce(if(cli.uf <> emp.uf, cu.picms, c.icmsaliq), 0) / 100), 
((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) * ((100-c.icmsredu) / 100)) * (coalesce(if(cli.uf <> emp.uf, cu.picms, c.icmsaliq), 0) / 100)), 0) as decimal(12,2)) as vicms
from vendaitem a 
left outer join venda v on (v.id = a.idvenda) 
left outer join prd p on (p.id = a.idprod) 
left outer join vendaoper vo on (vo.idvenda = a.idvenda) and (vo.seq = a.seq) 
left outer join impostos c on (c.id = vo.idimposto) 
left outer join operacoes op on (op.id = vo.idoperacao) 
left outer join ibpt d on (d.codigo = coalesce(p.ncm, '00000000')) and (d.ex='') 
left outer join cnt emp on (emp.id = v.idemp) 
left outer join cnt cli on (cli.id = v.idcli) 
left outer join impostouf cu on ((cu.idimposto = c.id) and (cu.uf = cli.uf))
where (a.idvenda=nrovenda) and (a.seq=seqvenda) into vicms;

return vicms;
END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.func_venda_compo
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_venda_compo`(xvenda int) RETURNS smallint
    SQL SECURITY INVOKER
BEGIN
declare xcount int;
declare xresult smallint;

select count(vi.s) as n from (
  select distinct servico as s from vendaitem where idvenda=xvenda
) as vi into xcount;

if (xcount = 1) then
  select distinct servico as s from vendaitem where idvenda=xvenda into xresult;
else
  set xresult = 2;
end if;

return xresult;

END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.func_venda_impostoprd
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_venda_impostoprd`(xvenda int, xseq  smallint) RETURNS int
    SQL SECURITY INVOKER
BEGIN
declare ximposto int;
declare xsubtipo varchar(1);

select subtipo from venda where id=xvenda into xsubtipo;

if (xsubtipo = 'G') then
	set ximposto = 1;
else
	select coalesce(pi.idimposto, 1) as idimposto 
	from vendaitem vi
	inner join venda v on (vi.idvenda = v.id)
	left outer join prdimposto pi on (pi.idprd = vi.idprod) and (pi.idoperacao=func_venda_operacaoprd(vi.idvenda, vi.seq))
	where vi.idvenda=xvenda and vi.seq=xseq into ximposto;
end if;

return ximposto;
END//
DELIMITER ;

-- Copiando estrutura para função b3erp.dsv.func_venda_operacaoprd
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` FUNCTION `func_venda_operacaoprd`(xvenda int, xseq  smallint) RETURNS int
    SQL SECURITY INVOKER
BEGIN
declare xoperacao int;
declare xprod int;
declare xemp int;
declare xsubtipo varchar(1);
declare blinter boolean;

select idemp, subtipo from venda where id=xvenda into xemp, xsubtipo;

select o.interestatual from venda v
inner join operacoes o on (o.id = v.idoper)
where v.id = xvenda into blinter;

if (xsubtipo in ('N','B','T')) then
	select pi.idoperacao, vi.idprod from vendaitem vi
	inner join venda v on (vi.idvenda = v.id)
	left outer join prdimposto pi on (pi.idprd = vi.idprod) and (pi.idoperacao=v.idoper)
	where vi.idvenda=xvenda and vi.seq=xseq into xoperacao, xprod;
end if;

if (xoperacao is null) then
	select idoperacao from prdimposto pi
	inner join operacoes o on (o.id = pi.idoperacao) and (o.subtipo = 'N') and (o.finalidade in ('R','C','I')) and
							  (o.interestatual=blinter) and (o.idemp is null or o.idemp=xemp)
	where pi.idprd=xprod LIMIT 1 into xoperacao;
end if;

if (xoperacao is null) then
	select idoper from venda
	where venda.id=xvenda into xoperacao;
end if;

return xoperacao;
END//
DELIMITER ;

-- Copiando estrutura para tabela b3erp.dsv.ibpt
CREATE TABLE IF NOT EXISTS `ibpt` (
  `codigo` varchar(10) NOT NULL,
  `ex` varchar(10) NOT NULL DEFAULT '',
  `tipo` varchar(10) NOT NULL DEFAULT '',
  `descricao` varchar(500) DEFAULT NULL,
  `nacionalfederal` decimal(10,2) DEFAULT NULL,
  `importadosfederal` decimal(10,2) DEFAULT NULL,
  `estadual` decimal(10,2) DEFAULT NULL,
  `municipal` decimal(10,2) DEFAULT NULL,
  `vigenciainicio` date DEFAULT NULL,
  `vigenciafim` date DEFAULT NULL,
  `chave` varchar(20) DEFAULT NULL,
  `versao` varchar(20) DEFAULT NULL,
  `fonte` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`codigo`,`ex`,`tipo`)
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.impostoloja
CREATE TABLE IF NOT EXISTS `impostoloja` (
  `idimposto` int NOT NULL,
  `idemp` int unsigned NOT NULL,
  `icmsaliq` decimal(12,3) NOT NULL DEFAULT '0.000',
  `issaliq` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idimposto`,`idemp`),
  KEY `fk_impostoloja_cnt_idx` (`idemp`),
  CONSTRAINT `fk_impostoloja_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_impostoloja_impostos` FOREIGN KEY (`idimposto`) REFERENCES `impostos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.impostoretido
CREATE TABLE IF NOT EXISTS `impostoretido` (
  `idimposto` int NOT NULL,
  `nome` varchar(60) NOT NULL,
  `aliquota` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idimposto`,`nome`),
  CONSTRAINT `fk_impostoretido_impostos` FOREIGN KEY (`idimposto`) REFERENCES `impostos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.impostos
CREATE TABLE IF NOT EXISTS `impostos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `descricao` varchar(60) NOT NULL,
  `icmscst` varchar(3) NOT NULL DEFAULT '41',
  `modbc` enum('0','1','2','3') DEFAULT '3',
  `icmsaliq` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `icmsredu` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `modbcst` enum('0','1','2','3','4','5') DEFAULT '4',
  `icmsiva` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `icmspdif` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `icmsecf` varchar(10) NOT NULL DEFAULT 'II',
  `piscst` varchar(3) NOT NULL DEFAULT '08',
  `pisaliq` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `pisvalor` decimal(9,4) NOT NULL DEFAULT '0.0000',
  `cofinscst` varchar(3) NOT NULL DEFAULT '08',
  `cofinsaliq` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `cofinsvalor` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `ipicst` varchar(3) NOT NULL DEFAULT '53',
  `ipialiq` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `ipivalor` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `codLCP116` varchar(10) DEFAULT NULL,
  `codTribMun` varchar(30) DEFAULT NULL,
  `issaliq` decimal(8,4) NOT NULL DEFAULT '0.0000',
  `obsnf` varchar(244) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_impostos_prdicmscst1_idx` (`icmscst`),
  KEY `fk_impostos_prdpiscst1_idx` (`piscst`),
  KEY `fk_impostos_prdpiscst2_idx` (`cofinscst`),
  KEY `fk_impostos_prdipicst1_idx` (`ipicst`),
  CONSTRAINT `fk_impostos_prdicmscst1` FOREIGN KEY (`icmscst`) REFERENCES `prdicmscst` (`cst`) ON UPDATE CASCADE,
  CONSTRAINT `fk_impostos_prdipicst1` FOREIGN KEY (`ipicst`) REFERENCES `prdipicst` (`cst`) ON UPDATE CASCADE,
  CONSTRAINT `fk_impostos_prdpiscst1` FOREIGN KEY (`piscst`) REFERENCES `prdpiscst` (`cst`) ON UPDATE CASCADE,
  CONSTRAINT `fk_impostos_prdpiscst2` FOREIGN KEY (`cofinscst`) REFERENCES `prdpiscst` (`cst`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.impostouf
CREATE TABLE IF NOT EXISTS `impostouf` (
  `idimposto` int NOT NULL,
  `uf` varchar(10) NOT NULL,
  `picms` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idimposto`,`uf`),
  CONSTRAINT `fk_impostouf_impostos` FOREIGN KEY (`idimposto`) REFERENCES `impostos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.log
CREATE TABLE IF NOT EXISTS `log` (
  `idlog` int unsigned NOT NULL AUTO_INCREMENT,
  `idusu` int unsigned NOT NULL,
  `idsup` int unsigned NOT NULL,
  `quando` datetime NOT NULL,
  `operacao` varchar(280) DEFAULT NULL,
  `idemp` int unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`idlog`),
  KEY `fk_log_usu1_idx` (`idusu`),
  KEY `fk_log_usu2_idx` (`idsup`),
  KEY `fk_log_emp_idx` (`idemp`),
  CONSTRAINT `fk_log_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_log_usu1` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_log_usu2` FOREIGN KEY (`idsup`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=433 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mailcfg
CREATE TABLE IF NOT EXISTS `mailcfg` (
  `idmail` smallint NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned DEFAULT NULL,
  `setor` varchar(1) NOT NULL,
  `tipo` enum('O','E','D') NOT NULL,
  `email` varchar(60) NOT NULL,
  `dominio` varchar(60) DEFAULT NULL,
  `servidor` varchar(120) DEFAULT NULL,
  `porta` varchar(20) DEFAULT NULL,
  `usuario` varchar(120) DEFAULT NULL,
  `senha` varchar(120) DEFAULT NULL,
  `ssl` bit(1) NOT NULL DEFAULT b'0',
  `tls` bit(1) NOT NULL DEFAULT b'0',
  `valido` bit(1) NOT NULL DEFAULT b'0',
  `ativo` bit(1) DEFAULT b'0',
  PRIMARY KEY (`idmail`),
  UNIQUE KEY `idx_emp_setor_unique` (`idemp`,`setor`),
  CONSTRAINT `fk_mailcfg_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mdfe
CREATE TABLE IF NOT EXISTS `mdfe` (
  `idmdfe` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `dthremissao` datetime NOT NULL,
  `tpemit` enum('1','2') NOT NULL DEFAULT '1',
  `modal` enum('1','2','3','4') NOT NULL DEFAULT '1',
  `ufinicio` varchar(4) DEFAULT NULL,
  `uffim` varchar(4) DEFAULT NULL,
  `veiculoplaca` varchar(30) DEFAULT NULL,
  `veiculotara` int unsigned NOT NULL DEFAULT '0',
  `propdocfed` varchar(20) DEFAULT NULL,
  `proprntrc` varchar(20) DEFAULT NULL,
  `propnome` varchar(80) DEFAULT NULL,
  `propdocest` varchar(20) DEFAULT NULL,
  `propuf` varchar(4) DEFAULT NULL,
  `proptipo` varchar(1) DEFAULT NULL,
  `condunome` varchar(80) DEFAULT NULL,
  `conducpf` varchar(20) DEFAULT NULL,
  `tipoveiculo` varchar(2) NOT NULL DEFAULT '06',
  `tipocarroceria` varchar(2) NOT NULL DEFAULT '00',
  `ufveiculo` varchar(4) NOT NULL DEFAULT 'SP',
  `vcarga` decimal(12,3) DEFAULT '0.000',
  `cunid` varchar(2) DEFAULT '01',
  `qcarga` decimal(12,3) DEFAULT '0.000',
  `respseg` enum('1','2') NOT NULL DEFAULT '1',
  `respdocfed` varchar(20) DEFAULT NULL,
  `segnome` varchar(30) DEFAULT NULL,
  `segdocfed` varchar(20) DEFAULT NULL,
  `napol` varchar(20) DEFAULT NULL,
  `naver` varchar(40) DEFAULT NULL,
  `prodtipo` varchar(2) NOT NULL DEFAULT '05',
  `prodnome` varchar(80) DEFAULT NULL,
  `obs` varchar(400) DEFAULT NULL,
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idmdfe`),
  KEY `fk_mdfe_cntemp_idx` (`idemp`),
  CONSTRAINT `fk_mdfe_cntemp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mdfecarga
CREATE TABLE IF NOT EXISTS `mdfecarga` (
  `idmdfe` int unsigned NOT NULL,
  `codmun` varchar(10) NOT NULL,
  `nomemun` varchar(60) NOT NULL,
  `ufmun` varchar(4) NOT NULL,
  `cepmun` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`idmdfe`,`codmun`),
  CONSTRAINT `fk_mdfecarga_mdfe` FOREIGN KEY (`idmdfe`) REFERENCES `mdfe` (`idmdfe`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mdfecfg
CREATE TABLE IF NOT EXISTS `mdfecfg` (
  `idemp` int unsigned NOT NULL,
  `modelo` varchar(10) DEFAULT '58',
  `seriemdfe` varchar(10) DEFAULT '0',
  `seqmdfe` int DEFAULT '1',
  `tipoemissao` varchar(1) DEFAULT '1',
  `ambiente` varchar(1) DEFAULT '1',
  `sslmdfe` varchar(1) DEFAULT '0',
  `seuemail` varchar(80) DEFAULT NULL,
  `assuntoemail` varchar(120) DEFAULT NULL,
  `ncopiasdamdfe` tinyint DEFAULT '1',
  `enviadamdfe` bit(1) DEFAULT b'1',
  `rntrc` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`idemp`),
  CONSTRAINT `fk_mdfecfg_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mdfecnt
CREATE TABLE IF NOT EXISTS `mdfecnt` (
  `idmdfe` int unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  PRIMARY KEY (`idmdfe`,`idcnt`),
  KEY `fk_mdfecnt_cnt_idx` (`idcnt`),
  CONSTRAINT `fk_mdfecnt_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mdfedescarga
CREATE TABLE IF NOT EXISTS `mdfedescarga` (
  `idmdfe` int unsigned NOT NULL,
  `codmun` varchar(10) NOT NULL,
  `nomemun` varchar(60) NOT NULL,
  `ufmun` varchar(4) NOT NULL,
  `cepmun` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`idmdfe`,`codmun`),
  CONSTRAINT `fk_mdfedescarga_mdfe` FOREIGN KEY (`idmdfe`) REFERENCES `mdfe` (`idmdfe`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mdfedocs
CREATE TABLE IF NOT EXISTS `mdfedocs` (
  `idmdfe` int unsigned NOT NULL,
  `codmun` varchar(10) NOT NULL,
  `chavedoc` varchar(60) NOT NULL,
  `tipodoc` enum('0','1') NOT NULL DEFAULT '0',
  PRIMARY KEY (`idmdfe`,`codmun`,`chavedoc`),
  CONSTRAINT `fk_mdfedocs_mdfedescarga` FOREIGN KEY (`idmdfe`, `codmun`) REFERENCES `mdfedescarga` (`idmdfe`, `codmun`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mdfepercur
CREATE TABLE IF NOT EXISTS `mdfepercur` (
  `idmdfe` int unsigned NOT NULL,
  `ufpercur` varchar(4) NOT NULL,
  PRIMARY KEY (`idmdfe`,`ufpercur`),
  CONSTRAINT `fk_mdfepercur_mdfe` FOREIGN KEY (`idmdfe`) REFERENCES `mdfe` (`idmdfe`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mdfereboque
CREATE TABLE IF NOT EXISTS `mdfereboque` (
  `idmdfe` int unsigned NOT NULL,
  `placa` varchar(30) NOT NULL,
  `tara` int NOT NULL DEFAULT '0',
  `capacidade` int NOT NULL DEFAULT '0',
  `propdocfed` varchar(20) DEFAULT NULL,
  `proprntrc` varchar(20) DEFAULT NULL,
  `propnome` varchar(80) DEFAULT NULL,
  `propdocest` varchar(20) DEFAULT NULL,
  `propuf` varchar(4) DEFAULT NULL,
  `proptipo` varchar(1) NOT NULL DEFAULT '2',
  `tiporeboque` varchar(2) NOT NULL DEFAULT '02',
  `ufreboque` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`idmdfe`,`placa`),
  CONSTRAINT `fk_mdfereboque_mdfe` FOREIGN KEY (`idmdfe`) REFERENCES `mdfe` (`idmdfe`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mnu
CREATE TABLE IF NOT EXISTS `mnu` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `idpai` smallint DEFAULT '1',
  `nome` varchar(100) NOT NULL,
  `descricao` varchar(200) DEFAULT NULL,
  `sql` mediumtext,
  `exe` varchar(200) DEFAULT NULL,
  `anexo` bit(1) DEFAULT b'0',
  `tipo` enum('M','E','P','R','S') DEFAULT 'M',
  `ordem` smallint NOT NULL DEFAULT '0',
  `idicone` smallint DEFAULT NULL,
  `icone` mediumblob,
  `nmclasse` varchar(80) DEFAULT NULL,
  `atalho` varchar(45) DEFAULT NULL,
  `fonte` mediumtext,
  `liberado` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  KEY `IDX_FK_IDMNU_IDPAI` (`idpai`),
  CONSTRAINT `FK_IDMNU_IDPAI` FOREIGN KEY (`idpai`) REFERENCES `mnu` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=371 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mnuagenda
CREATE TABLE IF NOT EXISTS `mnuagenda` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idusu` int unsigned NOT NULL,
  `dthr` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `situacao` tinyint NOT NULL DEFAULT '1',
  `texto` tinytext,
  PRIMARY KEY (`id`),
  KEY `fk_usu_mnuagenda_idx` (`idusu`),
  KEY `idx_usu_dthr` (`idusu`,`dthr`),
  CONSTRAINT `fk_usu_mnuagenda` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mnucampos
CREATE TABLE IF NOT EXISTS `mnucampos` (
  `idmnu` smallint NOT NULL,
  `id` smallint unsigned NOT NULL,
  `nmcampo` varchar(60) NOT NULL,
  `descampo` varchar(120) DEFAULT NULL,
  `tipocampo` enum('N','I','R','T','D','W','1','2','3','X') NOT NULL DEFAULT 'X',
  `leitura` bit(1) DEFAULT b'0',
  `alinhamento` enum('','E','C','D') DEFAULT NULL,
  PRIMARY KEY (`idmnu`,`id`),
  KEY `fk_mnucampos_mnu1_idx` (`idmnu`),
  CONSTRAINT `fk_mnucampos_mnu1` FOREIGN KEY (`idmnu`) REFERENCES `mnu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mnudash
CREATE TABLE IF NOT EXISTS `mnudash` (
  `tipochart` varchar(60) NOT NULL,
  `idchart` int NOT NULL,
  PRIMARY KEY (`tipochart`,`idchart`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mnugrid
CREATE TABLE IF NOT EXISTS `mnugrid` (
  `idmnu` smallint NOT NULL,
  `cfggrid` blob,
  PRIMARY KEY (`idmnu`),
  CONSTRAINT `fk_mnugrid_mnu1` FOREIGN KEY (`idmnu`) REFERENCES `mnu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mnuradios
CREATE TABLE IF NOT EXISTS `mnuradios` (
  `idmnu` smallint NOT NULL,
  `idcampos` smallint unsigned NOT NULL,
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `descitem` varchar(60) NOT NULL,
  `valitem` varchar(60) NOT NULL,
  PRIMARY KEY (`id`,`idmnu`,`idcampos`),
  KEY `fk_mnuradios_mnucampos1_idx` (`idmnu`,`idcampos`),
  CONSTRAINT `fk_mnuradios_mnucampos1` FOREIGN KEY (`idmnu`, `idcampos`) REFERENCES `mnucampos` (`idmnu`, `id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mnurel
CREATE TABLE IF NOT EXISTS `mnurel` (
  `idmnu` smallint NOT NULL,
  `sql1` mediumtext,
  `ifn1` varchar(60) DEFAULT NULL,
  `ms1` varchar(60) DEFAULT NULL,
  `mf1` varchar(60) DEFAULT NULL,
  `ob1` varchar(60) DEFAULT NULL,
  `gb1` varchar(80) DEFAULT NULL,
  `sql2` mediumtext,
  `ifn2` varchar(60) DEFAULT NULL,
  `ms2` varchar(60) DEFAULT NULL,
  `mf2` varchar(60) DEFAULT NULL,
  `ob2` varchar(60) DEFAULT NULL,
  `gb2` varchar(80) DEFAULT NULL,
  `sql3` mediumtext,
  `ifn3` varchar(60) DEFAULT NULL,
  `ms3` varchar(60) DEFAULT NULL,
  `mf3` varchar(60) DEFAULT NULL,
  `ob3` varchar(60) DEFAULT NULL,
  `gb3` varchar(80) DEFAULT NULL,
  `emptab` varchar(60) DEFAULT NULL,
  `empcol` varchar(60) DEFAULT NULL,
  `sameparam` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idmnu`),
  CONSTRAINT `fk_mnurel_mnu` FOREIGN KEY (`idmnu`) REFERENCES `mnu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mnurelbin
CREATE TABLE IF NOT EXISTS `mnurelbin` (
  `idmnu` smallint NOT NULL,
  `binario` mediumblob,
  PRIMARY KEY (`idmnu`),
  CONSTRAINT `fk_mnurelbin_mnu` FOREIGN KEY (`idmnu`) REFERENCES `mnu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mnurelconst
CREATE TABLE IF NOT EXISTS `mnurelconst` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idmnu` smallint NOT NULL,
  `query` varchar(10) NOT NULL,
  `nmvar` varchar(60) NOT NULL,
  `caption` varchar(80) DEFAULT NULL,
  `tipo` varchar(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_mnurelconst_mnurel_idx` (`idmnu`),
  CONSTRAINT `fk_mnurelconst_mnurel` FOREIGN KEY (`idmnu`) REFERENCES `mnurel` (`idmnu`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mnurelparam
CREATE TABLE IF NOT EXISTS `mnurelparam` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idmnu` smallint NOT NULL,
  `query` varchar(10) NOT NULL,
  `tabela` varchar(60) NOT NULL,
  `coluna` varchar(60) NOT NULL,
  `caption` varchar(80) DEFAULT NULL,
  `tipo` varchar(1) NOT NULL,
  `obriga` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `fk_mnurelparam_mnurel_idx` (`idmnu`),
  CONSTRAINT `fk_mnurelparam_mnurel` FOREIGN KEY (`idmnu`) REFERENCES `mnurel` (`idmnu`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=292 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mnurelradios
CREATE TABLE IF NOT EXISTS `mnurelradios` (
  `idmnu` smallint NOT NULL,
  `idparam` int unsigned NOT NULL,
  `id` int NOT NULL AUTO_INCREMENT,
  `descitem` varchar(60) NOT NULL,
  `valitem` varchar(60) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_mnurelradios_mnurelparam1_idx` (`idparam`),
  KEY `fk_mnurelradios_mnurel1_idx` (`idmnu`),
  CONSTRAINT `fk_mnurelradios_mnurel1` FOREIGN KEY (`idmnu`) REFERENCES `mnurel` (`idmnu`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_mnurelradios_mnurelparam1` FOREIGN KEY (`idparam`) REFERENCES `mnurelparam` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=200 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.monitorcfg
CREATE TABLE IF NOT EXISTS `monitorcfg` (
  `idemp` int unsigned NOT NULL,
  `razao` varchar(120) DEFAULT NULL,
  `fantasia` varchar(80) DEFAULT NULL,
  `usarsat` bit(1) DEFAULT b'0',
  `usartermica` bit(1) DEFAULT b'0',
  `usarnfce` bit(1) DEFAULT b'0',
  `cep` varchar(20) DEFAULT NULL,
  `endereco` varchar(120) DEFAULT NULL,
  `nroend` varchar(10) DEFAULT NULL,
  `bairro` varchar(80) DEFAULT NULL,
  `descid` varchar(60) DEFAULT NULL,
  `desuf` varchar(10) DEFAULT NULL,
  `codcid` varchar(20) DEFAULT NULL,
  `coduf` varchar(5) DEFAULT NULL,
  `fone` varchar(30) DEFAULT NULL,
  `idcsc` varchar(10) DEFAULT NULL,
  `keycsc` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`idemp`),
  CONSTRAINT `fk_monitorcfg_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.mov
CREATE TABLE IF NOT EXISTS `mov` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nrodoc` varchar(40) DEFAULT NULL,
  `idcnt` int unsigned DEFAULT NULL,
  `idoper` smallint unsigned NOT NULL,
  `saidaentrada` enum('0','1') NOT NULL DEFAULT '0',
  `fiscal` varchar(1) NOT NULL DEFAULT 'F',
  `deveemitir` bit(1) NOT NULL DEFAULT b'0',
  `devolucao` bit(1) NOT NULL DEFAULT b'0',
  `movestoque` bit(1) NOT NULL DEFAULT b'1',
  `gerafin` bit(1) NOT NULL DEFAULT b'0',
  `descarte` bit(1) NOT NULL DEFAULT b'0',
  `dthremissao` datetime NOT NULL,
  `dthrentrada` datetime DEFAULT NULL,
  `modelodoc` varchar(10) NOT NULL DEFAULT '55',
  `seriedoc` varchar(20) NOT NULL DEFAULT '1',
  `chavenfe` varchar(60) DEFAULT NULL,
  `chavenferef` varchar(60) DEFAULT NULL,
  `idemp` int unsigned NOT NULL,
  `obs` varchar(400) DEFAULT NULL,
  `baixado` bit(1) NOT NULL DEFAULT b'0',
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  `vtotprod` decimal(15,4) DEFAULT '0.0000',
  `vbcicms` decimal(15,4) DEFAULT '0.0000',
  `vicms` decimal(15,4) DEFAULT '0.0000',
  `vbcicmsst` decimal(15,4) DEFAULT '0.0000',
  `vicmsst` decimal(15,4) DEFAULT '0.0000',
  `vipi` decimal(15,4) DEFAULT '0.0000',
  `vfrete` decimal(15,4) DEFAULT '0.0000',
  `vseguro` decimal(15,4) DEFAULT '0.0000',
  `voutros` decimal(15,4) DEFAULT '0.0000',
  `vdesconto` decimal(15,4) DEFAULT '0.0000',
  `vtotdoc` decimal(15,4) DEFAULT '0.0000',
  `idped` int unsigned DEFAULT NULL,
  `idvenda` int unsigned DEFAULT NULL,
  `idvendedor` int unsigned DEFAULT NULL,
  `tipo` tinyint NOT NULL DEFAULT '0',
  `complementar` bit(1) NOT NULL DEFAULT b'0',
  `idctapag` int unsigned DEFAULT NULL,
  `idusu` int unsigned NOT NULL,
  `iddest` smallint unsigned DEFAULT NULL,
  `bonifica` bit(1) DEFAULT b'0',
  `obspagar` varchar(254) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_mov_cnt_idx` (`idcnt`),
  KEY `fk_mov_emp_idx` (`idemp`),
  KEY `fk_mov_operacoes_idx` (`idoper`),
  KEY `fk_mov_cntvend_idx` (`idvendedor`),
  KEY `fk_mov_ctapag_idx` (`idctapag`),
  KEY `fk_mov_usu_idx` (`idusu`),
  KEY `fk_mov_findestino_idx` (`iddest`),
  CONSTRAINT `fk_mov_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_mov_cntvend` FOREIGN KEY (`idvendedor`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_mov_ctapag` FOREIGN KEY (`idctapag`) REFERENCES `ctapag` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_mov_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_mov_findestino` FOREIGN KEY (`iddest`) REFERENCES `findestino` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_mov_operacoes` FOREIGN KEY (`idoper`) REFERENCES `operacoes` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_mov_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=192 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.movdi
CREATE TABLE IF NOT EXISTS `movdi` (
  `idmov` int unsigned NOT NULL,
  `ndi` varchar(12) DEFAULT NULL,
  `dtdi` date DEFAULT NULL,
  `xlocal` varchar(50) DEFAULT NULL,
  `uflocal` varchar(2) DEFAULT NULL,
  `dtlocal` date DEFAULT NULL,
  `tpvia` tinyint DEFAULT NULL,
  `vafrmm` decimal(15,4) DEFAULT NULL,
  `tpinter` smallint DEFAULT NULL,
  `cnpj` varchar(20) DEFAULT NULL,
  `ufterceiro` varchar(2) DEFAULT NULL,
  `codexportador` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`idmov`),
  CONSTRAINT `fk_movdi_mov` FOREIGN KEY (`idmov`) REFERENCES `mov` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.movnfe
CREATE TABLE IF NOT EXISTS `movnfe` (
  `idmovnfe` int unsigned NOT NULL AUTO_INCREMENT,
  `idmov` int unsigned NOT NULL,
  `idemp` int unsigned NOT NULL,
  `idoper` smallint unsigned NOT NULL,
  `dthremissao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dthrentrada` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dthrentrega` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idcntend` int unsigned DEFAULT NULL,
  `idlog` int unsigned DEFAULT NULL,
  `pesobruto` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pesoliquido` decimal(12,3) NOT NULL DEFAULT '0.000',
  `volume` varchar(40) DEFAULT NULL,
  `quantidade` decimal(12,3) NOT NULL DEFAULT '0.000',
  `especie` varchar(40) DEFAULT NULL,
  `marca` varchar(60) DEFAULT NULL,
  `pesoreal` decimal(12,3) DEFAULT '0.000',
  `fretereal` decimal(12,3) DEFAULT '0.000',
  `tipofrete` enum('F','C','T','P','3','X') NOT NULL DEFAULT 'X',
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idmovnfe`),
  KEY `fk_movnfe_mov_idx` (`idmov`),
  KEY `fk_movnfe_cntend_idx` (`idcntend`),
  KEY `fk_movnfe_cntlog_idx` (`idlog`),
  KEY `fk_movnfe_cntemp_idx` (`idemp`),
  KEY `fk_movnfe_operacoes_idx` (`idoper`),
  CONSTRAINT `fk_movnfe_cntemp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_movnfe_cntend` FOREIGN KEY (`idcntend`) REFERENCES `cntend` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_movnfe_cntlog` FOREIGN KEY (`idlog`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_movnfe_mov` FOREIGN KEY (`idmov`) REFERENCES `mov` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_movnfe_operacoes` FOREIGN KEY (`idoper`) REFERENCES `operacoes` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.movparc
CREATE TABLE IF NOT EXISTS `movparc` (
  `idmov` int unsigned NOT NULL,
  `parcela` tinyint NOT NULL,
  `vencimento` date NOT NULL,
  `valor` decimal(12,3) NOT NULL DEFAULT '0.000',
  `boleto` bit(1) NOT NULL DEFAULT b'0',
  `classe` enum('C','D','I') NOT NULL DEFAULT 'C',
  PRIMARY KEY (`idmov`,`parcela`),
  CONSTRAINT `fk_movparc_mov` FOREIGN KEY (`idmov`) REFERENCES `mov` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.movprd
CREATE TABLE IF NOT EXISTS `movprd` (
  `idmov` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `idprd` int NOT NULL,
  `sku` varchar(45) DEFAULT NULL,
  `qtde` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `vunit` decimal(15,6) NOT NULL DEFAULT '0.000000',
  `cfop` varchar(5) NOT NULL,
  `origem` varchar(2) NOT NULL DEFAULT '0',
  `csticms` varchar(5) NOT NULL DEFAULT '41',
  `picms` decimal(9,4) DEFAULT '0.0000',
  `predu` decimal(9,4) DEFAULT '0.0000',
  `bcicms` decimal(15,6) DEFAULT '0.000000',
  `vicms` decimal(15,4) DEFAULT '0.0000',
  `pivast` decimal(9,4) DEFAULT '0.0000',
  `bcicmsst` decimal(15,6) DEFAULT '0.000000',
  `vicmsst` decimal(15,4) DEFAULT '0.0000',
  `cstpis` varchar(5) NOT NULL DEFAULT '07',
  `ppis` decimal(9,4) DEFAULT '0.0000',
  `bcpis` decimal(15,6) DEFAULT '0.000000',
  `vpis` decimal(15,4) DEFAULT '0.0000',
  `cstcofins` varchar(5) NOT NULL DEFAULT '07',
  `pcofins` decimal(9,4) DEFAULT '0.0000',
  `bccofins` decimal(15,6) DEFAULT '0.000000',
  `vcofins` decimal(15,4) DEFAULT '0.0000',
  `cstipi` varchar(5) NOT NULL DEFAULT '53',
  `pipi` decimal(9,4) DEFAULT '0.0000',
  `vipi` decimal(15,4) DEFAULT '0.0000',
  `vseguro` decimal(15,4) DEFAULT '0.0000',
  `vfrete` decimal(15,4) DEFAULT '0.0000',
  `voutros` decimal(15,6) DEFAULT '0.000000',
  `vdesconto` decimal(15,6) DEFAULT '0.000000',
  `txsiscomex` decimal(15,4) DEFAULT '0.0000',
  `vtotal` decimal(15,4) DEFAULT '0.0000',
  `saldoatual` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `custoatual` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `custorateio` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `novocusto` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `ncm` varchar(8) DEFAULT NULL,
  `cest` varchar(7) DEFAULT NULL,
  `idpai` int unsigned DEFAULT NULL,
  `statusrr` enum('REM','RET','XXX') DEFAULT NULL,
  `idordem` int unsigned DEFAULT NULL,
  `idpedido` int unsigned DEFAULT NULL,
  `seqpedido` smallint unsigned DEFAULT NULL,
  `codfor` varchar(40) DEFAULT NULL,
  `cclass` varchar(8) DEFAULT NULL,
  `seqitemref` smallint DEFAULT NULL,
  `codbene` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`idmov`,`seq`),
  KEY `fk_movprd_prd_idx` (`idprd`),
  KEY `fk_movprd_cfop_idx` (`cfop`),
  KEY `fk_movprd_icmscst_idx` (`csticms`),
  KEY `fk_movprd_piscst_idx` (`cstpis`),
  KEY `fk_movprd_cofinscst_idx` (`cstcofins`),
  KEY `fk_movprd_ipicst_idx` (`cstipi`),
  KEY `fk_movprd_prdorigem_idx` (`origem`),
  KEY `fk_movprd_prdsku_idx` (`sku`),
  KEY `fk_movprd_movpai_idx` (`idpai`),
  KEY `fk_movprd_cprod_idx` (`idordem`,`idpedido`,`seqpedido`),
  CONSTRAINT `fk_movprd_cfop` FOREIGN KEY (`cfop`) REFERENCES `cfop` (`cfop`) ON UPDATE CASCADE,
  CONSTRAINT `fk_movprd_cofinscst` FOREIGN KEY (`cstcofins`) REFERENCES `prdpiscst` (`cst`) ON UPDATE CASCADE,
  CONSTRAINT `fk_movprd_cprod` FOREIGN KEY (`idordem`, `idpedido`, `seqpedido`) REFERENCES `cprod` (`idordem`, `idpedido`, `seq`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movprd_icmscst` FOREIGN KEY (`csticms`) REFERENCES `prdicmscst` (`cst`),
  CONSTRAINT `fk_movprd_ipicst` FOREIGN KEY (`cstipi`) REFERENCES `prdipicst` (`cst`) ON UPDATE CASCADE,
  CONSTRAINT `fk_movprd_mov` FOREIGN KEY (`idmov`) REFERENCES `mov` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_movprd_movpai` FOREIGN KEY (`idpai`) REFERENCES `mov` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_movprd_piscst` FOREIGN KEY (`cstpis`) REFERENCES `prdpiscst` (`cst`) ON UPDATE CASCADE,
  CONSTRAINT `fk_movprd_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_movprd_prdorigem` FOREIGN KEY (`origem`) REFERENCES `prdorigem` (`origem`) ON UPDATE CASCADE,
  CONSTRAINT `fk_movprd_prdsku` FOREIGN KEY (`sku`) REFERENCES `prdsku` (`sku`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.movprecohist
CREATE TABLE IF NOT EXISTS `movprecohist` (
  `idmov` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `tipo` varchar(10) NOT NULL DEFAULT 'MOV',
  `idprd` int NOT NULL,
  `sku` varchar(45) DEFAULT NULL,
  `tiporeajuste` enum('1','2','3','4') DEFAULT NULL,
  `margemvenda` enum('1','2','3') DEFAULT NULL,
  `custo` decimal(12,3) DEFAULT '0.000',
  `custoa` decimal(12,3) DEFAULT '0.000',
  `customedio` decimal(12,6) DEFAULT '0.000000',
  `custoultimo` decimal(12,6) DEFAULT '0.000000',
  `margem` decimal(10,4) DEFAULT '0.0000',
  `margemb` decimal(10,4) DEFAULT '0.0000',
  `venda` decimal(12,3) DEFAULT '0.000',
  `vendab` decimal(12,3) DEFAULT '0.000',
  `dtultcp` date DEFAULT NULL,
  PRIMARY KEY (`idmov`,`seq`,`tipo`,`idprd`),
  KEY `fk_movprecohist_movprd_idx` (`idmov`,`seq`),
  KEY `fk_movprecohist_prd_idx` (`idprd`),
  KEY `fk_movprecohist_prdsku_idx` (`sku`),
  CONSTRAINT `fk_movprecohist_movprd` FOREIGN KEY (`idmov`, `seq`) REFERENCES `movprd` (`idmov`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_movprecohist_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_movprecohist_prdsku` FOREIGN KEY (`sku`) REFERENCES `prdsku` (`sku`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.movrr
CREATE TABLE IF NOT EXISTS `movrr` (
  `idrr` smallint unsigned NOT NULL AUTO_INCREMENT,
  `idopen` smallint unsigned NOT NULL,
  `idclose` smallint unsigned NOT NULL,
  `externo` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idrr`,`idopen`,`idclose`),
  KEY `fk_movrr_operacoes_open_idx` (`idopen`),
  KEY `fk_movrr_operacoes_close_idx` (`idclose`),
  CONSTRAINT `fk_movrr_operacoes_close` FOREIGN KEY (`idclose`) REFERENCES `operacoes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_movrr_operacoes_open` FOREIGN KEY (`idopen`) REFERENCES `operacoes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.movxml
CREATE TABLE IF NOT EXISTS `movxml` (
  `idmov` int unsigned NOT NULL,
  `axml` mediumblob NOT NULL,
  PRIMARY KEY (`idmov`),
  CONSTRAINT `fk_movxml_mov` FOREIGN KEY (`idmov`) REFERENCES `mov` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.operacoes
CREATE TABLE IF NOT EXISTS `operacoes` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `operacao` varchar(60) NOT NULL,
  `saidaentrada` enum('0','1') NOT NULL DEFAULT '1',
  `cclass` varchar(8) DEFAULT NULL,
  `cfopnormal` varchar(5) NOT NULL DEFAULT '5102',
  `cfopst` varchar(5) NOT NULL DEFAULT '5405',
  `cfopservico` varchar(5) NOT NULL DEFAULT '5949',
  `tipocompragov` enum('X','1','2') NOT NULL DEFAULT 'X',
  `indpresenca` enum('1','2','3','4','5','9') NOT NULL DEFAULT '9',
  `finalidade` enum('C','R','I','T','F','U','D','G','V','O') NOT NULL DEFAULT 'C',
  `subtipo` enum('N','T','B','G') NOT NULL DEFAULT 'N',
  `finoutros` enum('N','P','A','C','D') NOT NULL DEFAULT 'N',
  `opercom` enum('X','B','C','E') NOT NULL DEFAULT 'X',
  `movestoque` bit(1) NOT NULL DEFAULT b'0',
  `intermunicipal` bit(1) NOT NULL DEFAULT b'0',
  `interestatual` bit(1) NOT NULL DEFAULT b'0',
  `internacional` bit(1) NOT NULL DEFAULT b'0',
  `dadosadicionais` varchar(244) DEFAULT NULL,
  `descontoserv` enum('I','C') NOT NULL DEFAULT 'I',
  `idemp` int unsigned DEFAULT NULL,
  `ckdoacao` bit(1) NOT NULL DEFAULT b'0',
  `ckintermedio` bit(1) NOT NULL DEFAULT b'0',
  `cnpjintermedio` varchar(20) DEFAULT NULL,
  `nomeintermedio` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_operacoes_cnt_idx` (`idemp`),
  KEY `fk_operacoes_tribClass_idx` (`cclass`),
  CONSTRAINT `fk_operacoes_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_operacoes_tribClass` FOREIGN KEY (`cclass`) REFERENCES `tribClass` (`classTrib`) ON DELETE RESTRICT ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.operadora
CREATE TABLE IF NOT EXISTS `operadora` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(80) NOT NULL,
  `txdeb` decimal(12,3) NOT NULL,
  `txcred` decimal(12,3) DEFAULT NULL,
  `tx2x` decimal(12,3) DEFAULT NULL,
  `cp2x` bit(1) DEFAULT b'0',
  `tx3x` decimal(12,3) DEFAULT NULL,
  `cp3x` bit(1) DEFAULT b'0',
  `tx4x` decimal(12,3) DEFAULT NULL,
  `cp4x` bit(1) DEFAULT b'0',
  `tx5x` decimal(12,3) DEFAULT NULL,
  `cp5x` bit(1) DEFAULT b'0',
  `tx6x` decimal(12,3) DEFAULT NULL,
  `cp6x` bit(1) DEFAULT b'0',
  `tx7x` decimal(12,3) DEFAULT NULL,
  `cp7x` bit(1) DEFAULT b'0',
  `tx8x` decimal(12,3) DEFAULT NULL,
  `cp8x` bit(1) DEFAULT b'0',
  `tx9x` decimal(12,3) DEFAULT NULL,
  `cp9x` bit(1) DEFAULT b'0',
  `tx10x` decimal(12,3) DEFAULT NULL,
  `cp10x` bit(1) DEFAULT b'0',
  `tx11x` decimal(12,3) DEFAULT NULL,
  `cp11x` bit(1) DEFAULT b'0',
  `tx12x` decimal(12,3) DEFAULT NULL,
  `cp12x` bit(1) DEFAULT b'0',
  `ddeb` smallint NOT NULL DEFAULT '0',
  `dcred` smallint NOT NULL DEFAULT '0',
  `dparc` smallint NOT NULL DEFAULT '0',
  `ddu` bit(1) NOT NULL DEFAULT b'0',
  `dpu` bit(1) NOT NULL DEFAULT b'1',
  `iddest` smallint unsigned NOT NULL DEFAULT '3',
  `optipo` enum('D','C','V','X') NOT NULL DEFAULT 'X',
  `parcunica` bit(1) NOT NULL DEFAULT b'0',
  `inativo` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `fk_operadora_findest_idx` (`iddest`),
  CONSTRAINT `fk_operadora_findest` FOREIGN KEY (`iddest`) REFERENCES `findestino` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.os
CREATE TABLE IF NOT EXISTS `os` (
  `idos` int unsigned NOT NULL AUTO_INCREMENT,
  `dthrini` datetime NOT NULL,
  `dthrfim` datetime DEFAULT NULL,
  `osref` varchar(40) DEFAULT NULL,
  `tipo` enum('I','E','S','G') NOT NULL DEFAULT 'I',
  `situ` enum('A','P','F') NOT NULL DEFAULT 'A',
  `idemp` int unsigned NOT NULL,
  `idcli` int unsigned DEFAULT NULL,
  `idsetor` int unsigned DEFAULT NULL,
  `idfunc` int unsigned DEFAULT NULL,
  `dtgarantia` date DEFAULT NULL,
  `dthrexec` datetime DEFAULT NULL,
  `solicitante` varchar(80) DEFAULT NULL,
  `descricao` varchar(300) DEFAULT NULL,
  `observacao` varchar(200) DEFAULT NULL,
  `cancelada` bit(1) NOT NULL DEFAULT b'0',
  `origem` varchar(20) NOT NULL DEFAULT 'osfull',
  PRIMARY KEY (`idos`),
  KEY `fk_os_emp_idx` (`idemp`),
  KEY `fk_os_cli_idx` (`idcli`),
  KEY `fk_os_func_idx` (`idfunc`),
  KEY `fk_os_cli_setor_idx` (`idsetor`),
  CONSTRAINT `fk_os_cli` FOREIGN KEY (`idcli`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_os_cli_setor` FOREIGN KEY (`idsetor`) REFERENCES `cntcli_setor` (`idsetor`) ON UPDATE CASCADE,
  CONSTRAINT `fk_os_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_os_func` FOREIGN KEY (`idfunc`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.osdefeito
CREATE TABLE IF NOT EXISTS `osdefeito` (
  `iddefeito` int unsigned NOT NULL AUTO_INCREMENT,
  `defeito` varchar(300) NOT NULL,
  `solucao` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`iddefeito`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.oseqp
CREATE TABLE IF NOT EXISTS `oseqp` (
  `idos` int unsigned NOT NULL,
  `ideqp` smallint unsigned NOT NULL,
  `iddefeito` int unsigned DEFAULT NULL,
  `defeito` varchar(300) DEFAULT NULL,
  `solucao` varchar(300) DEFAULT NULL,
  `identifica1` varchar(80) DEFAULT NULL,
  `identifica2` varchar(80) DEFAULT NULL,
  `contador` decimal(15,3) DEFAULT '0.000',
  `idemp_doc` int unsigned DEFAULT NULL,
  `nsu_doc` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`idos`),
  KEY `fk_oseqp_prdeqp_idx` (`ideqp`),
  KEY `fk_oseqp_osdefeito_idx` (`iddefeito`),
  KEY `fk_oseqp_docdist_idx` (`idemp_doc`,`nsu_doc`),
  CONSTRAINT `fk_oseqp_docdist` FOREIGN KEY (`idemp_doc`, `nsu_doc`) REFERENCES `docdist` (`idemp`, `nsu`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_oseqp_os` FOREIGN KEY (`idos`) REFERENCES `os` (`idos`) ON UPDATE CASCADE,
  CONSTRAINT `fk_oseqp_osdefeito` FOREIGN KEY (`iddefeito`) REFERENCES `osdefeito` (`iddefeito`) ON UPDATE CASCADE,
  CONSTRAINT `fk_oseqp_prdeqp` FOREIGN KEY (`ideqp`) REFERENCES `prdeqp` (`ideqp`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.oshist
CREATE TABLE IF NOT EXISTS `oshist` (
  `idos` int unsigned NOT NULL,
  `dthrhist` datetime NOT NULL,
  `situ` enum('A','P','F','C') NOT NULL,
  `idfunc` int unsigned DEFAULT NULL,
  `avaliacao` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`idos`,`dthrhist`,`situ`),
  KEY `fk_oshist_func_idx` (`idfunc`),
  CONSTRAINT `fk_oshist_func` FOREIGN KEY (`idfunc`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_oshist_os` FOREIGN KEY (`idos`) REFERENCES `os` (`idos`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.oshoras
CREATE TABLE IF NOT EXISTS `oshoras` (
  `idos` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `hrini` datetime NOT NULL,
  `hrfim` datetime NOT NULL,
  `hrtot` decimal(6,3) DEFAULT '0.000',
  PRIMARY KEY (`idos`,`seq`),
  CONSTRAINT `fk_oshoras_os` FOREIGN KEY (`idos`) REFERENCES `os` (`idos`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.ositem
CREATE TABLE IF NOT EXISTS `ositem` (
  `idos` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `idprod` int NOT NULL,
  `qtde` decimal(12,3) NOT NULL DEFAULT '0.000',
  `valor` decimal(12,3) NOT NULL DEFAULT '0.000',
  `servico` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idos`,`seq`),
  KEY `fk_ositem_prd_idx` (`idprod`),
  CONSTRAINT `fk_ositem_os` FOREIGN KEY (`idos`) REFERENCES `os` (`idos`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ositem_prd` FOREIGN KEY (`idprod`) REFERENCES `prd` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.oskm
CREATE TABLE IF NOT EXISTS `oskm` (
  `idos` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `kmini` decimal(12,3) NOT NULL,
  `kmfim` decimal(12,3) NOT NULL,
  `kmtot` decimal(12,3) DEFAULT '0.000',
  PRIMARY KEY (`idos`,`seq`),
  CONSTRAINT `fk_oskm_os` FOREIGN KEY (`idos`) REFERENCES `os` (`idos`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pagfor
CREATE TABLE IF NOT EXISTS `pagfor` (
  `uidpagfor` varchar(36) NOT NULL,
  `idcfg` int DEFAULT NULL,
  `dtcriado` date NOT NULL,
  `valorlote` decimal(18,3) NOT NULL DEFAULT '0.000',
  `arqseq` int NOT NULL DEFAULT '0',
  `gerado` bit(1) NOT NULL DEFAULT b'0',
  `dtgerado` date DEFAULT NULL,
  `nmarq` varchar(60) DEFAULT NULL,
  `arquivo` mediumblob,
  PRIMARY KEY (`uidpagfor`),
  KEY `fk_pagfor_pagforcfg_idx` (`idcfg`),
  CONSTRAINT `fk_pagfor_pagforcfg` FOREIGN KEY (`idcfg`) REFERENCES `pagforcfg` (`idcfg`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pagforcfg
CREATE TABLE IF NOT EXISTS `pagforcfg` (
  `idcfg` int NOT NULL AUTO_INCREMENT,
  `iddest` smallint unsigned NOT NULL,
  `idemp` int unsigned NOT NULL,
  `descricao` varchar(80) NOT NULL,
  `banco` varchar(5) NOT NULL DEFAULT '001',
  `convenio` varchar(30) DEFAULT NULL,
  `tipoconta` smallint NOT NULL DEFAULT '1',
  `agencia` varchar(20) DEFAULT NULL,
  `agenciadv` varchar(5) DEFAULT NULL,
  `conta` varchar(30) DEFAULT NULL,
  `contadv` varchar(5) DEFAULT NULL,
  `dvagenciaconta` varchar(5) DEFAULT NULL,
  `ambiente` enum('T','P') NOT NULL DEFAULT 'T',
  `densidade` varchar(10) NOT NULL DEFAULT '01600',
  `reserbanco` varchar(100) DEFAULT NULL,
  `reseremp` varchar(100) DEFAULT NULL,
  `substitutabanco` varchar(5) DEFAULT NULL,
  `paramtrans` varchar(10) DEFAULT '00',
  `tipocompro` smallint DEFAULT '1',
  `codcompro` smallint DEFAULT '1',
  `arqseq` int NOT NULL DEFAULT '0',
  `nmarqpequeno` bit(1) NOT NULL DEFAULT b'0',
  `inativo` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idcfg`),
  KEY `fk_pagforcfg_findest_idx` (`iddest`),
  CONSTRAINT `fk_pagforcfg_findest` FOREIGN KEY (`iddest`) REFERENCES `findestino` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pagforcnt
CREATE TABLE IF NOT EXISTS `pagforcnt` (
  `idcnt` int unsigned NOT NULL,
  `tipooper` varchar(1) NOT NULL DEFAULT 'C',
  `tiposervico` varchar(2) NOT NULL DEFAULT '20',
  `formalancto` varchar(2) NOT NULL DEFAULT '31',
  `indformapg` varchar(2) NOT NULL DEFAULT '01',
  `banco` varchar(5) DEFAULT NULL,
  `tipoconta` smallint NOT NULL DEFAULT '1',
  `agencia` varchar(20) DEFAULT NULL,
  `agenciadv` varchar(5) DEFAULT NULL,
  `conta` varchar(30) DEFAULT NULL,
  `contadv` varchar(5) DEFAULT NULL,
  `idjudicial` varchar(20) DEFAULT NULL,
  `tipochave` varchar(2) DEFAULT NULL,
  `chavepix` varchar(50) DEFAULT NULL,
  `docted` enum('X','D','T') NOT NULL DEFAULT 'X',
  `tipodoc` varchar(2) DEFAULT NULL,
  `tipoted` varchar(3) DEFAULT NULL,
  `dadosok` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idcnt`),
  CONSTRAINT `fk_pagforcnt_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pagforcta
CREATE TABLE IF NOT EXISTS `pagforcta` (
  `uidpagfor` varchar(36) NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `idpag` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `barrasok` bit(1) NOT NULL DEFAULT b'0',
  `cntok` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`uidpagfor`,`idcnt`,`idpag`,`seq`),
  KEY `fk_pagforcta_cnt_idx` (`idcnt`),
  KEY `fk_pagforcta_ctapagp_idx` (`idpag`,`seq`),
  CONSTRAINT `fk_pagforcta_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_pagforcta_ctapagp` FOREIGN KEY (`idpag`, `seq`) REFERENCES `ctapagp` (`idpag`, `seq`) ON UPDATE CASCADE,
  CONSTRAINT `fk_pagforcta_pagfor` FOREIGN KEY (`uidpagfor`) REFERENCES `pagfor` (`uidpagfor`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pagforret
CREATE TABLE IF NOT EXISTS `pagforret` (
  `idret` int NOT NULL AUTO_INCREMENT,
  `idcfg` int NOT NULL,
  `dtretorno` date NOT NULL,
  `nmarq` varchar(60) NOT NULL,
  `arquivo` mediumblob,
  `processado` bit(1) DEFAULT b'0',
  PRIMARY KEY (`idret`),
  KEY `fk_pagforret_pagforcfg_idx` (`idcfg`),
  CONSTRAINT `fk_pagforret_pagforcfg` FOREIGN KEY (`idcfg`) REFERENCES `pagforcfg` (`idcfg`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pagforretorno
CREATE TABLE IF NOT EXISTS `pagforretorno` (
  `idlinha` int unsigned NOT NULL AUTO_INCREMENT,
  `idret` int NOT NULL,
  `seunumero` varchar(20) DEFAULT NULL,
  `idpag` int DEFAULT NULL,
  `seq` smallint DEFAULT NULL,
  `codretorno` varchar(20) DEFAULT NULL,
  `msgretorno` varchar(120) DEFAULT NULL,
  `nossonum` varchar(20) DEFAULT NULL,
  `processado` bit(1) DEFAULT b'0',
  PRIMARY KEY (`idlinha`),
  KEY `fk_pagforretorno_pagforret_idx` (`idret`),
  KEY `idx_pagforretorno_ctapagp` (`idpag`,`seq`),
  CONSTRAINT `fk_pagforretorno_pagforret` FOREIGN KEY (`idret`) REFERENCES `pagforret` (`idret`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pcpcfg
CREATE TABLE IF NOT EXISTS `pcpcfg` (
  `idpa` int NOT NULL,
  `tipo` enum('F','A','D') NOT NULL DEFAULT 'A',
  `qtdebase` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idpa`),
  CONSTRAINT `fk_pcpcfg_prd` FOREIGN KEY (`idpa`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pcpformu
CREATE TABLE IF NOT EXISTS `pcpformu` (
  `idformu` int unsigned NOT NULL AUTO_INCREMENT,
  `idproc` int unsigned NOT NULL,
  `idprd` int NOT NULL,
  `perc` decimal(12,8) NOT NULL DEFAULT '0.00000000',
  `partes` decimal(14,5) NOT NULL DEFAULT '0.00000',
  `opcional` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idformu`),
  KEY `fk_pcpformu_pcpproc_idx` (`idproc`),
  KEY `fk_pcpformu_prd_idx` (`idprd`),
  CONSTRAINT `fk_pcpformu_pcpproc` FOREIGN KEY (`idproc`) REFERENCES `pcpproc` (`idproc`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pcpformu_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pcpmitem
CREATE TABLE IF NOT EXISTS `pcpmitem` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idop` int unsigned NOT NULL,
  `idprod` int NOT NULL,
  `idmov` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `fk_pcpmitem_pcpop_idx` (`idop`),
  KEY `fk_pcpmitem_prd_idx` (`idprod`),
  KEY `fk_pcpmitem_movprd_idx` (`idmov`,`seq`),
  CONSTRAINT `fk_pcpmitem_movprd` FOREIGN KEY (`idmov`, `seq`) REFERENCES `movprd` (`idmov`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pcpmitem_pcpop` FOREIGN KEY (`idop`) REFERENCES `pcpop` (`idop`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pcpmitem_prd` FOREIGN KEY (`idprod`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pcpop
CREATE TABLE IF NOT EXISTS `pcpop` (
  `idop` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `fiscal` enum('F','E') NOT NULL DEFAULT 'F',
  `dthrini` datetime NOT NULL,
  `dthrfim` datetime DEFAULT NULL,
  `idpa` int NOT NULL,
  `qtdsolicitada` decimal(12,3) NOT NULL DEFAULT '0.000',
  `qtdproduzida` decimal(12,3) NOT NULL DEFAULT '0.000',
  `obs` varchar(200) DEFAULT NULL,
  `lote` varchar(20) DEFAULT NULL,
  `validade` date DEFAULT NULL,
  `atucusto` bit(1) NOT NULL DEFAULT b'0',
  `custocalc` decimal(12,3) NOT NULL DEFAULT '0.000',
  `fechado` bit(1) NOT NULL DEFAULT b'0',
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  `idusu` int unsigned NOT NULL,
  `customaq` decimal(15,5) NOT NULL DEFAULT '0.00000',
  `custohum` decimal(15,5) NOT NULL DEFAULT '0.00000',
  PRIMARY KEY (`idop`),
  KEY `fk_pcpop_cnt_idx` (`idemp`),
  KEY `fk_pcpop_pcpcfg_idx` (`idpa`),
  KEY `fk_pcpop_usu_idx` (`idusu`),
  CONSTRAINT `fk_pcpop_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_pcpop_pcpcfg` FOREIGN KEY (`idpa`) REFERENCES `pcpcfg` (`idpa`) ON UPDATE CASCADE,
  CONSTRAINT `fk_pcpop_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pcpopmp
CREATE TABLE IF NOT EXISTS `pcpopmp` (
  `idop` int unsigned NOT NULL,
  `idproc` int unsigned NOT NULL,
  `idprd` int NOT NULL,
  `custo` decimal(12,5) NOT NULL DEFAULT '0.00000',
  `qtdpre` decimal(12,5) NOT NULL DEFAULT '0.00000',
  `qtdusu` decimal(12,5) NOT NULL DEFAULT '0.00000',
  `qtdperda` decimal(12,5) NOT NULL DEFAULT '0.00000',
  `obs` varchar(200) DEFAULT NULL,
  `opcional` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idop`,`idproc`,`idprd`),
  KEY `fk_pcpopmp_pcpproc_idx` (`idproc`),
  KEY `fk_pcpopmp_prd_idx` (`idprd`),
  CONSTRAINT `fk_pcpopmp_pcpop` FOREIGN KEY (`idop`) REFERENCES `pcpop` (`idop`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pcpopmp_pcpproc` FOREIGN KEY (`idproc`) REFERENCES `pcpproc` (`idproc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_pcpopmp_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pcpprecohist
CREATE TABLE IF NOT EXISTS `pcpprecohist` (
  `idhist` int unsigned NOT NULL AUTO_INCREMENT,
  `idop` int unsigned NOT NULL,
  `tipo` enum('A','M') NOT NULL,
  `idproc` int unsigned DEFAULT NULL,
  `idprd` int NOT NULL,
  `sku` varchar(45) DEFAULT NULL,
  `tiporeajuste` enum('1','2') DEFAULT NULL,
  `margemvenda` enum('1','2') DEFAULT NULL,
  `custo` decimal(12,3) DEFAULT '0.000',
  `custoa` decimal(12,3) DEFAULT '0.000',
  `customedio` decimal(12,6) DEFAULT '0.000000',
  `custoultimo` decimal(12,6) DEFAULT '0.000000',
  `margem` decimal(10,4) DEFAULT '0.0000',
  `margemb` decimal(10,4) DEFAULT '0.0000',
  `venda` decimal(12,3) DEFAULT '0.000',
  `vendab` decimal(12,3) DEFAULT '0.000',
  `dtultcp` date DEFAULT NULL,
  PRIMARY KEY (`idhist`),
  KEY `idx_pcphist01` (`idop`,`tipo`,`idproc`,`idprd`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pcpproc
CREATE TABLE IF NOT EXISTS `pcpproc` (
  `idproc` int unsigned NOT NULL AUTO_INCREMENT,
  `idpa` int NOT NULL,
  `processo` enum('0','1','2') NOT NULL DEFAULT '1',
  `hrmaq` decimal(8,2) NOT NULL DEFAULT '0.00',
  `customaq` decimal(12,2) NOT NULL DEFAULT '0.00',
  `hrhum` decimal(8,2) NOT NULL DEFAULT '0.00',
  `custohum` decimal(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`idproc`),
  KEY `fk_pcpproc_pcpcfg_idx` (`idpa`),
  CONSTRAINT `fk_pcpproc_pcpcfg` FOREIGN KEY (`idpa`) REFERENCES `pcpcfg` (`idpa`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pcpvitem
CREATE TABLE IF NOT EXISTS `pcpvitem` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idop` int unsigned NOT NULL,
  `idprod` int NOT NULL,
  `idvenda` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `cancelado` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `fk_pcpvitem_pcpop_idx` (`idop`),
  KEY `fk_pcpvitem_prd_idx` (`idprod`),
  KEY `fk_pcpvitem_vendaitem_idx` (`idvenda`,`seq`),
  CONSTRAINT `fk_pcpvitem_pcpop` FOREIGN KEY (`idop`) REFERENCES `pcpop` (`idop`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pcpvitem_prd` FOREIGN KEY (`idprod`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pcpvitem_vendaitem` FOREIGN KEY (`idvenda`, `seq`) REFERENCES `vendaitem` (`idvenda`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pdv
CREATE TABLE IF NOT EXISTS `pdv` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `nmpdv` varchar(40) NOT NULL,
  `utilizado` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.pdvcfg
CREATE TABLE IF NOT EXISTS `pdvcfg` (
  `idpdv` smallint unsigned NOT NULL,
  `pedevendedor` bit(1) NOT NULL DEFAULT b'0',
  `pedeoperacao` bit(1) NOT NULL DEFAULT b'0',
  `pedecliente` bit(1) NOT NULL DEFAULT b'0',
  `alterapreco` bit(1) NOT NULL DEFAULT b'0',
  `bloqueiasaldo` bit(1) NOT NULL DEFAULT b'0',
  `balancapeso` bit(1) NOT NULL DEFAULT b'1',
  `usarmonitor` bit(1) NOT NULL DEFAULT b'0',
  `usarsat` bit(1) NOT NULL DEFAULT b'0',
  `usarecf` bit(1) NOT NULL DEFAULT b'0',
  `usartermica` bit(1) NOT NULL DEFAULT b'0',
  `registralog` bit(1) NOT NULL DEFAULT b'0',
  `descontomax` decimal(12,3) NOT NULL DEFAULT '10.000',
  `taxaentrega` decimal(12,3) NOT NULL DEFAULT '0.000',
  `msg1` varchar(60) NOT NULL DEFAULT 'Obrigado pela preferência !',
  `msg2` varchar(60) NOT NULL DEFAULT 'V O L T E    S E M P R E . . .',
  `operacaopadrao` smallint NOT NULL DEFAULT '1',
  PRIMARY KEY (`idpdv`),
  CONSTRAINT `fk_pdv_pdvcfg1` FOREIGN KEY (`idpdv`) REFERENCES `pdv` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para procedure b3erp.dsv.prc_busca_sigla
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_busca_sigla`(XIDFICHA Integer, XIDMETA Integer, XDATA Date, OUT SUCESSO SmallInt, OUT NEWDIASEM SmallInt, OUT NEWSIG VarChar(5))
    READS SQL DATA
    SQL SECURITY INVOKER
BEGIN
/* variables */
declare xdtini date;
declare xperiodo varchar(1);
declare ii integer;
declare im decimal(18, 2);
declare diasem integer;
declare sig varchar(5);

/* procedure body */
  set sucesso = 90;
  
  select
    tb_etapa_aluno.dtini,
    tb_metas.periodo
  from
    tb_etapa_aluno
    inner join tb_etapa_meta on (tb_etapa_aluno.idetapa = tb_etapa_meta.idetapa)
    inner join tb_metas on (tb_etapa_meta.idmeta = tb_metas.idmeta)
  where
    tb_etapa_aluno.idficha = xidficha and
    tb_metas.idmeta = xidmeta
  into xdtini, xperiodo;
  
  set sucesso = 10;
  set ii =datediff(xdata,xdtini);
  
  if xperiodo = 'S' then
      set im = (ii / 7);
  elseif xperiodo = 'Q' then
      set im = (ii / 14);
  elseif xperiodo = 'M' then
      set im = (ii / 30);
  elseif xperiodo = 'D' then
      set im = ((ii-1) / 1);
  end if;
  
  set ii = truncate(im,0);
  set ii = ii + 1;
  
  set sig = concat(xperiodo, cast(ii as char(4)));
  set diasem = dayofweek(xdata);
  
  set newdiasem = diasem;
  set newsig = sig;
  
  set sucesso = 0;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_calc_romatotais
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_calc_romatotais`(xidroma integer)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
declare xpesob decimal(12,3);
declare xpesol decimal(12,3);
declare xtotal decimal(12,3);

set xpesob = 0;
set xpesol = 0;
set xtotal = 0;

select sum(p.pesob * vi.qtde) as pesob, sum(p.pesol * vi.qtde) as pesol, sum(vi.total) as total
from romaneioitem ri
inner join vendaitem vi on (vi.idvenda = ri.idvenda) and (vi.seq = ri.seq)
inner join prd p on (p.id = vi.idprod)
where ri.idromaneio = xidroma
into xpesob, xpesol, xtotal;

update romaneio set vtotal=xtotal, pesol=xpesol, pesob=xpesob where idromaneio = xidroma;

delete from romaneiotot where idromaneio = xidroma;

INSERT INTO romaneiotot
 (idromaneio, idprod, qtdtotal, qtdvenda, qtdpackauto)
 select xidroma, vi.idprod, sum(vi.qtde), p.qtdvenda, if(p.qtdvenda>0, concat(cast(sum(vi.qtde)/p.qtdvenda as decimal(12,1)), ' ', coalesce(p.unqtdvenda, 'FD'), ' x ', cast(p.qtdvenda as decimal(12,1))), null)
 from romaneioitem ri
 inner join vendaitem vi on (vi.idvenda = ri.idvenda) and (vi.seq = ri.seq)
 inner join prd p on (p.id = vi.idprod)
 where ri.idromaneio = xidroma
 group by vi.idprod;

END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_calc_servdedu
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_calc_servdedu`(xidvenda integer)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
declare fim boolean;
declare xtotservinss decimal(12,3);
declare xisento decimal(12,3);
declare xseq smallint;

declare curs cursor for
	select vi.seq from venda v
	inner join vendaitem vi on (v.id = vi.idvenda)
	inner join prdimposto i on (vi.idprod = i.idprd) and (v.idoper = i.idoperacao)
	inner join impostoretido r on (i.idimposto = r.idimposto)
	where vi.idvenda = xidvenda and vi.servico group by 1;

declare continue handler for not found set fim = true;

set xisento = 0;
set xtotservinss = 0;

select isento from venda where id = xidvenda into xisento;

select sum(vi.bruto - vi.desconto + vi.acrescimo) as totservinss from vendaitem vi
where vi.idvenda = xidvenda and vi.seq in (select vi.seq from venda v
inner join vendaitem vi on (v.id = vi.idvenda)
inner join prdimposto i on (vi.idprod = i.idprd) and (v.idoper = i.idoperacao)
inner join impostoretido r on (i.idimposto = r.idimposto)
where vi.idvenda = xidvenda and vi.servico and r.nome='INSS') into xtotservinss;
    
open curs;
  
servs: loop
  
	fetch curs into xseq;
    
	if fim then
		close curs;
		leave servs;
	end if;

    update vendaitem set deducoes = (
		select sum(retido) as retido from(
			select vi.idvenda, vi.seq, r.nome,
			if(r.nome='INSS', cast( (sum(vi.bruto - vi.desconto + vi.acrescimo) - (xisento * (sum(vi.bruto - vi.desconto + vi.acrescimo) / xtotservinss)))  * (r.aliquota / 100) as decimal(12,2) ),
			cast( sum(vi.bruto - vi.desconto + vi.acrescimo) * (r.aliquota / 100) as decimal(12,2) ) ) as retido 
			from venda v
			inner join vendaitem vi on (v.id = vi.idvenda)
			inner join prdimposto i on (vi.idprod = i.idprd) and (v.idoper = i.idoperacao)
			inner join impostoretido r on (i.idimposto = r.idimposto)
			where vi.idvenda = xidvenda and vi.seq = xseq
			group by 1, 2, 3) 
		as totretido)
	where vendaitem.idvenda = xidvenda and vendaitem.seq = xseq;

end loop servs;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_calc_vendafiscal
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_calc_vendafiscal`(xidvenda integer)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN

delete from vendafiscal where idvenda = xidvenda;

insert into vendafiscal(idvenda, seq, origem, cst, modbc, reducaobc, bc, picms, vicms, picmsdif, picmsori, modbcst, 
ivast, bcst, picmsst, vicmsst, cstpis, bcpis, ppis, vpis, vupis, cstcofins, bccofins, pcofins, vcofins, vucofins, 
cstipi, bcipi, pipi, vipi, vuipi, codLCP116, codTribMun, piss, viss, federal, estadual, municipal) 
select 
a.idvenda, a.seq, p.origem, 
-- ICMS
coalesce(c.icmscst, '41') as icmscst, 
coalesce(c.modbc, '3') as modbc, 
coalesce(c.icmsredu, 0) as icmsredu, 
cast(coalesce(if(a.servico or c.icmscst in ('41', '400'), 0, if(c.icmsredu = 0, 
(a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros), 
((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) * ((100-c.icmsredu) / 100)))), 0) as decimal(12,2)) as bcicms, 
coalesce(if(cli.uf <> emp.uf, cu.picms, c.icmsaliq), 0) as icmsaliq, 
cast(coalesce(if(c.icmsredu = 0, 
(a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) * (coalesce(if(cli.uf <> emp.uf, cu.picms, c.icmsaliq), 0) / 100), 
((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) * ((100-c.icmsredu) / 100)) * (coalesce(if(cli.uf <> emp.uf, cu.picms, c.icmsaliq), 0) / 100)), 0) as decimal(12,2)) as vicms, 
coalesce(c.icmspdif, 0) as picmsdif, 
coalesce(c.icmsaliq, 0) as picmsori, 
-- ST
coalesce(c.modbcst, '4') as modbcst, 
coalesce(if(c.icmsiva = 0 or op.finalidade='C', 0,c.icmsiva), 0) as ivast, 
-- BCST
cast(coalesce( if(c.icmsiva = 0 or op.finalidade='C', 0, 
(a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros + cast(coalesce((a.bruto - a.desconto + a.acrescimo) * (c.ipialiq / 100), coalesce(c.ipivalor * a.qtde, 0)) as decimal(12,2)) ) * (1 + (c.icmsiva / 100))
), 0) as decimal(12,2)) as bcst, 
-- VICMSST
coalesce(if(c.icmsiva = 0 or op.finalidade='C', 0, c.icmsaliq), 0) as picmsst,
cast(coalesce(if(c.icmsiva = 0 or op.finalidade='C', 0, if(cli.uf <> emp.uf, if(c.icmsredu = 0, 
((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros + coalesce(cast( (a.bruto - a.desconto + a.acrescimo) * (c.ipialiq / 100) as decimal(12,2)), coalesce(c.ipivalor * a.qtde, 0)) ) * (1 + (c.icmsiva / 100))) * (c.icmsaliq / 100) - ((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) * (cu.picms / 100)),
((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros + coalesce(cast( (a.bruto - a.desconto + a.acrescimo) * (c.ipialiq / 100) as decimal(12,2)), coalesce(c.ipivalor * a.qtde, 0)) ) * (1 + (c.icmsiva / 100))) * (c.icmsaliq / 100) - ((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) * ((cu.picms * ((100-c.icmsredu) / 100)) / 100)) ), 
if(c.icmsredu = 0, 
((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros + coalesce(cast( (a.bruto - a.desconto + a.acrescimo) * (c.ipialiq / 100) as decimal(12,2)), coalesce(c.ipivalor * a.qtde, 0)) ) * (1 + (c.icmsiva / 100))) * (c.icmsaliq / 100) - ((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) * (c.icmsaliq / 100)), 
((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros + coalesce(cast( (a.bruto - a.desconto + a.acrescimo) * (c.ipialiq / 100) as decimal(12,2)), coalesce(c.ipivalor * a.qtde, 0)) ) * (1 + (c.icmsiva / 100))) * (c.icmsaliq / 100) - ((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) * ((c.icmsaliq * ((100-c.icmsredu) / 100)) / 100)) ))
), 0) as decimal(12,2)) as vicmsst, 
-- PIS
coalesce(c.piscst, '08') as piscst, if(c.pisaliq > 0, a.bruto - a.desconto + a.acrescimo - (func_valoricms(a.idvenda, a.seq)), 0) as bcpis, 
coalesce(c.pisaliq, 0) as pisaliq, 
cast(coalesce(((a.bruto - a.desconto + a.acrescimo - (func_valoricms(a.idvenda, a.seq))) * (c.pisaliq / 100)), coalesce(c.pisvalor * a.qtde, 0)) as decimal(12,2)) as vpis, coalesce(c.pisvalor, 0) as vupis, 
-- COFINS
coalesce(c.cofinscst, '08') as cofinscst, if(c.cofinsaliq > 0, a.bruto - a.desconto + a.acrescimo - (func_valoricms(a.idvenda, a.seq)), 0) as bccofins, 
coalesce(c.cofinsaliq, 0) as cofinsaliq, 
cast(coalesce(((a.bruto - a.desconto + a.acrescimo - (func_valoricms(a.idvenda, a.seq))) * (c.cofinsaliq / 100)), coalesce(c.cofinsvalor * a.qtde, 0)) as decimal(12,2)) as vcofins, coalesce(c.cofinsvalor, 0) as vucofins, 
-- IPI
coalesce(c.ipicst, '53') as cstipi, if(c.ipialiq > 0, (a.bruto - a.desconto + a.acrescimo), 0) as bcipi, 
coalesce(c.ipialiq, 0) as ipisaliq, 
cast(coalesce(((a.bruto - a.desconto + a.acrescimo) * (c.ipialiq / 100)), coalesce(c.ipivalor * a.qtde, 0)) as decimal(12,2)) as vipi, coalesce(c.ipivalor, 0) as vuipi, 
-- ISS
c.codLCP116, c.codTribMun, coalesce(c.issaliq, 0) as piss, cast(coalesce(if(op.descontoserv = 'C', a.bruto, a.total) * (c.issaliq / 100), 0) as decimal(12,2)) as viss, 
-- IBPT
coalesce(if(p.origem = '0', d.nacionalfederal, d.importadosfederal),0) as federal, coalesce(d.estadual, 0) as estadual, coalesce(d.municipal, 0) as municipal 
from vendaitem a 
left outer join venda v on (v.id = a.idvenda) 
left outer join prd p on (p.id = a.idprod) 
-- left outer join prdimposto i on (i.idprd = p.id) and (i.idoperacao = v.idoper) 
left outer join vendaoper vo on (vo.idvenda = a.idvenda) and (vo.seq = a.seq) 
left outer join impostos c on (c.id = vo.idimposto) 
left outer join operacoes op on (op.id = vo.idoperacao) 
left outer join ibpt d on (d.codigo = coalesce(p.ncm, '00000000')) and (d.ex='') 
left outer join cnt emp on (emp.id = v.idemp) 
left outer join cnt cli on (cli.id = v.idcli) 
left outer join impostouf cu on ((cu.idimposto = c.id) and (cu.uf = cli.uf))
where a.idvenda = xidvenda;

END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_calc_vendaretido
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_calc_vendaretido`(xidvenda integer)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
declare xisento decimal(12,3);
set xisento = 0;

delete from vendaretido where idvenda = xidvenda;

select isento from venda where id = xidvenda into xisento;

insert into vendaretido	(idvenda, idimposto, nome, vlrbase, aliquota, valor)
select vi.idvenda, i.idimposto, r.nome, 
if(r.nome='INSS', cast( (sum(vi.bruto - vi.desconto + vi.acrescimo) - xisento) as decimal(12,2)), 
cast( sum(vi.bruto - vi.desconto + vi.acrescimo) as decimal(12,2)) ) as base, r.aliquota,
if(r.nome='INSS', cast( (sum(vi.bruto - vi.desconto + vi.acrescimo) - xisento)  * (r.aliquota / 100) as decimal(12,2) ),
cast( sum(vi.bruto - vi.desconto + vi.acrescimo) * (r.aliquota / 100) as decimal(12,2) ) ) as retido 
from venda v
inner join vendaitem vi on (v.id = vi.idvenda)
inner join prdimposto i on (vi.idprod = i.idprd) and (v.idoper = i.idoperacao)
inner join impostoretido r on (i.idimposto = r.idimposto)
where vi.idvenda = xidvenda and vi.servico
group by 1, 2, 3, 5;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_calc_vendatrib
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_calc_vendatrib`(xidvenda integer)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN

declare xpCBS decimal(12,3);
declare xpIBSUF decimal(12,3);
declare xpIBSMun decimal(12,3);

set xpCBS = 0.9;
set xpIBSUF = 0.1;
set xpIBSMun = 0.0;

delete from vendatrib where idvenda = xidvenda;

INSERT INTO vendatrib
    (idvenda, seq, tpEnteGov, pRedutor, tpOperGov, CST, classTrib, indDocao, vBC, 
    pIBSUF, pRedAliqUF, pAliqEfetUF, vIBSUF, 
    pIBSMun, pRedAliqMun, pAliqEfetMun, vIBSMun, 
    pCBS, pRedAliqCBS, pAliqEfetCBS, vCBS)
select 
a.idvenda, a.seq, coalesce(cli.tipoestatal, 'X') as tpEnteGov, 
coalesce(cli.reduestatal, 0.00) pRedutor, op.tipocompragov as tpOperGov,
left(tc.classTrib, 3) as CST, tc.classTrib, op.ckdoacao,
-- BC
(a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) as vBC,
-- IBSUF
xpIBSUF as pIBSUF, if(cst.ckReduzAliq, tc.pReduIBS, 0.00) as pRedAliqUF,
xpIBSUF * (1-(tc.pReduIBS / 100)) * (1-(coalesce(cli.reduestatal,0) / 100)) as pAliqEfetUF,
cast((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) * ((xpIBSUF * (1-(tc.pReduIBS / 100)) * (1-(coalesce(cli.reduestatal,0) / 100)))/100) as decimal(12,2)) as vIBSUF,
-- IBSMun
xpIBSMun as pIBSMun, if(cst.ckReduzAliq, tc.pReduIBS, 0.00) as pRedAliqMun,
xpIBSMun * (1-(tc.pReduIBS / 100)) * (1-(coalesce(cli.reduestatal,0) / 100)) as pAliqEfetMun,
cast((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) * ((xpIBSMun * (1-(tc.pReduIBS / 100)) * (1-(coalesce(cli.reduestatal,0) / 100)))/100) as decimal(12,2)) as vIBSMun,
-- CBS
xpCBS as pCBS, if(cst.ckReduzAliq, tc.pReduCBS, 0.00) as pRedAliqCBS,
xpCBS * (1-(tc.pReduCBS / 100)) * (1-(coalesce(cli.reduestatal,0) / 100)) as pAliqEfetCBS,
cast((a.bruto - a.desconto + a.acrescimo + a.frete + a.seguro + a.outros) * ((xpCBS * (1-(tc.pReduCBS / 100)) * (1-(coalesce(cli.reduestatal,0) / 100)))/100) as decimal(12,2)) as vCBS
from vendaitem a 
left outer join venda v on (v.id = a.idvenda) 
left outer join prd p on (p.id = a.idprod) 
left outer join vendaoper vo on (vo.idvenda = a.idvenda) and (vo.seq = a.seq) 
left outer join operacoes op on (op.id = vo.idoperacao) 
left outer join tribClass tc on (tc.classTrib = coalesce(op.cclass, p.cclass))
left outer join tribCst cst on (cst.cst = tc.cst)
left outer join cnt emp on (emp.id = v.idemp) 
left outer join cnt cli on (cli.id = v.idcli) 
where a.idvenda = xidvenda;

END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_diasu
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_diasu`(
    in startdate date, 
    in enddate date
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
   declare thisDate date;
   declare nextDate date;
   declare yy smallint;
   declare mm, dow, dweek tinyint;
   declare feriado, ativo boolean;
   
   set yy =  year(enddate);
   set thisDate = startdate;
   
   delete from `diasu` where `ano`=yy;

   repeat
      select date_add(thisDate, INTERVAL 1 DAY) into nextDate;
      set mm =  month(thisDate);
      set dow =  dayofweek(thisDate);
      set dweek =  weekofyear(thisDate);
      set feriado = (select count(*) from feriados where dia=thisDate) > 0;
      set ativo = if((dow in (1,7)) or feriado, false, true);

      insert into diasu select yy, mm, thisDate, ativo, feriado, dow, dweek;
      set thisDate = nextDate;
   until thisDate >= enddate
   end repeat;

END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_inc_metas_aerobio
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_inc_metas_aerobio`(XIDFICHA Integer, XDATA Date, XHORA Time, XDIST Float, XTEMPO Time, XORIGEM VarChar(1), OUT SUCESSO SmallInt)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
/* variables */
declare fim boolean;
declare xdtini date;
declare xidmeta integer;
declare xtipo varchar(1);
declare xtipouni varchar(1);
declare xperiodo varchar(1);
declare ii integer;
declare im decimal(18, 2);
declare diasem integer;
declare sig varchar(5);

declare curs cursor for
  select
    tb_etapa_aluno.dtini,
    tb_etapa_meta.idmeta,
    tb_metas.tipo,
    tb_metas.tipouni,
    tb_metas.periodo
  from
    tb_etapa_aluno
    inner join tb_etapa_meta on (tb_etapa_aluno.idetapa = tb_etapa_meta.idetapa)
    inner join tb_metas on (tb_etapa_meta.idmeta = tb_metas.idmeta)
  where
    tb_etapa_aluno.idficha=xidficha and
    tb_metas.tipo = 'A';
    
declare continue handler for not found set fim = true;

/* code */
  set sucesso = 90;
  open curs;
  
  metas: loop
  
    fetch curs into xdtini, xidmeta, xtipo, xtipouni, xperiodo;
    
    if fim then
         close curs;
         leave metas;
    end if;
    
    set sucesso = 10;
    set ii = datediff(xdata,xdtini);
    
    if (xperiodo = 'S') then
       set im = (ii / 7);
    elseif (xperiodo = 'Q') then
       set im = (ii / 14);
    elseif (xperiodo = 'M') then
       set im = (ii / 30);
    elseif (xperiodo = 'D') then
       set im = ((ii-1) / 1);
    end if;
    
    set ii = truncate(im,0);
    set ii = ii + 1;
    
    set sig = concat(xperiodo, cast(ii as char(4)));
    set diasem = dayofweek(xdata) + 1;
    
    set sucesso = 90;
    
    if (xtipouni = 'T') then
      insert into tb_entra_meta(idficha, idmeta, data1, hora, qtde, diasemana, sigla, origem)
      values (xidficha, xidmeta, xdata, xhora, cast((extract(hour from xtempo)*60) + extract(minute from xtempo) + (extract(second from xtempo)/60) as decimal(12,2)), diasem, sig, xorigem);
    elseif (xtipouni = 'D') then
      insert into tb_entra_meta(idficha, idmeta, data1, hora, qtde, diasemana, sigla, origem)
      values (xidficha, xidmeta, xdata, xhora, xdist, diasem, sig, xorigem);
    end if;
    
  end loop metas;
  
  set sucesso = 0;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_inc_metas_neuro
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_inc_metas_neuro`(XIDFICHA Integer, XDATA Date, XHORA Time, XORIG VarChar(1), OUT SUCESSO SmallInt)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
/* variables */
declare fim boolean;
declare xdtini date;
declare xidmeta integer;
declare xtipo varchar(1);
declare xperiodo varchar(1);
declare ii integer;
declare im decimal(18, 2);
declare diasem integer;
declare sig varchar(5);

declare curs cursor for
  select
    tb_etapa_aluno.dtini,
    tb_etapa_meta.idmeta,
    tb_metas.tipo,
    tb_metas.periodo
  from
    tb_etapa_aluno
    inner join tb_etapa_meta on (tb_etapa_aluno.idetapa = tb_etapa_meta.idetapa)
    inner join tb_metas on (tb_etapa_meta.idmeta = tb_metas.idmeta)
  where
    tb_etapa_aluno.idficha=xidficha and
    tb_metas.tipo = 'N';
    
declare continue handler for not found set fim = true;

/* code */
  set sucesso = 90;
  open curs;

  metas: loop
  
    fetch curs into xdtini, xidmeta, xtipo, xperiodo;
    
    if fim then
         close curs;
         leave metas;
    end if;
    
    set sucesso = 10;
    set ii = datediff(xdata,xdtini);
    
    if (xperiodo = 'S') then
       set im = (ii / 7);
    elseif (xperiodo = 'Q') then
       set im = (ii / 14);
    elseif (xperiodo = 'M') then
       set im = (ii / 30);
    elseif (xperiodo = 'D') then
       set im = ((ii-1) / 1);
    end if;
    
    set ii = truncate(im,0);
    set ii = ii + 1;
    
    set sig = concat(xperiodo, cast(ii as char(4)));
    set diasem = dayofweek(xdata) + 1;
    
    set sucesso = 90;
    
    insert into tb_entra_meta(idficha, idmeta, data1, hora, qtde, diasemana, sigla, origem)
    values (xidficha, xidmeta, xdata, xhora, 1, diasem, sig, xorig);
    
  end loop metas;
  
  set sucesso = 0;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_mnu_usu
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_mnu_usu`(xidusu integer)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
set @xtemp  = concat('temp_mnu_', xidusu);
set @xsel   = concat('select coalesce(c.idmnu,9999) from usu a left join usurole b on (b.idusu = a.id) left join usurolemnu c on (c.idusu = b.idusu) or (c.idrole = b.idusugrupo) where a.id = ', xidusu);

set @delstm = concat('DROP TABLE IF EXISTS ', @xtemp);
set @newstm = concat('CREATE TABLE ', @xtemp, ' SELECT * FROM mnu where liberado');
set @pkstm  = concat('ALTER TABLE ', @xtemp, ' ADD CONSTRAINT `PK_', @xtemp, '` PRIMARY KEY (`id`)');
set @fkstm  = concat('ALTER TABLE ', @xtemp, ' ADD CONSTRAINT `FK_', @xtemp, '` FOREIGN KEY (`idpai`) REFERENCES `', @xtemp, '` (`id`) ON UPDATE CASCADE ON DELETE CASCADE');
set @selstm = concat('SELECT ID, Case ID When 0 then cast(" " as char) else nome End as Nome, IDPai, Tipo, IdIcone, Icone, Ordem, nmClasse, Atalho, Exe, Descricao from ', @xtemp, ' order by IDPai, Ordem');
set @mnustm = concat('DELETE FROM ', @xtemp, ' WHERE ID IN (', @xsel, ')');
set @up1stm = concat('update ', @xtemp, ' set idicone=null where icone is null;');
set @i = -1;
set @up2stm = concat('update ', @xtemp, ', (select @i:=@i+1 ii, id from ', @xtemp, ' where icone is not null order by idpai, ordem) dest set idicone = ii where ', @xtemp, '.id=dest.id;');

PREPARE stmt1 FROM @delstm;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

PREPARE stmt1 FROM @newstm;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

PREPARE stmt1 FROM @pkstm;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

PREPARE stmt1 FROM @fkstm;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

PREPARE stmt1 FROM @mnustm;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

PREPARE stmt1 FROM @up1stm;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

PREPARE stmt1 FROM @up2stm;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

PREPARE stmt1 FROM @selstm;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_mov_baixa
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_mov_baixa`(
	IN `xidmov` integer,
	IN `xplata` varchar(20)
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
declare fim boolean;
declare xdthrest datetime;
declare xdthremi datetime;
declare xiemp integer;
declare xforn integer;
declare xiusu integer;
declare xorig varchar(50);
declare xida integer;
declare xidb integer;
declare xiprd integer;
declare xsku varchar(45);
declare xcfop varchar(5);
declare xfiscal varchar(1);
declare xtipo varchar(1);
declare xqtde decimal(12, 3);
declare xcusto decimal(12, 3);
declare xtpmov integer;
declare xfator decimal(12, 3);
declare xcodfor varchar(40);

declare curs cursor for
  select 
    coalesce(v.dthrentrada, v.dthremissao, func_dthr()) as dthrbaixa, 
    func_dthr() as dthremissao, 
    v.idemp, 
    v.idcnt, 
    coalesce(v.idusu, 1) as idusu, 
    'movprd' as orig, 
    a.idmov, 
    a.seq, 
    a.idprd, 
    a.sku, 
    a.cfop, 
    v.fiscal, 
    if((v.movestoque) and (not v.complementar) and (select controla from prd where prd.id=a.idprd), if(v.saidaentrada='0', 'E', 'S'), 'X') as tipo, 
    a.qtde, 
    a.vunit as custo,
    v.tipo as tpmov,
    a.codfor
  from 
    movprd a 
    inner join mov v on (v.id=a.idmov)
  where 
    a.idmov = xidmov;

declare continue handler for not found set fim = true;

if ((xplata is null) or (xplata = '')) then 
  set xplata = 'ERP';
end if;

  open curs;
  
  movs: loop
    fetch curs into xdthrest, xdthremi, xiemp, xforn, xiusu, xorig, xida, xidb, xiprd, xsku, xcfop, xfiscal, xtipo, xqtde, xcusto, xtpmov, xcodfor;

    if fim then
       close curs;
       leave movs;
    end if;
    
    set xfator = 1;
    if (xtpmov = 2) then
      if (xcodfor is null) then
        select coalesce(fator, 1) from prdfor where idcnt=xforn and idprd=xiprd limit 1 into xfator;
	  else
        select coalesce(fator, 1) from prdfor where idcnt=xforn and idprd=xiprd and codfor=xcodfor into xfator;
	  end if;
    end if;

    insert into estoque(dthrestoque, dthremissao, idemp, idusu, plataforma, origem, ida, idb, idprd, sku, cfop, fiscal, tipo, qtde, custo)
    values(xdthrest, xdthremi, xiemp, xiusu, xplata, xorig, xida, xidb, xiprd, xsku, xcfop, xfiscal, xtipo, (xqtde*xfator), xcusto);

  end loop movs;
  
  update mov set baixado = True where id = xidmov;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_mov_estorna
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_mov_estorna`(
	IN `xidmov` integer,
    IN `xidusu` integer
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  update estoque e
  inner join movprd v on (e.origem='movprd' and e.ida = v.idmov and e.idb = v.seq)
  set e.cancelado = True, e.idusucancela = xidusu
  where v.idmov = xidmov;
  
  update mov set baixado = False where id = xidmov;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_pcp_baixa
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_pcp_baixa`(
	IN `xidpcp` integer,
	IN `xplata` varchar(20)
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
declare xtipopcp varchar(1);
declare xdthrest datetime;
declare xdthremi datetime;
declare xiemp integer;
declare xiusu integer;
declare xorig varchar(50);
declare xida integer;
declare xidb integer;
declare xiprd integer;
declare xsku varchar(45);
declare xcfop varchar(5);
declare xfiscal varchar(1);
declare xtipo varchar(1);
declare xqtde decimal(12, 3);
declare xcusto decimal(12, 3);

declare cursmp cursor for
  select 
    v.dthrfim as dthrbaixa, 
    func_dthr() as dthremi, 
    v.idemp, 
    coalesce(v.idusu, 1) as idusu, 
    'pcpopmp' as orig, 
    a.idop, 
    a.idproc, 
    a.idprd, 
    null as sku, 
    if(xtipopcp='D','1949','5949') as cfop, 
    v.fiscal, 
    if((select controla from prd where prd.id=a.idprd), if(xtipopcp='D', 'E', 'S'), 'X') as tipo, 
    coalesce(a.qtdusu, 0) + coalesce(a.qtdperda, 0) as qtde, 
    (select custo from prd where prd.id=a.idprd) as custo 
  from 
    pcpopmp a 
    inner join pcpop v on (v.idop=a.idop)
  where 
    a.idop = xidpcp;

declare cursop cursor for
  select 
    v.dthrfim as dthrbaixa, 
    func_dthr() as dthremi, 
    v.idemp, 
    coalesce(v.idusu, 1) as idusu, 
    'pcpop' as orig, 
    v.idop, 
    null as idb, 
    v.idpa as idprd, 
    null as sku, 
    if(xtipopcp='D','5949','1949') as cfop, 
    v.fiscal, 
    if((select controla from prd where prd.id=v.idpa), if(xtipopcp='D', 'S', 'E'), 'X') as tipo, 
    coalesce(v.qtdproduzida, 0) as qtde, 
    (select custo from prd where prd.id=v.idpa) as custo 
  from 
    pcpop v 
  where 
    v.idop = xidpcp;

select pc.tipo from pcpop po inner join pcpcfg pc on (pc.idpa=po.idpa) where po.idop = xidpcp into xtipopcp;

if ((xplata is null) or (xplata = '')) then 
  set xplata = 'ERP';
end if;

  open cursmp;
  begin
	  declare fim boolean default False;
	  declare continue handler for not found set fim = true;
	  movmp: loop
	    fetch cursmp into xdthrest, xdthremi, xiemp, xiusu, xorig, xida, xidb, xiprd, xsku, xcfop, xfiscal, xtipo, xqtde, xcusto;
	
	    if fim then
	       close cursmp;
	       leave movmp;
	    end if;
	
	    insert into estoque(dthrestoque, dthremissao, idemp, idusu, plataforma, origem, ida, idb, idprd, sku, cfop, fiscal, tipo, qtde, custo)
	    values(xdthrest, xdthremi, xiemp, xiusu, xplata, xorig, xida, xidb, xiprd, xsku, xcfop, xfiscal, xtipo, xqtde, xcusto);
	
	  end loop movmp;
  end;

  open cursop;
  begin
	  declare fim boolean default False;
	  declare continue handler for not found set fim = true;
	  movop: loop
	    fetch cursop into xdthrest, xdthremi, xiemp, xiusu, xorig, xida, xidb, xiprd, xsku, xcfop, xfiscal, xtipo, xqtde, xcusto;
	
	    if fim then
	       close cursop;
	       leave movop;
	    end if;
	
	    insert into estoque(dthrestoque, dthremissao, idemp, idusu, plataforma, origem, ida, idb, idprd, sku, cfop, fiscal, tipo, qtde, custo)
	    values(xdthrest, xdthremi, xiemp, xiusu, xplata, xorig, xida, xidb, xiprd, xsku, xcfop, xfiscal, xtipo, xqtde, xcusto);
	
	  end loop movop;
  end;
  update pcpop set fechado = True where idop = xidpcp;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_pcp_calccusto
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_pcp_calccusto`(
	IN `xidop` integer,
	IN `xidpa` integer
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
	declare xtipo varchar(1);
	declare xmaq decimal(15,5);
	declare xmao decimal(15,5);
	declare xumaq decimal(15,5);
	declare xumao decimal(15,5);
	declare xqtdfinal integer;

	select tipo from pcpcfg where idpa = xidpa into xtipo;

-- PRODUTOS GRANEL / FRACIONAMENTO
	if (xtipo = 'A') then
       select (sum(maq) / base) as totmaq, 
       (sum(hum) / base) as tothum from (
       select (pp.hrmaq * pp.customaq) as maq, (pp.hrhum * pp.custohum) as hum, 
       pcf.qtdebase as base, op.qtdproduzida as realidade
       from pcpop op
       inner join pcpproc pp on (pp.idpa = op.idpa)
       inner join pcpcfg pcf on (pcf.idpa = pp.idpa)
       where op.idop = xidop
       ) as totproc into xmaq, xmao;

       update pcpopmp mp 
       inner join pcpop op on (mp.idop = op.idop)
       -- inner join pcpformu pf on (mp.idproc = pf.idproc) and (mp.idprd = pf.idprd)
       inner join prd p on (p.id = mp.idprd)
       -- set mp.custo = (p.custo * pf.perc) + ((p.custo * mp.qtdperda) / op.qtdproduzida)
       set mp.custo = ((p.custo * if(mp.qtdusu>0, mp.qtdusu, mp.qtdpre)) / op.qtdproduzida) + ((p.custo * mp.qtdperda) / op.qtdproduzida)
       where mp.idop = xidop;

       UPDATE pcpop set customaq = xmaq, custohum = xmao where idop = xidop;

-- PRODUTOS FÓRMULA / RECEITAS
	elseif (xtipo = 'F') then
       -- select (sum(maq) / base * (solicitada)) as totmaq, (sum(hum) / base * (solicitada)) as tothum from (
       select (sum(maq) / base) as totmaq, (sum(hum) / base) as tothum from (
       select (pp.hrmaq * pp.customaq) as maq, (pp.hrhum * pp.custohum) as hum,
       pcf.qtdebase as base, op.qtdsolicitada as solicitada
       from pcpop op
       inner join pcpproc pp on (pp.idpa = op.idpa)
       inner join pcpcfg pcf on (pcf.idpa = pp.idpa)
       where op.idop = xidop
       ) as totproc into xmaq, xmao;

       update pcpopmp mp 
       inner join pcpop op on (mp.idop = op.idop)
       -- inner join pcpformu pf on (mp.idproc = pf.idproc) and (mp.idprd = pf.idprd)
       -- inner join pcpcfg pc on (pc.idpa = op.idpa)
       inner join prd p on (p.id = mp.idprd)
       -- set mp.custo = (((p.custo * pf.partes) * op.qtdsolicitada) / op.qtdproduzida) + ((p.custo * mp.qtdperda) / op.qtdproduzida)
       set mp.custo =  ((p.custo * if(mp.qtdusu>0, mp.qtdusu, mp.qtdpre)) / op.qtdproduzida) + ((p.custo * mp.qtdperda) / op.qtdproduzida)
       where mp.idop = xidop;

       UPDATE pcpop set customaq = xmaq, custohum = xmao where idop = xidop;

-- DESMEMBRAMENTO / DESOSSA
	elseif (xtipo = 'D') then
       select count(*) as qtdfinal
       from pcpop op
       inner join pcpcfg pcf on (pcf.idpa = op.idpa)
       inner join pcpproc pp on (pp.idpa = pcf.idpa)
       inner join pcpformu pf on (pf.idproc = pp.idproc)
       where op.idop = xidop into xqtdfinal;

       select ((solicitada / base) * sum(maq)) as totmaq,
       ((solicitada / base) * sum(hum)) as tothum from (
       select (pp.hrmaq * pp.customaq) as maq, (pp.hrhum * pp.custohum) as hum,
       op.qtdproduzida as solicitada, pcf.qtdebase as base
       from pcpop op
       inner join pcpcfg pcf on (pcf.idpa = op.idpa)
       inner join pcpproc pp on (pp.idpa = pcf.idpa)
       where op.idop = xidop
       ) as totproc into xmaq, xmao;

       select (sum(maq) / xqtdfinal * (solicitada / base)) as totmaq, 
        (sum(hum) / xqtdfinal * (solicitada / base)) as tothum from (
       select (pp.hrmaq * pp.customaq) as maq, (pp.hrhum * pp.custohum) as hum,
       op.qtdproduzida as solicitada, pcf.qtdebase as base
       from pcpop op
       inner join pcpcfg pcf on (pcf.idpa = op.idpa)
       inner join pcpproc pp on (pp.idpa = pcf.idpa)
       where op.idop = xidop
       ) as totproc into xumaq, xumao;

       update pcpopmp mp 
       inner join pcpop op on (mp.idop = op.idop)
       -- inner join pcpformu pf on (mp.idproc = pf.idproc) and (mp.idprd = pf.idprd)
       -- inner join pcpcfg pc on (pc.idpa = op.idpa)
       inner join prd p on (p.id = op.idpa)
       set mp.custo = if(mp.qtdusu > 0, p.custo + ((xumaq + xumao) / mp.qtdusu) + ((mp.qtdperda * p.custo) / mp.qtdusu), mp.custo)
       where mp.idop = xidop;

       UPDATE pcpop set customaq = xmaq, custohum = xmao where idop = xidop;

	end if;

END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_pcp_estorna
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_pcp_estorna`(
	IN `xidop` integer,
    IN `xidusu` integer
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  update estoque e
  inner join pcpopmp v on (e.origem='pcpopmp' and e.ida = v.idop and e.idb = v.idproc and e.idprd = v.idprd)
  set e.cancelado = True, e.idusucancela = xidusu
  where v.idop = xidop;

  update estoque e
  inner join pcpop v on (e.origem='pcpop' and e.ida = v.idop and e.idprd = v.idpa)
  set e.cancelado = True, e.idusucancela = xidusu
  where v.idop = xidop;

  update pcpop set fechado = False where idop = xidop;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_pcp_gerarmp
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_pcp_gerarmp`(
	IN `xidop` integer,
	IN `xidpa` integer
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
	declare xtipo varchar(1);
	declare xmaq decimal(15,5);
	declare xmao decimal(15,5);
	declare xumaq decimal(15,5);
	declare xumao decimal(15,5);
	declare xqtdfinal integer;

	select tipo from pcpcfg where idpa = xidpa into xtipo;

	delete from pcpopmp where idop = xidop;

-- PRODUTOS GRANEL / FRACIONAMENTO
	if (xtipo = 'A') then
       select (sum(maq) / base) as totmaq, (sum(hum) / base) as tothum from (
       select (pp.hrmaq * pp.customaq) as maq, (pp.hrhum * pp.custohum) as hum, 
       pcf.qtdebase as base, op.qtdsolicitada as realidade
       from pcpop op
       inner join pcpproc pp on (pp.idpa = op.idpa)
       inner join pcpcfg pcf on (pcf.idpa = pp.idpa)
       where op.idop = xidop
       ) as totproc into xmaq, xmao;

       INSERT INTO pcpopmp (idop, idproc, idprd, custo, qtdpre, qtdusu, qtdperda, obs, opcional)
       select op.idop, pp.idproc, pf.idprd, 
       (p.custo * pf.perc) as custo,
       (op.qtdsolicitada * pf.perc) as qtdepre, 
       0 as qtdeusu, 0 as qtdeperda, 
       null as obs, pf.opcional
       from pcpop op
       inner join pcpproc pp on (pp.idpa = op.idpa)
       inner join pcpformu pf on (pf.idproc = pp.idproc)
       inner join prd p on (p.id = pf.idprd)
       where op.idop = xidop;

       UPDATE pcpop set customaq = xmaq, custohum = xmao where idop = xidop;

-- PRODUTOS FÓRMULA / RECEITAS
	elseif (xtipo = 'F') then
       select (sum(maq) / base * (solicitada)) as totmaq, (sum(hum) / base * (solicitada)) as tothum from (
       select (pp.hrmaq * pp.customaq) as maq, (pp.hrhum * pp.custohum) as hum,
       pcf.qtdebase as base, op.qtdsolicitada as solicitada
       from pcpop op
       inner join pcpproc pp on (pp.idpa = op.idpa)
       inner join pcpcfg pcf on (pcf.idpa = pp.idpa)
       where op.idop = xidop
       ) as totproc into xmaq, xmao;

       INSERT INTO pcpopmp (idop, idproc, idprd, custo, qtdpre, qtdusu, qtdperda, obs, opcional)
       select op.idop, pp.idproc, pf.idprd, 
       (p.custo * op.qtdsolicitada * pf.partes) / (pc.qtdebase * op.qtdsolicitada) as custo, 
       (op.qtdsolicitada * pf.partes) as qtdepre, 
       0 as qtdeusu, 0 as qtdeperda, 
       null as obs, pf.opcional
       from pcpop op
       inner join pcpproc pp on (pp.idpa = op.idpa)
       inner join pcpformu pf on (pf.idproc = pp.idproc)
       inner join pcpcfg pc on (pc.idpa = op.idpa)
       inner join prd p on (p.id = pf.idprd)
       where op.idop = xidop;

       UPDATE pcpop set customaq = xmaq, custohum = xmao where idop = xidop;

-- DESMEMBRAMENTO / DESOSSA
	elseif (xtipo = 'D') then
       select count(*) as qtdfinal
       from pcpop op
       inner join pcpcfg pcf on (pcf.idpa = op.idpa)
       inner join pcpproc pp on (pp.idpa = pcf.idpa)
       inner join pcpformu pf on (pf.idproc = pp.idproc)
       where op.idop = xidop into xqtdfinal;

       select ((solicitada / base) * sum(maq)) as totmaq,
       ((solicitada / base) * sum(hum)) as tothum from (
       select (pp.hrmaq * pp.customaq) as maq, (pp.hrhum * pp.custohum) as hum,
       op.qtdsolicitada as solicitada, pcf.qtdebase as base
       from pcpop op
       inner join pcpcfg pcf on (pcf.idpa = op.idpa)
       inner join pcpproc pp on (pp.idpa = pcf.idpa)
       where op.idop = xidop
       ) as totproc into xmaq, xmao;

       select (sum(maq) / xqtdfinal * (solicitada / base)) as totmaq, 
        (sum(hum) / xqtdfinal * (solicitada / base)) as tothum from (
       select (pp.hrmaq * pp.customaq) as maq, (pp.hrhum * pp.custohum) as hum,
       op.qtdsolicitada as solicitada, pcf.qtdebase as base
       from pcpop op
       inner join pcpcfg pcf on (pcf.idpa = op.idpa)
       inner join pcpproc pp on (pp.idpa = pcf.idpa)
       where op.idop = xidop
       ) as totproc into xumaq, xumao;

       INSERT INTO pcpopmp (idop, idproc, idprd, custo, qtdpre, qtdusu, qtdperda, obs, opcional)
       select op.idop, pp.idproc, pf.idprd,
       (p.custo * (op.qtdsolicitada * pf.perc) + xumaq + xumao) as custo,
       (op.qtdsolicitada * pf.perc) as qtdepre,
       0 as qtdeusu, 0 as qtdeperda,
       null as obs, pf.opcional
       from pcpop op
       inner join pcpproc pp on (pp.idpa = op.idpa)
       inner join pcpformu pf on (pf.idproc = pp.idproc)
       inner join pcpcfg pc on (pc.idpa = op.idpa)
       inner join prd p on (p.id = pc.idpa)
       where op.idop = xidop;

       UPDATE pcpop set customaq = xmaq, custohum = xmao where idop = xidop;

	end if;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_vendahist
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_vendahist`(
	IN `idv` INT,
	IN `dthr` DATETIME,
	IN `hist` VARCHAR(250) CHARSET utf8
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  declare iseq integer;
  set iseq = (select coalesce(max(seqhist),0)+1 from vendahist where idvenda=idv);
  if (dthr is null)  or (dthr = 0) then 
    set dthr = CURRENT_TIMESTAMP;
  end if;
  
  insert into vendahist(idvenda, seqhist, dthrhist, historico)
  values (idv, iseq, dthr, hist);
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_venda_baixa
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_venda_baixa`(
    IN `xidvenda` integer,
    IN `xplata` varchar(20)
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
declare fim boolean;
declare xdthrest datetime;
declare xdthremi datetime;
declare xicli integer;
declare xiemp integer;
declare xiusu integer;
declare xorig varchar(50);
declare xida integer;
declare xidb integer;
declare xiprd integer;
declare xcomi integer;
declare xsku varchar(45);
declare xcfop varchar(5);
declare xfiscal varchar(1);
declare xtipo varchar(1);
declare xqtde decimal(12, 3);
declare xcusto decimal(12, 3);
declare xpedref varchar(30);
declare xmanipulado bit(1);
declare xiprdbase integer;
declare xiprdman integer;

declare curs cursor for
  select 
    func_dthr() as dtbaixa, 
    v.dthremissao, 
    v.idemp,
    v.idcli,
    coalesce(v.ultimousu, 1) as idusu, 
    'vendaitem' as orig, 
    a.idvenda, 
    a.seq, 
    a.idprod, 
    a.sku, 
    a.cfop, 
    v.fiscal, 
    if((o.movestoque) and (select controla from prd where prd.id=a.idprod), if(o.saidaentrada='0', 'E', 'S'), 'X') as tipo, 
    a.qtde, 
    a.custo,
    a.seqpedref,
    p.manipulado,
    p.idprdbase
  from 
    vendaitem a 
    inner join venda v on (v.id=a.idvenda)
    inner join operacoes o on (o.id=v.idoper)
    inner join prd p on (p.id=a.idprod)
  where 
    a.idvenda = xidvenda and not a.servico;

declare continue handler for not found set fim = true;

if ((xplata is null) or (xplata = '')) then 
  set xplata = 'ERP';
end if;

  open curs;
  
  vendas: loop
    fetch curs into xdthrest, xdthremi, xiemp, xicli, xiusu, xorig, xida, xidb, xiprd, xsku, xcfop, xfiscal, xtipo, xqtde, xcusto, xpedref, xmanipulado, xiprdbase;

    if fim then
       close curs;
       leave vendas;
    end if;
    
    if (xpedref is not null) and (trim(xpedref) <> '') then
       delete from prdpedref where idcli=xicli and idprod=xiprd;
       insert into prdpedref(idprod, idcli, seqpedref)
       values (xiprd, xicli, xpedref);
    end if;
    
    if (xmanipulado) and (coalesce(xiprdbase,0) > 0) then
      set xiprdman = xiprd;
      set xiprd = xiprdbase;
      insert into estoque(dthrestoque, dthremissao, idemp, idusu, plataforma, origem, ida, idb, idprd, sku, cfop, fiscal, tipo, qtde, custo, idprdman)
      values(xdthrest, xdthremi, xiemp, xiusu, xplata, xorig, xida, xidb, xiprd, xsku, xcfop, xfiscal, xtipo, xqtde, xcusto, xiprdman);
    else
      insert into estoque(dthrestoque, dthremissao, idemp, idusu, plataforma, origem, ida, idb, idprd, sku, cfop, fiscal, tipo, qtde, custo)
      values(xdthrest, xdthremi, xiemp, xiusu, xplata, xorig, xida, xidb, xiprd, xsku, xcfop, xfiscal, xtipo, xqtde, xcusto);
    end if;

  end loop vendas;
  
  select c.idcomi from venda v 
  left outer join cnt c on (c.id=v.idvend) 
  where v.id=xidvenda into xcomi;
  
  update venda set tipo = 'V', baixado = True, idcomi = xcomi where id = xidvenda;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_venda_estorna
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_venda_estorna`(
    IN `xidvenda` integer,
    IN `xidusu` integer
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  update estoque e
  inner join vendaitem v on (e.origem='vendaitem' and e.ida = v.idvenda and e.idb = v.seq)
  set e.cancelado = True, e.idusucancela = xidusu
  where v.idvenda = xidvenda;
  
  update venda set tipo = 'P', baixado = False, faturado = False where id = xidvenda;
  
  delete from vendaoper where idvenda = xidvenda;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_venda_estorna_coblog
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_venda_estorna_coblog`(
    IN `xidvenda` integer
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  INSERT INTO cobtituloaltlog
  (idalter, idtitulo, idctarec, tpalter, arqseq, arqgerado, nmarq)
  select ca.idalter, ca.idtitulo, ca.idctarec, ca.tpalter, ca.arqseq, ca.arqgerado, ca.nmarq
  from ctareceber cr inner join cobtitulo cb on (cb.idctarec = cr.idctarec)
  inner join cobtituloalt ca on (ca.idtitulo = cb.idtitulo)
  where cr.idvenda = xidvenda;

  INSERT INTO cobtitulolog
  (idtitulo, idctarec, idcfg, dtcadastro, impresso, nn, nndv, linha, arqseq, arqgerado, nmarq, cancelado, idmov)
  select cb.idtitulo, cb.idctarec, cb.idcfg, cb.dtcadastro, cb.impresso, cb.nn, cb.nndv, cb.linha, cb.arqseq, cb.arqgerado, cb.nmarq, cb.cancelado, cb.idmov
  from ctareceber cr inner join cobtitulo cb on (cb.idctarec = cr.idctarec)
  where cr.idvenda = xidvenda;

  INSERT INTO ctareceberlog
  (idctarec, idvenda, idforma, seq, idcaixa, parcela, idcond, idcnt, idemp, emissao, vencimento, pagamento, valor, juros, multa, taxas, valortotal, valorpago, desconto, identracx, baixacob, idmov, obs, anulada, perda, bonificado, idctaorigem, vencoriginal)
  select cr.idctarec, cr.idvenda, cr.idforma, cr.seq, cr.idcaixa, cr.parcela, cr.idcond, cr.idcnt, cr.idemp, cr.emissao, cr.vencimento, cr.pagamento, cr.valor, cr.juros, cr.multa, cr.taxas, cr.valortotal, 
  cr.valorpago, cr.desconto, cr.identracx, cr.baixacob, cr.idmov, cr.obs, cr.anulada, cr.perda, cr.bonificado, cr.idctaorigem, cr.vencoriginal
  from ctareceber cr 
  where cr.idvenda = xidvenda;
END//
DELIMITER ;

-- Copiando estrutura para procedure b3erp.dsv.prc_venda_oper
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `prc_venda_oper`(
    IN `xidvenda` integer
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN

  delete from vendaoper where idvenda=xidvenda;
  
  insert into vendaoper (idvenda, seq, idoperacao, idimposto)
  select idvenda, seq, func_venda_operacaoprd(idvenda, seq), func_venda_impostoprd(idvenda, seq) from vendaitem where idvenda=xidvenda;

END//
DELIMITER ;

-- Copiando estrutura para tabela b3erp.dsv.prd
CREATE TABLE IF NOT EXISTS `prd` (
  `id` int NOT NULL AUTO_INCREMENT,
  `codigo` varchar(30) DEFAULT NULL,
  `ref` varchar(30) DEFAULT NULL,
  `refpar` varchar(100) DEFAULT NULL,
  `barras` varchar(30) DEFAULT NULL,
  `barrasdun` varchar(30) DEFAULT NULL,
  `isbn` varchar(30) DEFAULT NULL,
  `nome` varchar(100) NOT NULL,
  `nomeredu` varchar(29) DEFAULT NULL,
  `ncm` varchar(8) NOT NULL DEFAULT '99999999',
  `cest` varchar(7) DEFAULT NULL,
  `nbs` varchar(15) DEFAULT NULL,
  `cclass` varchar(8) NOT NULL DEFAULT '000001',
  `unidade` varchar(3) NOT NULL DEFAULT 'UN',
  `idsubgrupo` int DEFAULT NULL,
  `custo` decimal(12,3) NOT NULL DEFAULT '0.000',
  `custoa` decimal(12,3) NOT NULL DEFAULT '0.000',
  `customedio` decimal(12,6) NOT NULL DEFAULT '0.000000',
  `custoultimo` decimal(12,6) NOT NULL DEFAULT '0.000000',
  `margem` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `margemb` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `margemmin` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `venda` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vendab` decimal(12,3) NOT NULL DEFAULT '0.000',
  `saldoatu` decimal(9,3) NOT NULL DEFAULT '0.000',
  `saldomin` decimal(9,3) NOT NULL DEFAULT '0.000',
  `saldomax` decimal(9,3) NOT NULL DEFAULT '0.000',
  `pesob` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `pesol` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `altura` decimal(12,3) NOT NULL DEFAULT '0.000',
  `largura` decimal(12,3) NOT NULL DEFAULT '0.000',
  `comprimento` decimal(12,3) NOT NULL DEFAULT '0.000',
  `volume_m3` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `volume_cm3` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `tipoestoque` enum('X','Z') NOT NULL DEFAULT 'X',
  `serial` bit(1) NOT NULL DEFAULT b'0',
  `lote` bit(1) NOT NULL DEFAULT b'0',
  `sku` bit(1) NOT NULL DEFAULT b'0',
  `ativo` bit(1) NOT NULL DEFAULT b'1',
  `controla` bit(1) NOT NULL DEFAULT b'1',
  `balanca` bit(1) NOT NULL DEFAULT b'0',
  `podevender` bit(1) NOT NULL DEFAULT b'1',
  `podecomprar` bit(1) NOT NULL DEFAULT b'1',
  `servico` bit(1) NOT NULL DEFAULT b'0',
  `revenda` bit(1) NOT NULL DEFAULT b'1',
  `consumo` bit(1) NOT NULL DEFAULT b'0',
  `embalagem` bit(1) NOT NULL DEFAULT b'0',
  `materia` bit(1) NOT NULL DEFAULT b'0',
  `acabado` bit(1) NOT NULL DEFAULT b'0',
  `manipulado` bit(1) NOT NULL DEFAULT b'0',
  `prdcontrolado` bit(1) NOT NULL DEFAULT b'0',
  `usado` bit(1) NOT NULL DEFAULT b'0',
  `receita` mediumtext,
  `qtdvenda` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `unqtdvenda` varchar(3) DEFAULT NULL,
  `qtdatacado` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `qtdreceita` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `origem` varchar(2) NOT NULL DEFAULT '0',
  `cenqipi` varchar(10) DEFAULT NULL,
  `codselo` varchar(20) DEFAULT NULL,
  `idfabricante` smallint unsigned DEFAULT '1',
  `dtcad` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dtultcp` date DEFAULT NULL,
  `diasrepo` smallint NOT NULL DEFAULT '0',
  `localiza` varchar(60) DEFAULT NULL,
  `dthrvarejo` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dthratacado` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `diasvenc` smallint NOT NULL DEFAULT '0',
  `codbene` varchar(20) DEFAULT NULL,
  `idprdbase` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_prd_prdorigem1_idx` (`origem`),
  KEY `prd_idx_nome` (`nome`),
  KEY `prd_idx_barras` (`barras`),
  KEY `prd_idx_codref` (`codigo`,`ref`),
  KEY `fk_prd_prdsubgrupo1_idx` (`idsubgrupo`),
  KEY `fk_prd_fabricante_idx` (`idfabricante`),
  KEY `fk_prd_prdbase_idx` (`idprdbase`),
  KEY `fk_prd_tribClass_idx` (`cclass`),
  CONSTRAINT `fk_prd_fabricante` FOREIGN KEY (`idfabricante`) REFERENCES `fabricante` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_prd_prdbase` FOREIGN KEY (`idprdbase`) REFERENCES `prd` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_prd_prdorigem1` FOREIGN KEY (`origem`) REFERENCES `prdorigem` (`origem`) ON UPDATE CASCADE,
  CONSTRAINT `fk_prd_prdsubgrupo1` FOREIGN KEY (`idsubgrupo`) REFERENCES `prdsubgrupo` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_prd_tribClass` FOREIGN KEY (`cclass`) REFERENCES `tribClass` (`classTrib`) ON DELETE RESTRICT ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=299 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdaplic
CREATE TABLE IF NOT EXISTS `prdaplic` (
  `idprd` int NOT NULL,
  `ideqp` smallint unsigned NOT NULL,
  `revisao` decimal(12,3) DEFAULT '0.000',
  `unidade` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`idprd`,`ideqp`),
  KEY `fk_prdaplic_prdeqp_idx` (`ideqp`),
  CONSTRAINT `fk_prdaplic_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_prdaplic_prdeqp` FOREIGN KEY (`ideqp`) REFERENCES `prdeqp` (`ideqp`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdeqp
CREATE TABLE IF NOT EXISTS `prdeqp` (
  `ideqp` smallint unsigned NOT NULL AUTO_INCREMENT,
  `idfabricante` smallint unsigned NOT NULL,
  `nome` varchar(80) NOT NULL,
  PRIMARY KEY (`ideqp`),
  KEY `fk_prdeqp_fabricante_idx` (`idfabricante`),
  CONSTRAINT `fk_prdeqp_fabricante` FOREIGN KEY (`idfabricante`) REFERENCES `fabricante` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdfor
CREATE TABLE IF NOT EXISTS `prdfor` (
  `idprd` int NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `codfor` varchar(40) NOT NULL,
  `fator` decimal(12,3) NOT NULL DEFAULT '1.000',
  `unidade` varchar(3) NOT NULL DEFAULT 'UN',
  `eanfor` varchar(45) DEFAULT NULL,
  `descrfor` varchar(120) DEFAULT NULL,
  PRIMARY KEY (`idprd`,`idcnt`,`codfor`),
  KEY `fk_prdfor_cnt_idx` (`idcnt`),
  CONSTRAINT `fk_prdfor_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_prdfor_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdgrade
CREATE TABLE IF NOT EXISTS `prdgrade` (
  `idgrade` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `grade` varchar(50) NOT NULL,
  PRIMARY KEY (`idgrade`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdgrupo
CREATE TABLE IF NOT EXISTS `prdgrupo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `grupo` varchar(60) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `grupo_UNIQUE` (`grupo`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdicmscst
CREATE TABLE IF NOT EXISTS `prdicmscst` (
  `cst` varchar(3) NOT NULL,
  `nomecst` varchar(120) NOT NULL,
  PRIMARY KEY (`cst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdimg
CREATE TABLE IF NOT EXISTS `prdimg` (
  `idprd` int NOT NULL,
  `seq` tinyint NOT NULL,
  `altura` decimal(12,2) NOT NULL DEFAULT '0.00',
  `largura` decimal(12,2) NOT NULL DEFAULT '0.00',
  `nomearq` varchar(200) DEFAULT NULL,
  `nomearqmini` varchar(200) DEFAULT NULL,
  `urlb3` varchar(300) DEFAULT NULL,
  `thurlb3` varchar(300) DEFAULT NULL,
  `urls3` varchar(300) DEFAULT NULL,
  `thurls3` varchar(300) DEFAULT NULL,
  `ekey` varchar(100) DEFAULT NULL,
  `thekey` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`idprd`,`seq`),
  CONSTRAINT `fk_prdimg_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdimposto
CREATE TABLE IF NOT EXISTS `prdimposto` (
  `idprd` int NOT NULL,
  `idoperacao` smallint unsigned NOT NULL,
  `idimposto` int NOT NULL,
  PRIMARY KEY (`idprd`,`idoperacao`),
  KEY `fk_prdimposto_operacoes_idx` (`idoperacao`),
  KEY `fk_prdimposto_impostos_idx` (`idimposto`),
  CONSTRAINT `fk_prdimposto_impostos` FOREIGN KEY (`idimposto`) REFERENCES `impostos` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_prdimposto_operacoes` FOREIGN KEY (`idoperacao`) REFERENCES `operacoes` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_prdimposto_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdinfo
CREATE TABLE IF NOT EXISTS `prdinfo` (
  `idprd` int NOT NULL,
  `mdesc` varchar(300) DEFAULT NULL,
  `mkey` varchar(200) DEFAULT NULL,
  `texto` text,
  `html` text,
  PRIMARY KEY (`idprd`),
  CONSTRAINT `fk_prdinfo_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdipicst
CREATE TABLE IF NOT EXISTS `prdipicst` (
  `cst` varchar(3) NOT NULL,
  `nomecst` varchar(120) NOT NULL,
  PRIMARY KEY (`cst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdlote
CREATE TABLE IF NOT EXISTS `prdlote` (
  `idlote` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `idprd` int NOT NULL,
  `codlote` varchar(20) NOT NULL,
  `fabricacao` date NOT NULL,
  `validade` date NOT NULL,
  `saldo` decimal(12,3) NOT NULL DEFAULT '0.000',
  `idmov` int unsigned DEFAULT NULL,
  `seqmov` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`idlote`),
  KEY `fk_prdlote_cnt_idx` (`idemp`),
  KEY `fk_prdlote_prd_idx` (`idprd`),
  KEY `fk_prdlote_movprd_idx` (`idmov`,`seqmov`),
  CONSTRAINT `fk_prdlote_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_prdlote_movprd` FOREIGN KEY (`idmov`, `seqmov`) REFERENCES `movprd` (`idmov`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_prdlote_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdmarkup
CREATE TABLE IF NOT EXISTS `prdmarkup` (
  `idprd` int NOT NULL,
  `impfed` decimal(12,3) NOT NULL DEFAULT '0.000',
  `impest` decimal(12,3) NOT NULL DEFAULT '0.000',
  `impmun` decimal(12,3) NOT NULL DEFAULT '0.000',
  `comissao` decimal(12,3) NOT NULL DEFAULT '0.000',
  `folha` decimal(12,3) NOT NULL DEFAULT '0.000',
  `custofixo` decimal(12,3) NOT NULL DEFAULT '0.000',
  `outros` decimal(12,3) NOT NULL DEFAULT '0.000',
  `mvarejo` decimal(12,3) NOT NULL DEFAULT '0.000',
  `matacado` decimal(12,3) NOT NULL DEFAULT '0.000',
  `ivarejo` decimal(12,3) NOT NULL DEFAULT '0.000',
  `iatacado` decimal(12,3) NOT NULL DEFAULT '0.000',
  `tvarejo` decimal(12,3) NOT NULL DEFAULT '0.000',
  `tatacado` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idprd`),
  CONSTRAINT `fk_prdmarkup_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdminmax
CREATE TABLE IF NOT EXISTS `prdminmax` (
  `idprod` int NOT NULL,
  `idemp` int unsigned NOT NULL,
  `ano` smallint NOT NULL,
  `mes` tinyint NOT NULL,
  `total` float NOT NULL DEFAULT '0',
  `minimo` float NOT NULL DEFAULT '0',
  `maximo` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`idprod`,`idemp`,`ano`,`mes`),
  KEY `fk_prdminmax_emp_idx` (`idemp`),
  CONSTRAINT `fk_prdminmax_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_prdminmax_prd` FOREIGN KEY (`idprod`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdobs
CREATE TABLE IF NOT EXISTS `prdobs` (
  `idprdobs` int NOT NULL AUTO_INCREMENT,
  `obsprd` varchar(80) NOT NULL,
  PRIMARY KEY (`idprdobs`),
  UNIQUE KEY `prdobs_unq` (`obsprd`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdorigem
CREATE TABLE IF NOT EXISTS `prdorigem` (
  `origem` varchar(2) NOT NULL,
  `nomeorigem` varchar(150) NOT NULL,
  PRIMARY KEY (`origem`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdpacote
CREATE TABLE IF NOT EXISTS `prdpacote` (
  `idprd` int NOT NULL,
  `tipo` enum('P','S') NOT NULL DEFAULT 'P',
  `qtde` smallint DEFAULT '1',
  `pesob` decimal(12,4) DEFAULT '0.0000',
  `pesol` decimal(12,4) DEFAULT '0.0000',
  `altura` decimal(12,3) DEFAULT '0.000',
  `largura` decimal(12,3) DEFAULT '0.000',
  `comprimento` decimal(12,3) DEFAULT '0.000',
  `volume_m3` decimal(12,4) DEFAULT '0.0000',
  `volume_c3` decimal(12,4) DEFAULT '0.0000',
  `lastro` smallint DEFAULT '1',
  `camada` smallint DEFAULT '1',
  PRIMARY KEY (`idprd`,`tipo`),
  CONSTRAINT `fk_prdpacote_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdpedref
CREATE TABLE IF NOT EXISTS `prdpedref` (
  `idprod` int NOT NULL,
  `idcli` int unsigned NOT NULL,
  `seqpedref` varchar(30) NOT NULL,
  PRIMARY KEY (`idprod`,`idcli`),
  KEY `fk_prdpedref_cli_idx` (`idcli`),
  CONSTRAINT `fk_prdpedref_cli` FOREIGN KEY (`idcli`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_prdpedref_prd` FOREIGN KEY (`idprod`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdpiscst
CREATE TABLE IF NOT EXISTS `prdpiscst` (
  `cst` varchar(3) NOT NULL,
  `nomecst` varchar(120) NOT NULL,
  PRIMARY KEY (`cst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdsaldo
CREATE TABLE IF NOT EXISTS `prdsaldo` (
  `idemp` int unsigned NOT NULL,
  `idprod` int NOT NULL,
  `saldo` decimal(12,3) DEFAULT '0.000',
  PRIMARY KEY (`idemp`,`idprod`),
  KEY `fk_prdsaldo_prd_idx` (`idprod`),
  CONSTRAINT `fk_prdsaldo_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_prdsaldo_prd` FOREIGN KEY (`idprod`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdserial
CREATE TABLE IF NOT EXISTS `prdserial` (
  `idserial` int unsigned NOT NULL AUTO_INCREMENT,
  `idemp` int unsigned NOT NULL,
  `idprd` int NOT NULL,
  `serial` varchar(60) NOT NULL DEFAULT 'Não informado',
  `imei` varchar(30) DEFAULT NULL,
  `idmov` int unsigned DEFAULT NULL,
  `seqmov` smallint unsigned DEFAULT NULL,
  `baixado` bit(1) NOT NULL DEFAULT b'0',
  `idvenda` int unsigned DEFAULT NULL,
  `seqvenda` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`idserial`),
  KEY `fk_prdserial_cnt_idx` (`idemp`),
  KEY `fk_prdserial_prd_idx` (`idprd`),
  KEY `fk_prdserial_vendaitem_idx` (`idvenda`,`seqvenda`),
  KEY `fk_prdserial_movprd_idx` (`idmov`,`seqmov`),
  CONSTRAINT `fk_prdserial_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_prdserial_movprd` FOREIGN KEY (`idmov`, `seqmov`) REFERENCES `movprd` (`idmov`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_prdserial_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_prdserial_vendaitem` FOREIGN KEY (`idvenda`, `seqvenda`) REFERENCES `vendaitem` (`idvenda`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdsku
CREATE TABLE IF NOT EXISTS `prdsku` (
  `sku` varchar(45) NOT NULL,
  `idprd` int NOT NULL,
  `codigo` varchar(30) NOT NULL,
  `idvar1` smallint unsigned NOT NULL,
  `codvar1` varchar(4) NOT NULL,
  `idvar2` smallint unsigned DEFAULT NULL,
  `codvar2` varchar(4) DEFAULT NULL,
  `idvar3` smallint unsigned DEFAULT NULL,
  `codvar3` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`sku`),
  KEY `fk_prdsku_prd_idx` (`idprd`),
  KEY `fk_prdsku_prdvar1_idx` (`idvar1`),
  KEY `fk_prdsku_prdvar2_idx` (`idvar2`),
  KEY `fk_prdsku_prdvar3_idx` (`idvar3`),
  CONSTRAINT `fk_prdsku_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_prdsku_prdvar1` FOREIGN KEY (`idvar1`) REFERENCES `prdvar` (`idvar`) ON UPDATE CASCADE,
  CONSTRAINT `fk_prdsku_prdvar2` FOREIGN KEY (`idvar2`) REFERENCES `prdvar` (`idvar`) ON UPDATE CASCADE,
  CONSTRAINT `fk_prdsku_prdvar3` FOREIGN KEY (`idvar3`) REFERENCES `prdvar` (`idvar`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdskusaldo
CREATE TABLE IF NOT EXISTS `prdskusaldo` (
  `idemp` int unsigned NOT NULL,
  `sku` varchar(45) NOT NULL,
  `saldo` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idemp`,`sku`),
  KEY `fk_prdskusaldo_prdsku_idx` (`sku`),
  CONSTRAINT `fk_prdskusaldo_cnt` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_prdskusaldo_prdsku` FOREIGN KEY (`sku`) REFERENCES `prdsku` (`sku`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdsubgrupo
CREATE TABLE IF NOT EXISTS `prdsubgrupo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idgrupo` int NOT NULL,
  `subgrupo` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `subgrupo_UNIQUE` (`subgrupo`),
  KEY `fk_prdsubgrupo_prdgrupo1_idx` (`idgrupo`),
  CONSTRAINT `fk_prdsubgrupo_prdgrupo1` FOREIGN KEY (`idgrupo`) REFERENCES `prdgrupo` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdtab
CREATE TABLE IF NOT EXISTS `prdtab` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `nometab` varchar(60) NOT NULL,
  `perc` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `percb` decimal(10,4) NOT NULL DEFAULT '0.0000',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdtabvalor
CREATE TABLE IF NOT EXISTS `prdtabvalor` (
  `idtab` smallint unsigned NOT NULL,
  `idprod` int NOT NULL,
  `valor` decimal(12,3) NOT NULL DEFAULT '0.000',
  `valorb` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idtab`,`idprod`),
  KEY `fk_tabvalor_prd_idx` (`idprod`),
  CONSTRAINT `fk_tabvalor_prd` FOREIGN KEY (`idprod`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tabvalor_tab` FOREIGN KEY (`idtab`) REFERENCES `prdtab` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.prdvar
CREATE TABLE IF NOT EXISTS `prdvar` (
  `idvar` smallint unsigned NOT NULL AUTO_INCREMENT,
  `idgrade` tinyint unsigned NOT NULL,
  `nomevar` varchar(50) NOT NULL,
  `nomeopt` varchar(50) NOT NULL,
  `codigo` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`idvar`),
  KEY `fk_prdvar_prdgrade_idx` (`idgrade`),
  CONSTRAINT `fk_prdvar_prdgrade` FOREIGN KEY (`idgrade`) REFERENCES `prdgrade` (`idgrade`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para procedure b3erp.dsv.raise
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` PROCEDURE `raise`(coderro BigInt, msgerro VarChar(256))
    NO SQL
    DETERMINISTIC
    SQL SECURITY INVOKER
BEGIN
SIGNAL SQLSTATE
    'ERR0R'
SET
    MESSAGE_TEXT = `msgerro`,
    MYSQL_ERRNO = `coderro`;
END//
DELIMITER ;

-- Copiando estrutura para tabela b3erp.dsv.romaneio
CREATE TABLE IF NOT EXISTS `romaneio` (
  `idromaneio` int unsigned NOT NULL AUTO_INCREMENT,
  `tipo` enum('V','T','B','X') NOT NULL DEFAULT 'X',
  `finalidade` enum('S','C') NOT NULL DEFAULT 'C',
  `dthrcad` datetime NOT NULL,
  `vtotal` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pesol` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pesob` decimal(12,3) NOT NULL DEFAULT '0.000',
  `qvolume` smallint DEFAULT NULL,
  `idlog` int unsigned DEFAULT NULL,
  `placa` varchar(30) DEFAULT NULL,
  `idfunc` int unsigned DEFAULT NULL,
  `idemp` int unsigned NOT NULL,
  PRIMARY KEY (`idromaneio`),
  KEY `fk_romaneio_cntlog_idx` (`idlog`),
  KEY `fk_romaneio_cntfunc_idx` (`idfunc`),
  KEY `fk_romaneio_cntemp_idx` (`idemp`),
  CONSTRAINT `fk_romaneio_cntemp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_romaneio_cntfunc` FOREIGN KEY (`idfunc`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_romaneio_cntlog` FOREIGN KEY (`idlog`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.romaneioitem
CREATE TABLE IF NOT EXISTS `romaneioitem` (
  `idvenda` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `idromaneio` int unsigned NOT NULL,
  PRIMARY KEY (`idvenda`,`seq`),
  KEY `fk_romaneioitem_romaneio_idx` (`idromaneio`),
  CONSTRAINT `fk_romaneioitem_romaneio` FOREIGN KEY (`idromaneio`) REFERENCES `romaneio` (`idromaneio`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_romaneioitem_vendaitem` FOREIGN KEY (`idvenda`, `seq`) REFERENCES `vendaitem` (`idvenda`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.romaneiopost
CREATE TABLE IF NOT EXISTS `romaneiopost` (
  `idpost` int unsigned NOT NULL,
  `idvenda` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `metodo` enum('P','C','X') NOT NULL DEFAULT 'X',
  `dthrcad` datetime NOT NULL,
  `idlog` int unsigned DEFAULT NULL,
  `codtrack` varchar(60) DEFAULT NULL,
  `nocc` varchar(45) DEFAULT NULL,
  `socc` varchar(20) DEFAULT NULL,
  `dtocc` date DEFAULT NULL,
  PRIMARY KEY (`idvenda`,`seq`,`idpost`),
  KEY `fk_romaneiopost_cntlog_idx` (`idlog`),
  CONSTRAINT `fk_romaneiopost_cntlog` FOREIGN KEY (`idlog`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_romaneiopost_vendaitem` FOREIGN KEY (`idvenda`, `seq`) REFERENCES `vendaitem` (`idvenda`, `seq`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.romaneiotot
CREATE TABLE IF NOT EXISTS `romaneiotot` (
  `idromaneio` int unsigned NOT NULL,
  `idprod` int NOT NULL,
  `qtdtotal` decimal(12,3) NOT NULL DEFAULT '0.000',
  `qtdvenda` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `qtdpackauto` varchar(100) DEFAULT NULL,
  `qtdpackmanu` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`idromaneio`,`idprod`),
  KEY `fk_romatot_prd_idx` (`idprod`),
  CONSTRAINT `fk_romatot_prd` FOREIGN KEY (`idprod`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_romatot_roma` FOREIGN KEY (`idromaneio`) REFERENCES `romaneio` (`idromaneio`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.rota
CREATE TABLE IF NOT EXISTS `rota` (
  `idrota` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(80) NOT NULL,
  PRIMARY KEY (`idrota`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.spedcfg
CREATE TABLE IF NOT EXISTS `spedcfg` (
  `idemp` int unsigned NOT NULL,
  `ftipo` varchar(1) NOT NULL DEFAULT '0',
  `fperfil` varchar(1) NOT NULL DEFAULT 'A',
  `findustria` varchar(2) NOT NULL DEFAULT '00',
  `cnatcnpj` varchar(2) NOT NULL DEFAULT '00',
  `catividade` varchar(1) NOT NULL DEFAULT '0',
  `contaprod` varchar(30) DEFAULT NULL,
  `nome` varchar(80) DEFAULT NULL,
  `cpf` varchar(20) DEFAULT NULL,
  `crc` varchar(30) DEFAULT NULL,
  `cep` varchar(20) DEFAULT NULL,
  `endereco` varchar(80) DEFAULT NULL,
  `cidade` varchar(50) DEFAULT NULL,
  `uf` varchar(4) DEFAULT NULL,
  `codmun` varchar(12) DEFAULT NULL,
  `codicms` varchar(12) DEFAULT NULL,
  `codst` varchar(12) DEFAULT NULL,
  `codpis` varchar(12) DEFAULT NULL,
  `codcofins` varchar(12) DEFAULT NULL,
  `isentomostrabc` bit(1) DEFAULT b'0',
  PRIMARY KEY (`idemp`),
  CONSTRAINT `fk_spedcfg_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.spedcontrib
CREATE TABLE IF NOT EXISTS `spedcontrib` (
  `idemp` int unsigned NOT NULL,
  `exercicio` varchar(7) NOT NULL,
  `dtini` date NOT NULL,
  `dtfim` date NOT NULL,
  `layout` varchar(10) NOT NULL,
  `tipo` varchar(1) NOT NULL DEFAULT '0',
  `recanterior` varchar(50) DEFAULT NULL,
  `credpis` decimal(12,2) DEFAULT '0.00',
  `credcofins` decimal(12,2) DEFAULT '0.00',
  `recolherpis` decimal(12,2) DEFAULT '0.00',
  `recolhercofins` decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`idemp`,`exercicio`),
  CONSTRAINT `fk_spedcontrib_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.spedfiscal
CREATE TABLE IF NOT EXISTS `spedfiscal` (
  `idemp` int unsigned NOT NULL,
  `exercicio` varchar(7) NOT NULL,
  `dtini` date NOT NULL,
  `dtfim` date NOT NULL,
  `layout` varchar(10) NOT NULL,
  `dticmsvenc` date NOT NULL,
  `dtstvenc` date NOT NULL,
  `credicms` decimal(12,2) DEFAULT '0.00',
  `credipi` decimal(12,2) DEFAULT '0.00',
  `recolhericms` decimal(12,2) DEFAULT '0.00',
  `recolherst` decimal(12,2) DEFAULT '0.00',
  `recolheripi` decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`idemp`,`exercicio`),
  CONSTRAINT `fk_spedfiscal_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.tb_docs
CREATE TABLE IF NOT EXISTS `tb_docs` (
  `iddoc` int NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `idusu` int unsigned NOT NULL,
  `datareg` date NOT NULL,
  `tipodoc` varchar(60) DEFAULT 'EXAMES',
  `tipoarq` varchar(3) DEFAULT 'PDF',
  `docu` mediumblob,
  PRIMARY KEY (`iddoc`),
  KEY `fk_docs_aluno_idx` (`idcnt`),
  KEY `fk_docs_usu_idx` (`idusu`),
  CONSTRAINT `fk_docs_aluno` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_docs_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.tb_evento
CREATE TABLE IF NOT EXISTS `tb_evento` (
  `idevento` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `dtini` date NOT NULL,
  `dtfim` date NOT NULL,
  `idusu` int unsigned NOT NULL,
  `justifica` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`idevento`),
  KEY `fk_tbevento_cnt_idx` (`idcnt`),
  KEY `fk_tbevento_usu_idx` (`idusu`),
  KEY `tbevento_idx1` (`idcnt`,`dtini`,`dtfim`),
  CONSTRAINT `fk_tbevento_cnt` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tbevento_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.tb_frases
CREATE TABLE IF NOT EXISTS `tb_frases` (
  `idfrase` int NOT NULL AUTO_INCREMENT,
  `frase` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `tipo` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `autor` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`idfrase`)
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.tb_justi
CREATE TABLE IF NOT EXISTS `tb_justi` (
  `idjusti` int NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `idusu` int unsigned NOT NULL,
  `datareg` date NOT NULL,
  `justifica` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`idjusti`),
  KEY `fk_justi_cnt_idx` (`idcnt`),
  KEY `fk_justi_usu_idx` (`idusu`),
  CONSTRAINT `fk_justi_aluno` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_justi_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.tb_treino
CREATE TABLE IF NOT EXISTS `tb_treino` (
  `idtreino` int unsigned NOT NULL AUTO_INCREMENT,
  `idcnt` int unsigned NOT NULL,
  `idusu` int unsigned NOT NULL,
  `dthremi` datetime NOT NULL,
  `datareg` date NOT NULL,
  `overdrive` bit(1) NOT NULL DEFAULT b'0',
  `tempo` tinyint NOT NULL DEFAULT '0',
  `obs` varchar(512) DEFAULT NULL,
  `pse` tinyint DEFAULT NULL,
  `sensorial` tinyint DEFAULT NULL,
  `sono` tinyint DEFAULT NULL,
  `hidrata` tinyint DEFAULT NULL,
  `dispo` tinyint DEFAULT NULL,
  `intes` tinyint DEFAULT NULL,
  `alimen` tinyint DEFAULT NULL,
  PRIMARY KEY (`idtreino`),
  KEY `fk_treino_aluno_idx` (`idcnt`),
  KEY `fk_treino_usu_idx` (`idusu`),
  CONSTRAINT `fk_treino_aluno` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_treino_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.temp_mnu_1
CREATE TABLE IF NOT EXISTS `temp_mnu_1` (
  `id` smallint NOT NULL DEFAULT '0',
  `idpai` smallint DEFAULT '1',
  `nome` varchar(100) NOT NULL,
  `descricao` varchar(200) DEFAULT NULL,
  `sql` mediumtext,
  `exe` varchar(200) DEFAULT NULL,
  `anexo` bit(1) DEFAULT b'0',
  `tipo` enum('M','E','P','R','S') DEFAULT 'M',
  `ordem` smallint NOT NULL DEFAULT '0',
  `idicone` smallint DEFAULT NULL,
  `icone` mediumblob,
  `nmclasse` varchar(80) DEFAULT NULL,
  `atalho` varchar(45) DEFAULT NULL,
  `fonte` mediumtext,
  `liberado` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  KEY `FK_temp_mnu_1` (`idpai`),
  CONSTRAINT `FK_temp_mnu_1` FOREIGN KEY (`idpai`) REFERENCES `temp_mnu_1` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.temp_mnu_2
CREATE TABLE IF NOT EXISTS `temp_mnu_2` (
  `id` smallint NOT NULL DEFAULT '0',
  `idpai` smallint DEFAULT '1',
  `nome` varchar(100) NOT NULL,
  `descricao` varchar(200) DEFAULT NULL,
  `sql` mediumtext,
  `exe` varchar(200) DEFAULT NULL,
  `anexo` bit(1) DEFAULT b'0',
  `tipo` enum('M','E','P','R','S') DEFAULT 'M',
  `ordem` smallint NOT NULL DEFAULT '0',
  `idicone` smallint DEFAULT NULL,
  `icone` mediumblob,
  `nmclasse` varchar(80) DEFAULT NULL,
  `atalho` varchar(45) DEFAULT NULL,
  `fonte` mediumtext,
  `liberado` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  KEY `FK_temp_mnu_2` (`idpai`),
  CONSTRAINT `FK_temp_mnu_2` FOREIGN KEY (`idpai`) REFERENCES `temp_mnu_2` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.temp_mnu_3
CREATE TABLE IF NOT EXISTS `temp_mnu_3` (
  `id` smallint NOT NULL DEFAULT '0',
  `idpai` smallint DEFAULT '1',
  `nome` varchar(100) NOT NULL,
  `descricao` varchar(200) DEFAULT NULL,
  `sql` mediumtext,
  `exe` varchar(200) DEFAULT NULL,
  `anexo` bit(1) DEFAULT b'0',
  `tipo` enum('M','E','P','R','S') DEFAULT 'M',
  `ordem` smallint NOT NULL DEFAULT '0',
  `idicone` smallint DEFAULT NULL,
  `icone` mediumblob,
  `nmclasse` varchar(80) DEFAULT NULL,
  `atalho` varchar(45) DEFAULT NULL,
  `fonte` mediumtext,
  `liberado` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  KEY `FK_temp_mnu_3` (`idpai`),
  CONSTRAINT `FK_temp_mnu_3` FOREIGN KEY (`idpai`) REFERENCES `temp_mnu_3` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.tribAliq
CREATE TABLE IF NOT EXISTS `tribAliq` (
  `idAliq` int NOT NULL AUTO_INCREMENT,
  `nomeAliq` varchar(255) NOT NULL,
  `ckPadrao` bit(1) NOT NULL DEFAULT b'0',
  `ckFixo` bit(1) NOT NULL DEFAULT b'0',
  `ckSemAliq` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idAliq`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.tribAnexos
CREATE TABLE IF NOT EXISTS `tribAnexos` (
  `idAnexo` int NOT NULL AUTO_INCREMENT,
  `nroAnexo` int NOT NULL,
  `codNcmNbs` varchar(10) NOT NULL,
  `tipoAnexo` varchar(5) NOT NULL,
  `dthrIniVig` datetime NOT NULL,
  `dthrFimVig` datetime DEFAULT NULL,
  PRIMARY KEY (`idAnexo`),
  KEY `idx_ncm_anexo` (`codNcmNbs`,`nroAnexo`)
) ENGINE=InnoDB AUTO_INCREMENT=2195 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.tribClass
CREATE TABLE IF NOT EXISTS `tribClass` (
  `cst` varchar(4) NOT NULL,
  `classif` varchar(4) NOT NULL,
  `classTrib` varchar(8) NOT NULL,
  `nomeTrib` varchar(200) NOT NULL,
  `descritivoTrib` text,
  `redacaoTrib` text,
  `lc214_25` varchar(60) DEFAULT NULL,
  `pReduIBS` decimal(12,3) DEFAULT '0.000',
  `pReduCBS` decimal(12,3) DEFAULT '0.000',
  `ckTribRegular` bit(1) NOT NULL DEFAULT b'0',
  `ckCredPresu` bit(1) NOT NULL DEFAULT b'0',
  `ckEstornoCred` bit(1) NOT NULL DEFAULT b'0',
  `ckMonoNormal` bit(1) NOT NULL DEFAULT b'0',
  `ckMonoRetencao` bit(1) NOT NULL DEFAULT b'0',
  `ckMonoRetida` bit(1) NOT NULL DEFAULT b'0',
  `ckMonoDiferimento` bit(1) NOT NULL DEFAULT b'0',
  `idAliq` int DEFAULT NULL,
  `NFe` bit(1) NOT NULL DEFAULT b'0',
  `NFCe` bit(1) NOT NULL DEFAULT b'0',
  `CTe` bit(1) NOT NULL DEFAULT b'0',
  `CTeOS` bit(1) NOT NULL DEFAULT b'0',
  `BPe` bit(1) NOT NULL DEFAULT b'0',
  `NF3e` bit(1) NOT NULL DEFAULT b'0',
  `NFCom` bit(1) NOT NULL DEFAULT b'0',
  `NFSE` bit(1) NOT NULL DEFAULT b'0',
  `BPeTM` bit(1) NOT NULL DEFAULT b'0',
  `BPeTA` bit(1) NOT NULL DEFAULT b'0',
  `NFAg` bit(1) NOT NULL DEFAULT b'0',
  `NFSVIA` bit(1) NOT NULL DEFAULT b'0',
  `NFABI` bit(1) NOT NULL DEFAULT b'0',
  `NFGas` bit(1) NOT NULL DEFAULT b'0',
  `DERE` bit(1) NOT NULL DEFAULT b'0',
  `numAnexo` varchar(50) DEFAULT NULL,
  `urlLCP` varchar(180) DEFAULT NULL,
  PRIMARY KEY (`classTrib`),
  UNIQUE KEY `UK_tribClass_class` (`cst`,`classif`) USING BTREE,
  KEY `FK_tribClass_tribAliq` (`idAliq`),
  CONSTRAINT `FK_tribClass_tribAliq` FOREIGN KEY (`idAliq`) REFERENCES `tribAliq` (`idAliq`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `FK_tribClass_tribCst` FOREIGN KEY (`cst`) REFERENCES `tribCst` (`cst`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.tribCst
CREATE TABLE IF NOT EXISTS `tribCst` (
  `cst` varchar(4) NOT NULL,
  `nomecst` varchar(255) NOT NULL,
  `ckTrib` bit(1) NOT NULL DEFAULT b'0',
  `ckReduzBase` bit(1) NOT NULL DEFAULT b'0',
  `ckReduzAliq` bit(1) NOT NULL DEFAULT b'0',
  `ckTransfCred` bit(1) NOT NULL DEFAULT b'0',
  `ckDifere` bit(1) NOT NULL DEFAULT b'0',
  `ckMono` bit(1) NOT NULL DEFAULT b'0',
  `ckPresuIBSZFM` bit(1) NOT NULL DEFAULT b'0',
  `ckAjuste` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`cst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.tribIndOper
CREATE TABLE IF NOT EXISTS `tribIndOper` (
  `codOperacao` varchar(6) NOT NULL,
  `nomeOperacao` varchar(255) NOT NULL,
  `texDispLegal` varchar(50) NOT NULL,
  `texLocalOperacao` varchar(500) NOT NULL,
  `texLocalFornec` varchar(500) NOT NULL,
  `texCaractFornec` varchar(500) NOT NULL,
  `dthrPublicacao` datetime NOT NULL,
  `dthrIniVig` datetime NOT NULL,
  `dthrFimVig` datetime DEFAULT NULL,
  PRIMARY KEY (`codOperacao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.usu
CREATE TABLE IF NOT EXISTS `usu` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `userId` varchar(60) DEFAULT NULL,
  `login` varchar(60) DEFAULT NULL,
  `senha` varchar(255) DEFAULT NULL,
  `nome` varchar(60) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `telefone` varchar(60) DEFAULT NULL,
  `inativo` bit(1) NOT NULL DEFAULT b'0',
  `caixa` bit(1) NOT NULL DEFAULT b'0',
  `agendaliberada` bit(1) NOT NULL DEFAULT b'0',
  `dashboard` bit(1) NOT NULL DEFAULT b'0',
  `dtadd` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `idvend` int unsigned DEFAULT NULL,
  `assinatura` mediumblob,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_unique_userId` (`userId`),
  KEY `fk_usu_cntvend_idx` (`idvend`),
  CONSTRAINT `fk_usu_cntvend` FOREIGN KEY (`idvend`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.usuagenda
CREATE TABLE IF NOT EXISTS `usuagenda` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `idusu` int unsigned NOT NULL,
  `idemp` int unsigned NOT NULL,
  `idpai` int DEFAULT NULL,
  `tipo` int DEFAULT NULL,
  `inicio` datetime DEFAULT NULL,
  `fim` datetime DEFAULT NULL,
  `options` int DEFAULT NULL,
  `titulo` varchar(255) DEFAULT NULL,
  `recurrindex` int DEFAULT NULL,
  `recurrinfo` mediumblob,
  `resourceid` mediumblob,
  `local` varchar(255) DEFAULT NULL,
  `mensagem` varchar(255) DEFAULT NULL,
  `datalembrete` datetime DEFAULT NULL,
  `minutoslembrete` int DEFAULT NULL,
  `estado` int DEFAULT NULL,
  `rotulo` int DEFAULT NULL,
  `inicioreal` datetime DEFAULT NULL,
  `fimreal` datetime DEFAULT NULL,
  `idsync` varchar(255) DEFAULT NULL,
  `tarefacompleta` int DEFAULT NULL,
  `tarefaindex` int DEFAULT NULL,
  `tarefalinks` mediumblob,
  `tarefastatus` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_usuagenda_usu_idx` (`idusu`),
  KEY `fk_usuagenda_emp_idx` (`idemp`),
  CONSTRAINT `fk_usuagenda_emp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_usuagenda_usu` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.usuemp
CREATE TABLE IF NOT EXISTS `usuemp` (
  `idusu` int unsigned NOT NULL,
  `idcnt` int unsigned NOT NULL,
  PRIMARY KEY (`idusu`,`idcnt`),
  KEY `fk_usuemp_cnt1_idx` (`idcnt`),
  CONSTRAINT `fk_usuemp_cnt1` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_usuemp_usu1` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.usugrupo
CREATE TABLE IF NOT EXISTS `usugrupo` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `grupo` varchar(60) NOT NULL,
  `acesso` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_u_role` (`grupo`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.usulogin
CREATE TABLE IF NOT EXISTS `usulogin` (
  `idusu` int unsigned NOT NULL,
  `token` varchar(255) NOT NULL,
  `idcnt` int unsigned NOT NULL,
  `validade` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dthrlogin` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tenancy` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`idusu`,`token`),
  KEY `fk_usulogin_cnt1_idx` (`idcnt`),
  CONSTRAINT `fk_usulogin_cnt1` FOREIGN KEY (`idcnt`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_usulogin_usu1` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.usurole
CREATE TABLE IF NOT EXISTS `usurole` (
  `idusu` int unsigned NOT NULL,
  `idusugrupo` int unsigned NOT NULL,
  PRIMARY KEY (`idusu`,`idusugrupo`),
  KEY `fk_usurole_usugrupo1_idx` (`idusugrupo`),
  CONSTRAINT `fk_usurole_usu1` FOREIGN KEY (`idusu`) REFERENCES `usu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_usurole_usugrupo1` FOREIGN KEY (`idusugrupo`) REFERENCES `usugrupo` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.usurolemnu
CREATE TABLE IF NOT EXISTS `usurolemnu` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `idmnu` smallint NOT NULL,
  `idusu` int unsigned DEFAULT NULL,
  `idrole` int unsigned DEFAULT NULL,
  `permissao` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `fk_usurolemnu_mnu1_idx` (`idmnu`),
  KEY `fk_usurolemnu_usurole1_idx` (`idusu`,`idrole`),
  CONSTRAINT `fk_usurolemnu_mnu1` FOREIGN KEY (`idmnu`) REFERENCES `mnu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_usurolemnu_usurole1` FOREIGN KEY (`idusu`, `idrole`) REFERENCES `usurole` (`idusu`, `idusugrupo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.venda
CREATE TABLE IF NOT EXISTS `venda` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `dthremissao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idoper` smallint unsigned NOT NULL DEFAULT '1',
  `fiscal` varchar(1) NOT NULL DEFAULT 'F',
  `tipo` varchar(1) NOT NULL DEFAULT 'V',
  `subtipo` enum('N','T','B','G') NOT NULL DEFAULT 'N',
  `vlrbruto` decimal(16,3) NOT NULL DEFAULT '0.000',
  `acrescimo` decimal(12,3) NOT NULL DEFAULT '0.000',
  `desconto` decimal(12,3) NOT NULL DEFAULT '0.000',
  `frete` decimal(12,3) NOT NULL DEFAULT '0.000',
  `seguro` decimal(12,3) NOT NULL DEFAULT '0.000',
  `outros` decimal(12,3) NOT NULL DEFAULT '0.000',
  `deducoes` decimal(12,3) NOT NULL DEFAULT '0.000',
  `st` decimal(12,3) NOT NULL DEFAULT '0.000',
  `ipi` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vlrtotal` decimal(16,3) NOT NULL DEFAULT '0.000',
  `idcli` int unsigned DEFAULT NULL,
  `idvend` int unsigned DEFAULT NULL,
  `idemp` int unsigned DEFAULT NULL,
  `idcaixa` int unsigned DEFAULT NULL,
  `obs` varchar(400) DEFAULT NULL,
  `baixado` bit(1) NOT NULL DEFAULT b'0',
  `faturado` bit(1) NOT NULL DEFAULT b'0',
  `idcontrato` int unsigned DEFAULT NULL,
  `isento` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pedidoref` varchar(40) DEFAULT NULL,
  `bloqueio` bit(1) NOT NULL DEFAULT b'0',
  `motivobloq` varchar(200) DEFAULT NULL,
  `autorizado` bit(1) NOT NULL DEFAULT b'0',
  `idusuautoriza` int unsigned DEFAULT NULL,
  `tipofrete` enum('F','C','T','P','3','X') NOT NULL DEFAULT 'X',
  `idcntend` int unsigned DEFAULT NULL,
  `idlog` int unsigned DEFAULT NULL,
  `formaentrega` varchar(60) DEFAULT NULL,
  `prazoentrega` varchar(45) DEFAULT NULL,
  `dataentrega` date DEFAULT NULL,
  `solicitante` varchar(80) DEFAULT NULL,
  `docfedcfe` varchar(20) DEFAULT NULL,
  `emiticfe` tinyint NOT NULL DEFAULT '0',
  `msgerrocfe` varchar(120) DEFAULT NULL,
  `idcomi` smallint unsigned DEFAULT NULL,
  `plataforma` varchar(20) DEFAULT 'ERP',
  `processo` varchar(20) DEFAULT NULL,
  `ultimousu` int unsigned DEFAULT NULL,
  `obsinter` varchar(255) DEFAULT NULL,
  `totdevo` decimal(12,3) DEFAULT '0.000',
  PRIMARY KEY (`id`),
  KEY `fk_venda_cnt1_idx` (`idcli`),
  KEY `fk_venda_cnt2_idx` (`idvend`),
  KEY `fk_venda_cnt3_idx` (`idemp`),
  KEY `fk_venda_caixa1_idx` (`idcaixa`),
  KEY `fk_venda_operacoes1_idx` (`idoper`),
  KEY `fk_venda_contrato1_idx` (`idcontrato`),
  KEY `fk_venda_idcntend_idx` (`idcntend`),
  KEY `fk_venda_cntlog_idx` (`idlog`),
  KEY `fk_venda_usuautoriza_idx` (`idusuautoriza`),
  KEY `fk_venda_comi_idx` (`idcomi`),
  KEY `fk_venda_ultimousu_idx` (`ultimousu`),
  CONSTRAINT `fk_venda_caixa1` FOREIGN KEY (`idcaixa`) REFERENCES `caixa` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_venda_cnt1` FOREIGN KEY (`idcli`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_venda_cnt2` FOREIGN KEY (`idvend`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_venda_cnt3` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_venda_cntlog` FOREIGN KEY (`idlog`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_venda_comi` FOREIGN KEY (`idcomi`) REFERENCES `comi` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_venda_contrato1` FOREIGN KEY (`idcontrato`) REFERENCES `contrato` (`idcontrato`) ON UPDATE CASCADE,
  CONSTRAINT `fk_venda_idcntend` FOREIGN KEY (`idcntend`) REFERENCES `cntend` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_venda_operacoes1` FOREIGN KEY (`idoper`) REFERENCES `operacoes` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_venda_ultimousu` FOREIGN KEY (`ultimousu`) REFERENCES `usu` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_venda_usuautoriza` FOREIGN KEY (`idusuautoriza`) REFERENCES `usu` (`id`) ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=2205 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendacaixa
CREATE TABLE IF NOT EXISTS `vendacaixa` (
  `idvenda` int unsigned NOT NULL,
  `idforma` smallint unsigned NOT NULL,
  `seq` tinyint unsigned NOT NULL,
  `idcaixa` int unsigned DEFAULT NULL,
  `valor` decimal(12,2) NOT NULL,
  `idcond` smallint unsigned DEFAULT NULL,
  `operacao` varchar(1) NOT NULL DEFAULT 'I',
  `baixado` bit(1) NOT NULL DEFAULT b'1',
  `vchave` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`idvenda`,`idforma`,`seq`),
  KEY `fk_vendacaixa_caixa_idx` (`idcaixa`),
  KEY `fk_vendacaixa_forma_idx` (`idforma`),
  KEY `fk_vendacaixa_condpg_idx` (`idcond`),
  KEY `idx_vendacaixa_vchave` (`vchave`),
  CONSTRAINT `fk_vendacaixa_caixa` FOREIGN KEY (`idcaixa`) REFERENCES `caixa` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_vendacaixa_condpg` FOREIGN KEY (`idcond`) REFERENCES `condpg` (`idcond`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendacaixa_formapg` FOREIGN KEY (`idforma`) REFERENCES `formapg` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_vendacaixa_venda` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendacartao
CREATE TABLE IF NOT EXISTS `vendacartao` (
  `idvenda` int unsigned NOT NULL,
  `idforma` smallint unsigned NOT NULL,
  `seq` tinyint unsigned NOT NULL,
  `parc` tinyint unsigned NOT NULL,
  `idcaixa` int unsigned DEFAULT NULL,
  `operacao` varchar(1) NOT NULL,
  `idoperadora` smallint unsigned NOT NULL,
  `dtemi` date NOT NULL,
  `valortot` decimal(12,3) NOT NULL DEFAULT '0.000',
  `dtsaldo` date NOT NULL,
  `clientepaga` bit(1) NOT NULL DEFAULT b'0',
  `custofin` decimal(10,3) NOT NULL DEFAULT '0.000',
  `valorliq` decimal(12,3) NOT NULL DEFAULT '0.000',
  `idmov` int unsigned DEFAULT NULL,
  `nsu` varchar(18) DEFAULT NULL,
  `autoriza` varchar(12) DEFAULT NULL,
  PRIMARY KEY (`idvenda`,`idforma`,`seq`,`parc`),
  KEY `fk_vendacartao_operadora_idx` (`idoperadora`),
  KEY `fk_vendacartao_finmov_idx` (`idmov`),
  KEY `fk_vendacartao_caixa_idx` (`idcaixa`),
  CONSTRAINT `fk_vendacartao_caixa` FOREIGN KEY (`idcaixa`) REFERENCES `caixa` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendacartao_finmov` FOREIGN KEY (`idmov`) REFERENCES `finmov` (`idmov`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendacartao_operadora` FOREIGN KEY (`idoperadora`) REFERENCES `operadora` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendacartao_vendacaixa` FOREIGN KEY (`idvenda`, `idforma`, `seq`) REFERENCES `vendacaixa` (`idvenda`, `idforma`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendadev
CREATE TABLE IF NOT EXISTS `vendadev` (
  `iddev` int unsigned NOT NULL AUTO_INCREMENT,
  `dthrdevo` datetime DEFAULT NULL,
  `idvenda` int unsigned NOT NULL,
  `idcli` int unsigned NOT NULL,
  `vchave` varchar(60) NOT NULL,
  `totvenda` decimal(12,3) NOT NULL DEFAULT '0.000',
  `totdevo` decimal(12,3) NOT NULL DEFAULT '0.000',
  `estornofin` enum('A','R','X') NOT NULL DEFAULT 'X',
  `baixado` bit(1) NOT NULL DEFAULT b'0',
  `utilizado` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`iddev`),
  KEY `fk_vendadev_venda_idx` (`idvenda`),
  KEY `fk_vendadev_cliente_idx` (`idcli`),
  CONSTRAINT `fk_vendadev_cliente` FOREIGN KEY (`idcli`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendadev_venda` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendadevitem
CREATE TABLE IF NOT EXISTS `vendadevitem` (
  `iddev` int unsigned NOT NULL,
  `idvenda` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `idprd` int NOT NULL,
  `sku` varchar(45) DEFAULT NULL,
  `qtde` decimal(10,3) NOT NULL DEFAULT '0.000',
  `unitario` decimal(12,3) NOT NULL DEFAULT '0.000',
  `desconto` decimal(10,2) NOT NULL DEFAULT '0.00',
  `totprod` decimal(12,3) NOT NULL DEFAULT '0.000',
  `qtdedev` decimal(10,3) NOT NULL DEFAULT '0.000',
  `vlrdevo` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`iddev`,`idvenda`,`seq`),
  KEY `fk_devitem_vendaitem_idx` (`idvenda`,`seq`),
  KEY `fk_devitem_prd_idx` (`idprd`),
  KEY `fk_devitem_prdsku_idx` (`sku`),
  CONSTRAINT `fk_devitem_prd` FOREIGN KEY (`idprd`) REFERENCES `prd` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_devitem_prdsku` FOREIGN KEY (`sku`) REFERENCES `prdsku` (`sku`) ON UPDATE CASCADE,
  CONSTRAINT `fk_devitem_vendaitem` FOREIGN KEY (`idvenda`, `seq`) REFERENCES `vendaitem` (`idvenda`, `seq`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendafiscal
CREATE TABLE IF NOT EXISTS `vendafiscal` (
  `idvenda` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `origem` varchar(2) DEFAULT NULL,
  `cst` varchar(3) DEFAULT NULL,
  `modbc` varchar(3) DEFAULT NULL,
  `reducaobc` decimal(12,4) DEFAULT '0.0000',
  `bc` decimal(12,4) DEFAULT '0.0000',
  `picms` decimal(12,4) DEFAULT '0.0000',
  `vicms` decimal(12,4) DEFAULT '0.0000',
  `picmsdif` decimal(12,4) DEFAULT '0.0000',
  `picmsori` decimal(12,4) DEFAULT '0.0000',
  `modbcst` varchar(3) DEFAULT NULL,
  `ivast` decimal(12,4) DEFAULT '0.0000',
  `bcst` decimal(12,4) DEFAULT '0.0000',
  `picmsst` decimal(12,4) DEFAULT '0.0000',
  `vicmsst` decimal(12,4) DEFAULT '0.0000',
  `cstpis` varchar(3) DEFAULT NULL,
  `bcpis` decimal(12,4) DEFAULT '0.0000',
  `ppis` decimal(12,4) DEFAULT '0.0000',
  `vpis` decimal(12,4) DEFAULT '0.0000',
  `vupis` decimal(12,4) DEFAULT '0.0000',
  `cstcofins` varchar(3) DEFAULT NULL,
  `bccofins` decimal(12,4) DEFAULT '0.0000',
  `pcofins` decimal(12,4) DEFAULT '0.0000',
  `vcofins` decimal(12,4) DEFAULT '0.0000',
  `vucofins` decimal(12,4) DEFAULT '0.0000',
  `cstipi` varchar(3) DEFAULT NULL,
  `bcipi` decimal(12,4) DEFAULT '0.0000',
  `pipi` decimal(12,4) DEFAULT '0.0000',
  `vipi` decimal(12,4) DEFAULT '0.0000',
  `vuipi` decimal(12,4) DEFAULT '0.0000',
  `codLCP116` varchar(10) DEFAULT NULL,
  `codTribMun` varchar(30) DEFAULT NULL,
  `piss` decimal(12,4) DEFAULT '0.0000',
  `viss` decimal(12,4) DEFAULT '0.0000',
  `federal` decimal(10,2) DEFAULT '0.00',
  `estadual` decimal(10,2) DEFAULT '0.00',
  `municipal` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`idvenda`,`seq`),
  CONSTRAINT `fk_vendaitem_vendafiscal1` FOREIGN KEY (`idvenda`, `seq`) REFERENCES `vendaitem` (`idvenda`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendahist
CREATE TABLE IF NOT EXISTS `vendahist` (
  `idvenda` int unsigned NOT NULL,
  `seqhist` smallint unsigned NOT NULL,
  `dthrhist` datetime NOT NULL,
  `historico` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`idvenda`,`seqhist`),
  CONSTRAINT `fk_vendahist_venda` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendaitem
CREATE TABLE IF NOT EXISTS `vendaitem` (
  `idvenda` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `idprod` int NOT NULL,
  `sku` varchar(45) DEFAULT NULL,
  `qtde` decimal(10,3) NOT NULL DEFAULT '0.000',
  `custo` decimal(12,3) NOT NULL DEFAULT '0.000',
  `unitario` decimal(12,3) NOT NULL DEFAULT '0.000',
  `desconto` decimal(10,2) NOT NULL DEFAULT '0.00',
  `acrescimo` decimal(10,2) NOT NULL DEFAULT '0.00',
  `bruto` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `margem` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `frete` decimal(12,3) NOT NULL DEFAULT '0.000',
  `seguro` decimal(12,3) NOT NULL DEFAULT '0.000',
  `outros` decimal(12,3) NOT NULL DEFAULT '0.000',
  `deducoes` decimal(12,3) NOT NULL DEFAULT '0.000',
  `st` decimal(12,3) NOT NULL DEFAULT '0.000',
  `ipi` decimal(12,3) NOT NULL DEFAULT '0.000',
  `cfop` varchar(5) NOT NULL DEFAULT '5102',
  `qtdedev` decimal(10,3) NOT NULL DEFAULT '0.000',
  `servico` bit(1) NOT NULL DEFAULT b'0',
  `seqpedref` varchar(30) DEFAULT NULL,
  `estoque` tinyint NOT NULL DEFAULT '0',
  `vlrtab` decimal(12,3) NOT NULL DEFAULT '0.000',
  `obsprd` varchar(60) DEFAULT NULL,
  `comtroca` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idvenda`,`seq`),
  KEY `fk_vendaitem_prd1_idx` (`idprod`),
  KEY `fk_vendaitem_prdsku_idx` (`sku`),
  CONSTRAINT `fk_vendaitem_prd1` FOREIGN KEY (`idprod`) REFERENCES `prd` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendaitem_prdsku` FOREIGN KEY (`sku`) REFERENCES `prdsku` (`sku`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendaitem_venda1` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendaitemhist
CREATE TABLE IF NOT EXISTS `vendaitemhist` (
  `idhist` int unsigned NOT NULL AUTO_INCREMENT,
  `idcli` int unsigned NOT NULL,
  `idvenda` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `idprod` int NOT NULL,
  `qtde` decimal(10,3) NOT NULL DEFAULT '0.000',
  `vunit` decimal(12,3) NOT NULL DEFAULT '0.000',
  `dthrhist` datetime DEFAULT NULL,
  `deletado` bit(1) NOT NULL DEFAULT b'0',
  `usado` bit(1) NOT NULL DEFAULT b'0',
  `idvendausado` int unsigned DEFAULT NULL,
  PRIMARY KEY (`idhist`),
  KEY `fk_vendaitemhist_prd_idx` (`idprod`),
  KEY `fk_vendaitemhist_cnt` (`idcli`),
  CONSTRAINT `fk_vendaitemhist_cnt` FOREIGN KEY (`idcli`) REFERENCES `cnt` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_vendaitemhist_prd` FOREIGN KEY (`idprod`) REFERENCES `prd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendajunta
CREATE TABLE IF NOT EXISTS `vendajunta` (
  `idvenda` int unsigned NOT NULL,
  `idpedido` int unsigned NOT NULL,
  PRIMARY KEY (`idvenda`,`idpedido`),
  KEY `fk_vendajunta_venda_idx` (`idpedido`),
  CONSTRAINT `fk_vendajunta_venda` FOREIGN KEY (`idpedido`) REFERENCES `venda` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendalote
CREATE TABLE IF NOT EXISTS `vendalote` (
  `idrastro` int unsigned NOT NULL AUTO_INCREMENT,
  `idlote` int unsigned NOT NULL,
  `idvenda` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `qtde` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idrastro`),
  KEY `fk_vendalote_prdlote_idx` (`idlote`),
  KEY `fk_vendalote_vendaitem_idx` (`idvenda`,`seq`),
  CONSTRAINT `fk_vendalote_prdlote` FOREIGN KEY (`idlote`) REFERENCES `prdlote` (`idlote`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendalote_vendaitem` FOREIGN KEY (`idvenda`, `seq`) REFERENCES `vendaitem` (`idvenda`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendalotemanu
CREATE TABLE IF NOT EXISTS `vendalotemanu` (
  `idrastro` int unsigned NOT NULL AUTO_INCREMENT,
  `idvenda` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `codlote` varchar(20) NOT NULL,
  `fabricacao` date NOT NULL,
  `validade` date NOT NULL,
  `qtde` decimal(12,3) NOT NULL,
  `codAgreg` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`idrastro`),
  KEY `fk_vendalotemanu_vi_idx` (`idvenda`,`seq`),
  CONSTRAINT `fk_vendalotemanu_vi` FOREIGN KEY (`idvenda`, `seq`) REFERENCES `vendaitem` (`idvenda`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendaoper
CREATE TABLE IF NOT EXISTS `vendaoper` (
  `idvenda` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `idoperacao` smallint unsigned DEFAULT NULL,
  `idimposto` int DEFAULT NULL,
  PRIMARY KEY (`idvenda`,`seq`),
  KEY `fk_vendaoper_operacoes_idx` (`idoperacao`),
  KEY `fk_vendaoper_impostos_idx` (`idimposto`),
  CONSTRAINT `fk_vendaoper_impostos` FOREIGN KEY (`idimposto`) REFERENCES `impostos` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendaoper_operacoes` FOREIGN KEY (`idoperacao`) REFERENCES `operacoes` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendaos
CREATE TABLE IF NOT EXISTS `vendaos` (
  `idvenda` int unsigned NOT NULL,
  `idos` int unsigned NOT NULL,
  PRIMARY KEY (`idvenda`,`idos`),
  KEY `fk_vendaos_os_idx` (`idos`),
  CONSTRAINT `fk_vendaos_os` FOREIGN KEY (`idos`) REFERENCES `os` (`idos`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendaos_venda` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendaparc
CREATE TABLE IF NOT EXISTS `vendaparc` (
  `idvenda` int unsigned NOT NULL,
  `parcela` tinyint unsigned NOT NULL,
  `vencimento` date NOT NULL,
  `valor` decimal(12,3) NOT NULL DEFAULT '0.000',
  `diasemana` varchar(20) DEFAULT NULL,
  `idcond` smallint unsigned NOT NULL,
  `desconto` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idvenda`,`parcela`),
  KEY `fk_vendaparc_condpg_idx` (`idcond`),
  CONSTRAINT `fk_vendaparc_condpg` FOREIGN KEY (`idcond`) REFERENCES `condpg` (`idcond`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendaparc_venda` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendaretido
CREATE TABLE IF NOT EXISTS `vendaretido` (
  `idvenda` int unsigned NOT NULL,
  `idimposto` int NOT NULL,
  `nome` varchar(60) NOT NULL,
  `vlrbase` decimal(12,3) NOT NULL DEFAULT '0.000',
  `aliquota` decimal(12,3) NOT NULL DEFAULT '0.000',
  `valor` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idvenda`,`idimposto`,`nome`),
  KEY `fk_vendaretido_imposto_idx` (`idimposto`),
  CONSTRAINT `fk_vendaretido_imposto` FOREIGN KEY (`idimposto`) REFERENCES `impostos` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_vendaretido_venda` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendasat
CREATE TABLE IF NOT EXISTS `vendasat` (
  `idvenda` int unsigned NOT NULL,
  `ID` varchar(60) NOT NULL,
  `cNF` varchar(20) DEFAULT NULL,
  `modelo` varchar(6) DEFAULT NULL,
  `nserieSAT` varchar(40) DEFAULT NULL,
  `nCFe` varchar(20) DEFAULT NULL,
  `dthrEmi` timestamp NULL DEFAULT NULL,
  `cDV` varchar(4) DEFAULT NULL,
  `TpAmb` varchar(4) DEFAULT NULL,
  `Cancelado` bit(1) NOT NULL DEFAULT b'0',
  `dthrCancelado` timestamp NULL DEFAULT NULL,
  `CNPJCPF` varchar(30) DEFAULT NULL,
  `idemp` int unsigned NOT NULL,
  `xml` mediumblob,
  PRIMARY KEY (`idvenda`,`ID`),
  KEY `fk_vendasat_cntemp_idx` (`idemp`),
  CONSTRAINT `fk_vendasat_cntemp` FOREIGN KEY (`idemp`) REFERENCES `cnt` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendasat_venda1` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendatrib
CREATE TABLE IF NOT EXISTS `vendatrib` (
  `idvenda` int unsigned NOT NULL,
  `seq` smallint unsigned NOT NULL,
  `tpEnteGov` varchar(2) NOT NULL DEFAULT 'X',
  `pRedutor` varchar(45) NOT NULL DEFAULT '0.00',
  `tpOperGov` varchar(2) NOT NULL DEFAULT 'X',
  `CST` varchar(4) NOT NULL DEFAULT '000',
  `classTrib` varchar(8) NOT NULL DEFAULT '000001',
  `indDocao` bit(1) NOT NULL DEFAULT b'0',
  `vBC` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pIBSUF` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pRedAliqUF` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pAliqEfetUF` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vIBSUF` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pIBSMun` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pRedAliqMun` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pAliqEfetMun` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vIBSMun` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pCBS` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pRedAliqCBS` decimal(12,3) NOT NULL DEFAULT '0.000',
  `pAliqEfetCBS` decimal(12,3) NOT NULL DEFAULT '0.000',
  `vCBS` decimal(12,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`idvenda`,`seq`),
  CONSTRAINT `fk_vendatrib_vendaitem` FOREIGN KEY (`idvenda`, `seq`) REFERENCES `vendaitem` (`idvenda`, `seq`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.vendatroco
CREATE TABLE IF NOT EXISTS `vendatroco` (
  `idvenda` int unsigned NOT NULL,
  `idcaixa` int unsigned NOT NULL,
  `troco` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`idvenda`,`idcaixa`),
  KEY `fk_vendatroco2_idx` (`idcaixa`),
  CONSTRAINT `fk_vendatroco1` FOREIGN KEY (`idvenda`) REFERENCES `venda` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_vendatroco2` FOREIGN KEY (`idcaixa`) REFERENCES `caixa` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.wg_angulargauge
CREATE TABLE IF NOT EXISTS `wg_angulargauge` (
  `id` int NOT NULL AUTO_INCREMENT,
  `caption` varchar(120) NOT NULL,
  `subcaption` varchar(80) NOT NULL,
  `lowerlimit` decimal(12,3) NOT NULL DEFAULT '0.000',
  `upperlimit` decimal(12,3) NOT NULL DEFAULT '1000.000',
  `theme` varchar(20) NOT NULL DEFAULT 'fint',
  `sql1` mediumtext,
  `col1dial` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.wg_column2d
CREATE TABLE IF NOT EXISTS `wg_column2d` (
  `id` int NOT NULL AUTO_INCREMENT,
  `caption` varchar(120) NOT NULL,
  `subcaption` varchar(80) NOT NULL,
  `xaxisname` varchar(60) NOT NULL,
  `yaxisname` varchar(60) NOT NULL,
  `theme` varchar(20) NOT NULL DEFAULT 'fint',
  `sql1` mediumtext,
  `col1label` varchar(60) DEFAULT NULL,
  `col2value` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.wg_livre
CREATE TABLE IF NOT EXISTS `wg_livre` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `caption` varchar(120) DEFAULT NULL,
  `html` text,
  `uu` smallint DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.wg_msline
CREATE TABLE IF NOT EXISTS `wg_msline` (
  `id` int NOT NULL AUTO_INCREMENT,
  `caption` varchar(120) NOT NULL,
  `subcaption` varchar(80) NOT NULL,
  `xaxisname` varchar(60) DEFAULT NULL,
  `theme` varchar(20) NOT NULL DEFAULT 'fint',
  `tipo` varchar(20) NOT NULL DEFAULT 'msline',
  `serieslist` mediumtext,
  `seriesvalues` mediumtext,
  `sql1` mediumtext,
  `col1param` varchar(60) DEFAULT NULL,
  `col2param` varchar(60) DEFAULT NULL,
  `col3value` varchar(60) DEFAULT NULL,
  `col4value` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`)
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.wg_pie2d
CREATE TABLE IF NOT EXISTS `wg_pie2d` (
  `id` int NOT NULL AUTO_INCREMENT,
  `caption` varchar(120) NOT NULL,
  `subcaption` varchar(80) NOT NULL,
  `numberprefix` varchar(6) NOT NULL,
  `showpercentintooltip` varchar(1) NOT NULL,
  `decimals` varchar(1) NOT NULL,
  `usedataplotcolorforlabels` varchar(1) NOT NULL,
  `theme` varchar(20) NOT NULL DEFAULT 'fint',
  `sql1` mediumtext,
  `col1label` varchar(60) DEFAULT NULL,
  `col2value` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.wg_symbol
CREATE TABLE IF NOT EXISTS `wg_symbol` (
  `id` int NOT NULL AUTO_INCREMENT,
  `symbol` varchar(20) NOT NULL,
  `source` varchar(45) NOT NULL,
  `caption` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `symbol_source_UNI` (`symbol`,`source`)
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.wg_ticker
CREATE TABLE IF NOT EXISTS `wg_ticker` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ticker` varchar(20) NOT NULL,
  `source` varchar(45) NOT NULL,
  `caption` varchar(80) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ticker_source_UNI` (`ticker`,`source`)
) /*!50100 TABLESPACE `innodb_system` */ ENGINE=InnoDB AUTO_INCREMENT=409 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela b3erp.dsv.wg_urls
CREATE TABLE IF NOT EXISTS `wg_urls` (
  `idurl` smallint unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) NOT NULL,
  `url` varchar(254) DEFAULT NULL,
  PRIMARY KEY (`idurl`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para trigger b3erp.dsv.CNTCLASSES_AFTER_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `CNTCLASSES_AFTER_INSERT` AFTER INSERT ON `cntclasses` FOR EACH ROW BEGIN

  if (select count(id) from cntclass where emitente and id = new.idclass) > 0 then

    insert into prdsaldo(idemp, idprod)
    select new.idcnt, id from prd;

    insert into prdskusaldo(idemp, sku)
    select new.idcnt, sku from prdsku;

  end if;
  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.CNTCLASSES_BEFORE_DELETE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `CNTCLASSES_BEFORE_DELETE` BEFORE DELETE ON `cntclasses` FOR EACH ROW BEGIN
  declare msg varchar(128);
  declare msgsku varchar(128);
  
  set msg = 'Existem produtos com saldo em estoque para este emitente!';
  set msgsku = 'Existem SKU com saldo em estoque para este emitente!';
  
  if (select count(id) from cntclass where emitente and id = old.idclass) > 0 then
  
    if (select count(idprod) from prdsaldo where saldo > 0 and idemp = old.idcnt) > 0 then
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg; 
    else
      delete from prdsaldo where idemp = old.idcnt;
    end if;
    
    if (select count(sku) from prdskusaldo where saldo > 0 and idemp = old.idcnt) > 0 then
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msgsku; 
    else
      delete from prdskusaldo where idemp = old.idcnt;
    end if;

  end if;
  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.CNTFUNC_AFTER_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `CNTFUNC_AFTER_UPDATE` AFTER UPDATE ON `cntfunc` FOR EACH ROW BEGIN
  declare hist varchar(300);
  
  if (new.idemp <> old.idemp) or (new.idemp is not null and old.idemp is null) then
     set hist = concat('Mudança de empresa: ', coalesce(old.idemp, 'vazio'), ' alterado para ', coalesce(new.idemp, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.idsetor <> old.idsetor) or (new.idsetor is not null and old.idsetor is null) then
     set hist = concat('Mudança de setor: ', coalesce(old.idsetor, 'vazio'), ' alterado para ', coalesce(new.idsetor, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.grauescola <> old.grauescola) or (new.grauescola is not null and old.grauescola is null) then
     set hist = concat('Mudança de Grau Escolar: ', coalesce(old.grauescola, 'vazio'), ' alterado para ', coalesce(new.grauescola, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.idcargo <> old.idcargo) or (new.idcargo is not null and old.idcargo is null) then
     set hist = concat('Mudança de Cargo: ', coalesce(old.idcargo, 'vazio'), ' alterado para ', coalesce(new.idcargo, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.funcao <> old.funcao) or (new.funcao is not null and old.funcao is null) then
     set hist = concat('Mudança de Função: ', coalesce(old.funcao, 'vazio'), ' alterado para ', coalesce(new.funcao, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.salariobase <> old.salariobase) or (new.salariobase is not null and old.salariobase is null) then
     set hist = concat('Mudança de Salario: ', coalesce(old.salariobase, 'vazio'), ' alterado para ', coalesce(new.salariobase, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.situadi <> old.situadi) or (new.situadi is not null and old.situadi is null) then
     set hist = concat('Mudança de Situação Admissibilidade: ', coalesce(old.situadi, 'vazio'), ' alterado para ', coalesce(new.situadi, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.convenio <> old.convenio) or (new.convenio is not null and old.convenio is null) then
     set hist = concat('Mudança de Plano de Saude: ', coalesce(old.convenio, 'vazio'), ' alterado para ', coalesce(new.convenio, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.transporte <> old.transporte) or (new.transporte is not null and old.transporte is null) then
     set hist = concat('Mudança de Vale Transporte: ', coalesce(old.transporte, 'vazio'), ' alterado para ', coalesce(new.transporte, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.terceiro <> old.terceiro) or (new.terceiro is not null and old.terceiro is null) then
     set hist = concat('Mudança Terceirização: ', coalesce(old.terceiro, 'vazio'), ' alterado para ', coalesce(new.terceiro, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.idposto <> old.idposto) or (new.idposto is not null and old.idposto is null) then
     set hist = concat('Mudança Posto de Serviço: ', coalesce(old.idposto, 'vazio'), ' alterado para ', coalesce(new.idposto, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.idturno <> old.idturno) or (new.idturno is not null and old.idturno is null) then
     set hist = concat('Mudança de Turno: ', coalesce(old.idturno, 'vazio'), ' alterado para ', coalesce(new.idturno, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.situacao <> old.situacao) or (new.situacao is not null and old.situacao is null) then
     set hist = concat('Mudança de Situação: ', coalesce(old.situacao, 'vazio'), ' alterado para ', coalesce(new.situacao, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
  if (new.tpafasta <> old.tpafasta) or (new.tpafasta is not null and old.tpafasta is null) then
     set hist = concat('Mudança de Afastamento: ', coalesce(old.tpafasta, 'vazio'), ' alterado para ', coalesce(new.tpafasta, 'vazio'));
     insert into cntfunc_hist(idcnt, dthr, loghist) values(new.idcnt, now(), hist);
  end if;
  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.CNT_AFTER_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `CNT_AFTER_INSERT` AFTER INSERT ON `cnt` FOR EACH ROW BEGIN
  if (new.idgrupo <> null) or (new.idgrupo <> 0) then
    insert into cntgrupohist(idcnt, idgrupo, dthrhist) values (new.id, new.idgrupo, now());
  end if;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.CNT_AFTER_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `CNT_AFTER_UPDATE` AFTER UPDATE ON `cnt` FOR EACH ROW BEGIN
  if (coalesce(new.idgrupo,0) <> coalesce(old.idgrupo,0)) and ((new.idgrupo <> null) or (new.idgrupo <> 0)) then
    insert into cntgrupohist(idcnt, idgrupo, dthrhist) values (new.id, new.idgrupo, now());
  end if;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.ESTOQUEK200_AFTER_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `ESTOQUEK200_AFTER_UPDATE` AFTER UPDATE ON `estoquek200` FOR EACH ROW BEGIN

if (new.baixado <> old.baixado) and (new.baixado) then
  insert into estoque(dthrestoque, dthremissao, idemp, idusu, plataforma, origem, ida, idprd, sku, fiscal, tipo, qtde, custo)
  values (new.dthrbalanco, func_dthr(), new.idemp, new.idusu, 'ERP', 'estoquek200', new.idbalanco, new.idprd, new.sku, new.fiscal, 'B', new.qtdecorreta, new.custobalanco);
end if;

if (new.cancelado <> old.cancelado) then
  update estoque set cancelado=new.cancelado, idusucancela=if(new.cancelado,new.idusu,NULL) where origem='estoquek200' and ida=new.idbalanco;
end if;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.ESTOQUEK280_AFTER_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `ESTOQUEK280_AFTER_UPDATE` AFTER UPDATE ON `estoquek280` FOR EACH ROW BEGIN

if (new.baixado <> old.baixado) and (new.baixado) then
  if (new.qtdemais > 0) then
    insert into estoque(dthrestoque, dthremissao, idemp, idusu, plataforma, origem, ida, idprd, sku, fiscal, tipo, qtde, custo)
    values (new.dtcorrige, func_dthr(), new.idemp, new.idusu, 'ERP', 'estoquek280', new.idcorrige, new.idprd, new.sku, new.fiscal, 'E', new.qtdemais, 0.00);
  end if;
  if (new.qtdemenos > 0) then
    insert into estoque(dthrestoque, dthremissao, idemp, idusu, plataforma, origem, ida, idprd, sku, fiscal, tipo, qtde, custo)
    values (new.dtcorrige, func_dthr(), new.idemp, new.idusu, 'ERP', 'estoquek280', new.idcorrige, new.idprd, new.sku, new.fiscal, 'S', new.qtdemenos, 0.00);
  end if;
end if;

if (new.cancelado <> old.cancelado) then
  update estoque set cancelado=new.cancelado, idusucancela=if(new.cancelado,new.idusu,NULL) where origem='estoquek280' and ida=new.idcorrige;
end if;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.ESTOQUE_AFTER_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `ESTOQUE_AFTER_INSERT` AFTER INSERT ON `estoque` FOR EACH ROW BEGIN

  if new.tipo in ('E', 'S') then
    if (new.tipo = 'E') then
      if (new.sku is not null) and (new.sku <> '') then
        update prdskusaldo set saldo = (saldo + new.qtde) where idemp=new.idemp and sku=new.sku;
	  else
        update prdsaldo set saldo = (saldo + new.qtde) where idemp=new.idemp and idprod=new.idprd;
      end if;
	elseif (new.tipo = 'S') then
      if (new.sku is not null) and (new.sku <> '') then
        update prdskusaldo set saldo = (saldo - new.qtde) where idemp=new.idemp and sku=new.sku;
	  else
        update prdsaldo set saldo = (saldo - new.qtde) where idemp=new.idemp and idprod=new.idprd;
      end if;
    end if;
  end if;
  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.ESTOQUE_AFTER_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `ESTOQUE_AFTER_UPDATE` AFTER UPDATE ON `estoque` FOR EACH ROW BEGIN

  if (new.cancelado <> old.cancelado) then
    if ((new.cancelado) and (new.tipo = 'E')) or ((not new.cancelado) and (new.tipo = 'S')) then
      if (new.sku is not null) and (new.sku <> '') then
        update prdskusaldo set saldo = (saldo - new.qtde) where idemp=new.idemp and sku=new.sku;
	  else
        update prdsaldo set saldo = (saldo - new.qtde) where idemp=new.idemp and idprod=new.idprd;
      end if;
	elseif ((new.cancelado) and (new.tipo = 'S')) or ((not new.cancelado) and (new.tipo = 'E')) then
      if (new.sku is not null) and (new.sku <> '') then
        update prdskusaldo set saldo = (saldo + new.qtde) where idemp=new.idemp and sku=new.sku;
	  else
        update prdsaldo set saldo = (saldo + new.qtde) where idemp=new.idemp and idprod=new.idprd;
      end if;
    end if;
  end if;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.MOVPRD_BEFORE_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `MOVPRD_BEFORE_INSERT` BEFORE INSERT ON `movprd` FOR EACH ROW BEGIN

  set new.vtotal = round(((new.vunit * new.qtde) - new.vdesconto) + new.vicmsst + new.vipi + new.vseguro + new.vfrete + new.voutros, 2);
  
  set new.seq = (
     select ifnull(max(seq), 0) + 1 from movprd
     where idmov  = new.idmov
  );  
  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.MOVPRD_BEFORE_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `MOVPRD_BEFORE_UPDATE` BEFORE UPDATE ON `movprd` FOR EACH ROW BEGIN

  set new.vtotal = round(((new.vunit * new.qtde) - new.vdesconto) + new.vicmsst + new.vipi + new.vseguro + new.vfrete + new.voutros, 2);

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.MOV_BEFORE_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `MOV_BEFORE_INSERT` BEFORE INSERT ON `mov` FOR EACH ROW BEGIN

  set new.vtotdoc = round((new.vtotprod + new.vicmsst + new.vipi + new.vfrete + new.vseguro + new.voutros) - new.vdesconto, 2);

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.MOV_BEFORE_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `MOV_BEFORE_UPDATE` BEFORE UPDATE ON `mov` FOR EACH ROW BEGIN

  set new.vtotdoc = round((new.vtotprod + new.vicmsst + new.vipi + new.vfrete + new.vseguro + new.voutros) - new.vdesconto, 2);

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.PDV_AFTER_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `PDV_AFTER_INSERT` AFTER INSERT ON `pdv` FOR EACH ROW BEGIN

  INSERT INTO pdvcfg(idpdv)
  VALUES(new.id);
  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.PDV_BEFORE_DELETE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `PDV_BEFORE_DELETE` BEFORE DELETE ON `pdv` FOR EACH ROW BEGIN

   DELETE FROM pdvcfg WHERE idpdv = old.id;
   
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.PRDSALDO_AFTER_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `PRDSALDO_AFTER_UPDATE` AFTER UPDATE ON `prdsaldo` FOR EACH ROW BEGIN

  DECLARE rsaldo decimal(12,3);

  set rsaldo := (select sum(saldo) from prdsaldo where idprod=new.idprod);
  
  update prd set saldoatu=rsaldo where id=new.idprod;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.PRDSKUSALDO_AFTER_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `PRDSKUSALDO_AFTER_UPDATE` AFTER UPDATE ON `prdskusaldo` FOR EACH ROW BEGIN

  DECLARE rsaldo decimal(12,3);
  DECLARE iprd integer;
  DECLARE iemp integer;
  
  set iemp := new.idemp;
  set iprd := (select idprd from prdsku where sku = new.sku);

  set rsaldo := (select sum(s.saldo) from prdskusaldo s 
  inner join prdsku p on (s.sku = p.sku)
  where p.idprd=iprd and s.idemp=iemp);
  
  update prdsaldo set saldo=rsaldo where idprod=iprd and idemp=iemp;
  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.PRDSKU_AFTER_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `PRDSKU_AFTER_INSERT` AFTER INSERT ON `prdsku` FOR EACH ROW BEGIN

    insert into prdskusaldo(idemp, sku)
    select a.idcnt, new.sku from cntclasses a, cntclass b
    where a.idclass = b.id and emitente;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.PRDTAB_AFTER_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `PRDTAB_AFTER_INSERT` AFTER INSERT ON `prdtab` FOR EACH ROW BEGIN
  declare p1 decimal(10,4);
  declare p2 decimal(10,4);

  set p1 = 0;
  set p2 = 0;
  
  if new.perc <> 0 then
    set p1 = 1 + (new.perc / 100);
  end if;
    
  if new.percb <> 0 then
    set p2 = 1 + (new.percb / 100);
  end if;
  
  insert into prdtabvalor(idtab, idprod, valor, valorb)
  select new.id, a.id, if(p1 = 0, 0.000, round(a.venda*p1, 2)), if(p2 = 0, 0.000, round(a.vendab*p2, 2)) from prd a;
  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.PRDTAB_AFTER_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `PRDTAB_AFTER_UPDATE` AFTER UPDATE ON `prdtab` FOR EACH ROW BEGIN
  declare p1 decimal(10,4);
  declare p2 decimal(10,4);

  set p1 = 0;
  set p2 = 0;
  
  if new.perc <> 0 then
    set p1 = 1 + (new.perc / 100);
  end if;
    
  if new.percb <> 0 then
    set p2 = 1 + (new.percb / 100);
  end if;
  
  update prdtabvalor a
    inner join prd b on (b.id = a.idprod)
  set a.valor = if(p1 <> 0, round(b.venda*p1, 2), a.valor), a.valorb = if(p2 <> 0, round(b.vendab*p2, 2), a.valorb)
  where a.idtab = new.id;
  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.PRDVAR_BEFORE_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `PRDVAR_BEFORE_INSERT` BEFORE INSERT ON `prdvar` FOR EACH ROW BEGIN
  declare xid varchar(5);
  set xid = lpad((select AUTO_INCREMENT from information_schema.TABLES where
	TABLE_SCHEMA = DATABASE() and TABLE_NAME = 'prdvar'), 3, '0');  
  
  if (new.codigo is null) or (trim(new.codigo) = '') then
    set new.codigo = concat( substr(trim(new.nomevar),1,1), substr(trim(new.nomeopt),1,1), xid);
  end if;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.PRD_AFTER_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `PRD_AFTER_INSERT` AFTER INSERT ON `prd` FOR EACH ROW BEGIN

  if (select count(a.idcnt) from cntclasses a, cntclass b where a.idclass = b.id and emitente) = 1 then
    insert into prdsaldo(idemp, idprod, saldo)
    select a.idcnt, new.id, new.saldoatu from cntclasses a, cntclass b
    where a.idclass = b.id and emitente;
  else
    insert into prdsaldo(idemp, idprod)
    select a.idcnt, new.id from cntclasses a, cntclass b
    where a.idclass = b.id and emitente;
  end if;
  
  insert into prdtabvalor(idtab, idprod, valor, valorb)
  select a.id, new.id, if(a.perc = 0, 0.000, round(new.venda * (1 + (a.perc/100)), 2)),
  if(a.percb = 0, 0.000, round(new.vendab * (1 + (a.percb / 100)), 2)) from prdtab a;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.PRD_AFTER_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `PRD_AFTER_UPDATE` AFTER UPDATE ON `prd` FOR EACH ROW BEGIN

  /* faz update nas tabelas de preço do produto */
  update prdtabvalor pv
  inner join prdtab pt on (pt.id = pv.idtab)
  inner join prd p on (p.id = pv.idprod)
  set pv.valor = if(pt.perc <> 0, round(p.venda * (1 + (pt.perc / 100)), 2), pv.valor),
  pv.valorb = if(pt.percb <> 0, round(p.vendab * (1 + (pt.percb / 100)), 2), pv.valorb)
  where pv.idprod = new.id;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.PRD_BEFORE_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `PRD_BEFORE_UPDATE` BEFORE UPDATE ON `prd` FOR EACH ROW BEGIN
  
  /* data de ultimo reajuste de preços */
  if (old.venda <> new.venda) then 
    set new.dthrvarejo = CURRENT_TIMESTAMP;
  end if;

  if (old.vendab <> new.vendab) then 
    set new.dthratacado = CURRENT_TIMESTAMP;
  end if;

  if (old.custo <> new.custo) then 
    set new.dtultcp = CURRENT_DATE;
  end if;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.VENDAITEM_BEFORE_DELETE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `VENDAITEM_BEFORE_DELETE` BEFORE DELETE ON `vendaitem` FOR EACH ROW BEGIN
  delete from vendaoper where idvenda=old.idvenda and seq=old.seq;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.VENDAITEM_BEFORE_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `VENDAITEM_BEFORE_INSERT` BEFORE INSERT ON `vendaitem` FOR EACH ROW BEGIN
  declare iemp      integer;
  declare blestoque varchar(20);
  declare blunico   varchar(20);
  declare rtot      decimal(12,3);
  declare rped      decimal(12,3);
  
  select idemp from venda where id = new.idvenda into iemp;
  select valor from cfg where param = 'VESTOQUE' into blestoque;
  select valor from cfg where param = 'ESTOQUEUNICO' into blunico;
  
  set new.bruto = new.qtde * new.unitario;
  set new.total = ((new.qtde * new.unitario) + new.acrescimo + new.frete + new.seguro + new.outros + new.st + new.ipi) - new.desconto;
  if (new.custo > 0) then
    set new.margem = coalesce(((( ((new.qtde * new.unitario) + new.acrescimo - new.desconto) / (new.custo * new.qtde) ) * 100.00) - 100.00), 0);
  else
    set new.margem = 0.00;
  end if;
  
  if upper(trim(blestoque)) = 'FALSE' then
    if upper(trim(blunico)) = 'FALSE' then
       select cast(coalesce(sum(saldo), 0) as decimal(12,3)) as saldo from prdsaldo where idprod = new.idprod and idemp = iemp into rtot;
       
       select coalesce(sum(vi.qtde), 0) as qtde from vendaitem vi
       inner join venda v on (v.id = vi.idvenda)
       where v.tipo = 'P' and ((not v.bloqueio) or (v.bloqueio and v.autorizado))
       and vi.idprod = new.idprod and v.idemp = iemp and v.id <> new.idvenda into rped;
    else
       select cast(coalesce(sum(saldo), 0) as decimal(12,3)) as saldo from prdsaldo where idprod = new.idprod into rtot;
       
       select coalesce(sum(vi.qtde), 0) as qtde from vendaitem vi
       inner join venda v on (v.id = vi.idvenda)
       where v.tipo = 'P' and ((not v.bloqueio) or (v.bloqueio and v.autorizado)) 
       and vi.idprod = new.idprod and v.id <> new.idvenda into rped;
    end if;

    if rtot <= 0 then 
       set new.estoque = -1;
    else
        if (rtot - rped - new.qtde) < 0 then
           set new.estoque = 1;
        else
           set new.estoque = 0;
        end if;
    end if;
  else
    set new.estoque = 0;
  end if;
  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.VENDAITEM_BEFORE_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `VENDAITEM_BEFORE_UPDATE` BEFORE UPDATE ON `vendaitem` FOR EACH ROW BEGIN
  declare iemp      integer;
  declare blestoque varchar(20);
  declare blunico   varchar(20);
  declare rtot      decimal(12,3);
  declare rped      decimal(12,3);
  
  select idemp from venda where id = new.idvenda into iemp;
  select valor from cfg where param = 'VESTOQUE' into blestoque;
  select valor from cfg where param = 'ESTOQUEUNICO' into blunico;

  set new.bruto = new.qtde * new.unitario;
  set new.total = ((new.qtde * new.unitario) + new.acrescimo + new.frete + new.seguro + new.outros + new.st + new.ipi) - new.desconto;
  if (new.custo > 0) then
    set new.margem = coalesce(((( ((new.qtde * new.unitario) + new.acrescimo - new.desconto) / (new.custo * new.qtde) ) * 100.00) - 100.00), 0);
  else
    set new.margem = 0.00;
  end if;  

  if upper(trim(blestoque)) = 'FALSE' then
    if upper(trim(blunico)) = 'FALSE' then
       select cast(coalesce(sum(saldo), 0) as decimal(12,3)) as saldo from prdsaldo where idprod = new.idprod and idemp = iemp into rtot;
       
       select coalesce(sum(vi.qtde), 0) as qtde from vendaitem vi
       inner join venda v on (v.id = vi.idvenda)
       where v.tipo = 'P' and ((not v.bloqueio) or (v.bloqueio and v.autorizado))
       and vi.idprod = new.idprod and v.idemp = iemp and v.id <> new.idvenda into rped;
    else
       select cast(coalesce(sum(saldo), 0) as decimal(12,3)) as saldo from prdsaldo where idprod = new.idprod into rtot;
       
       select coalesce(sum(vi.qtde), 0) as qtde from vendaitem vi
       inner join venda v on (v.id = vi.idvenda)
       where v.tipo = 'P' and ((not v.bloqueio) or (v.bloqueio and v.autorizado))
       and vi.idprod = new.idprod and v.id <> new.idvenda into rped;
    end if;

    if rtot <= 0 then
       set new.estoque = -1;
    else
        if (rtot - rped - new.qtde) < 0 then
           set new.estoque = 1;
        else
           set new.estoque = 0;
        end if;
    end if;
  else
    set new.estoque = 0;
  end if;
  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.VENDA_AFTER_INSERT
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `VENDA_AFTER_INSERT` AFTER INSERT ON `venda` FOR EACH ROW BEGIN

  declare msg varchar(250) CHARSET utf8;
  declare tipo varchar(30) CHARSET utf8;
  
  if (new.tipo = 'O') then
    set tipo = 'ORÇAMENTO';
  elseif (new.tipo = 'P') then
    set tipo = 'PEDIDO';
  elseif (new.tipo = 'V') then
    set tipo = 'VENDA';
  elseif (new.tipo = 'E') then
    set tipo = 'EXTRATO AGREGAÇÃO';
  end if;
  
  set msg = concat('Lançamento criado com o tipo: ', tipo, ' pelo usuário: ', coalesce(new.ultimousu, 'não informado'));
  
  CALL `prc_vendahist`(new.id, func_dthr(), msg);
  
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Copiando estrutura para trigger b3erp.dsv.VENDA_AFTER_UPDATE
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE DEFINER=`SYSDBA`@`%` TRIGGER `VENDA_AFTER_UPDATE` AFTER UPDATE ON `venda` FOR EACH ROW BEGIN

  declare msg varchar(250) CHARSET utf8;
  declare tipo varchar(30) CHARSET utf8;
  
  if (new.ultimousu > 0) and (old.ultimousu > 0) and (new.ultimousu <> old.ultimousu) then
    set msg = concat('Usuário diferente no lançamento. Usuário novo: ', coalesce(new.ultimousu, 'não informado'), ' Usuário anterior: ', coalesce(old.ultimousu, 'não informado'));
    CALL `prc_vendahist`(new.id, func_dthr(), msg);
    set msg = '';
  end if;
  
  if (new.tipo <> old.tipo) then
    if (new.tipo = 'P') then
      set tipo = 'PEDIDO';
    elseif (new.tipo = 'V') then
      set tipo = 'VENDA';
    elseif (new.tipo = 'X') then
      set tipo = 'CANCELADO';
    end if;
    set msg = concat('Alterado tipo de Lançamento para: ', tipo);
    CALL `prc_vendahist`(new.id, func_dthr(), msg);
    set msg = '';
  end if;

  if (new.baixado <> old.baixado) then
    set msg = concat('Operação de baixa no Lançamento: ', if(new.baixado, 'BAIXA', 'ESTORNO'));
    CALL `prc_vendahist`(new.id, func_dthr(), msg);
    set msg = '';
  end if;
  
  if (new.faturado <> old.faturado) then
    set msg = concat('Faturamento do Lançamento: ', if(new.faturado, 'FATURA CRIADA', 'FATURA CANCELADA'));
    CALL `prc_vendahist`(new.id, func_dthr(), msg);
    set msg = '';
  end if;
  
  if (new.idoper <> old.idoper) then
	delete from vendaoper where idvenda=new.id;

	insert into vendaoper(idvenda, seq, idoperacao, idimposto) 
	select vi.idvenda, vi.seq, func_venda_operacaoprd(vi.idvenda, vi.seq), func_venda_impostoprd(vi.idvenda, vi.seq) 
	from vendaitem vi where vi.idvenda=new.id;
  end if;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
