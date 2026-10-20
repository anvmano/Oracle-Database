-- Objetivo: Solicitar encerramento de uma sessao local identificada
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$DATABASE, V$PDBS, USER_USERS, V$SESSION, V$INSTANCE, DBA_USERS; ALTER SYSTEM; EXECUTE DBMS_ASSERT; API/DDL indicado no corpo.
-- Parametros bind: p_owner; p_dbid_esperado; p_container_esperado; p_confirmacao=ENCERRAR; p_sid; p_serial; p_usuario_alvo; p_instancia_esperada (numero)
-- Efeito: ALTERA o alvo; leia pre-condicoes e retorno no indice.
-- Tutorial: ../../Monitorar sessoes e bloqueios.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Somente instancia local; sem IMMEDIATE/FORCE. Rollback pode demorar; reconexao exige acao da aplicacao.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

DECLARE
  l_confirmacao VARCHAR2(40) := :p_confirmacao;
  l_dbid NUMBER;
  l_role VARCHAR2(30);
  l_open VARCHAR2(30);
  l_mantido VARCHAR2(1);
  l_comum VARCHAR2(3);
  l_pdb_open VARCHAR2(30);
  l_count NUMBER;
  l_usuario VARCHAR2(128);
  l_instancia NUMBER;
BEGIN
  :p_confirmacao := NULL;
  IF l_confirmacao IS NULL OR l_confirmacao <> 'ENCERRAR' THEN
    RAISE_APPLICATION_ERROR(-20001,'Confirmacao ausente/incorreta; releia o indice.');
  END IF;
  SELECT dbid,database_role,open_mode INTO l_dbid,l_role,l_open FROM v$database;
  IF :p_dbid_esperado IS NULL OR :p_dbid_esperado<>l_dbid
     OR :p_container_esperado IS NULL
     OR :p_container_esperado<>SYS_CONTEXT('USERENV','CON_NAME')
     OR SYS_CONTEXT('USERENV','CON_NAME') IN ('CDB$ROOT','PDB$SEED')
     OR l_role<>'PRIMARY' OR l_open<>'READ WRITE' THEN
    RAISE_APPLICATION_ERROR(-20002,'Banco/container/papel/abertura divergente.');
  END IF;
  IF TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))>1 THEN
    SELECT open_mode INTO l_pdb_open FROM v$pdbs
      WHERE con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'));
    IF l_pdb_open<>'READ WRITE' THEN RAISE_APPLICATION_ERROR(-20002,'PDB nao esta READ WRITE.'); END IF;
  END IF;
  SELECT oracle_maintained,common INTO l_mantido,l_comum FROM user_users;
  IF l_mantido<>'N' OR l_comum<>'NO' OR :p_owner IS NULL
     OR :p_owner<>SYS_CONTEXT('USERENV','SESSION_USER')
     OR :p_owner<>SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
     OR NOT REGEXP_LIKE(:p_owner,'^[A-Z][A-Z0-9_$#]{0,127}$','c') THEN
    RAISE_APPLICATION_ERROR(-20003,'Conectar com dono local nao mantido pela Oracle, nome convencional.');
  END IF;
  SELECT instance_number INTO l_instancia FROM v$instance;
  IF :p_instancia_esperada IS NULL OR :p_instancia_esperada<>l_instancia THEN
    RAISE_APPLICATION_ERROR(-20016,'Instancia local divergente da instancia do alvo.');
  END IF;
  IF :p_sid IS NULL OR :p_serial IS NULL OR :p_sid<1 OR :p_serial<1
     OR :p_sid<>TRUNC(:p_sid) OR :p_serial<>TRUNC(:p_serial)
     OR :p_sid=TO_NUMBER(SYS_CONTEXT('USERENV','SID'))
     OR :p_usuario_alvo IS NULL THEN
    RAISE_APPLICATION_ERROR(-20016,'SID/SERIAL/usuario invalidos ou propria sessao.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM v$session s JOIN dba_users u ON u.username=s.username
    WHERE s.sid=:p_sid AND s.serial#=:p_serial AND s.username=:p_usuario_alvo
      AND s.type='USER' AND s.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
      AND u.oracle_maintained='N' AND u.common='NO' AND s.status<>'KILLED';
  IF l_count<>1 THEN RAISE_APPLICATION_ERROR(-20017,'Sessao divergente, protegida ou ja encerrada.'); END IF;
  l_usuario:=TO_CHAR(:p_sid,'FM9999999990')||','||TO_CHAR(:p_serial,'FM9999999990');
  EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '||DBMS_ASSERT.ENQUOTE_LITERAL(l_usuario);
END;
/
