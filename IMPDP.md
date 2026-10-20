# Importar dados com Oracle Data Pump (impdp)

[← Índice](README.md)

**Escopo:** Importação lógica 12.1–19c; destino e efeitos de DDL/carga precisam ser planejados.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Importação pode criar/alterar objetos e carregar dados. Use um destino identificado, backup e plano de retorno; em CDB, conecte à **PDB de destino**. Os exemplos usam `ORCLPDB`, `APP_OWNER` e uma conta administrativa; substitua os nomes. Confirme charset, versões, timezone, espaço, quotas, dependências e suporte a dumps criptografados.

## 1. Preparar arquivos e objeto DIRECTORY

Copie todas as peças do dump para uma pasta protegida **no servidor de destino**, com permissões para o processo Oracle, e compare checksums com a origem. Como administrador no container correto:

```sql
CREATE DIRECTORY IMP_DUMPS AS '/u02/dumps';
GRANT READ, WRITE ON DIRECTORY IMP_DUMPS TO SYSTEM;
```

Confirme o caminho antes de alterar objeto existente. Para conta dedicada, conceda os privilégios necessários, inclusive `DATAPUMP_IMP_FULL_DATABASE` apenas quando a operação privilegiada exigir. Usuários comuns podem importar seu próprio escopo com privilégios/quotas adequados.

## 2. Inspecionar o DDL antes da carga

```bash
impdp system@ORCLPDB directory=IMP_DUMPS dumpfile=app_01.dmp logfile=preview_app.log sqlfile=preview_app.sql schemas=APP_OWNER
```

O SQL é gravado em `/u02/dumps/preview_app.sql`, no servidor, não em `sqlfile.sql` no cliente. Essa opção produz o DDL selecionado sem executar a importação de objetos/dados. Leia o arquivo e planeje tablespaces, paths, usuários, quotas e privilégios antes da execução real. SQLFILE não valida sozinho toda a carga.

## 3. Importar — modos alternativos

```bash
impdp system@ORCLPDB directory=IMP_DUMPS dumpfile=app_01.dmp logfile=import_app.log schemas=APP_OWNER
impdp system@ORCLPDB directory=IMP_DUMPS dumpfile=clientes_01.dmp logfile=import_clientes.log tables=APP_OWNER.CLIENTES
impdp system@ORCLPDB directory=IMP_DUMPS dumpfile=tbs_01.dmp logfile=import_tbs.log tablespaces=TBS_APP
impdp system@ORCLPDB directory=IMP_DUMPS dumpfile=full_01.dmp logfile=import_full.log full=y
```

Escolha um modo compatível com o dump e o objetivo. `FULL` não significa recuperação física completa nem restauração de toda a CDB. Erros de objetos preexistentes não devem ser aceitos como normais sem revisar o que foi efetivamente importado.

`REUSE_DUMPFILES` pertence ao **export** e foi retirado dos exemplos de import. Para tabelas existentes, o comportamento é definido por `TABLE_EXISTS_ACTION`: `SKIP`, `APPEND`, `TRUNCATE` ou `REPLACE`, com restrições/defaults dependentes das demais opções. APPEND pode duplicar linhas; TRUNCATE/REPLACE podem remover dados/objetos. Não escolha automaticamente uma dessas opções para eliminar mensagens de erro.

## 4. Remapear schema ou tablespace

Exemplo em arquivo local `import_app.par`, após criar e preparar o schema/tablespace de destino conforme o plano:

```ini
DIRECTORY=IMP_DUMPS
DUMPFILE=app_01.dmp
LOGFILE=import_app_novo.log
SCHEMAS=APP_OWNER
REMAP_SCHEMA=APP_OWNER:APP_NOVO
REMAP_TABLESPACE=TBS_APP:TBS_NOVA
LOGTIME=ALL
METRICS=YES
```

Execute `impdp system@ORCLPDB parfile=import_app.par`. Confira quotas e dependências/código com referências explícitas ao nome antigo: remapear schema não corrige todo texto de aplicação automaticamente.

Para importar metadados que **criam datafiles**, quando aplicável e autorizado, use pares origem/destino distintos, por exemplo no parfile:

```ini
REMAP_DATAFILE='/u01/oradata/ORIGEM/tbs_app01.dbf':'/u02/oradata/DESTINO/tbs_app01.dbf'
```

Confira o par em SQLFILE antes. `REMAP_DATAFILE` altera referências a paths no DDL; não move arquivos existentes e não equivale a `REMAP_TABLESPACE`. Não combine filtros `INCLUDE=SCHEMA` e `INCLUDE=TABLESPACE` supondo preservar todas as dependências; selecione o modo apropriado e examine o DDL.

## 5. Importar tablespaces transportáveis

Pré-condições: exportação transportável válida, todos os datafiles copiados enquanto a origem estava READ ONLY, autocontenção e compatibilidade confirmadas, conversão de plataforma/TDE realizada quando requerida e schemas proprietários preparados no destino. Use cópias de destino, não arquivos ativos da origem.

```bash
impdp system@ORCLPDB directory=IMP_DUMPS dumpfile=tts_01.dmp logfile=import_tts.log transport_datafiles=/u02/oradata/DESTINO/tbs_app01.dbf
```

Liste todos os arquivos do conjunto. Confira o log, tablespaces, datafiles e objetos; só passe o destino para READ WRITE depois de aceitar a importação e o plano de uso. Se falhar, preserve evidências e diagnostique a fase; não repita sobre o mesmo destino parcialmente alterado sem um plano de limpeza/restauração específico.

## 6. Validar

Leia o log inteiro, código de saída e erros ORA-/UDI-. Confira contagens, objetos inválidos, índices, constraints, grants, sequências, sinônimos, jobs e testes funcionais. Compare com o inventário de origem/escopo planejado; não confie só na última linha do log.

Use `impdp help=y` para os parâmetros da versão e `impdp system@ORCLPDB attach=NOME_REAL` para jobs existentes, respeitando o proprietário. `EXIT_CLIENT` não mata o job; operações STOP/KILL exigem avaliar seu efeito antes de usá-las.

## 7. Conferir efeitos além das linhas

| Item | Verificar no destino isolado |
|---|---|
| Dados | Contagens e amostras fictícias no escopo/ponto exportado |
| Objetos | Tipos, proprietários, inválidos e erros de compilação |
| Integridade | PK/FK, índices, constraints e estado de validação |
| Execução | Jobs, triggers, sequences e dependências/serviços externos |
| Representação | NLS, caracteres, datas e versões de timezone aplicáveis |

Para objetos inválidos, siga o [diagnóstico seletivo](<Diagnosticar objetos invalidos.md>), não uma recompilação global automática. Mantenha destino sem saída para integrações enquanto valida. TABLE_EXISTS_ACTION e repetição de import precisam de decisão explícita: um destino parcialmente alterado não é uma base neutra para nova tentativa. DDL/carga já confirmados exigem restauração ou limpeza específica, não um ROLLBACK genérico.

## Roteiros de solução de problemas

- [17 · Exportação/importação Data Pump falhando ou parada](solucao-de-problemas/17-falhas-no-data-pump.md).

## Referências oficiais

- [Data Pump Import](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/datapump-import-utility.html)
