-- Objetivo: Consultar quotas de tablespace de um usuario
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_TS_QUOTAS.
-- Parametros bind: p_owner (usuario)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar capacidade e crescimento do banco.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Quota nao representa espaco livre fisico; privilegio UNLIMITED TABLESPACE deve ser examinado separadamente.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT username,tablespace_name,ROUND(bytes/1048576,3) AS usado_mib,
       CASE WHEN max_bytes=-1 THEN 'UNLIMITED' ELSE TO_CHAR(ROUND(max_bytes/1048576,3)) END AS limite_mib,
       blocks,max_blocks
FROM dba_ts_quotas WHERE username=:p_owner ORDER BY tablespace_name;
