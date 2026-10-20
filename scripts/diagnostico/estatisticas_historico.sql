-- Objetivo: Consultar datas do historico de estatisticas por tabela
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_TAB_STATS_HISTORY.
-- Parametros bind: p_owner; p_nome opcional (tabela); p_dias (1 a 31)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Gerenciar estatisticas com DBMS_STATS.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Historico depende da retencao; nao restaura estatisticas e nao substitui o repositorio exportado.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_dias IS NULL OR :p_dias<1 OR :p_dias>31 THEN
    RAISE_APPLICATION_ERROR(-20040,'p_dias deve estar entre 1 e 31.');
  END IF;
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,table_name,partition_name,subpartition_name,stats_update_time
FROM dba_tab_stats_history WHERE owner=:p_owner AND (:p_nome IS NULL OR table_name=:p_nome)
 AND stats_update_time>=SYSTIMESTAMP-NUMTODSINTERVAL(:p_dias,'DAY')
ORDER BY stats_update_time DESC,table_name,partition_name,subpartition_name;
