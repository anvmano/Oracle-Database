-- Objetivo: Medir UNDO por transacao com tamanho de bloco real
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de GV$TRANSACTION, GV$SESSION, GV$DATAFILE.
-- Parametros bind: p_owner (usuario)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar TEMP e UNDO.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Se o arquivo nao puder ser resolvido, MiB fica NULL; nao assumir 8192 bytes.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT s.inst_id, s.con_id, s.sid, s.serial#, s.username, t.start_date,
       t.used_ublk, t.used_urec, f.block_size,
       ROUND(t.used_ublk*f.block_size/1048576,3) AS undo_mib
FROM gv$transaction t
JOIN gv$session s ON s.inst_id=t.inst_id AND s.con_id=t.con_id AND s.taddr=t.addr
LEFT JOIN gv$datafile f ON f.inst_id=t.inst_id AND f.con_id=t.con_id AND f.file#=t.ubafil
WHERE s.username=:p_owner AND s.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
ORDER BY undo_mib DESC NULLS LAST, s.inst_id, s.sid;
