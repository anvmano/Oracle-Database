-- Objetivo: Consultar colunas e ordem dos indices
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_INDEXES, DBA_IND_COLUMNS.
-- Parametros bind: p_owner; p_nome opcional (tabela)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Administrar indices e constraints.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Colunas SYS_NC em indices por funcao precisam ser relacionadas as expressoes; nao presumir duplicidade so pelo nome.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT i.owner,i.index_name,i.table_owner,i.table_name,i.index_type,i.uniqueness,
       i.partitioned,i.status,c.column_position,c.column_name,c.descend
FROM dba_indexes i JOIN dba_ind_columns c ON c.index_owner=i.owner AND c.index_name=i.index_name
WHERE i.table_owner=:p_owner AND (:p_nome IS NULL OR i.table_name=:p_nome)
ORDER BY i.table_name,i.index_name,c.column_position;
