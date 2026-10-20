-- Objetivo: Consultar timezone de banco, sessao e arquivo de timezone
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$TIMEZONE_FILE e DUAL.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar character set e NLS.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Nao altera DBTIMEZONE nem inicia upgrade de timezone; timezone do SO e configuracao separada.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT DBTIMEZONE AS timezone_banco,SESSIONTIMEZONE AS timezone_sessao FROM dual;
SELECT filename,version,con_id FROM v$timezone_file ORDER BY con_id;
