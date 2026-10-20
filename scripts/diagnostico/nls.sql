-- Objetivo: Comparar NLS de banco, instancia e sessao
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de NLS_DATABASE_PARAMETERS, NLS_INSTANCE_PARAMETERS, NLS_SESSION_PARAMETERS.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar character set e NLS.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT 'DATABASE' AS origem,parameter,value FROM nls_database_parameters
UNION ALL SELECT 'INSTANCE',parameter,value FROM nls_instance_parameters
UNION ALL SELECT 'SESSION',parameter,value FROM nls_session_parameters
ORDER BY parameter,origem;
