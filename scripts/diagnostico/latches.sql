-- Objetivo: Consultar contadores acumulados de latches
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$LATCH.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar memoria SGA e PGA.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Contadores desde startup; comparar duas amostras antes de inferir contencao atual.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT name,gets,misses,sleeps,spin_gets,wait_time,
       ROUND(100.0*misses/NULLIF(gets,0),4) AS pct_misses
FROM v$latch WHERE gets>0 OR sleeps>0 ORDER BY sleeps DESC,misses DESC;
