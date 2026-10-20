# Diagnosticar corrupção de blocos

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; diagnóstico e decisão de recuperação, sem produzir corrupção artificial.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Registre erro, horário, arquivo/bloco, instância e operação. Preserve logs e backups. Erros de storage precisam de investigação do SO/armazenamento além do banco. Não reproduza corrupção alterando datafiles com ferramentas de disco. Mudanças devem ocorrer em cópia isolada, com backup/redo e critérios de aceitação definidos.

## 1. Confirmar a ocorrência

Como administrador autorizado no container apropriado:

```sql
SELECT name, dbid, database_role, open_mode, log_mode FROM v$database;
SELECT file#, block#, blocks, corruption_change#, corruption_type
FROM v$database_block_corruption ORDER BY file#, block#;
SELECT file#, name, status FROM v$datafile ORDER BY file#;
```

A view registra blocos detectados, não prova que todo o banco foi examinado. Em CDB, inclua CON_ID no levantamento quando aplicável e consulte extents na PDB correspondente; FILE_ID e BLOCK_ID não podem ser correlacionados com outro container por suposição.

## 2. Validar um escopo planejado

No RMAN conectado ao banco confirmado, modelo para o número real do datafile:

```text
VALIDATE CHECK LOGICAL DATAFILE NUMERO_REAL_DO_ARQUIVO;
```

VALIDATE pode consumir I/O significativo. Planeje janela e leia todo o log, incluindo falhas de acesso e corrupção lógica. DBVERIFY é outra ferramenta de verificação com escopo próprio; nenhum resultado isolado demonstra a recuperabilidade completa da aplicação.

## 3. Escolher a recuperação

| Situação confirmada | Caminho a avaliar |
|---|---|
| Poucos blocos físicos identificados | Block media recovery com pré-condições e mídia válidas |
| Perda extensa/indefinida | Restore/recover de datafile ou banco conforme o incidente |
| Corrupção lógica ou entre objetos | Recuperação específica, reconstrução a partir de fonte íntegra ou escalonamento |

RMAN block recovery exige as condições do manual, incluindo ARCHIVELOG, control file corrente, backup full/nível 0 ou outra fonte suportada e archived redo necessário. Nível 1 sozinho não substitui essa base. Confirme edição/recursos; reparo automático com standby tem requisitos adicionais.

## 4. Recuperar somente após conferir as fontes

Exemplo de forma do comando, sem números executáveis de outro incidente:

```text
RECOVER DATAFILE NUMERO_REAL_DO_ARQUIVO BLOCK NUMERO_REAL_DO_BLOCO;
```

Não emita RECOVER CORRUPTION LIST como primeira tentativa sem analisar o conjunto. DBMS_REPAIR pode marcar/ignorar blocos; isso não recupera seu conteúdo e pode ocultar perda. Parâmetros ocultos de abertura/resetlogs não integram este roteiro.

## 5. Validar os dados e encerrar

Repita a validação do escopo, confira a view, alert log e consultas funcionais dos objetos afetados. Diferencie bloco reparado de consistência funcional do conjunto. Se faltar redo ou persistir falha, preserve o estado e siga o plano de recuperação; não abra o banco forçando a ignorar o erro. Registre a fonte recuperada e faça backup após a recuperação aceita. Esse procedimento não oferece undo genérico das intervenções.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [corrupcao_blocos.sql](scripts/diagnostico/corrupcao_blocos.sql) — Consultar corrupcoes registradas pelo banco.

## Roteiros de solução de problemas

- [20 · Corrupção de blocos ou falha de leitura de dados](solucao-de-problemas/20-corrupcao-de-blocos.md).

## Referências oficiais

- [Block media recovery](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/rman-block-media-recovery.html)
- [DBMS_REPAIR e suas limitações](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/repairing-corrupted-data.html)
- [VALIDATE](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/VALIDATE.html)
