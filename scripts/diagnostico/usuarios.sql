-- Objetivo: Consultar estado das contas sem hashes ou senhas
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_USERS.
-- Parametros bind: p_owner (usuario exato)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../User _ Profile _ Roles _ Grants.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT username,account_status,lock_date,expiry_date,default_tablespace,
       temporary_tablespace,profile,authentication_type,common,oracle_maintained,last_login
FROM dba_users WHERE username=:p_owner;
