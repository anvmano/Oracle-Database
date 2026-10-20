# Adicionar membros aos grupos de redo log

[← Índice](README.md)

**Escopo:** Grupos de redo online em file system; exemplo single instance.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Adicionar um **membro** replica o mesmo grupo; não aumenta a quantidade de grupos nem o tamanho do redo. Planeje discos/failure domains distintos, capacidade e permissões. Em ASM/RAC/Data Guard, avalie os requisitos específicos antes de alterar grupos.

## 1. Inventariar — SQL*Plus SYSDBA

```sql
SELECT l.group#, l.thread#, l.bytes/1024/1024 tamanho_mb,
       l.members, l.status, f.member
FROM v$log l JOIN v$logfile f ON f.group#=l.group#
ORDER BY l.thread#, l.group#, f.member;
```

Confira grupos reais e membros existentes; não presuma que sejam 1, 2 e 3. Prepare o destino no SO, com proprietário/grupo corretos. Os nomes novos não podem apontar para arquivos existentes de outro banco.

## 2. Adicionar um membro por grupo

Exemplo somente se os grupos **1, 2 e 3** existirem e os caminhos forem os planejados:

```sql
ALTER DATABASE ADD LOGFILE MEMBER '/u02/oradata/ORCL/redo01b.log' TO GROUP 1;
ALTER DATABASE ADD LOGFILE MEMBER '/u02/oradata/ORCL/redo02b.log' TO GROUP 2;
ALTER DATABASE ADD LOGFILE MEMBER '/u02/oradata/ORCL/redo03b.log' TO GROUP 3;
```

Os arquivos são criados pela Oracle; não faça uma cópia manual de redo ativo. Execute as adições individualmente e confira o resultado antes da próxima.

## 3. Validar

Repita o inventário e consulte:

```sql
SELECT group#, member, status FROM v$logfile ORDER BY group#, member;
```

Membros novos podem aparecer como `INVALID` antes de o grupo ser usado pela primeira vez. Acompanhe a passagem pelos grupos, os estados e o alert log; faça switches/checkpoint somente quando planejados. Não remova os membros antigos como parte automática da multiplexação e não trate estados transitórios como justificativa para apagar arquivos.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [redo_archives.sql](scripts/diagnostico/redo_archives.sql) — Consultar grupos redo e sequencias arquivadas.
- [redo_switches.sql](scripts/diagnostico/redo_switches.sql) — Contar switches de redo por hora, thread e encarnacao.

## Referências oficiais

- [Gerenciar redo logs](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/managing-the-redo-log.html)
