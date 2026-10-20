# Usuários, profiles, roles e privilégios

[← Índice](README.md)

**Escopo:** Usuários locais em PDB/non-CDB; privilégios e quotas por finalidade.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Exemplos de usuário **local**, no non-CDB ou na PDB da aplicação. Em CDB root, usuários comuns seguem regras próprias; não desative validações de nomes comuns para criar um usuário local no lugar errado. Confira `SHOW CON_NAME`.

Nomes, quotas, tempos e privilégios abaixo são exemplos. Use o menor conjunto de acessos necessário. DDL e concessões podem confirmar transações implicitamente; não são uma alteração de aplicação desfeita por `ROLLBACK`.

## 1. Criar profile

```sql
CREATE PROFILE APP_PROFILE LIMIT
  SESSIONS_PER_USER 5
  CONNECT_TIME 120
  IDLE_TIME 30
  FAILED_LOGIN_ATTEMPTS 5
  PASSWORD_LIFE_TIME 60
  PASSWORD_REUSE_TIME 60
  PASSWORD_REUSE_MAX 5
  PASSWORD_LOCK_TIME 1/24
  PASSWORD_GRACE_TIME 10;
```

`CONNECT_TIME`/`IDLE_TIME` são minutos; os parâmetros de prazo de senha são dias. Recursos de kernel dependem de `RESOURCE_LIMIT`; restrições de senha não dependem desse parâmetro. Confira `SHOW PARAMETER resource_limit` e, se necessário e autorizado, habilite-o pelo escopo apropriado.

`PASSWORD_VERIFY_FUNCTION DEFAULT` herda o profile DEFAULT e **não garante** por si só uma política de complexidade. Use uma função aprovada e instalada para sua versão, após avaliar os usuários existentes. `PRIVATE_SGA` só se aplica ao cenário de shared server correspondente. Para gestão ampla de carga, avalie Resource Manager em vez de tratar profiles como limitador universal de CPU.

## 2. Criar usuário e atribuir quota

As tablespaces `TBS_APP` e `TEMP_APP` precisam existir. No SQL*Plus interativo, sem spool de credenciais:

```sql
SET VERIFY OFF
SET ECHO OFF
ACCEPT senha CHAR PROMPT 'Senha do novo usuário: ' HIDE
CREATE USER APP_USER IDENTIFIED BY "&senha"
  DEFAULT TABLESPACE TBS_APP
  TEMPORARY TABLESPACE TEMP_APP
  QUOTA 100M ON TBS_APP
  PROFILE APP_PROFILE
  ACCOUNT UNLOCK;
UNDEFINE senha
```

Digite a senha conforme as regras Oracle, sem aspas duplas que quebrem esse exemplo de substituição SQL*Plus. Não salve a senha no documento ou no histórico de comandos com o valor literal. Criação de usuário não concede automaticamente o direito de conexão.

## 3. Criar role e conceder acessos

```sql
CREATE ROLE APP_READ;
GRANT CREATE SESSION TO APP_USER;
GRANT SELECT ON APP_OWNER.CLIENTES TO APP_READ;
GRANT APP_READ TO APP_USER;
```

`APP_OWNER.CLIENTES` deve ser um objeto real; execute a concessão como proprietário ou administrador autorizado. `WITH ADMIN OPTION` se aplica a concessões de roles/privilégios de sistema; para delegar privilégio de objeto, a opção é `WITH GRANT OPTION` e há restrições de destinatário. Não conceda delegação sem necessidade. Privilégios usados por PL/SQL com direitos do definidor normalmente precisam de concessão direta ao proprietário, não apenas de role.

## 4. Alterações independentes

```sql
ALTER USER APP_USER PROFILE APP_PROFILE;
ALTER USER APP_USER QUOTA 200M ON TBS_APP;
```

Revogação é uma mudança separada: após avaliar consumidores, use `REVOKE APP_READ FROM APP_USER;` ou `REVOKE SELECT ON APP_OWNER.CLIENTES FROM APP_READ;`. Bloquear a conta com `ALTER USER APP_USER ACCOUNT LOCK;` não equivale a encerrar sessões já abertas.

## 5. Validar

```sql
SELECT username, account_status, profile, default_tablespace, temporary_tablespace
FROM dba_users WHERE username='APP_USER';
SELECT * FROM dba_profiles WHERE profile='APP_PROFILE';
SELECT * FROM dba_sys_privs WHERE grantee='APP_USER';
SELECT * FROM dba_role_privs WHERE grantee='APP_USER';
SELECT * FROM dba_tab_privs WHERE grantee IN ('APP_USER','APP_READ');
SELECT username, tablespace_name, bytes/1024/1024 usado_mb,
       CASE WHEN max_bytes=-1 THEN 'UNLIMITED'
            ELSE TO_CHAR(max_bytes/1024/1024)||' MB' END quota
FROM dba_ts_quotas WHERE username='APP_USER';
```

Teste login pelo serviço da PDB e uma operação permitida/negada com `APP_USER`. Não use credenciais SYS para demonstrar que os privilégios da aplicação estão corretos.

## 6. Restringir uma conta de monitoramento

Para uma conta dedicada, crie usuário local no container confirmado pelo mesmo fluxo de senha interativa do item 2, usando nome próprio, profile apropriado e sem privilégios de criação/quota se não forem necessários. Exemplo de concessões **somente para inventário de instância/banco**, como administrador, após criar ZBX_MON:

```sql
GRANT CREATE SESSION TO ZBX_MON;
GRANT SELECT ON SYS.V_$INSTANCE TO ZBX_MON;
GRANT SELECT ON SYS.V_$DATABASE TO ZBX_MON;
```

Esses grants não implementam todos os itens do [template Zabbix](<Monitorar Oracle com Zabbix.md>). Mapeie cada consulta adicional ao objeto/privilégio e escopo de container; não conceda DBA, SELECT ANY TABLE ou delegação como atalho. Teste as consultas permitidas e uma operação negada em schema de laboratório. Revogue somente acessos exclusivos da integração e não registre senha ou conexão preenchida no Git.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [privilegios_usuario.sql](scripts/diagnostico/privilegios_usuario.sql) — Listar concessoes diretas para usuario ou role.
- [usuarios.sql](scripts/diagnostico/usuarios.sql) — Consultar estado das contas sem hashes ou senhas.
- [profiles_limites.sql](scripts/diagnostico/profiles_limites.sql) — Consultar limites configurados em profiles.

## Roteiros de solução de problemas

- [02 · Conta bloqueada ou senha expirada](solucao-de-problemas/02-conta-bloqueada-senha-expirada.md).
- [03 · Privilégio insuficiente ou objeto não acessível](solucao-de-problemas/03-privilegios-e-acesso-a-objetos.md).

## Referências oficiais

- [CREATE USER](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-USER.html)
- [CREATE PROFILE](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-PROFILE.html)
- [GRANT](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/GRANT.html)
