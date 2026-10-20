-- Objetivo: Criar repositorio de estatisticas no proprio schema
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$DATABASE, V$PDBS, USER_USERS, USER_OBJECTS; EXECUTE em DBMS_STATS; CREATE TABLE e quota; API/DDL indicado no corpo.
-- Parametros bind: p_owner; p_dbid_esperado; p_container_esperado; p_confirmacao=CRIAR_STAT_TABLE; p_nome (novo repositorio)
-- Efeito: ALTERA o alvo; leia pre-condicoes e retorno no indice.
-- Tutorial: ../../Gerenciar estatisticas com DBMS_STATS.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_STATS.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: DDL pode confirmar transacoes; repositorio ocupa quota. Nao ha DROP automatico.
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
BEGIN
  :p_confirmacao := NULL;
  IF l_confirmacao IS NULL OR l_confirmacao <> 'CRIAR_STAT_TABLE' THEN
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

  SELECT COUNT(*) INTO l_count FROM user_objects WHERE object_name=:p_nome;
  IF l_count<>0 THEN RAISE_APPLICATION_ERROR(-20009,'Nome ja existe; nao reutilizar nem remover automaticamente.'); END IF;
  DBMS_STATS.CREATE_STAT_TABLE(ownname=>:p_owner,stattab=>:p_nome);
END;
/
