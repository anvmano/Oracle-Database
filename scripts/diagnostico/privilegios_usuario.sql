-- Objetivo: Listar concessoes diretas para usuario ou role
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_SYS_PRIVS, DBA_ROLE_PRIVS, DBA_TAB_PRIVS.
-- Parametros bind: p_owner (grantee exato)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../User _ Profile _ Roles _ Grants.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Nao expande roles aninhadas, PUBLIC, grants em colunas ou todos os privilegios efetivos.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT grantee,privilege,admin_option FROM dba_sys_privs WHERE grantee=:p_owner ORDER BY privilege;
SELECT grantee,granted_role,admin_option,default_role FROM dba_role_privs WHERE grantee=:p_owner ORDER BY granted_role;
SELECT grantee,owner,table_name,privilege,grantable FROM dba_tab_privs WHERE grantee=:p_owner ORDER BY owner,table_name,privilege;
