-- Objetivo: Consultar consumo atual e maximo de recursos da instancia
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$RESOURCE_LIMIT.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar sessoes e bloqueios.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: CDB$ROOT/non-CDB, instancia local; MAX_UTILIZATION e historico desde startup e LIMIT_VALUE pode ser texto.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT resource_name,current_utilization,max_utilization,initial_allocation,limit_value,con_id
FROM v$resource_limit ORDER BY resource_name,con_id;
