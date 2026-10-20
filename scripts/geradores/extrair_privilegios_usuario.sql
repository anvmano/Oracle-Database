-- Objetivo: Extrair grants diretos do usuario conectado
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de USER_SYS_PRIVS, USER_ROLE_PRIVS, USER_TAB_PRIVS_RECD; EXECUTE DBMS_METADATA; API/DDL indicado no corpo.
-- Parametros bind: p_owner; nenhum adicional
-- Efeito: Produz texto DDL; nao executa o texto gerado.
-- Tutorial: ../../visualizar DDL.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_METADATA.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Nao extrai CREATE USER, senha/hash, concessoes de colunas ou privilegios herdados. Saida e sensivel.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SET LONG 10000000
SET LONGCHUNKSIZE 32767
VARIABLE ddl_sys CLOB
VARIABLE ddl_roles CLOB
VARIABLE ddl_grants CLOB
DECLARE
  l_count NUMBER;
BEGIN
  :ddl_sys:=NULL; :ddl_roles:=NULL; :ddl_grants:=NULL;

  IF :p_owner IS NULL OR :p_owner<>SYS_CONTEXT('USERENV','SESSION_USER')
    OR :p_owner<>SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
    OR NOT REGEXP_LIKE(:p_owner,'^[A-Z][A-Z0-9_$#]{0,127}$','c') THEN
    RAISE_APPLICATION_ERROR(-20030,'Gerador limitado ao proprio schema, nome convencional.');
  END IF;

  SELECT COUNT(*) INTO l_count FROM user_sys_privs;
  IF l_count>0 THEN :ddl_sys:=DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT',:p_owner); END IF;
  SELECT COUNT(*) INTO l_count FROM user_role_privs;
  IF l_count>0 THEN :ddl_roles:=DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT',:p_owner); END IF;
  SELECT COUNT(*) INTO l_count FROM user_tab_privs_recd;
  IF l_count>0 THEN :ddl_grants:=DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT',:p_owner); END IF;
END;
/
PRINT ddl_sys
PRINT ddl_roles
PRINT ddl_grants
