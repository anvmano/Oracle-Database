# Exportar dados com Oracle Data Pump (expdp)

[← Índice](README.md)

**Escopo:** Data Pump 12.1–19c; exemplos lógicos por serviço/PDB e transporte físico planejado.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Os exemplos usam serviço `ORCLPDB` e schema `APP_OWNER`; substitua pelos reais. Em CDB, conecte ao serviço da **PDB** pretendida. Data Pump produz exportação lógica, não um substituto de backup físico RMAN para recuperar o banco inteiro. Confira compatibilidade de versões, privilégios, espaço e proteção dos dumps.

## 1. Preparar o diretório do servidor

O `DIRECTORY` é um objeto Oracle apontando para uma pasta **no servidor do banco**, não no computador que executa a CLI. Como administrador do SO, prepare uma pasta dedicada e gravável pelo processo Oracle; exemplo para diretório novo:

```bash
install -d -o oracle -g oinstall -m 750 /u02/dumps
```

No container correto, como administrador autorizado:

```sql
CREATE DIRECTORY EXP_DUMPS AS '/u02/dumps';
GRANT READ, WRITE ON DIRECTORY EXP_DUMPS TO SYSTEM;
```

Se o objeto já existir, confira o caminho/consumidores antes de alterá-lo. Os exemplos administrativos usam `SYSTEM` com senha solicitada no prompt; uma conta dedicada deve ter os acessos necessários e, para operações privilegiadas entre schemas/full/transportáveis, as roles Data Pump correspondentes. Em RAC, confirme acesso ao destino pelos nós envolvidos ou limite a execução conforme o plano.

## 2. Exportar — escolher um modo

No shell com ambiente Oracle correto:

```bash
expdp system@ORCLPDB directory=EXP_DUMPS dumpfile=full_01.dmp logfile=full_01.log full=y
expdp system@ORCLPDB directory=EXP_DUMPS dumpfile=app_01.dmp logfile=app_01.log schemas=APP_OWNER
expdp system@ORCLPDB directory=EXP_DUMPS dumpfile=clientes_01.dmp logfile=clientes_01.log tables=APP_OWNER.CLIENTES
expdp system@ORCLPDB directory=EXP_DUMPS dumpfile=tbs_01.dmp logfile=tbs_01.log tablespaces=TBS_APP
```

Essas linhas são **alternativas**, não uma sequência obrigatória. `FULL=Y` em uma PDB não exporta toda a CDB. Use nomes novos para cada operação; `REUSE_DUMPFILES=Y` pode sobrescrever uma exportação existente e não deve ser padrão.

Para nome datado no Bash:

```bash
stamp=$(date +%Y%m%d_%H%M%S)
expdp system@ORCLPDB directory=EXP_DUMPS dumpfile="app_${stamp}.dmp" logfile="app_${stamp}.log" schemas=APP_OWNER
```

## 3. Consistência e arquivo de parâmetros

Quando precisar de consistência de leitura no ponto escolhido, avalie `FLASHBACK_SCN` ou `FLASHBACK_TIME`, retenção de undo e privilégios. Em um arquivo local `export_app.par`, por exemplo:

```ini
DIRECTORY=EXP_DUMPS
DUMPFILE=app_consistente_%U.dmp
LOGFILE=app_consistente.log
SCHEMAS=APP_OWNER
FLASHBACK_TIME=SYSTIMESTAMP
LOGTIME=ALL
METRICS=YES
```

Execute `expdp system@ORCLPDB parfile=export_app.par`. Não edite o parfile durante o job esperando alterar os parâmetros já lidos. Trate compressão, criptografia e paralelismo conforme suporte/licenciamento e capacidade; não são opções gratuitas/universais.

## 4. Tablespaces transportáveis

Este modo transfere metadados **mais datafiles copiados separadamente**. Verifique compatibilidade de plataforma/endian, charset, versões, TDE e autocontenção. Não transporte SYSTEM/SYSAUX como tablespaces de aplicação.

No SQL*Plus, avalie o conjunto real:

```sql
EXEC DBMS_TTS.TRANSPORT_SET_CHECK('TBS_APP', TRUE, TRUE);
SELECT * FROM transport_set_violations;
```

