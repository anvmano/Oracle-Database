-- Objetivo: Identificar estatisticas ausentes, stale ou bloqueadas
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_TAB_STATISTICS.
-- Parametros bind: p_owner; p_nome opcional
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Gerenciar estatisticas com DBMS_STATS.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Stale e metadado estimado; nao coletar todas as tabelas automaticamente.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,table_name,partition_name,subpartition_name,object_type,
       num_rows,sample_size,last_analyzed,stale_stats,stattype_locked
FROM dba_tab_statistics WHERE owner=:p_owner
 AND (:p_nome IS NULL OR table_name=:p_nome)
 AND (last_analyzed IS NULL OR stale_stats='YES' OR stattype_locked IS NOT NULL)
ORDER BY table_name,object_type,partition_name,subpartition_name;
