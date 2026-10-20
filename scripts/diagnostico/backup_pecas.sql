-- Objetivo: Consultar pecas de backup registradas no periodo
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$BACKUP_PIECE.
-- Parametros bind: p_dias (1 a 31)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Automatizar backups RMAN.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: CDB$ROOT/non-CDB; HANDLE pode identificar caminhos. Catalogo nao comprova existencia fisica ou restaurabilidade.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_dias IS NULL OR :p_dias<1 OR :p_dias>31 THEN
    RAISE_APPLICATION_ERROR(-20040,'p_dias deve estar entre 1 e 31.');
  END IF;
END;
/

SELECT recid,set_stamp,set_count,piece#,copy#,device_type,status,deleted,
       start_time,completion_time,ROUND(bytes/1048576,3) AS mib,handle
FROM v$backup_piece WHERE completion_time>=SYSDATE-:p_dias
ORDER BY completion_time DESC,set_stamp,set_count,piece#,copy#;
