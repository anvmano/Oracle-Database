-- Objetivo: Relacionar espera e bloqueador entre instancias
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de GV$SESSION.
-- Parametros bind: p_owner (usuario da sessao em espera)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar sessoes e bloqueios.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Fotografia de views dinamicas; confirme novamente SID, SERIAL e usuario antes de agir.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT w.inst_id AS espera_inst, w.sid AS espera_sid, w.serial# AS espera_serial,
       w.username AS espera_usuario, w.event, w.seconds_in_wait,
       w.blocking_instance, w.blocking_session,
       b.serial# AS bloqueador_serial, b.username AS bloqueador_usuario,
       b.con_id AS bloqueador_con_id, b.sql_id AS bloqueador_sql_id
FROM gv$session w LEFT JOIN gv$session b
  ON b.inst_id = w.blocking_instance AND b.sid = w.blocking_session
WHERE w.blocking_session_status = 'VALID' AND w.username = :p_owner
  AND w.con_id = TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
ORDER BY w.seconds_in_wait DESC, w.inst_id, w.sid;
