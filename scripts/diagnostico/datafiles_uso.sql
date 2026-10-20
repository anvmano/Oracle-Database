-- Objetivo: Medir alocado e livre por arquivo
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_DATA_FILES, DBA_FREE_SPACE, DBA_TABLESPACES.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar capacidade e crescimento do banco.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Arquivo offline/inacessivel conserva NULL em livre/usado, nao um falso zero.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

WITH livres AS (
 SELECT file_id, SUM(bytes) AS livre FROM dba_free_space GROUP BY file_id
)
SELECT d.file_id, d.tablespace_name, d.file_name, d.online_status,
       ROUND(d.bytes/1048576,2) AS alocado_mib,
       CASE WHEN d.online_status IN ('ONLINE','SYSTEM') AND d.status='AVAILABLE'
                  AND t.status IN ('ONLINE','READ ONLY')
            THEN ROUND(COALESCE(l.livre,0)/1048576,2) END AS livre_mib,
       CASE WHEN d.online_status IN ('ONLINE','SYSTEM') AND d.status='AVAILABLE'
                  AND t.status IN ('ONLINE','READ ONLY')
            THEN ROUND((d.bytes-COALESCE(l.livre,0))/1048576,2) END AS usado_mib,
       d.autoextensible, ROUND(d.maxbytes/1048576,2) AS maxbytes_mib
FROM dba_data_files d LEFT JOIN livres l ON l.file_id=d.file_id
JOIN dba_tablespaces t ON t.tablespace_name=d.tablespace_name
ORDER BY d.tablespace_name, d.file_id;