Corrija violações. Planeje a indisponibilidade e coloque todas as tablespaces do conjunto em READ ONLY. Então exporte os metadados:

```bash
expdp system@ORCLPDB directory=EXP_DUMPS dumpfile=tts_01.dmp logfile=tts_01.log transport_tablespaces=TBS_APP transport_full_check=y
```

Confira o log e liste **todos** os datafiles do conjunto em `DBA_DATA_FILES`. Copie-os enquanto as tablespaces continuam READ ONLY, por canal seguro, junto com o dump; valide integridade e eventual conversão de endian/TDE pelo procedimento aplicável. Só devolva a origem a READ WRITE depois de concluir e conferir as cópias. Importe conforme [IMPDP](IMPDP.md), sem reutilizar os datafiles ativos da origem como destino.

## 5. Acompanhar e aceitar o resultado

Confira término, código de saída, log completo e quantidade de objetos/linhas esperada. Um dump existente não prova sucesso. Registre serviço, escopo, ponto de consistência e todas as peças produzidas; proteja os arquivos e teste importação em banco isolado.

Para acompanhar um job existente, use `expdp system@ORCLPDB attach=NOME_REAL_DO_JOB`, com proprietário apropriado. No prompt interativo, `STATUS` consulta e `EXIT_CLIENT` desconecta o cliente mantendo o job; `STOP_JOB` e `KILL_JOB` têm efeitos diferentes, sendo o último destrutivo para o job. Consulte `HELP` antes de interromper.

## Referência de parâmetros

Execute `expdp help=y` no cliente instalado; a lista de help antiga foi substituída por esta consulta para não apresentar defaults de outra versão como universais.

| Finalidade | Parâmetros |
|---|---|
| Escopo | `FULL`, `SCHEMAS`, `TABLES`, `TABLESPACES`, `TRANSPORT_TABLESPACES` |
| Seleção e conteúdo | `CONTENT`, `INCLUDE`, `EXCLUDE`, `QUERY`, `SAMPLE` |
| Arquivos | `DIRECTORY`, `DUMPFILE`, `LOGFILE`, `FILESIZE`, `PARFILE` |
| Consistência | `FLASHBACK_SCN`, `FLASHBACK_TIME` |
| Operação | `JOB_NAME`, `ATTACH`, `STATUS`, `PARALLEL`, `CLUSTER` |
| Outros modos | `NETWORK_LINK`, `VERSION`, `REMAP_DATA`, `VIEWS_AS_TABLES` |

Compatibilidade de `INCLUDE`/`EXCLUDE` e outras combinações depende da versão. Não copie opções de export para o import sem conferir o help correspondente.

## 6. Fixar o escopo e reconciliar a exportação

Antes do job, registre serviço/PDB, proprietário, lista de objetos, contagens autorizadas e ponto de consistência. Em exportação consistente, FLASHBACK_SCN e FLASHBACK_TIME são alternativas; não use os dois no mesmo job. UNDO precisa sustentar a leitura durante a exportação. Um COUNT executado depois, sob carga, pode divergir legitimamente do ponto exportado.

Preserve nome/proprietário do job, todas as peças, código de saída, log e checksums em local privado. Uma exportação parcial com erro não vira válida por ter produzido um dump. Teste o import em destino isolado, reconciliando o escopo e o ponto escolhidos. Consulte [NLS](<Diagnosticar character set e NLS.md>) para diferenças de representação e [transporte de tablespaces](<Transportar tablespaces entre bancos.md>) para o fluxo físico completo.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [datapump_jobs.sql](scripts/diagnostico/datapump_jobs.sql) — Consultar jobs Data Pump existentes.
- [directories.sql](scripts/diagnostico/directories.sql) — Consultar objetos DIRECTORY visiveis.

## Roteiros de solução de problemas

- [17 · Exportação/importação Data Pump falhando ou parada](solucao-de-problemas/17-falhas-no-data-pump.md).

## Referências oficiais

- [Data Pump Export](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-data-pump-export-utility.html)
- [DBMS_TTS](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_TTS.html)
