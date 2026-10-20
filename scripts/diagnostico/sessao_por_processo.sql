-- Objetivo: Relacionar processo do servidor a sessao
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de GV$SESSION, GV$PROCESS.
-- Parametros bind: p_spid (texto exato)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar sessoes e bloqueios.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: SPID identifica o processo no servidor; nao e o PID do cliente.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_spid IS NULL THEN RAISE_APPLICATION_ERROR(-20042,'Informar p_spid exato.'); END IF;
END;
/

SELECT s.inst_id, s.con_id, p.spid, s.sid, s.serial#, s.username,
       s.program, s.status, s.sql_id
FROM gv$session s JOIN gv$process p
  ON p.inst_id = s.inst_id AND p.addr = s.paddr
WHERE p.spid = :p_spid
  AND s.con_id = TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
ORDER BY s.inst_id, s.sid;
