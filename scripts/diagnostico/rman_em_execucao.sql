-- Objetivo: Consultar operacoes RMAN ainda marcadas como running
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$RMAN_STATUS.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Automatizar backups RMAN.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: CDB$ROOT/non-CDB; linhas de sessao/comando podem se sobrepor. Nao somar MB entre niveis.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT recid,stamp,parent_recid,parent_stamp,row_level,operation,status,
       object_type,start_time,end_time,mbytes_processed
FROM v$rman_status WHERE status LIKE 'RUNNING%'
ORDER BY start_time,row_level,recid;
