# Configurar e consultar parâmetros RMAN

[← Índice](README.md)

**Escopo:** RMAN 12.1–19c; confirme opções/licença na versão instalada.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## 1. Registrar configuração existente

Como proprietário do banco, carregue o ambiente correto e conecte ao banco-alvo; em CDB, use o root para configuração do banco inteiro:

```bash
rman target /
```

```rman
SHOW ALL;
REPORT SCHEMA;
```

Guarde a saída antes de alterar. As configurações persistem no repositório RMAN. Não confunda control file do alvo com recovery catalog separado.

## 2. Definir a política de recuperação

Exemplo de janela de sete dias, a dimensionar pelo objetivo de recuperação e capacidade:

```rman
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE DEFAULT DEVICE TYPE TO DISK;
CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO COMPRESSED BACKUPSET;
```

Uma janela de recuperação não significa simplesmente apagar tudo com mais de sete dias; RMAN considera a cadeia necessária para recuperar nesse período. `REDUNDANCY` é uma política alternativa de número de backups, não deve ser combinada como se fosse outro filtro simultâneo.

## 3. Configurar destinos

Crie primeiro um diretório protegido e gravável por `oracle`, em armazenamento com capacidade/monitoramento. Exemplo configurável:

```rman
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/u02/backup/%d_%T_%U.bkp';
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/u02/backup/controlfile/%F';
```

No **autobackup de control file**, use `%F` conforme a sintaxe específica; não reutilize ali todos os especificadores aceitos pelo `BACKUP FORMAT`. `%d` representa o nome do banco, não necessariamente o SID; `%I`, DBID; `%T`, data `YYYYMMDD`; `%U`, identificação única. Registre DBID e caminho do autobackup fora do próprio banco para recuperação de desastre.

O diretório de backup em outro volume não garante proteção contra perda do host. Planeje cópia independente, proteção das chaves e teste de restauração.

## 4. Outras opções

| Configuração | Uso e limite |
|---|---|
| `BACKUP OPTIMIZATION ON` | Evita certos backups idênticos segundo critérios RMAN; não é backup incremental de blocos alterados |
| `PARALLELISM` | Número de canais automáticos por device type; dimensione por I/O, CPU e capacidade, não só por cores |
| `MAXSETSIZE` / `MAXPIECESIZE` | Limites diferentes: backup set e peça; confirme a sintaxe no help/referência |
| `BACKUP COPIES` | Número de cópias; revise suporte/destinos e espaço |
| `COMPRESSION ALGORITHM 'BASIC'` | A compressão depende também de `AS COMPRESSED BACKUPSET`; outras modalidades podem ter requisitos de licença |
| `ENCRYPTION FOR DATABASE` | Depende de keystore/chaves/modo e edição; nunca ative sem preservar meios de recuperação |
| `ARCHIVELOG DELETION POLICY` | Coordena elegibilidade de remoção; configure segundo cópias e Data Guard existentes |
| `SNAPSHOT CONTROLFILE NAME` | Arquivo operacional de snapshot, diferente do autobackup; não aponte para caminho de outra instalação |

Em Data Guard, não aplique cegamente `BACKED UP 1 TIMES` ou `APPLIED ON STANDBY`; considere transporte, aplicação, cópias e todos os destinos requeridos pelo plano.

## 5. Conferir antes de limpar

```rman
SHOW ALL;
CROSSCHECK BACKUP;
CROSSCHECK ARCHIVELOG ALL;
LIST EXPIRED BACKUP;
REPORT OBSOLETE;
```

**EXPIRED** significa que o crosscheck não encontrou/acessou o objeto na verificação; pode ser indisponibilidade temporária do armazenamento. **OBSOLETE** significa dispensável segundo a política de retenção. Investigue destinos indisponíveis antes de apagar registros; não use limpeza automática para esconder falha de montagem.

Para restaurar uma configuração ao padrão, use a forma `CONFIGURE ... CLEAR` específica da opção e confira com `SHOW ALL`; não execute uma linha com `xxxxxxxx` do exemplo antigo.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [rman_configuracao.sql](scripts/diagnostico/rman_configuracao.sql) — Consultar configuracoes RMAN persistidas.

## Roteiros de solução de problemas

- [18 · Backup RMAN falhando ou não acontecendo](solucao-de-problemas/18-falhas-no-backup-rman.md).

## Referências oficiais

- [CONFIGURE](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/CONFIGURE.html)
- [SHOW](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/SHOW.html)
- [Backup e recuperação](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/)
