-- Objetivo: Consultar destinos de sinonimos
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_SYNONYMS.
-- Parametros bind: p_owner; p_nome opcional (sinonimo)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Administrar database links e sinonimos.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Para sinonimos publicos use p_owner=PUBLIC; nao resolve cadeias nem verifica acesso ao destino.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,synonym_name,table_owner,table_name,db_link
FROM dba_synonyms WHERE owner=:p_owner AND (:p_nome IS NULL OR synonym_name=:p_nome)
ORDER BY synonym_name;
