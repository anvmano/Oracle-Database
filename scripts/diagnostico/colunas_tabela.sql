-- Objetivo: Consultar tipos, tamanhos e nulabilidade de colunas
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_TAB_COLUMNS.
-- Parametros bind: p_owner; p_nome obrigatorio (tabela ou view)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Fundamentos de SQL para administracao Oracle.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: DATA_LENGTH esta em bytes; CHAR_LENGTH/CHAR_USED descrevem semantica de caracteres. Nao consulta dados da tabela.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_nome IS NULL THEN RAISE_APPLICATION_ERROR(-20043,'Informar p_nome do objeto.'); END IF;
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,table_name,column_id,column_name,data_type,data_length,char_length,char_used,
       data_precision,data_scale,nullable
FROM dba_tab_columns WHERE owner=:p_owner AND table_name=:p_nome ORDER BY column_id;
