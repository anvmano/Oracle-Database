-- Objetivo: Consultar contadores de I/O por sessao
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de GV$SESS_IO, GV$SESSION.
-- Parametros bind: p_owner
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar sessoes e bloqueios.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Fotografia acumulada; SID pode ser reutilizado entre amostras, preserve SERIAL#.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT s.inst_id,s.con_id,s.sid,s.serial#,s.username,i.block_gets,i.consistent_gets,
       i.physical_reads,i.block_changes,i.consistent_changes
FROM gv$sess_io i JOIN gv$session s
 ON s.inst_id=i.inst_id AND s.sid=i.sid AND s.con_id=i.con_id
WHERE s.username=:p_owner AND s.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
ORDER BY i.physical_reads DESC,s.inst_id,s.sid;
