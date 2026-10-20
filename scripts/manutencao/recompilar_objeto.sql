-- Objetivo: Recompilar um objeto proprio por tipo permitido
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$DATABASE, V$PDBS, USER_USERS, USER_OBJECTS, USER_ERRORS; EXECUTE DBMS_ASSERT; direito de compilar objeto proprio; API/DDL indicado no corpo.
-- Parametros bind: p_owner; p_dbid_esperado; p_container_esperado; p_confirmacao=RECOMPILAR; p_nome; p_tipo (PROCEDURE/FUNCTION/VIEW/PACKAGE/PACKAGE BODY/TRIGGER)
-- Efeito: ALTERA o alvo; leia pre-condicoes e retorno no indice.
-- Tutorial: ../../Diagnosticar objetos invalidos.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: DDL confirma transacoes e pode invalidar dependentes; nao recompila schema inteiro nem mascara falha.
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
  l_ddl VARCHAR2(1000);
BEGIN
  :p_confirmacao := NULL;
  IF l_confirmacao IS NULL OR l_confirmacao <> 'RECOMPILAR' THEN
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
  IF :p_nome IS NULL OR NOT REGEXP_LIKE(:p_nome,'^[A-Z][A-Z0-9_$#]{0,127}$','c') THEN
    RAISE_APPLICATION_ERROR(-20004,'p_nome deve ser identificador convencional em maiusculas.');
  END IF;

  IF :p_tipo IS NULL OR :p_tipo NOT IN ('PROCEDURE','FUNCTION','VIEW','PACKAGE','PACKAGE BODY','TRIGGER') THEN
    RAISE_APPLICATION_ERROR(-20013,'Tipo de objeto fora do escopo.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM user_objects WHERE object_name=:p_nome AND object_type=:p_tipo;
  IF l_count<>1 THEN RAISE_APPLICATION_ERROR(-20014,'Objeto/tipo nao encontrado unicamente.'); END IF;
  IF :p_tipo='PACKAGE BODY' THEN
    l_ddl:='ALTER PACKAGE '||DBMS_ASSERT.ENQUOTE_NAME(:p_nome,FALSE)||' COMPILE BODY';
  ELSIF :p_tipo='PACKAGE' THEN
    l_ddl:='ALTER PACKAGE '||DBMS_ASSERT.ENQUOTE_NAME(:p_nome,FALSE)||' COMPILE SPECIFICATION';
  ELSE
    l_ddl:='ALTER '||:p_tipo||' '||DBMS_ASSERT.ENQUOTE_NAME(:p_nome,FALSE)||' COMPILE';
  END IF;
  EXECUTE IMMEDIATE l_ddl;
  SELECT COUNT(*) INTO l_count FROM user_objects WHERE object_name=:p_nome AND object_type=:p_tipo AND status='VALID';
  IF l_count<>1 THEN RAISE_APPLICATION_ERROR(-20015,'Objeto continua invalido; consultar erros.'); END IF;
  SELECT COUNT(*) INTO l_count FROM user_errors WHERE name=:p_nome AND type=:p_tipo AND attribute='ERROR';
  IF l_count<>0 THEN RAISE_APPLICATION_ERROR(-20015,'Erros de compilacao persistem.'); END IF;
END;
/
