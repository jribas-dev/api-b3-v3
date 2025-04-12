<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

# 📦 API B3 v3 (NestJS)

Este projeto é a API principal da aplicação B3 v3, desenvolvida com **NestJS 11** e **Node.js 22**, utilizando **TypeScript** e arquitetura modular.

A API desempenha múltiplas funções:

- Servidor de autenticação (Authorization Server) com suporte a OAuth2, JWT e refresh tokens rotativos
- Servidor de recursos (Resource Server) com controle de acesso por instância (multi-tenancy)
- Integração com AWS S3 para upload de arquivos
- Integração com AWS SES para envio de e-mails de ativação e notificações

---

## ⚙️ Tecnologias utilizadas

| Lib / Tecnologia   | Descrição                                                        |
| ------------------ | ---------------------------------------------------------------- |
| `@nestjs/core`     | Framework base do NestJS                                         |
| `@nestjs/common`   | Módulos utilitários do Nest (pipes, guards, interceptors, etc.)  |
| `@nestjs/jwt`      | Geração e validação de tokens JWT                                |
| `@nestjs/passport` | Integração do Nest com o PassportJS (middleware de autenticação) |
| `passport`         | Biblioteca de autenticação extensível usada com estratégias      |
| `passport-jwt`     | Estratégia JWT para PassportJS                                   |
| `bcrypt`           | Utilizado para hash e comparação segura de senhas                |
| `@nestjs/config`   | Leitura e tipagem de variáveis de ambiente (`.env`)              |
| `dotenv`           | Carregamento do arquivo `.env` no ambiente                       |

> ❌ **Obs.:** As bibliotecas de banco de dados (ORM) estão listadas separadamente abaixo.

---

## 🗄️ ORM: TypeORM + MariaDB

A biblioteca **TypeORM** será utilizada para mapear entidades e controlar as conexões com o banco de dados MariaDB. Ela permite:

- Conexões dinâmicas (necessárias para multi-tenancy)
- Migrations (para versionar o schema do banco)
- Repositórios (para acesso orientado a entidades)

Libs envolvidas:

| Lib               | Descrição                                           |
| ----------------- | --------------------------------------------------- |
| `@nestjs/typeorm` | Módulo oficial de integração entre NestJS e TypeORM |
| `typeorm`         | ORM para banco de dados SQL                         |
| `mysql2`          | Driver do MariaDB/MySQL para TypeORM                |

---

## 🚀 Subindo o projeto localmente

### Pré-requisitos

- Node.js v22
- MariaDB rodando localmente
- Arquivo `.env` com as configurações necessárias

### Rodar a aplicação

```bash
npm install
npm run start:dev
```
