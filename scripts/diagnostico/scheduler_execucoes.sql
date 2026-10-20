-- Objetivo: Consultar definicoes e logs do Scheduler
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_SCHEDULER_JOBS, DBA_SCHEDULER_JOB_RUN_DETAILS.
-- Parametros bind: p_owner; p_nome opcional; p_dias (1 a 31)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Criar e monitorar jobs com DBMS_SCHEDULER.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Logs de jobs removidos sao preservados pelo LEFT JOIN; JOB_ACTION pode conter informacao sensivel.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_dias IS NULL OR :p_dias<1 OR :p_dias>31 THEN
    RAISE_APPLICATION_ERROR(-20040,'p_dias deve estar entre 1 e 31.');
  END IF;
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT j.owner,j.job_name,j.enabled,j.state,j.job_type,j.job_action,
       j.start_date,j.next_run_date,j.repeat_interval,j.run_count,j.failure_count
FROM dba_scheduler_jobs j
WHERE j.owner=:p_owner AND (:p_nome IS NULL OR j.job_name=:p_nome)
ORDER BY j.job_name;
SELECT r.owner,r.job_name,r.log_date,r.status,r.error#,r.run_duration,
       j.enabled,j.state
FROM dba_scheduler_job_run_details r
LEFT JOIN dba_scheduler_jobs j ON j.owner=r.owner AND j.job_name=r.job_name
WHERE r.owner=:p_owner AND (:p_nome IS NULL OR r.job_name=:p_nome)
  AND :p_dias BETWEEN 1 AND 31
  AND r.log_date >= SYSTIMESTAMP-NUMTODSINTERVAL(:p_dias,'DAY')
ORDER BY r.log_date DESC;
