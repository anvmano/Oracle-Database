-- Objetivo: Consultar estado e capacidade dos discos ASM
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$ASM_DISK_STAT na instancia ASM.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Administrar ASM e disk groups.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Conexao separada a instancia ASM; nao faz descoberta forcada nem altera/remova discos.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT group_number,disk_number,name,path,header_status,mode_status,state,failgroup,
       total_mb,free_mb,read_errs,write_errs
FROM v$asm_disk_stat ORDER BY group_number,disk_number;
