-- Objetivo: Consultar jobs Data Pump existentes
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_DATAPUMP_JOBS.
-- Parametros bind: p_owner
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../EXPDP.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Nao anexa nem remove jobs; NOT RUNNING exige investigacao antes de qualquer limpeza.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner_name,job_name,operation,job_mode,state,degree,attached_sessions,datapump_sessions
FROM dba_datapump_jobs WHERE owner_name=:p_owner ORDER BY job_name;
