-- Objetivo: Preservar e coletar estatisticas de uma tabela propria
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$DATABASE, V$PDBS, USER_USERS, USER_TABLES, USER_EXTERNAL_TABLES, USER_TAB_STATISTICS, USER_TAB_PENDING_STATS; EXECUTE DBMS_STATS/DBMS_ASSERT; repositorio proprio; API/DDL indicado no corpo.
-- Parametros bind: p_owner; p_dbid_esperado; p_container_esperado; p_confirmacao=COLETAR_STATS; p_nome; p_stat_table; p_statid (novo)
-- Efeito: ALTERA o alvo; leia pre-condicoes e retorno no indice.
-- Tutorial: ../../Gerenciar estatisticas com DBMS_STATS.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_STATS.html
-- Revisao: 23/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Pode gerar I/O e mudar planos. Backup e coleta nao sao uma transacao atomica; retorne com IMPORT, nunca ROLLBACK.
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
  l_locked VARCHAR2(30);
BEGIN
  :p_confirmacao := NULL;
  IF l_confirmacao IS NULL OR l_confirmacao <> 'COLETAR_STATS' THEN
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

  IF :p_stat_table IS NULL OR NOT REGEXP_LIKE(:p_stat_table,'^[A-Z][A-Z0-9_$#]{0,127}$','c')
     OR :p_statid IS NULL OR NOT REGEXP_LIKE(:p_statid,'^[A-Z][A-Z0-9_]{0,29}$','c')
     OR :p_nome=:p_stat_table THEN
    RAISE_APPLICATION_ERROR(-20005,'Informar stat_table separada e statid unico de ate 30 caracteres.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM user_tables WHERE table_name=:p_stat_table
    AND temporary='N' AND partitioned='NO';
  IF l_count<>1 THEN RAISE_APPLICATION_ERROR(-20006,'Stat_table inexistente/incompativel; criar pela API.'); END IF;
  SELECT COUNT(*) INTO l_count FROM user_tables t WHERE t.table_name=:p_nome
    AND t.temporary='N' AND t.partitioned='NO' AND t.nested='NO'
    AND NOT EXISTS (SELECT 1 FROM user_external_tables e WHERE e.table_name=t.table_name);
  IF l_count<>1 THEN RAISE_APPLICATION_ERROR(-20007,'Escopo: uma tabela propria, permanente, nao particionada e nao externa.'); END IF;
  SELECT stattype_locked INTO l_locked FROM user_tab_statistics
    WHERE table_name=:p_nome AND object_type='TABLE';
  IF l_locked IS NOT NULL THEN RAISE_APPLICATION_ERROR(-20008,'Estatisticas bloqueadas; nao desbloquear automaticamente.'); END IF;

  IF NVL(UPPER(DBMS_STATS.GET_PREFS('PUBLISH',:p_owner,:p_nome)),'?')<>'TRUE' THEN
    RAISE_APPLICATION_ERROR(-20021,'Fluxo limitado a estatisticas publicadas; PUBLISH deve ser TRUE.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM user_tab_pending_stats WHERE table_name=:p_nome;
  IF l_count<>0 THEN RAISE_APPLICATION_ERROR(-20022,'Ha estatisticas pendentes; preservar e tratar em fluxo separado.'); END IF;
  IF NVL(UPPER(DBMS_STATS.GET_PREFS('PREFERENCE_OVERRIDES_PARAMETER',:p_owner,:p_nome)),'?')<>'FALSE' THEN
    RAISE_APPLICATION_ERROR(-20023,'Preferencias podem substituir os parametros da coleta; nenhuma preferencia sera alterada.');
  END IF;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||DBMS_ASSERT.ENQUOTE_NAME(:p_stat_table,FALSE)||' WHERE statid=:id'
    INTO l_count USING :p_statid;

  IF l_count<>0 THEN RAISE_APPLICATION_ERROR(-20010,'Statid ja existe; escolha outro.'); END IF;
  SELECT COUNT(*) INTO l_count FROM user_tab_statistics WHERE table_name=:p_nome
    AND object_type='TABLE' AND last_analyzed IS NOT NULL;
  IF l_count<>1 THEN RAISE_APPLICATION_ERROR(-20011,'Escopo exige estatisticas anteriores para preservar.'); END IF;

  DBMS_STATS.EXPORT_TABLE_STATS(ownname=>:p_owner,tabname=>:p_nome,
    stattab=>:p_stat_table,statid=>:p_statid,statown=>:p_owner,cascade=>TRUE);

  DBMS_STATS.GATHER_TABLE_STATS(ownname=>:p_owner,tabname=>:p_nome,
    estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE,degree=>1,
    cascade=>TRUE,no_invalidate=>DBMS_STATS.AUTO_INVALIDATE);
END;
/
