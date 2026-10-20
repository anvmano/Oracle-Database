-- Objetivo: Consultar contadores acumulados de eventos de espera
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$SYSTEM_EVENT.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar sessoes e bloqueios.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Instancia local, inclui CON_ID na saida; contadores acumulados nao descrevem so o instante atual.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT event,wait_class,total_waits,total_timeouts,time_waited_micro,
       ROUND(time_waited_micro/NULLIF(total_waits,0)/1000,3) AS media_ms,con_id
FROM v$system_event WHERE wait_class<>'Idle'
ORDER BY time_waited_micro DESC,event;
