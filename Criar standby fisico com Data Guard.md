# Criar um standby físico com Data Guard

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c EE single instance, dois hosts isolados de laboratório, sem RAC/TDE/Broker inicialmente.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Confirme suporte/licenciamento, mesma plataforma/RU, capacidade, rede, latência, resolução de nomes e senha administrativa/password files. O exemplo usa DB_NAME **ORCL em ambos**, SID ORCL em hosts distintos, DB_UNIQUE_NAME `ORCL_PRI` e `ORCL_STB`. Arquivos de cada host são independentes; não há discos/FRA compartilhados. Não é um roteiro para SE2, RAC, primary TDE ou failover de produção.

Reserve janela, backup recuperável da origem e plano de retorno. Um standby replica também certas mudanças lógicas/erros humanos; não substitui backup. O exemplo mantém standby em MOUNT com Redo Apply e não usa consulta read only simultânea ao apply (Active Data Guard tem requisitos próprios).

## 1. Preparar o primário

No primário, confirme identidade, ARCHIVELOG e FORCE LOGGING:

```sql
SELECT name, db_unique_name, database_role, log_mode, force_logging FROM v$database;
SELECT group#, thread#, bytes, members, status FROM v$log ORDER BY thread#,group#;
```

Se necessário, habilite ARCHIVELOG pelo [guia de backup](<Informações e parâmetros de backup.md>) e FORCE LOGGING pelo procedimento planejado (`ALTER DATABASE FORCE LOGGING;`), avaliando cargas em andamento. Defina DB_UNIQUE_NAME correto no SPFILE e reinicie na janela se ainda não for ORCL_PRI; confirme o resultado antes de prosseguir.

Prepare OMF e standby redo logs em **ambos** os hosts para receber redo após troca de papéis. Cada thread precisa de pelo menos um grupo SRL a mais que os online redo groups, e SRLs de tamanho pelo menos igual ao maior redo da origem. Exemplo **somente se** houver três grupos online de 200 MiB na thread 1 e nenhum SRL correspondente, com destino OMF configurado:

```sql
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 SIZE 200M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 SIZE 200M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 SIZE 200M;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 SIZE 200M;
```

Depois do duplicate, inspecione SRLs do standby e crie apenas os faltantes; não repita adições sobre grupos existentes.

## 2. Preparar Oracle Net e autenticação

Instale software no standby, sem criar um banco sobre o destino. Configure listeners e aliases `ORCL_PRI`/`ORCL_STB` em ambos os hosts. Os aliases usados para duplicate/administração precisam funcionar também em NOMOUNT/MOUNT.

Para este cenário sem Restart, prepare registro estático da instância no listener. Exemplo de item SID_DESC do **standby**, a integrar ao arquivo existente, sem substituir outros serviços:

```text
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = ORCL_STB_DGMGRL.example.test)
      (ORACLE_HOME = /u01/app/oracle/product/19.3/dbhome_1)
      (SID_NAME = ORCL)
    )
  )
```

No primário, use o serviço estático equivalente ORCL_PRI_DGMGRL.example.test. Configure aliases com host/porta reais e o SERVICE_NAME correspondente, teste listeners e login administrativo remoto com senha no prompt. `tnsping` sozinho não comprova autenticação.

Prepare o password file do standby conforme o guia, com a mesma credencial exigida para o duplicate, por método seguro e sem senha em argumentos/Git. Confirme REMOTE_LOGIN_PASSWORDFILE e privilégios. O duplicate ativo usa autenticação e transfere arquivos pela rede; proteja o transporte conforme a política. Não reutilize o acesso externo de aplicação como regra aberta de administração.

## 3. Configurar transporte no primário

Registre antes os parâmetros atuais. Exemplo com aliases resolvidos e destino FRA válido, como SYSDBA:

```sql
ALTER SYSTEM SET log_archive_config='DG_CONFIG=(ORCL_PRI,ORCL_STB)' SCOPE=BOTH;
ALTER SYSTEM SET log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORCL_PRI' SCOPE=BOTH;
ALTER SYSTEM SET log_archive_dest_2='SERVICE=ORCL_STB ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCL_STB' SCOPE=BOTH;
ALTER SYSTEM SET log_archive_dest_state_2=ENABLE SCOPE=BOTH;
ALTER SYSTEM SET fal_server='ORCL_STB' SCOPE=BOTH;
ALTER SYSTEM SET standby_file_management='AUTO' SCOPE=BOTH;
```

Esses são destinos **do laboratório novo**. Não sobrescreva destinos existentes de produção. ASYNC corresponde ao plano de proteção escolhido; não afirme perda zero sem avaliar modo de proteção, transporte e condições de falha.

## 4. Preparar auxiliar e duplicar

