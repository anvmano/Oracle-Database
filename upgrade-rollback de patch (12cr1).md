# Aplicar e reverter patches em Oracle Database 12.1

[← Índice](README.md)

**Escopo:** 12.1.0.2 single instance; README do patch prevalece sobre o fluxo geral.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Este fluxo é para **Database home single instance sem RAC/Data Guard/Grid a atualizar**. Para esses ambientes, use o procedimento específico, que pode exigir OPatchAuto e ordem entre homes/nós. Uma RU/PSU/BP não é um upgrade de versão principal.

O README **incluído no patch exato** determina SO, release, versão mínima do OPatch, conflitos, componentes, modo de abertura, ordem e reversão. Os pacotes/README autenticados do MOS não estão presentes neste acervo: esses detalhes não foram homologados nesta revisão. Não prossiga usando apenas um número de patch histórico.

## 1. Registrar estado e preparar recuperação

Como proprietário do software, confira `ORACLE_HOME`, `ORACLE_SID`, inventário e espaço:

```bash
printf '%s\n' "$ORACLE_HOME" "$ORACLE_SID"
"$ORACLE_HOME/OPatch/opatch" version
"$ORACLE_HOME/OPatch/opatch" lsinventory -detail
df -h "$ORACLE_HOME"
```

Antes da parada, registre no SQL*Plus:

```sql
SELECT banner FROM v$version;
SELECT name, open_mode, log_mode FROM v$database;
SELECT patch_id, action, status, action_time, description
FROM dba_registry_sqlpatch ORDER BY action_time;
SELECT owner, object_type, COUNT(*) FROM dba_objects
WHERE status='INVALID' GROUP BY owner, object_type;
```

Faça backup recuperável do banco, do Oracle home, inventário e configuração conforme o plano. Teste a restauração em ambiente separado. Reserve janela e forma de retorno; não apague `.patch_storage`.

## 2. Preparar OPatch e verificar conflitos

Obtenha mídia e OPatch oficiais e confira checksums. Se precisar atualizar OPatch, preserve a pasta anterior com nome único e extraia a versão **compatível com esse home**, conforme o README; não sobrescreva backups anteriores. Reconfira `opatch version` e inventário.

Extraia o patch em staging e entre no diretório que contém seus metadados. Exemplo Bash com caminho a substituir:

```bash
PATCH_DIR=/home/oracle/patches/SUBSTITUIR_DIRETORIO_DO_PATCH
cd "$PATCH_DIR"
"$ORACLE_HOME/OPatch/opatch" prereq CheckConflictAgainstOHWithDetail -ph .
"$ORACLE_HOME/OPatch/opatch" prereq CheckSystemSpace -ph .
```

Para bundle com vários subpatches, faça as verificações e a sequência do README; se ele solicitar `-phBaseFile`, o arquivo deve listar **todos os diretórios reais**. Não deduza subpatches pela posição das pastas. Interrompa o fluxo se qualquer verificação falhar.

## 3. Parar os consumidores do home

Pare aplicações e todos os bancos/serviços que utilizam o home. No SQL*Plus de **cada** instância afetada:

```sql
SHUTDOWN IMMEDIATE;
EXIT
```

No shell, pare o listener correspondente se ele usar esse home: `"$ORACLE_HOME/bin/lsnrctl" stop`. Não pare um listener de outro home compartilhado sem planejar o impacto. Confira processos ativos.

Se o pré-requisito `CheckActiveFilesAndExecutables` falhar, identifique o processo com `fuser`/`ps` e pare-o pelo mecanismo normal. Não use `kill -9` como correção padrão nem troque aplicação por rollback.

## 4. Aplicar o patch binário

No diretório confirmado do patch, como proprietário do home:

```bash
"$ORACLE_HOME/OPatch/opatch" apply
"$ORACLE_HOME/OPatch/opatch" lsinventory
```

Responda às confirmações somente após verificar a parada. Se o README exigir múltiplos componentes, aplique todos na ordem prescrita. Uma mensagem de bootstrap ou um inventário sem o patch esperado não confirma sucesso.

## 5. Aplicar alterações SQL

Inicie os bancos afetados no modo **exigido pelo README**; não use `STARTUP UPGRADE` indiscriminadamente. Para o fluxo usual com banco aberto normalmente:

```sql
STARTUP;
```

Em CDB, conectado ao root, confira `SHOW PDBS` e abra todas as PDBs de aplicação previstas para o patch (`ALTER PLUGGABLE DATABASE ALL OPEN;`, se aplicável ao estado e ao ambiente). Não tente abrir PDBs que já estão abertas sem conferir; PDB$SEED permanece read only.

No shell, para cada banco com componente SQL:

```bash
"$ORACLE_HOME/OPatch/datapatch" -verbose
```

Confira o log completo, o código de saída e `DBA_REGISTRY_SQLPATCH` no root e nas PDBs aplicáveis. PDB fechada pode ficar sem a etapa SQL. `catbundle.sql psu apply` **não** é uma rotina de recompilação nem deve ser executado em paralelo ao datapatch sem instrução expressa do README.

## 6. Validar e devolver o serviço

Execute `@?/rdbms/admin/utlrp.sql` quando indicado e compare objetos inválidos ao estado anterior. Registre patch/action/status por banco/container, reinicie normalmente se necessário e use `lsnrctl start` para iniciar o listener parado. Confirme serviços, aplicação, alert log e backup pós-mudança.

Catálogo RMAN: confira a compatibilidade do cliente/esquema e a documentação específica antes de `UPGRADE CATALOG`. Essa mudança é separada, exige backup do catálogo e pode impedir clientes antigos; não a execute duas vezes como rotina após qualquer patch.

## 7. Reversão, somente quando necessária

1. Antes da parada, identifique no inventário **o patch efetivamente instalado** e confira se o README permite rollback.
2. Pare os mesmos bancos/serviços.
3. Como proprietário do home, execute `opatch rollback -id ID_CONFIRMADO`, substituindo o marcador pelo número real e respeitando a ordem dos componentes.
4. Inicie os bancos no modo prescrito e rode `datapatch -verbose` por banco, quando requerido, para concluir a reversão SQL.
5. Verifique ação **ROLLBACK**, status **SUCCESS**, inventário, PDBs, objetos e aplicação. A reversão de um patch não implica que nenhum outro patch deva permanecer instalado.
6. Se a reversão falhar, preserve os logs e use o plano de restauração; não tente remover arquivos do home manualmente.

## Referências oficiais

- [OPatch e datapatch](https://docs.oracle.com/en/cloud/paas/base-database/update-db/index.html)
- [My Oracle Support — README e certificação do patch](https://support.oracle.com/)
