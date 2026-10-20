-- Objetivo: Relacionar segmentos temporarios a sessoes
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de GV$TEMPSEG_USAGE, GV$SESSION, DBA_TABLESPACES.
-- Parametros bind: p_owner (usuario)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar TEMP e UNDO.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Espaco por segmento em uso; nao equivale ao tamanho total dos tempfiles.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT u.inst_id, u.con_id, s.sid, s.serial#, u.username, u.tablespace,
       u.segtype, u.sql_id, SUM(u.blocks) AS blocos, t.block_size,
       ROUND(SUM(u.blocks)*t.block_size/1048576,3) AS temp_mib
FROM gv$tempseg_usage u
LEFT JOIN gv$session s ON s.inst_id=u.inst_id AND s.con_id=u.con_id
 AND s.saddr=u.session_addr AND s.serial#=u.session_num
JOIN dba_tablespaces t ON t.tablespace_name=u.tablespace
WHERE u.username=:p_owner AND u.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
GROUP BY u.inst_id,u.con_id,s.sid,s.serial#,u.username,u.tablespace,u.segtype,u.sql_id,t.block_size
ORDER BY temp_mib DESC;
