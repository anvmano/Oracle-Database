-- Objetivo: Extrair DDL de um objeto proprio
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de USER_OBJECTS; EXECUTE DBMS_METADATA; API/DDL indicado no corpo.
-- Parametros bind: p_owner; p_nome; p_tipo (TABLE/INDEX/VIEW/SEQUENCE/PROCEDURE/FUNCTION/PACKAGE/PACKAGE_BODY/TRIGGER/TYPE/TYPE_BODY)
-- Efeito: Produz texto DDL; nao executa o texto gerado.
-- Tutorial: ../../visualizar DDL.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_METADATA.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Sem conexao/senha ou execucao de DDL; saida pode exceder SET LONG. Transformacoes padrao da sessao devem ser preservadas.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SET LONG 10000000
SET LONGCHUNKSIZE 32767
VARIABLE ddl_objeto CLOB
BEGIN
  :ddl_objeto:=NULL;

  IF :p_owner IS NULL OR :p_owner<>SYS_CONTEXT('USERENV','SESSION_USER')
    OR :p_owner<>SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
    OR NOT REGEXP_LIKE(:p_owner,'^[A-Z][A-Z0-9_$#]{0,127}$','c') THEN
    RAISE_APPLICATION_ERROR(-20030,'Gerador limitado ao proprio schema, nome convencional.');
  END IF;

  IF :p_nome IS NULL OR NOT REGEXP_LIKE(:p_nome,'^[A-Z][A-Z0-9_$#]{0,127}$','c') THEN
    RAISE_APPLICATION_ERROR(-20004,'p_nome deve ser identificador convencional em maiusculas.');
  END IF;

  IF :p_tipo IS NULL OR :p_tipo NOT IN ('TABLE','INDEX','VIEW','SEQUENCE','PROCEDURE','FUNCTION','PACKAGE','PACKAGE_BODY','TRIGGER','TYPE','TYPE_BODY') THEN
    RAISE_APPLICATION_ERROR(-20031,'Tipo nao permitido para DBMS_METADATA.');
  END IF;
  :ddl_objeto:=DBMS_METADATA.GET_DDL(:p_tipo,:p_nome,:p_owner);
END;
/
PRINT ddl_objeto
