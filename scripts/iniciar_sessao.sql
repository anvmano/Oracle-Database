-- Objetivo: preparar parametros bind em sessao dedicada; nao conecta nem altera objetos.
-- Ambiente: Oracle/SQL*Plus 19c; executar novamente APAGA parametros anteriores.
-- Efeito: configura cliente; erros SQL/SO encerram cliente com falha e ROLLBACK.
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
SET SERVEROUTPUT ON SIZE UNLIMITED
SET PAGESIZE 100
SET LINESIZE 220
SET TRIMSPOOL ON
SET SQLBLANKLINES ON
VARIABLE p_owner VARCHAR2(128)
VARIABLE p_nome VARCHAR2(128)
VARIABLE p_tipo VARCHAR2(30)
VARIABLE p_sql_id VARCHAR2(13)
VARIABLE p_spid VARCHAR2(24)
VARIABLE p_sid NUMBER
VARIABLE p_serial NUMBER
VARIABLE p_instancia_esperada NUMBER
VARIABLE p_usuario_alvo VARCHAR2(128)
VARIABLE p_dias NUMBER
VARIABLE p_dbid_esperado NUMBER
VARIABLE p_container_esperado VARCHAR2(128)
VARIABLE p_confirmacao VARCHAR2(40)
VARIABLE p_stat_table VARCHAR2(128)
VARIABLE p_statid VARCHAR2(30)
VARIABLE p_acao VARCHAR2(10)
BEGIN
  :p_owner:=SYS_CONTEXT('USERENV','SESSION_USER');
  :p_nome:=NULL; :p_tipo:=NULL; :p_sql_id:=NULL; :p_spid:=NULL;
  :p_sid:=NULL; :p_serial:=NULL; :p_instancia_esperada:=NULL; :p_usuario_alvo:=NULL; :p_dias:=1;
  :p_dbid_esperado:=NULL; :p_container_esperado:=NULL; :p_confirmacao:=NULL;
  :p_stat_table:=NULL; :p_statid:=NULL; :p_acao:=NULL;
END;
/
SELECT SYS_CONTEXT('USERENV','DB_NAME') AS banco,
       SYS_CONTEXT('USERENV','CON_NAME') AS container,
       SYS_CONTEXT('USERENV','SESSION_USER') AS usuario
FROM dual;
