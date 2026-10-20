-- Objetivo: Consultar erros e avisos do ADR no periodo
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$DIAG_ALERT_EXT.
-- Parametros bind: p_dias (1 a 31)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar erros com ADRCI e alert log.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: ADR local, pode haver custo/volume elevado; tipos 2/3/4: incidente/erro/aviso; ausencia nao prova saude.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_dias IS NULL OR :p_dias<1 OR :p_dias>31 THEN
    RAISE_APPLICATION_ERROR(-20040,'p_dias deve estar entre 1 e 31.');
  END IF;
END;
/

SELECT originating_timestamp,message_type,message_level,message_text
FROM v$diag_alert_ext
WHERE originating_timestamp>=SYSTIMESTAMP-NUMTODSINTERVAL(:p_dias,'DAY')
  AND :p_dias BETWEEN 1 AND 31 AND message_type IN (2,3,4)
ORDER BY originating_timestamp DESC;
