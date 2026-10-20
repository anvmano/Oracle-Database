-- Objetivo: Consultar execucoes de workareas por faixa de memoria
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$SQL_WORKAREA_HISTOGRAM.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar memoria SGA e PGA.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Faixas em bytes, contadores locais acumulados; nao equivale ao consumo atual de PGA por sessao.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT low_optimal_size,high_optimal_size,optimal_executions,onepass_executions,
       multipasses_executions,total_executions,con_id
FROM v$sql_workarea_histogram WHERE total_executions>0 ORDER BY low_optimal_size,con_id;
