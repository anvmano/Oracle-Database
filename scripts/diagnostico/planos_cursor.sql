-- Objetivo: Consultar linhas de plano por SQL_ID e cursor filho
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de GV$SQL_PLAN.
-- Parametros bind: p_sql_id (13 caracteres minusculos)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar SQL lento com DBMS_XPLAN.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Plano no cache, separado por instancia e filho; nao consulta AWR/ASH. Predicados podem conter valores sensiveis.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_sql_id IS NULL OR NOT REGEXP_LIKE(:p_sql_id,'^[0-9a-z]{13}$','c') THEN
    RAISE_APPLICATION_ERROR(-20041,'Informar SQL_ID de 13 caracteres minusculos.');
  END IF;
END;
/

SELECT inst_id,con_id,sql_id,child_number,plan_hash_value,id,parent_id,depth,
       operation,options,object_owner,object_name,cost,cardinality,bytes,
       access_predicates,filter_predicates
FROM gv$sql_plan WHERE sql_id=:p_sql_id
 AND con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
ORDER BY inst_id,child_number,id;
