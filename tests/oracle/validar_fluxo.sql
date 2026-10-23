-- Homologacao MANUAL com alteracoes em APP_LAB, PDB descartavel Oracle 19c.
-- Leia README.md desta pasta. Inicialize binds e informe contexto esperado ANTES.
-- Nao executado pelo teste local; sem limpeza automatica, sem KILL SESSION.
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
DECLARE
  l_dbid NUMBER;
  l_count NUMBER;
  l_mode VARCHAR2(30);
  l_role VARCHAR2(30);
  l_common VARCHAR2(3);
  l_maint VARCHAR2(1);
  l_token VARCHAR2(40):=:p_confirmacao;
BEGIN
  :p_confirmacao:=NULL;
  SELECT dbid,open_mode,database_role INTO l_dbid,l_mode,l_role FROM v$database;
  IF l_token IS NULL OR l_token<>'HOMOLOGAR_BIBLIOTECA'
    OR SYS_CONTEXT('USERENV','SESSION_USER')<>'APP_LAB'
    OR SYS_CONTEXT('USERENV','CURRENT_SCHEMA')<>'APP_LAB'
    OR :p_owner IS NULL OR :p_owner<>'APP_LAB'
    OR :p_dbid_esperado IS NULL OR l_dbid<>:p_dbid_esperado
    OR :p_container_esperado IS NULL
    OR :p_container_esperado<>SYS_CONTEXT('USERENV','CON_NAME')
    OR TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))<2
    OR l_mode<>'READ WRITE' OR l_role<>'PRIMARY' THEN
    RAISE_APPLICATION_ERROR(-20100,'Laboratorio/contexto/confirmacao nao conferidos.');
  END IF;
  SELECT open_mode INTO l_mode FROM v$pdbs WHERE con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'));
  SELECT common,oracle_maintained INTO l_common,l_maint FROM user_users;
  IF l_mode<>'READ WRITE' OR l_common<>'NO' OR l_maint<>'N' THEN
    RAISE_APPLICATION_ERROR(-20100,'PDB/usuario fora do escopo.');
  END IF;
  SELECT COUNT(*) INTO l_count FROM user_objects
    WHERE object_name IN ('T_BIB_TEST','PK_BIB_TEST','T_BIB_IOT','PK_BIB_IOT','CK_BIB_IOT','FK_BIB_IOT','S_BIB_TEST','P_BIB_TEST','J_BIB_TEST');
  IF l_count<>0 THEN RAISE_APPLICATION_ERROR(-20101,'Nomes de teste ocupados; preservar objetos.'); END IF;
  SELECT COUNT(*) INTO l_count FROM user_constraints
    WHERE constraint_name IN ('PK_BIB_TEST','PK_BIB_IOT','CK_BIB_IOT','FK_BIB_IOT');
  IF l_count<>0 THEN RAISE_APPLICATION_ERROR(-20101,'Nomes de constraints de teste ocupados; preservar objetos.'); END IF;
END;
/
CREATE TABLE T_BIB_TEST (n NUMBER);
BEGIN
  :p_nome:='T_BIB_TEST';
END;
/
@@../../scripts/geradores/extrair_constraints_tabela.sql
BEGIN
  IF :ddl_constraints IS NOT NULL OR :ddl_fks IS NOT NULL THEN RAISE_APPLICATION_ERROR(-20107,'Tabela sem constraints deve retornar NULL.'); END IF;
END;
/
ALTER TABLE T_BIB_TEST MODIFY n NOT NULL;
@@../../scripts/geradores/extrair_constraints_tabela.sql
BEGIN
  IF :ddl_constraints IS NOT NULL OR :ddl_fks IS NOT NULL THEN RAISE_APPLICATION_ERROR(-20107,'NOT NULL pertence ao DDL da tabela.'); END IF;
END;
/
ALTER TABLE T_BIB_TEST ADD CONSTRAINT PK_BIB_TEST PRIMARY KEY (n);
CREATE TABLE T_BIB_IOT (n NUMBER CONSTRAINT PK_BIB_IOT PRIMARY KEY) ORGANIZATION INDEX;
BEGIN
  :p_nome:='T_BIB_IOT';
END;
/
@@../../scripts/geradores/extrair_constraints_tabela.sql
BEGIN
  IF :ddl_constraints IS NOT NULL OR :ddl_fks IS NOT NULL THEN RAISE_APPLICATION_ERROR(-20107,'PK de IOT pertence ao DDL da tabela.'); END IF;
END;
/
ALTER TABLE T_BIB_IOT ADD CONSTRAINT FK_BIB_IOT FOREIGN KEY (n) REFERENCES T_BIB_TEST(n);
@@../../scripts/geradores/extrair_constraints_tabela.sql
BEGIN
  IF :ddl_constraints IS NOT NULL OR :ddl_fks IS NULL THEN RAISE_APPLICATION_ERROR(-20107,'FK deve ter DDL separado, mesmo em IOT.'); END IF;
END;
/
ALTER TABLE T_BIB_IOT ADD CONSTRAINT CK_BIB_IOT CHECK (n>0);
@@../../scripts/geradores/extrair_constraints_tabela.sql
BEGIN
  IF :ddl_constraints IS NULL OR :ddl_fks IS NULL THEN RAISE_APPLICATION_ERROR(-20107,'CHECK e FK devem ter DDL separado.'); END IF;
