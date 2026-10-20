-- Objetivo: Consultar indices e particoes indisponiveis
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_INDEXES, DBA_IND_PARTITIONS, DBA_IND_SUBPARTITIONS.
-- Parametros bind: p_owner; p_nome opcional (tabela)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Administrar indices e constraints.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Status N/A no indice particionado nao indica saude de suas particoes; nao reconstrui indices.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,index_name,table_owner,table_name,index_type,partitioned,status,visibility
FROM dba_indexes WHERE table_owner=:p_owner AND (:p_nome IS NULL OR table_name=:p_nome)
ORDER BY table_name,index_name;
SELECT p.index_owner,p.index_name,p.partition_name,p.status
FROM dba_ind_partitions p JOIN dba_indexes i ON i.owner=p.index_owner AND i.index_name=p.index_name
WHERE i.table_owner=:p_owner AND (:p_nome IS NULL OR i.table_name=:p_nome) AND p.status='UNUSABLE'
ORDER BY p.index_name,p.partition_position;
SELECT p.index_owner,p.index_name,p.partition_name,p.subpartition_name,p.status
FROM dba_ind_subpartitions p JOIN dba_indexes i ON i.owner=p.index_owner AND i.index_name=p.index_name
WHERE i.table_owner=:p_owner AND (:p_nome IS NULL OR i.table_name=:p_nome) AND p.status='UNUSABLE'
ORDER BY p.index_name,p.partition_name,p.subpartition_position;
