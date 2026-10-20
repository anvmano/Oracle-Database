# Testar restauração do banco inteiro em laboratório

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c, file system, host isolado e mesmo patch; banco inteiro até um SCN declarado.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Este é um exercício de desastre em um **segundo host**, sem acesso gravável a discos, ASM, FRA ou mounts da origem. Restaurar o banco inteiro não significa necessariamente recuperar até o instante atual: este teste usa um ponto conhecido, com todos os archives necessários. Não execute na origem.

Registre DBID, DB_NAME, versão/RU, timezone, arquivos e tamanho; copie backups, archives, control file, password/configuração e wallets quando necessários. Confirme checksums, espaço e meios de recuperação TDE. Não conecte o teste ao catálogo de produção nem a serviços/integrações externos. Meça o tempo total e registre RPO/RTO obtidos.

## 1. Preparar uma evidência na origem de laboratório

Em `APP_LAB`, na PDB de teste, crie uma tabela exclusiva se ainda não existir:

```sql
CREATE TABLE T_RESTORE_LAB (id NUMBER PRIMARY KEY, descricao VARCHAR2(100));
INSERT INTO T_RESTORE_LAB VALUES (1,'antes do backup');
COMMIT;
```

Faça backup do banco e archives com a [rotina manual](<Informações e parâmetros de backup.md>), adaptando o destino para `/u04/backup`. Depois insira `id=2`, descrição `depois do backup`, e confirme a transação. Como administrador, registre um SCN posterior a esse COMMIT, force um archive planejado e faça backup dos archives necessários para alcançar esse ponto. Registre como `SCN_ALVO_EXCLUSIVO` esse SCN mais 1 e copie todas as peças exigidas ao host isolado.

## 2. Preparar o destino

Instale software no mesmo nível, sem criar um banco novo nos paths escolhidos. Use SID `ORCL`, DB_NAME da origem `ORCL` e **DB_UNIQUE_NAME distinto** `ORCL_RESTORE`. Crie diretórios novos e privados `/u02/restore`, `/u03/restore_fra` e `/u04/incoming`, sem sobreposição com a origem.

Crie `/home/oracle/initORCL_restore.ora` com memória/capacidade dimensionadas. Exemplo de parâmetros mínimos a adaptar:

```ini
db_name=ORCL
db_unique_name=ORCL_RESTORE
control_files='/u02/restore/control01.ctl'
db_create_file_dest='/u02/restore'
db_recovery_file_dest='/u03/restore_fra'
db_recovery_file_dest_size=8G
enable_pluggable_database=true
```

Esse exemplo é CDB; em non-CDB, adapte a configuração. TDE e parâmetros dependentes da versão precisam da configuração própria. Não restaure cegamente um SPFILE com paths da origem.

## 3. Restaurar o control file — somente no destino

Em `rman target /`, com o DBID e peça reais substituídos:

```text
SET DBID DBID_REAL;
STARTUP NOMOUNT PFILE='/home/oracle/initORCL_restore.ora';
RESTORE CONTROLFILE FROM '/u04/incoming/PECA_CONTROLFILE_REAL.bkp';
ALTER DATABASE MOUNT;
CATALOG START WITH '/u04/incoming/';
REPORT SCHEMA;
LIST BACKUP SUMMARY;
```

O bloco é um modelo: substitua os marcadores antes de executar. Confira os arquivos propostos para catalogação e o DBID; não avance se as peças não forem do banco/ponto planejado. Proteja o inventário de origem contra sincronização acidental.

## 4. Restaurar datafiles e recuperar no ponto planejado

Com OMF configurado **no destino**, use o mesmo limite antes do restore e do recover:

```text
RUN {
  SET UNTIL SCN SCN_ALVO_EXCLUSIVO;
  SET NEWNAME FOR DATABASE TO NEW;
  RESTORE DATABASE;
  SWITCH DATAFILE ALL;
  RECOVER DATABASE;
}
```

Confirme sucesso da recuperação. Antes de abrir, consulte `V$LOGFILE` e prepare o redirecionamento de **todos** os membros de redo ainda apontados ao layout antigo, com `ALTER DATABASE RENAME FILE` em MOUNT e paths novos exclusivos. Não remova arquivos de redo da origem nem use NOFILENAMECHECK para contornar conflitos. Revise também tempfiles e qualquer destino persistente herdado.

Abra com `ALTER DATABASE OPEN RESETLOGS;` somente depois da recuperação planejada bem-sucedida e do mapa de arquivos conferido. Control file de backup/recuperação incompleta exigem o tratamento correspondente. Se faltar archive, preserve o erro e reavalie o ponto; não aceite uma perda diferente da acordada sem registrá-la.

## 5. Validar e encerrar o exercício

Confira todos os paths em control files, datafiles, tempfiles, redo e parâmetros; confirme que nenhum destino de origem é usado. Abra apenas as PDBs previstas e verifique `APP_LAB.T_RESTORE_LAB`: no ponto escolhido, devem existir as duas linhas.

Valide componentes, alert log, aplicação de teste, serviços isolados e tempo de recuperação. Registre peças usadas, ponto efetivo, falhas e ajustes. Faça novo backup do destino se ele continuar existindo. A desativação/remoção do laboratório é uma mudança separada, depois da aceitação, com inventário dos discos exclusivos; o plano de retorno da origem permanece intacto.

## 6. Comprovar o ponto e medir o tempo total

Antes do teste, fixe qual transação fictícia precisa existir e qual ponto foi escolhido. Preserve SCN-alvo exclusivo, DBID, incarnation, inventário das peças, checksums e todos os archives exigidos. As datas do backup, cópia, início/fim do restore e recovery precisam formar uma sequência coerente.

Meça separadamente obtenção das peças/chaves, transferência, restore, recover, abertura e teste funcional. RTO inclui o caminho até o serviço utilizável, não apenas o tempo informado pelo RESTORE. RPO depende do último ponto recuperável efetivamente aceito, não do horário de geração de um arquivo. Uma restauração testada prova esse conjunto de peças/ponto/cenário; não certifica todos os backups futuros.

Se houver corrupção confirmada, acrescente a validação do escopo e os testes dos objetos afetados conforme [corrupção de blocos](<Diagnosticar corrupcao de blocos.md>). Guarde as evidências privadamente; este repositório recebe apenas procedimento e dados fictícios.

## Roteiros de solução de problemas

- [18 · Backup RMAN falhando ou não acontecendo](solucao-de-problemas/18-falhas-no-backup-rman.md).

## Referências oficiais

- [Restauração e recuperação](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/)
- [SET e novos nomes](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/SET.html)
- [RESTORE](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/RESTORE.html)
