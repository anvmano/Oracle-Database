-- Objetivo: Consultar limite, uso e elegibilidade de recuperacao da FRA
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$RECOVERY_FILE_DEST, V$RECOVERY_AREA_USAGE.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar FRA e archivelogs.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Consultar em CDB$ROOT/non-CDB. Reclaimable nao autoriza exclusao manual de arquivos.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT name, ROUND(space_limit/1048576,2) AS limite_mib,
       ROUND(space_used/1048576,2) AS usado_mib,
       ROUND(space_reclaimable/1048576,2) AS recuperavel_mib,
       ROUND(100.0*space_used/NULLIF(space_limit,0),2) AS pct_usado, number_of_files
FROM v$recovery_file_dest;
SELECT file_type, percent_space_used, percent_space_reclaimable, number_of_files
FROM v$recovery_area_usage ORDER BY percent_space_used DESC;
