-- Objetivo: Extrair grants publicados em um objeto proprio
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de USER_OBJECTS, USER_TAB_PRIVS; EXECUTE DBMS_METADATA; API/DDL indicado no corpo.
-- Parametros bind: p_owner; p_nome (objeto)
-- Efeito: Produz texto DDL; nao executa o texto gerado.
-- Tutorial: ../../visualizar DDL.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_METADATA.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Grants no objeto, diferente dos grants recebidos pelo usuario; nao executa GRANT e nao cobre grants de coluna.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SET LONG 10000000
SET LONGCHUNKSIZE 32767
VARIABLE ddl_grants_objeto CLOB
DECLARE
  l_count NUMBER;
BEGIN
  :ddl_grants_objeto:=NULL;

  IF :p_owner IS NULL OR :p_owner<>SYS_CONTEXT('USERENV','SESSION_USER')
    OR :p_owner<>SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
    OR NOT REGEXP_LIKE(:p_owner,'^[A-Z][A-Z0-9_$#]{0,127}$','c') THEN
    RAISE_APPLICATION_ERROR(-20030,'Gerador limitado ao proprio schema, nome convencional.');
  END IF;

  IF :p_nome IS NULL OR NOT REGEXP_LIKE(:p_nome,'^[A-Z][A-Z0-9_$#]{0,127}$','c') THEN
    RAISE_APPLICATION_ERROR(-20004,'p_nome deve ser identificador convencional em maiusculas.');
  END IF;

  SELECT COUNT(*) INTO l_count FROM user_objects WHERE object_name=:p_nome;
  IF l_count=0 THEN RAISE_APPLICATION_ERROR(-20032,'Objeto proprio nao encontrado.'); END IF;
  SELECT COUNT(*) INTO l_count FROM user_tab_privs WHERE owner=:p_owner AND table_name=:p_nome;
  IF l_count>0 THEN
    :ddl_grants_objeto:=DBMS_METADATA.GET_DEPENDENT_DDL('OBJECT_GRANT',:p_nome,:p_owner);
  ELSE DBMS_OUTPUT.PUT_LINE('Objeto sem grants de objeto registrados.'); END IF;
END;
/
PRINT ddl_grants_objeto
