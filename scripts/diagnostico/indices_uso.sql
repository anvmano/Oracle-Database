-- Objetivo: Consultar registros de monitoramento de indices
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_OBJECT_USAGE.
-- Parametros bind: p_owner; p_nome opcional (tabela)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Administrar indices e constraints.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Nao inicia monitoramento. USED=NO ou ausencia de registro nao justificam remover um indice.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,index_name,table_name,monitoring,used,start_monitoring,end_monitoring
FROM dba_object_usage WHERE owner=:p_owner AND (:p_nome IS NULL OR table_name=:p_nome)
ORDER BY table_name,index_name;
