# Recuperar um banco Oracle com RMAN

[← Índice](README.md)

**Escopo:** Cenários alternativos de recuperação; comandos dependem dos arquivos e backups reais.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Os cenários abaixo são **alternativas**, não uma sequência para executar inteira. Exemplos para single instance em ARCHIVELOG, mesmo host/layout e banco inteiro. Em CDB, conecte ao root; RAC, Data Guard, ASM, novo host e PDB isolada exigem procedimentos próprios.

**Confirme primeiro** nome, DBID, SID, home, arquivos, tipo de falha, última cópia válida e archives disponíveis. Preserve alert log, inventário de backup, configuração e arquivos ainda íntegros. Garanta destino/montagens, proprietário, espaço e wallet/chaves quando houver TDE. Pare os acessos da aplicação antes da indisponibilidade. Não faça uma restauração de teste sobre os arquivos de produção.

No RMAN, `LIST BACKUP`, `RESTORE DATABASE PREVIEW` e validação das peças ajudam a confirmar a cadeia. Uma peça com nome parecido não garante que pertença ao banco/incarnation correto. Nomes e números abaixo são exemplos e precisam ser substituídos pelos valores verificados.

## 1. Perda de um datafile ou de todos os datafiles

Com control files e parâmetros íntegros, no SQL*Plus:

```sql
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
EXIT
```

Se a falha impedir a parada normal, avalie `SHUTDOWN ABORT` como contingência documentada, não como primeiro passo universal. Em `rman target /`, escolha **uma** alternativa:

```rman
RESTORE DATAFILE 7;
RECOVER DATAFILE 7;
```

ou, para o banco inteiro:

```rman
RESTORE DATABASE;
RECOVER DATABASE;
```

O número `7` deve vir de `REPORT SCHEMA`/inventário. Após recuperação **completa**, usando control file corrente e todo redo requerido, abra normalmente com `ALTER DATABASE OPEN;`. Não use RESETLOGS por hábito. Confira arquivos, alert log e aplicação e faça backup pós-recuperação conforme o plano.

## 2. Perda da tablespace UNDO ativa

Não apague/recrie a UNDO ativa para contornar perda de dados. Pare a instância conforme o diagnóstico e inicie em MOUNT. Em RMAN, usando o nome real:

```rman
RESTORE TABLESPACE UNDOTBS1;
RECOVER TABLESPACE UNDOTBS1;
ALTER DATABASE OPEN;
```

Esse fluxo pressupõe backup/redo suficientes e control file corrente. Sem eles, interrompa e defina a estratégia de recuperação antes de mudar parâmetros ou criar outra UNDO.

## 3. Perda de tablespace read only

Verifique se existe backup da versão correta dos arquivos, inclusive mudanças de read only/read write. Com banco em MOUNT, por exemplo:

```rman
RESTORE TABLESPACE TBS_RO;
RECOVER TABLESPACE TBS_RO;
ALTER DATABASE OPEN;
```

`TBS_RO` é o nome real a substituir; `RESTORE tablespace_name read_only` não era uma sintaxe executável. A necessidade de redo depende do estado/checkpoint do arquivo e do backup selecionado; preserve a cadeia indicada pelo RMAN.

## 4. Perda de tempfile

Tempfiles não são recuperados como datafiles por backup RMAN. Confirme tablespace/container e nomes em `DBA_TEMP_FILES`. Com o banco aberto e espaço disponível, crie primeiro um tempfile válido; exemplo no SQL*Plus:

```sql
ALTER TABLESPACE TEMP ADD TEMPFILE '/u01/oradata/ORCL/temp02.dbf'
  SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE 2G;
```

Valide o novo arquivo e a capacidade. Se o registro antigo precisar ser removido, avalie sessões/uso e restrições antes de `ALTER DATABASE TEMPFILE 'CAMINHO_REAL_ANTIGO' DROP;`. Não remova o único tempfile utilizável nem copie caminhos da PDB/CDB errada.

## 5. Perda de todos os control files

Se uma cópia **corrente e íntegra** ainda existir, prefira o procedimento de [multiplexação/reposição](<multiplexando control file.md>) com o banco parado. Para recuperar de um **backup**, obtenha a peça correta e, no SQL*Plus, pare e inicie em NOMOUNT. Em RMAN:

