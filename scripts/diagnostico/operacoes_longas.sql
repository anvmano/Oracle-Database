-- Objetivo: Consultar progresso instrumentado de operacoes longas
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de GV$SESSION_LONGOPS.
-- Parametros bind: p_owner (usuario)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar sessoes e bloqueios.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Somente operacoes instrumentadas; TIME_REMAINING e estimativa, nao prazo garantido.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT inst_id,con_id,sid,serial#,username,opname,target,sql_id,start_time,last_update_time,
       sofar,totalwork,units,ROUND(100.0*sofar/NULLIF(totalwork,0),2) AS pct_concluido,
       elapsed_seconds,time_remaining
FROM gv$session_longops WHERE username=:p_owner
 AND con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID')) AND totalwork>0 AND sofar<totalwork
ORDER BY start_time,inst_id,sid;
