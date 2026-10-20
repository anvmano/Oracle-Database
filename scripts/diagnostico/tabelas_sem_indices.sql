-- Objetivo: Localizar tabelas sem indices registrados
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_TABLES, DBA_INDEXES.
-- Parametros bind: p_owner
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Administrar indices e constraints.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Nao classifica necessidade de indice nem custo de criacao.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT t.owner,t.table_name,t.temporary,t.partitioned
FROM dba_tables t
WHERE t.owner=:p_owner AND NOT EXISTS (
  SELECT 1 FROM dba_indexes i WHERE i.table_owner=t.owner AND i.table_name=t.table_name
)
ORDER BY t.table_name;
