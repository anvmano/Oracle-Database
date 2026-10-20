-- Objetivo: Revisar indicadores historicos de cache com divisor protegido
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$SYSSTAT.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar memoria SGA e PGA.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Indicador cumulativo legado; valor alto nao comprova bom desempenho e nao orienta aumento automatico de memoria.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

WITH s AS (
 SELECT SUM(CASE WHEN name IN ('db block gets from cache','consistent gets from cache') THEN value END) AS logicos,
        MAX(CASE WHEN name='physical reads cache' THEN value END) AS fisicos
 FROM v$sysstat
)
SELECT logicos,fisicos,ROUND(100.0*(1-fisicos/NULLIF(logicos,0)),3) AS cache_hit_pct
FROM s;
