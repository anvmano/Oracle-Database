-- Objetivo: Consultar metadados de database links sem senhas
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_DB_LINKS.
-- Parametros bind: p_owner; p_nome opcional (DB_LINK exato)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Administrar database links e sinonimos.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Nao abre links nem consulta tabelas remotas; HOST e usuario remoto podem identificar o ambiente.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,db_link,username,host,created
FROM dba_db_links WHERE owner=:p_owner AND (:p_nome IS NULL OR db_link=:p_nome)
ORDER BY db_link;
