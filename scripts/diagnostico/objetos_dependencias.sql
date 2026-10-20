-- Objetivo: Consultar dependencias diretas de um objeto
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_DEPENDENCIES.
-- Parametros bind: p_owner; p_nome obrigatorio
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar objetos invalidos.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Nao percorre transitivamente nem resolve dependencias presentes somente em SQL dinamico.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_nome IS NULL THEN RAISE_APPLICATION_ERROR(-20043,'Informar p_nome do objeto.'); END IF;
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,name,type,referenced_owner,referenced_name,referenced_type,referenced_link_name,dependency_type
FROM dba_dependencies WHERE owner=:p_owner AND name=:p_nome
ORDER BY type,referenced_owner,referenced_name;
