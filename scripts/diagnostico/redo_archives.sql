-- Objetivo: Consultar grupos redo e sequencias arquivadas
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$LOG, V$ARCHIVED_LOG.
-- Parametros bind: p_dias (1 a 31)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Multiplexar grupos de redo logs.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: CDB$ROOT/non-CDB; uma sequencia pode ter varias copias/destinos, nao somar como redo distinto.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_dias IS NULL OR :p_dias<1 OR :p_dias>31 THEN
    RAISE_APPLICATION_ERROR(-20040,'p_dias deve estar entre 1 e 31.');
  END IF;
END;
/

SELECT group#,thread#,sequence#,bytes/1048576 AS mib,members,archived,status FROM v$log ORDER BY thread#,group#;
SELECT thread#,sequence#,resetlogs_change#,dest_id,name,first_time,completion_time,deleted,status
FROM v$archived_log WHERE completion_time>=SYSDATE-:p_dias AND :p_dias BETWEEN 1 AND 31
ORDER BY completion_time DESC,thread#,sequence#,dest_id;
