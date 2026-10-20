-- Objetivo: Relacionar colunas de FKs as chaves referenciadas
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_CONSTRAINTS, DBA_CONS_COLUMNS.
-- Parametros bind: p_owner; p_nome opcional (tabela filha)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Administrar indices e constraints.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Para estudar cobertura de FKs, compare com indices_colunas.sql; nao gera CREATE INDEX automaticamente.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT f.owner,f.table_name,f.constraint_name,f.status,f.validated,
       c.position,c.column_name,r.owner AS referencia_owner,r.table_name AS referencia_tabela,
       r.constraint_name AS referencia_constraint,rc.column_name AS referencia_coluna
FROM dba_constraints f
JOIN dba_cons_columns c ON c.owner=f.owner AND c.constraint_name=f.constraint_name
JOIN dba_constraints r ON r.owner=f.r_owner AND r.constraint_name=f.r_constraint_name
JOIN dba_cons_columns rc ON rc.owner=r.owner AND rc.constraint_name=r.constraint_name AND rc.position=c.position
WHERE f.constraint_type='R' AND f.owner=:p_owner AND (:p_nome IS NULL OR f.table_name=:p_nome)
ORDER BY f.table_name,f.constraint_name,c.position;