No standby, crie paths novos `/u02/standby` e `/u03/standby_fra`; faça OMF apontar para eles e configure o PFILE de bootstrap com DB_NAME ORCL, DB_UNIQUE_NAME ORCL_STB, control files exclusivos, memória/FRA dimensionadas e ENABLE_PLUGGABLE_DATABASE conforme a origem. Inicie NOMOUNT com SID/home corretos. Não herde conversões de nomes ou keystores sem revisão.

Em RMAN no host de administração, conecte interativamente; as senhas não aparecem nas linhas:

```text
CONNECT TARGET sys@ORCL_PRI;
CONNECT AUXILIARY sys@ORCL_STB;
DUPLICATE TARGET DATABASE FOR STANDBY FROM ACTIVE DATABASE
  SPFILE
    SET db_unique_name='ORCL_STB'
    SET control_files='/u02/standby/control01.ctl'
    SET db_create_file_dest='/u02/standby'
    SET db_create_online_log_dest_1='/u02/standby'
    SET db_recovery_file_dest='/u03/standby_fra'
    SET log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORCL_STB'
    SET log_archive_dest_2='SERVICE=ORCL_PRI ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=ORCL_PRI'
    SET fal_server='ORCL_PRI'
    SET standby_file_management='AUTO'
  DORECOVER;
```

O bloco é um modelo que depende dos parâmetros/mídia e paths verificados. O SPFILE copiado pode herdar outros parâmetros da origem; revise todos, especialmente FRA, diagnóstico e destinations. Se aparecer conflito de arquivos, diagnostique; não acrescente NOFILENAMECHECK. O standby físico preserva o DBID do primário; **não** abra com RESETLOGS nem use NID.

## 5. Iniciar Redo Apply e validar

Confirme papel PHYSICAL STANDBY e estado MOUNTED, paths exclusivos, arquivos/redo e SRLs. Se recovery gerenciado ainda não estiver ativo, no standby:

```sql
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
SELECT name, database_role, open_mode, protection_mode FROM v$database;
SELECT name, value, unit, time_computed, datum_time FROM v$dataguard_stats;
SELECT * FROM v$archive_gap;
SELECT role, thread#, sequence#, action FROM v$dataguard_process;
```

No primário, faça um archive planejado (`ALTER SYSTEM ARCHIVE LOG CURRENT;`) e confira erro/status do destino, chegada e aplicação no standby. Lag zero com DATUM_TIME antigo não prova atualização. View de gap vazia sozinha não comprova convergência; acompanhe transporte, apply, erros e evolução das sequences/SCNs.

## 6. Aceitação, troca de papéis e retorno

Aceite apenas com autenticação, transporte, SRLs, apply, backup e capacidade monitorados. Teste uma mudança de dados fictícios e sua aplicação pelo método compatível com o modo/licenciamento, sem abrir o standby read write. Para gestão/troca de papéis, siga [Broker](<Administrar Data Guard com Broker.md>); não misture comandos manuais e Broker simultaneamente.

Se precisar desfazer o laboratório, interrompa a configuração de transporte planejada no primário e preserve logs/backups; retire só os recursos exclusivos de standby depois de confirmar o escopo. Não remova archives exigidos pelo standby nem inverta papéis para tentar corrigir simples atraso.

## 7. Supervisionar atraso sem depender apenas de sequences

No standby, registre VALUE, UNIT, TIME_COMPUTED e DATUM_TIME de V$DATAGUARD_STATS em coletas sucessivas; compare relógios/fuso e confirme que os dados de transporte continuam chegando. Faça a correlação com erros de destino no primário, processo de apply, threads/incarnation e carga. Uma diferença de sequence não representa uma duração universal nem o mesmo volume de redo.

Se usar [Zabbix](<Monitorar Oracle com Zabbix.md>), diferencie indisponibilidade da coleta, atraso de transporte e atraso de aplicação. Não converta NULL ou timestamp antigo em lag zero. Um teste aceito precisa observar nova transação fictícia transportada/aplicada pelo método compatível com o modo do standby e seus direitos de uso. Limpeza de archives deve respeitar a necessidade de todos os destinos exigidos, conforme [FRA](<Monitorar FRA e archivelogs.md>).

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [data_guard_gap.sql](scripts/diagnostico/data_guard_gap.sql) — Consultar gap bloqueante registrado no standby.

## Roteiros de solução de problemas

- [19 · Standby atrasado ou com gap de archives](solucao-de-problemas/19-data-guard-atraso-e-gap.md).

## Referências oficiais

- [Conceitos e administração Data Guard](https://docs.oracle.com/en/database/oracle/oracle-database/19/sbydb/)
- [Criar standby com RMAN](https://docs.oracle.com/en/database/oracle/oracle-database/19/sbydb/creating-data-guard-standby-database-using-RMAN.html)
- [Transporte e SRLs](https://docs.oracle.com/en/database/oracle/oracle-database/19/sbydb/oracle-data-guard-redo-transport-services.html)
- [Licenciamento](https://docs.oracle.com/en/database/oracle/oracle-database/19/dblic/)
