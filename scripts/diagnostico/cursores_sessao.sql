-- Objetivo: Contar entradas de cursores por sessao e tipo
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de GV$OPEN_CURSOR, GV$SESSION.
-- Parametros bind: p_owner (usuario)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar sessoes e bloqueios.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: OPEN_CURSOR inclui cursores em cache; entradas nao equivalem somente aos cursores abertos.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT s.inst_id,s.con_id,s.sid,s.serial#,s.username,c.cursor_type,
       COUNT(*) AS entradas,COUNT(DISTINCT c.sql_id) AS sql_ids_distintos
FROM gv$open_cursor c JOIN gv$session s
 ON s.inst_id=c.inst_id AND s.con_id=c.con_id AND s.sid=c.sid
WHERE s.username=:p_owner AND s.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
GROUP BY s.inst_id,s.con_id,s.sid,s.serial#,s.username,c.cursor_type
ORDER BY entradas DESC,s.inst_id,s.sid,c.cursor_type;
