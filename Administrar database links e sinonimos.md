# Administrar database links e sinônimos

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; link privado entre serviços de laboratório e objeto remoto de leitura.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use APP_LAB na origem e conta remota `REMOTE_READ_LAB`, com CREATE SESSION e somente SELECT no objeto preparado. Configure serviço `LABREMOTO` no Oracle Net do servidor da origem. Não use link público nem conta remota administrativa. O tráfego e a autenticação remota precisam da proteção prevista para o ambiente.

## 1. Preparar o alvo remoto

Na base remota, crie uma tabela fictícia de saúde no schema proprietário escolhido e conceda SELECT diretamente a REMOTE_READ_LAB. Valide a conexão dessa conta pelo serviço LABREMOTO e a leitura do objeto. Um teste no desktop não comprova resolução a partir do servidor da origem.

Na origem, confirme GLOBAL_NAMES e inventarie links privados do usuário:

```sql
SELECT db_link, username, host, created FROM user_db_links;
```

Se GLOBAL_NAMES=TRUE, o nome do link precisa seguir a identidade global remota. Escolha nome compatível com o valor real; `LNK_LAB` abaixo pressupõe que essa restrição não exige outro nome. Não altere parâmetro global só para encaixar o exemplo.

## 2. Criar um link privado

Conceda CREATE DATABASE LINK somente ao proprietário autorizado. No SQL*Plus APP_LAB, interativo e sem spool, exemplo de senha digitada com caracteres compatíveis com a substituição e sem aspas duplas:

```sql
SET VERIFY OFF
SET ECHO OFF
ACCEPT senha_remota CHAR PROMPT 'Senha da conta remota: ' HIDE
CREATE DATABASE LINK LNK_LAB CONNECT TO REMOTE_READ_LAB
  IDENTIFIED BY "&senha_remota" USING 'LABREMOTO';
UNDEFINE senha_remota
```

A senha permanece protegida pelo banco conforme o mecanismo do link; não está sendo armazenada no repositório. Não use a mesma credencial de produção. A criação é DDL e não é desfeita por ROLLBACK.

## 3. Testar identidade e objeto

```sql
SELECT global_name FROM global_name@LNK_LAB;
```

Confira o GLOBAL_NAME remoto com o inventário. USER_DB_LINKS identifica a conta configurada; a autenticação efetiva pode ser conferida no destino pelo administrador. Depois consulte o objeto previamente preparado, com proprietário remoto real. Caso tenha sido criado `APP_LAB.T_SAUDE_LINK` no destino, com SELECT concedido:

```sql
SELECT id, descricao FROM APP_LAB.T_SAUDE_LINK@LNK_LAB;
CREATE SYNONYM S_SAUDE_LINK FOR APP_LAB.T_SAUDE_LINK@LNK_LAB;
SELECT id, descricao FROM S_SAUDE_LINK;
```

CREATE SYNONYM precisa ser concedido quando necessário. O sinônimo não concede acesso e não muda o proprietário nem a proteção do link. Diagnostique separadamente nome de serviço, autenticação e privilégio remoto.

## 4. Operar e retirar

Inventarie consumidores antes de rotacionar a credencial remota ou substituir o link. Transações distribuídas têm efeitos além da sessão local; não faça DML remoto como teste inicial. Para retirar o exercício, após concluir as transações e conferir o proprietário:

```sql
DROP SYNONYM S_SAUDE_LINK;
DROP DATABASE LINK LNK_LAB;
```

Remover link/sinônimo não desfaz operações remotas anteriores. Revogue grants e retire a conta remota somente se forem exclusivos do laboratório e não houver outro consumidor.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [database_links.sql](scripts/diagnostico/database_links.sql) — Consultar metadados de database links sem senhas.
- [sinonimos.sql](scripts/diagnostico/sinonimos.sql) — Consultar destinos de sinonimos.

## Roteiros de solução de problemas

- [03 · Privilégio insuficiente ou objeto não acessível](solucao-de-problemas/03-privilegios-e-acesso-a-objetos.md).

## Referências oficiais

- [CREATE DATABASE LINK](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-DATABASE-LINK.html)
- [CREATE SYNONYM](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-SYNONYM.html)
