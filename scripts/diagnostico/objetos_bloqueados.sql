-- Objetivo: Relacionar locks de objetos a sessoes
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de GV$LOCKED_OBJECT, GV$SESSION, DBA_OBJECTS.
-- Parametros bind: p_owner (dono do objeto)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar sessoes e bloqueios.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Lock existente nao significa bloqueio entre sessoes; correlacione bloqueadores.sql.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT l.inst_id, l.con_id, l.session_id AS sid, s.serial#, s.username,
       o.owner, o.object_name, o.subobject_name, o.object_type, l.locked_mode
FROM gv$locked_object l
JOIN gv$session s ON s.inst_id = l.inst_id AND s.sid = l.session_id AND s.con_id = l.con_id
JOIN dba_objects o ON o.object_id = l.object_id
WHERE l.con_id = TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID')) AND o.owner = :p_owner
ORDER BY l.inst_id, l.session_id, o.object_name;
