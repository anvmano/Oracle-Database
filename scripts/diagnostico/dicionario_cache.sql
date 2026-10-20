-- Objetivo: Consultar contadores de caches do dicionario
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$ROWCACHE.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar memoria SGA e PGA.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Valores acumulados por tipo de cache; nao soma pais e subordinados como uma unica metrica.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT parameter,type,count,gets,getmisses,modifications,flushes,
       ROUND(100.0*getmisses/NULLIF(gets,0),3) AS misses_pct,con_id
FROM v$rowcache ORDER BY parameter,type,con_id;
