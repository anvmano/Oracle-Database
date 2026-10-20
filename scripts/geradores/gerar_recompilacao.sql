-- Objetivo: Gerar comandos para objetos invalidos sem executa-los
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de USER_OBJECTS; EXECUTE DBMS_ASSERT; API/DDL indicado no corpo.
-- Parametros bind: p_owner; p_nome opcional; p_tipo opcional (tipo Oracle com espaco)
-- Efeito: Produz texto DDL; nao executa o texto gerado.
-- Tutorial: ../../visualizar DDL.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_METADATA.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Nao resolve ordem completa de dependencias; revise cada comando e confirme erros depois de compilar.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN

  IF :p_owner IS NULL OR :p_owner<>SYS_CONTEXT('USERENV','SESSION_USER')
    OR :p_owner<>SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
    OR NOT REGEXP_LIKE(:p_owner,'^[A-Z][A-Z0-9_$#]{0,127}$','c') THEN
    RAISE_APPLICATION_ERROR(-20030,'Gerador limitado ao proprio schema, nome convencional.');
  END IF;

  NULL;
END;
/
SELECT CASE WHEN object_type='PACKAGE BODY' THEN
         'ALTER PACKAGE '||DBMS_ASSERT.ENQUOTE_NAME(object_name,FALSE)||' COMPILE BODY;'
       WHEN object_type='PACKAGE' THEN
         'ALTER PACKAGE '||DBMS_ASSERT.ENQUOTE_NAME(object_name,FALSE)||' COMPILE SPECIFICATION;'
       ELSE 'ALTER '||object_type||' '||DBMS_ASSERT.ENQUOTE_NAME(object_name,FALSE)||' COMPILE;' END AS ddl
FROM user_objects
WHERE status='INVALID' AND object_type IN ('PROCEDURE','FUNCTION','VIEW','PACKAGE','PACKAGE BODY','TRIGGER')
 AND (:p_nome IS NULL OR object_name=:p_nome) AND (:p_tipo IS NULL OR object_type=:p_tipo)
ORDER BY CASE object_type WHEN 'PACKAGE' THEN 1 WHEN 'PACKAGE BODY' THEN 3 ELSE 2 END,object_name;
