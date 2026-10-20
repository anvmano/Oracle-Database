-- Objetivo: Consultar execucoes RMAN no periodo
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$RMAN_BACKUP_JOB_DETAILS.
-- Parametros bind: p_dias (1 a 31)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Automatizar backups RMAN.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Consultar em CDB$ROOT/non-CDB; ausencia de linha nao comprova backup valido ou restauravel.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_dias IS NULL OR :p_dias<1 OR :p_dias>31 THEN
    RAISE_APPLICATION_ERROR(-20040,'p_dias deve estar entre 1 e 31.');
  END IF;
END;
/

SELECT session_key, input_type, status, start_time, end_time,
       elapsed_seconds, input_bytes_display, output_bytes_display
FROM v$rman_backup_job_details
WHERE start_time >= SYSDATE-:p_dias AND :p_dias BETWEEN 1 AND 31
ORDER BY start_time DESC;
