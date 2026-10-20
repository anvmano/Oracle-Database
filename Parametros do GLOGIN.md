# Personalizar a sessão SQL*Plus

[← Índice](README.md)

**Escopo:** SQL*Plus interativo; perfil global exige teste também em lote e /nolog.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

`$ORACLE_HOME/sqlplus/admin/glogin.sql` é o perfil global desse home e pode afetar administradores e scripts automatizados. Para personalização individual, prefira `login.sql` conforme o mecanismo de busca da versão. Faça backup do perfil antes de editar e teste conexão local, remota e execução em lote. Em home compartilhado, planeje a mudança.

## 1. Configurar opções que não exigem conexão

No perfil global, limite-se às opções de sessão e variáveis SQL*Plus que não consultam o banco. Exemplo:

```sql
SET ECHO OFF
SET VERIFY OFF
SET LINESIZE 200
SET SQLPROMPT '_USER@_CONNECT_IDENTIFIER> '
DEFINE _EDITOR = vim
```

As variáveis predefinidas refletem o usuário e identificador de conexão; sem conexão, os campos podem ficar vazios. O identificador não é garantia de qual container está ativo; confira `SHOW CON_NAME` quando necessário.

## 2. Saudação opcional depois de conectar

Salve o bloco seguinte em um script pessoal `saudacao.sql` e execute `@saudacao.sql` **após a conexão**. Não o inclua automaticamente em `glogin.sql`, pois as consultas falham em sessões `/nolog`:

```sql
SET ECHO OFF
SET VERIFY OFF
SET TERMOUT OFF
DEFINE vUsuario = 'NaoConectado'
DEFINE vBanco = 'SemServico'
DEFINE vSaudacao = 'Ola'
COLUMN cUsuario NEW_VALUE vUsuario NOPRINT
COLUMN cBanco NEW_VALUE vBanco NOPRINT
COLUMN cSaudacao NEW_VALUE vSaudacao NOPRINT
SELECT SYS_CONTEXT('USERENV','SESSION_USER') cUsuario,
       SYS_CONTEXT('USERENV','SERVICE_NAME') cBanco,
       CASE
         WHEN TO_NUMBER(TO_CHAR(SYSDATE,'HH24')) < 12 THEN 'Bom dia'
         WHEN TO_NUMBER(TO_CHAR(SYSDATE,'HH24')) < 18 THEN 'Boa tarde'
         ELSE 'Boa noite'
       END cSaudacao
FROM dual;
SET TERMOUT ON
PROMPT &vSaudacao, voce esta conectado ao servico &vBanco.
SET SQLPROMPT '&vUsuario@&vBanco> '
DEFINE _EDITOR = vim
SET LINESIZE 200
```

Não acrescente consultas a `V$INSTANCE` para todo usuário: elas podem exigir privilégios que usuários comuns não têm. `SYS_CONTEXT` evita essa dependência. A saudação usa a hora do servidor (`SYSDATE`); para outra política, ajuste explicitamente a fonte de hora.

## 3. Opções de sessão

`SET TIME ON` e `SET TIMING ON` são úteis interativamente, mas mudam a saída de scripts e spools. Ative-os somente nos perfis/sessões em que isso seja desejado. A definição correta do editor é `DEFINE _EDITOR`, não `DEFINE_EDITOR`.

## 4. Validar os limites

Confira o resultado às 00h, 12h e 18h: `[00,12)` → bom dia, `[12,18)` → boa tarde, `[18,24)` → boa noite. O teste antigo exigia simultaneamente hora maior que 18h e menor que a meia-noite **do mesmo dia**, intervalo impossível.

Teste também `sqlplus /nolog`, `CONNECT` posterior e um usuário sem privilégios de catálogo. O perfil global acima não consulta o banco; a saudação é invocada explicitamente após conectar. Não configure `WHENEVER SQLERROR EXIT` no perfil global para tentar esconder falhas.

## Referências oficiais

- [Perfis SQL*Plus](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqpug/configuring-SQL-Plus.html)
- [SYS_CONTEXT](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/SYS_CONTEXT.html)
