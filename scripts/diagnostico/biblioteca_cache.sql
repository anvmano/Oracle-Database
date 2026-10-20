-- Objetivo: Consultar contadores do library cache
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$LIBRARYCACHE.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar memoria SGA e PGA.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Nao aplica limite universal de 1 por cento nem recomenda aumento automatico do shared pool.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT namespace,gets,gethits,pins,pinhits,reloads,invalidations,
       ROUND(100.0*gethits/NULLIF(gets,0),3) AS get_hit_pct,
       ROUND(100.0*reloads/NULLIF(pins,0),3) AS reload_pct,con_id
FROM v$librarycache ORDER BY namespace,con_id;
