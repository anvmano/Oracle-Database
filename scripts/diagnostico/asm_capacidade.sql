-- Objetivo: Consultar capacidade util dos disk groups
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$ASM_DISKGROUP_STAT na instancia ASM.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Administrar ASM e disk groups.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Excecao de conexao: instancia ASM, conta de leitura autorizada; nao executar como manutencao do banco.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT group_number,name,state,type,total_mb,free_mb,required_mirror_free_mb,
       usable_file_mb,offline_disks,compatibility,database_compatibility
FROM v$asm_diskgroup_stat ORDER BY name;
