-- Objetivo: Consultar texto e contadores por cursor filho
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de GV$SQL.
-- Parametros bind: p_sql_id (13 caracteres minusculos)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar SQL lento com DBMS_XPLAN.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Contadores acumulados enquanto cursor esta no cache; ausencia nao comprova SQL inexistente.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_sql_id IS NULL OR NOT REGEXP_LIKE(:p_sql_id,'^[0-9a-z]{13}$','c') THEN
    RAISE_APPLICATION_ERROR(-20041,'Informar SQL_ID de 13 caracteres minusculos.');
  END IF;
END;
/

SET LONG 1000000
SET LONGCHUNKSIZE 32767
SELECT inst_id, con_id, sql_id, child_number, plan_hash_value, executions,
       ROUND(elapsed_time/1e6,3) AS elapsed_s,
       ROUND(elapsed_time/NULLIF(executions,0)/1e6,6) AS s_por_execucao,
       buffer_gets, disk_reads, rows_processed, last_active_time, sql_fulltext
FROM gv$sql
WHERE sql_id = :p_sql_id AND REGEXP_LIKE(:p_sql_id,'^[0-9a-z]{13}$','c')
  AND con_id = TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
ORDER BY inst_id, child_number;
