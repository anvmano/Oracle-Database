-- Objetivo: Contar switches de redo por hora, thread e encarnacao
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$LOG_HISTORY.
-- Parametros bind: p_dias (1 a 31)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Multiplexar grupos de redo logs.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: CDB$ROOT/non-CDB; historico do control file nao mede bytes nem garante retencao de todos os eventos.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_dias IS NULL OR :p_dias<1 OR :p_dias>31 THEN
    RAISE_APPLICATION_ERROR(-20040,'p_dias deve estar entre 1 e 31.');
  END IF;
END;
/

SELECT thread#,resetlogs_change#,TRUNC(first_time,'HH24') AS hora,COUNT(*) AS switches
FROM v$log_history WHERE first_time>=SYSDATE-:p_dias
GROUP BY thread#,resetlogs_change#,TRUNC(first_time,'HH24')
ORDER BY hora DESC,thread#,resetlogs_change#;
