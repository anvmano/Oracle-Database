-- Objetivo: Consultar configuracoes RMAN persistidas
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$RMAN_CONFIGURATION.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Parametros RMAN.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: CDB$ROOT/non-CDB; mostra configuracoes persistidas, nao reproduz todos os defaults de SHOW ALL.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT conf#,name,value FROM v$rman_configuration ORDER BY conf#;
