-- Objetivo: Consultar configuracao de politicas de auditoria unificada
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de AUDIT_UNIFIED_POLICIES, AUDIT_UNIFIED_ENABLED_POLICIES.
-- Parametros bind: p_nome opcional (politica)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Configurar auditoria unificada.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Somente configuracao no container; nao le, expurga ou publica eventos de auditoria.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT policy_name,audit_option,audit_option_type,object_schema,object_name
FROM audit_unified_policies WHERE :p_nome IS NULL OR policy_name=:p_nome
ORDER BY policy_name,audit_option;
SELECT policy_name,enabled_option,entity_name,entity_type,success,failure
FROM audit_unified_enabled_policies WHERE :p_nome IS NULL OR policy_name=:p_nome
ORDER BY policy_name,entity_name;
