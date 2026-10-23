-- Objetivo: Extrair constraints definidas em uma tabela propria
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de USER_TABLES, USER_CONSTRAINTS; EXECUTE DBMS_METADATA; API/DDL indicado no corpo.
-- Parametros bind: p_owner; p_nome (tabela)
-- Efeito: Produz texto DDL; nao executa o texto gerado.
-- Tutorial: ../../visualizar DDL.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_METADATA.html
-- Revisao: 23/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: NOT NULL e PK de IOT pertencem ao DDL da tabela. Inclui so FKs de saida; nao e migracao completa.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SET LONG 10000000
SET LONGCHUNKSIZE 32767
VARIABLE ddl_constraints CLOB
VARIABLE ddl_fks CLOB
DECLARE
  l_count NUMBER;
  e_sem_dependencias EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_sem_dependencias,-31608);
BEGIN
  :ddl_constraints:=NULL; :ddl_fks:=NULL;

  IF :p_owner IS NULL OR :p_owner<>SYS_CONTEXT('USERENV','SESSION_USER')
    OR :p_owner<>SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
    OR NOT REGEXP_LIKE(:p_owner,'^[A-Z][A-Z0-9_$#]{0,127}$','c') THEN
    RAISE_APPLICATION_ERROR(-20030,'Gerador limitado ao proprio schema, nome convencional.');
  END IF;

  IF :p_nome IS NULL OR NOT REGEXP_LIKE(:p_nome,'^[A-Z][A-Z0-9_$#]{0,127}$','c') THEN
    RAISE_APPLICATION_ERROR(-20004,'p_nome deve ser identificador convencional em maiusculas.');
  END IF;

  SELECT COUNT(*) INTO l_count FROM user_tables WHERE table_name=:p_nome;
  IF l_count<>1 THEN RAISE_APPLICATION_ERROR(-20032,'Tabela nao encontrada.'); END IF;
  -- USER_CONSTRAINTS inclui tipos que a API so emite dentro do DDL da tabela.
  BEGIN
    :ddl_constraints:=DBMS_METADATA.GET_DEPENDENT_DDL('CONSTRAINT',:p_nome,:p_owner);
  EXCEPTION
    WHEN e_sem_dependencias THEN :ddl_constraints:=NULL;
  END;
  SELECT COUNT(*) INTO l_count FROM user_constraints WHERE table_name=:p_nome AND constraint_type='R';
  IF l_count>0 THEN :ddl_fks:=DBMS_METADATA.GET_DEPENDENT_DDL('REF_CONSTRAINT',:p_nome,:p_owner); END IF;
END;
/
PRINT ddl_constraints
PRINT ddl_fks
