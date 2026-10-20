-- Objetivo: Consultar estado e validacao de constraints
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_CONSTRAINTS.
-- Parametros bind: p_owner; p_nome opcional (tabela)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Administrar indices e constraints.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: ENABLED e VALIDATED sao propriedades diferentes; a consulta nao altera nenhuma delas.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,table_name,constraint_name,constraint_type,status,validated,
       deferrable,deferred,rely,r_owner,r_constraint_name,delete_rule,index_owner,index_name
FROM dba_constraints WHERE owner=:p_owner AND (:p_nome IS NULL OR table_name=:p_nome)
ORDER BY table_name,constraint_type,constraint_name;
