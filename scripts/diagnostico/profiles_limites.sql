-- Objetivo: Consultar limites configurados em profiles
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_PROFILES.
-- Parametros bind: p_nome opcional (profile)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../User _ Profile _ Roles _ Grants.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: DEFAULT e UNLIMITED sao valores textuais; limites KERNEL dependem de RESOURCE_LIMIT. Nao altera senhas ou profiles.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT profile,resource_name,resource_type,limit
FROM dba_profiles WHERE :p_nome IS NULL OR profile=:p_nome ORDER BY profile,resource_type,resource_name;
