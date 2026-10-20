-- Objetivo: Listar sessoes ativas e o cursor filho corrente
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de GV$SESSION, GV$SQL.
-- Parametros bind: p_owner (usuario exato)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar sessoes e bloqueios.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Texto SQL pode conter dados sensiveis; nao publicar a saida.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT s.inst_id, s.con_id, s.sid, s.serial#, s.username, s.service_name,
       s.status, s.event, s.wait_class, s.sql_id, s.sql_child_number,
       q.plan_hash_value, SUBSTR(q.sql_text,1,300) AS sql_text
FROM gv$session s
LEFT JOIN gv$sql q ON q.inst_id = s.inst_id AND q.con_id = s.con_id
 AND q.sql_id = s.sql_id AND q.child_number = s.sql_child_number
WHERE s.type = 'USER' AND s.status = 'ACTIVE'
  AND s.con_id = TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
  AND s.username = :p_owner
ORDER BY s.inst_id, s.sid;
