-- Objetivo: Consultar objetos presentes na lixeira
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_RECYCLEBIN.
-- Parametros bind: p_owner
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Flashback e restore points.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: SPACE esta em blocos; nao realiza PURGE ou FLASHBACK e nao garante recuperacao de todos os dependentes.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,object_name,original_name,type,ts_name,droptime,can_undrop,can_purge,space AS blocos
FROM dba_recyclebin WHERE owner=:p_owner ORDER BY droptime DESC,original_name;
