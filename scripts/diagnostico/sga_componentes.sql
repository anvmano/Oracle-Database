-- Objetivo: Consultar componentes SGA sem misturar backup RMAN
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$SGAINFO, V$SGA_DYNAMIC_COMPONENTS, V$PGASTAT.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar memoria SGA e PGA.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Valores locais da instancia; nao somar novamente componentes sobrepostos.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT name,bytes,resizeable FROM v$sgainfo ORDER BY name;
SELECT component,current_size,min_size,max_size,last_oper_type,last_oper_mode
FROM v$sga_dynamic_components ORDER BY component;
SELECT name,value,unit FROM v$pgastat ORDER BY name;
