---
name: security-audit
description: Realiza auditoria de segurança completa na API buscando vulnerabilidades exploráveis por invasores
disable-model-invocation: true
effort: max
---

Realize uma auditoria de segurança completa no código em $ARGUMENTS.

## Escopo da análise

### Vulnerabilidades de disponibilidade (DoS/DDoS)
- Endpoints sem rate limiting
- Queries sem paginação ou limite de resultado
- Loops ou recursões potencialmente infinitas
- Operações síncronas bloqueantes no event loop
- Memory leaks em operações recorrentes
- Ausência de timeout em chamadas externas (HTTP, banco, filas)

### Vulnerabilidades de autenticação e autorização
- Endpoints expostos sem autenticação
- Falhas de autorização entre tenants (vazamento de dados cross-tenant)
- JWT sem validação adequada de expiração ou assinatura
- Tokens sem revogação

### Injeção e manipulação de dados
- SQL Injection via QueryBuilder ou raw queries
- Parâmetros de entrada sem validação ou sanitização
- Mass assignment em DTOs
- Exposição de campos sensíveis na resposta

### Configuração e infraestrutura
- Variáveis de ambiente sensíveis expostas em logs ou respostas
- Dependências com CVEs conhecidos
- Headers de segurança ausentes
- CORS mal configurado

## Formato de saída

Para cada vulnerabilidade encontrada, informe:
1. **Severidade**: Critical / High / Medium / Low
2. **Arquivo e linha**
3. **Descrição** do problema
4. **Como pode ser explorado** (vetor de ataque)
5. **Correção recomendada** com exemplo de código

Ordene por severidade. Ao final, gere um resumo executivo com contagem por severidade.