# Multiplexar ou repor control files

[← Índice](README.md)

**Escopo:** Control files em file system, instância única; cópia com banco parado.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Procedimento para single instance com **SPFILE**, control file corrente íntegro e armazenamento em file system. Para ASM/Oracle Restart, siga os métodos específicos de cópia e gerenciamento. Duas cópias no mesmo disco não protegem contra perda desse disco.

Não copie control file enquanto o banco estiver alterando-o. Multiplexação de uma cópia corrente é diferente de restaurar um backup de control file, que pode exigir recovery/RESETLOGS.

## 1. Registrar estado — SQL*Plus SYSDBA

```sql
SHOW PARAMETER spfile
SHOW PARAMETER control_files
SELECT name, status, is_recovery_dest_file FROM v$controlfile;
```

Guarde a lista completa de caminhos e um PFILE de contingência, em diretório protegido e existente:

```sql
CREATE PFILE='/u02/backup/initORCL_antes_controlfiles.ora' FROM SPFILE;
```

Se a instância usa PFILE, altere o arquivo de parâmetros realmente usado; `SCOPE=SPFILE` não se aplica. Confirme SID/home e um plano de retorno antes da parada.

## 2. Preparar destinos

Como root ou administrador do armazenamento, prepare diretórios graváveis pelo proprietário Oracle em dispositivos/failure domains distintos. Confirme montagens, espaço e permissões. O exemplo seguinte pressupõe duas cópias existentes mais uma nova; adapte a lista inteira à realidade.

No SQL*Plus:

```sql
ALTER SYSTEM SET control_files=
  '/u01/oradata/ORCL/control01.ctl',
  '/u02/oradata/ORCL/control02.ctl',
  '/u03/oradata/ORCL/control03.ctl'
  SCOPE=SPFILE;
SHUTDOWN IMMEDIATE;
```

**Mantenha todas as cópias que pretende continuar usando**, inclusive a origem íntegra. Confirme que a instância realmente parou antes da cópia.

## 3. Copiar — proprietário Oracle

Com o banco parado, copie **uma cópia corrente confirmada** para o novo destino. Se estiver repondo cópias perdidas, copie também para esses destinos listados, preservando a origem:

```bash
cp -p /u01/oradata/ORCL/control01.ctl /u03/oradata/ORCL/control03.ctl
cmp /u01/oradata/ORCL/control01.ctl /u03/oradata/ORCL/control03.ctl
```

Confirme que o destino não contém um arquivo válido de outro banco; não sobrescreva sem verificar. Não altere permissões para `777` como tentativa de correção.

## 4. Iniciar e validar — SQL*Plus

```sql
STARTUP;
SHOW PARAMETER control_files
SELECT name, status FROM v$controlfile;
SELECT name, open_mode FROM v$database;
```

Revise alert log e faça backup da configuração/control file conforme a rotina. Se houver ORA-00205/ORA-00210, confira **todos** os caminhos, montagens, permissões e cópias antes de repetir. Use o PFILE de contingência para recuperar a configuração se necessário; não emita RESETLOGS para resolver erro de caminho.

## Quando usar RMAN

O caminho alternativo antigo desligava a instância e chamava `RESTORE CONTROLFILE` sem NOMOUNT. Para restauração de backup, siga o [cenário de recuperação](<Comandos para restore.md>), com NOMOUNT, mount, recovery e abertura apropriada. Para adicionar uma réplica corrente em file system, o fluxo acima elimina essa confusão e evita restaurar um control file antigo sobre os atuais.

## Referências oficiais

- [Gerenciar control files](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/managing-control-files.html)
- [RESTORE](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/RESTORE.html)
