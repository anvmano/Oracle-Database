-- Objetivo: Consultar operacoes de redimensionamento da SGA
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$SGA_RESIZE_OPS.
-- Parametros bind: p_dias (1 a 31)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar memoria SGA e PGA.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Historico limitado na memoria da instancia; nao substitui serie temporal persistente.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_dias IS NULL OR :p_dias<1 OR :p_dias>31 THEN
    RAISE_APPLICATION_ERROR(-20040,'p_dias deve estar entre 1 e 31.');
  END IF;
END;
/

SELECT component,oper_type,oper_mode,parameter,status,start_time,end_time,
       ROUND(initial_size/1048576,3) AS inicial_mib,
       ROUND(target_size/1048576,3) AS alvo_mib,
       ROUND(final_size/1048576,3) AS final_mib,con_id
FROM v$sga_resize_ops WHERE start_time>=SYSDATE-:p_dias
ORDER BY start_time DESC,component;