END;
/
INSERT INTO T_BIB_TEST SELECT LEVEL FROM dual CONNECT BY LEVEL<=10;
COMMIT;
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(ownname=>'APP_LAB',tabname=>'T_BIB_TEST',estimate_percent=>100,degree=>1);
END;
/
CREATE PROCEDURE P_BIB_TEST AS
BEGIN
  NULL;
END;
/
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(job_name=>'J_BIB_TEST',job_type=>'PLSQL_BLOCK',
    job_action=>'BEGIN NULL; END;',start_date=>SYSTIMESTAMP+INTERVAL '30' DAY,
    enabled=>FALSE,auto_drop=>FALSE);
  :p_nome:='S_BIB_TEST';
  :p_confirmacao:='CRIAR_STAT_TABLE';
END;
/
@@../../scripts/manutencao/criar_tabela_estatisticas.sql
BEGIN
  :p_nome:='T_BIB_TEST'; :p_stat_table:='S_BIB_TEST'; :p_statid:='TEST_EXPORT';
  :p_confirmacao:='EXPORTAR_STATS';
END;
/
@@../../scripts/manutencao/exportar_estatisticas_tabela.sql
INSERT INTO T_BIB_TEST SELECT LEVEL+10 FROM dual CONNECT BY LEVEL<=10;
COMMIT;
BEGIN
  :p_statid:='TEST_ANTES_COLETA'; :p_confirmacao:='COLETAR_STATS';
END;
/
@@../../scripts/manutencao/coletar_estatisticas_tabela.sql
DECLARE
  l_rows NUMBER;
BEGIN
  SELECT num_rows INTO l_rows FROM user_tab_statistics WHERE table_name='T_BIB_TEST' AND object_type='TABLE';
  IF l_rows IS NULL OR l_rows<>20 THEN RAISE_APPLICATION_ERROR(-20102,'Coleta nao registrou 20 linhas.'); END IF;
  :p_confirmacao:='IMPORTAR_STATS';
END;
/
@@../../scripts/manutencao/importar_estatisticas_tabela.sql
DECLARE
  l_rows NUMBER;
BEGIN
  SELECT num_rows INTO l_rows FROM user_tab_statistics WHERE table_name='T_BIB_TEST' AND object_type='TABLE';
  IF l_rows IS NULL OR l_rows<>10 THEN RAISE_APPLICATION_ERROR(-20103,'Importacao nao restaurou stats de 10 linhas.'); END IF;
  :p_nome:='P_BIB_TEST'; :p_tipo:='PROCEDURE'; :p_confirmacao:='RECOMPILAR';
END;
/
@@../../scripts/manutencao/recompilar_objeto.sql
BEGIN
  :p_nome:='T_BIB_TEST'; :p_tipo:='TABLE';
END;
/
@@../../scripts/geradores/extrair_ddl_objeto.sql
BEGIN
  IF :ddl_objeto IS NULL OR DBMS_LOB.GETLENGTH(:ddl_objeto)=0 THEN RAISE_APPLICATION_ERROR(-20104,'DDL de tabela vazio.'); END IF;
END;
/
@@../../scripts/geradores/extrair_indices_tabela.sql
BEGIN
  IF :ddl_indices IS NULL OR DBMS_LOB.GETLENGTH(:ddl_indices)=0 THEN RAISE_APPLICATION_ERROR(-20104,'DDL de indice vazio.'); END IF;
END;
/
@@../../scripts/geradores/extrair_constraints_tabela.sql
BEGIN
  IF :ddl_constraints IS NULL OR DBMS_LOB.GETLENGTH(:ddl_constraints)=0 THEN RAISE_APPLICATION_ERROR(-20104,'DDL de constraint vazio.'); END IF;
END;
/
@@../../scripts/geradores/extrair_privilegios_usuario.sql
@@../../scripts/geradores/gerar_recompilacao.sql
BEGIN
  :p_nome:='J_BIB_TEST'; :p_acao:='ENABLE'; :p_confirmacao:='ALTERAR_JOB';
END;
/
@@../../scripts/manutencao/alterar_estado_job.sql
DECLARE
  l_enabled VARCHAR2(5);
BEGIN
  SELECT enabled INTO l_enabled FROM user_scheduler_jobs WHERE job_name='J_BIB_TEST';
  IF l_enabled<>'TRUE' THEN RAISE_APPLICATION_ERROR(-20105,'Job nao habilitado.'); END IF;
  :p_acao:='DISABLE'; :p_confirmacao:='ALTERAR_JOB';
END;
/
@@../../scripts/manutencao/alterar_estado_job.sql
DECLARE
  l_enabled VARCHAR2(5);
BEGIN
  SELECT enabled INTO l_enabled FROM user_scheduler_jobs WHERE job_name='J_BIB_TEST';
  IF l_enabled<>'FALSE' THEN RAISE_APPLICATION_ERROR(-20106,'Job nao desabilitado.'); END IF;
  DBMS_OUTPUT.PUT_LINE('Fluxo concluido; guardar evidencias e revisar limpeza manual.');
END;
/
