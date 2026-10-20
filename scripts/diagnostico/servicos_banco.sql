-- Objetivo: Consultar servicos registrados no container
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_SERVICES.
-- Parametros bind: p_nome opcional (NAME)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Configurar listener e conexões Oracle Net.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Metadados de servico nao substituem listener/SRVCTL nem comprovam conectividade do cliente.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT name,network_name,pdb,creation_date
FROM dba_services WHERE :p_nome IS NULL OR name=:p_nome ORDER BY name;