```rman
RESTORE CONTROLFILE FROM '/u02/backup/PECA_CONTROLFILE_CONFIRMADA.bkp';
ALTER DATABASE MOUNT;
```

Confira se os caminhos catalogados e os datafiles presentes são corretos. Catalogue peças faltantes pelo procedimento aplicável. Recupere o banco; restaure datafiles **somente se também precisarem de restauração**:

```rman
RECOVER DATABASE;
ALTER DATABASE OPEN RESETLOGS;
```

Control file restaurado de backup exige a recuperação e a abertura RESETLOGS previstas pela Oracle. Se faltar redo, não abra nem tente contornar a falha: defina explicitamente o ponto possível e a perda aceita. Depois, registre a nova incarnation e faça novo backup.

## 6. Perda de SPFILE, control files e datafiles

É necessário ter DBID, autobackup e sua localização/formato documentados fora do banco. Exemplo RMAN; **substitua o DBID e o caminho antes de usar**:

```rman
SET DBID 1234567890;
STARTUP NOMOUNT;
SET CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/u02/backup/controlfile/%F';
RESTORE SPFILE FROM AUTOBACKUP;
SHUTDOWN IMMEDIATE;
STARTUP NOMOUNT;
RESTORE CONTROLFILE FROM AUTOBACKUP;
ALTER DATABASE MOUNT;
RESTORE DATABASE;
RECOVER DATABASE;
ALTER DATABASE OPEN RESETLOGS;
```

O RMAN pode iniciar NOMOUNT com parâmetros temporários para restaurar o SPFILE. Confirme que os parâmetros restaurados apontam aos caminhos corretos; em outro host/layout, restaure para PFILE e adapte os parâmetros/nomes antes da abertura. A busca por autobackup também depende das datas, device type e disponibilidade das peças. Erro não autoriza avançar para o próximo comando.

## 7. Perda de redo online e recuperação incompleta

Identifique o grupo, membros, status, thread/sequence e archives:

```sql
SELECT group#, thread#, sequence#, status, archived FROM v$log ORDER BY group#;
SELECT group#, member, status FROM v$logfile ORDER BY group#, member;
```

Se apenas um membro se perdeu e houver outro íntegro, avalie reposição/multiplexação; **não restaure o banco inteiro automaticamente**. Perda de grupo CURRENT/ACTIVE pode exigir recuperação com perda de transações se não houver redo suficiente. Preserve membros sobreviventes e busque a estratégia compatível com o erro.

Para um ponto de recuperação **previamente definido e aceito**, monte o banco e use o mesmo limite para restore/recover. Exemplo RMAN:

```rman
RUN {
  SET UNTIL SEQUENCE 123 THREAD 1;
  RESTORE DATABASE;
  RECOVER DATABASE;
}
ALTER DATABASE OPEN RESETLOGS;
```

O limite de sequence é **exclusivo**: esse exemplo recupera até antes da sequence 123. Não copie a sequence atual como alvo nem trate um RMAN-06054 como autorização automática para perder dados. Confirme archives/SCN/data e o alcance da recuperação. O exemplo de thread única não é um plano de recuperação RAC.

## 8. Aceitação após qualquer recuperação

Confira `V$DATABASE`, `V$DATAFILE_HEADER`, componentes, objetos inválidos, alert log, serviços/PDBs e consistência funcional da aplicação. Registre o ponto efetivamente recuperado e eventual perda. Reestabeleça backups e proteção dos archives; após RESETLOGS, faça novo backup conforme a estratégia. Use o [guia de backup](<Informações e parâmetros de backup.md>) para uma rotina separada, sem limpeza automática misturada ao atendimento de desastre.

## Roteiros de solução de problemas

- [20 · Corrupção de blocos ou falha de leitura de dados](solucao-de-problemas/20-corrupcao-de-blocos.md).

## Referências oficiais

- [RESTORE](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/RESTORE.html)
- [STARTUP](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/STARTUP.html)
- [SET e limites de recuperação](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/SET.html)
- [Recuperação de falhas](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/)
