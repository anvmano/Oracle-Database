-- Objetivo: Consultar papel e transporte Data Guard
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$DATABASE, V$ARCHIVE_DEST_STATUS, V$DATAGUARD_STATS.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Administrar Data Guard com Broker.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: CDB$ROOT/non-CDB; linhas vazias no primary nao significam lag zero; nao usa Broker para alterar papel.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT db_unique_name,database_role,open_mode,protection_mode,switchover_status FROM v$database;
SELECT dest_id,status,type,database_mode,recovery_mode,db_unique_name,error
FROM v$archive_dest_status WHERE status<>'INACTIVE' ORDER BY dest_id;
SELECT name,value,unit,time_computed,datum_time FROM v$dataguard_stats ORDER BY name;
