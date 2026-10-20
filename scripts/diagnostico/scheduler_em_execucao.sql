-- Objetivo: Consultar jobs Scheduler em execucao
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_SCHEDULER_RUNNING_JOBS.
-- Parametros bind: p_owner; p_nome opcional (job)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Criar e monitorar jobs com DBMS_SCHEDULER.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Scheduler atual; jobs DBMS_JOB continuam no diagnostico legado separado. Nao interrompe execucoes.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,job_name,job_subname,session_id,running_instance,elapsed_time,cpu_used
FROM dba_scheduler_running_jobs WHERE owner=:p_owner AND (:p_nome IS NULL OR job_name=:p_nome)
ORDER BY elapsed_time DESC,job_name;
