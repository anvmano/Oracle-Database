-- Objetivo: Confirmar identidade, papel, abertura e container
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$DATABASE, V$INSTANCE, V$VERSION.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Arquitetura e componentes do Oracle.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: DBID e container devem ser conferidos antes de qualquer manutencao.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT d.dbid, d.name, d.db_unique_name, d.database_role, d.open_mode,
       i.instance_name, i.instance_number, i.host_name, i.startup_time,
       SYS_CONTEXT('USERENV','CON_NAME') AS container,
       SYS_CONTEXT('USERENV','SESSION_USER') AS usuario
FROM v$database d CROSS JOIN v$instance i;
SELECT banner_full FROM v$version;
