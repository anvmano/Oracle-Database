-- Objetivo: Medir espaco permanente sem multiplicar extents livres
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_DATA_FILES, DBA_FREE_SPACE, DBA_TABLESPACES.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar capacidade e crescimento do banco.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Teto de autoextend nao e espaco garantido no filesystem/ASM; nao inclui TEMP.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

WITH arquivos AS (
  SELECT tablespace_name, SUM(bytes) AS alocado,
         SUM(CASE WHEN autoextensible='YES' THEN GREATEST(bytes,maxbytes) ELSE bytes END) AS limite,
         SUM(CASE WHEN online_status IN ('ONLINE','SYSTEM') AND status='AVAILABLE' THEN 0 ELSE 1 END) AS inacessiveis
  FROM dba_data_files GROUP BY tablespace_name
), livres AS (
  SELECT tablespace_name, SUM(bytes) AS livre FROM dba_free_space GROUP BY tablespace_name
)
SELECT a.tablespace_name, t.status, ROUND(a.alocado/1048576,2) AS alocado_mib,
       CASE WHEN a.inacessiveis=0 AND t.status IN ('ONLINE','READ ONLY')
            THEN ROUND(COALESCE(l.livre,0)/1048576,2) END AS livre_mib,
       CASE WHEN a.inacessiveis=0 AND t.status IN ('ONLINE','READ ONLY')
            THEN ROUND((a.alocado-COALESCE(l.livre,0))/1048576,2) END AS usado_mib,
       CASE WHEN a.inacessiveis=0 AND t.status IN ('ONLINE','READ ONLY')
            THEN ROUND(100.0*(a.alocado-COALESCE(l.livre,0))/NULLIF(a.alocado,0),2) END AS pct_usado,
       ROUND(a.limite/1048576,2) AS teto_configurado_mib, a.inacessiveis
FROM arquivos a JOIN dba_tablespaces t ON t.tablespace_name=a.tablespace_name
LEFT JOIN livres l ON l.tablespace_name=a.tablespace_name
ORDER BY a.tablespace_name;
