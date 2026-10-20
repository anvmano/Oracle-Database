-- Objetivo: Consultar entradas de ACL de rede para um principal
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_HOST_ACES.
-- Parametros bind: p_owner (principal exato)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Configurar ACLs de rede no Oracle.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Concessoes herdadas de roles e precedencia precisam ser consideradas; nao testa conexoes nem modifica ACLs.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT host,lower_port,upper_port,ace_order,principal,principal_type,privilege,
       grant_type,inverted_principal,start_date,end_date
FROM dba_host_aces WHERE principal=:p_owner ORDER BY host,lower_port,upper_port,ace_order;
