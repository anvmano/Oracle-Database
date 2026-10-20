-- Objetivo: Consultar DBMS_JOB sem confundir com Scheduler
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_JOBS.
-- Parametros bind: p_owner (schema_user)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Criar e monitorar jobs com DBMS_SCHEDULER.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Legado DBMS_JOB; WHAT pode conter dados sensiveis; nao migra nem executa jobs.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT job,log_user,priv_user,schema_user,last_date,this_date,next_date,
       broken,failures,interval,what
FROM dba_jobs WHERE schema_user=:p_owner ORDER BY job;
