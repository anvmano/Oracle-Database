-- Objetivo: Consultar gap bloqueante registrado no standby
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$ARCHIVE_GAP.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Criar standby fisico com Data Guard.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Standby, CDB$ROOT/non-CDB. Ausencia de linha nao comprova sincronismo ou ausencia de lag.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT thread#,low_sequence#,high_sequence#,con_id FROM v$archive_gap ORDER BY thread#,low_sequence#;
