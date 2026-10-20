-- Objetivo: Medir participacao acumulada de I/O por tablespace
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_DATA_FILES, V$FILESTAT.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar capacidade e crescimento do banco.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Percentual de operacoes acumuladas locais; nao mede latencia nem inclui TEMP.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

WITH arquivos AS (
 SELECT d.file_id,d.tablespace_name,d.file_name,f.phyrds,f.phywrts,f.readtim,f.writetim
 FROM dba_data_files d JOIN v$filestat f ON f.file#=d.file_id
 WHERE f.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
)
SELECT tablespace_name,SUM(phyrds) AS leituras,SUM(phywrts) AS escritas,
       ROUND(100.0*SUM(phyrds)/NULLIF(SUM(SUM(phyrds)) OVER (),0),2) AS pct_leituras,
       ROUND(100.0*SUM(phywrts)/NULLIF(SUM(SUM(phywrts)) OVER (),0),2) AS pct_escritas
FROM arquivos GROUP BY tablespace_name ORDER BY tablespace_name;
