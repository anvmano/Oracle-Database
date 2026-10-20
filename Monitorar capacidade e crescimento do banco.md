# Monitorar capacidade e crescimento do banco

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; snapshots próprios de capacidade sem dependência de AWR/Diagnostics Pack.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Defina periodicidade, timezone, banco/container, unidades e responsável pela coleta. Diferencie tamanho alocado, dados ocupados, teto de autoextend, espaço livre do armazenamento e espaço recuperável. Colete uma linha de base antes de projetar expansão; backup, TEMP, redo e FRA têm perfis distintos.

## 1. Medir tablespaces permanentes no container correto

```sql
WITH d AS (
  SELECT tablespace_name, SUM(bytes) alocado,
         SUM(CASE WHEN autoextensible='YES' THEN maxbytes ELSE bytes END) teto
  FROM dba_data_files GROUP BY tablespace_name
), f AS (
  SELECT tablespace_name, SUM(bytes) livre FROM dba_free_space GROUP BY tablespace_name
)
SELECT SYSTIMESTAMP coleta, d.tablespace_name,
       ROUND(d.alocado/1024/1024) alocado_mb,
       ROUND((d.alocado-NVL(f.livre,0))/1024/1024) ocupado_mb,
       ROUND(d.teto/1024/1024) teto_configurado_mb
FROM d LEFT JOIN f ON f.tablespace_name=d.tablespace_name
ORDER BY d.tablespace_name;
```

As agregações prévias evitam multiplicar datafiles por extents livres. Dicionário de espaço livre tem restrições para arquivos/tablespaces offline; confira estados antes de interpretar ausência de linha como zero livre. O teto configurado pode não ser alcançável por falta de disco, limites de arquivos, quotas ou compartilhamento de capacidade.

## 2. Complementar com armazenamento e recuperação

No SO, confirme mounts reais e `df -hT`; em ASM, confira espaço útil após redundância, não só FREE_MB. Colete separadamente FRA, geração de archives, TEMP, UNDO, backups retidos, cópias e logs. Consulte [FRA](<Monitorar FRA e archivelogs.md>) e [TEMP/UNDO](<Monitorar TEMP e UNDO.md>).

Não some máximo de vários datafiles como se cada um tivesse um disco exclusivo. Registre quais tablespaces/backups competem pelo mesmo volume. Crescimento de tablespace não mede sozinho crescimento do host.

## 3. Preservar um histórico utilizável

Salve snapshots em armazenamento de monitoramento privado, com chave de banco/container, horário, unidade e estado da coleta. Evite reescrever o snapshot anterior. O repositório Git deve guardar script/modelo e dados fictícios, não o inventário de produção.

Use pelo menos uma janela que inclua cargas cíclicas, fechamento, importações e retenção. Coleta ausente deve ser registrada como ausência, não como consumo zero. Arquivamento de logs/limpezas podem causar quedas legítimas de tamanho.

## 4. Projetar com hipóteses explícitas

Exemplo didático, em GiB, com limite efetivo de 100 e alerta em 80:

| Dia | Ocupado GiB |
|---|---:|
| 1 | 40 |
| 11 | 50 |

Nesse intervalo, o crescimento médio é `(50-40)/(11-1) = 1 GiB/dia`; a distância ao alerta é `80-50 = 30 GiB`, ou **30 dias**, se a taxa continuar igual. Picos, sazonalidade e tempo de aquisição justificam margem adicional.

Se crescimento for zero/negativo, não divida por ele nem declare prazo infinito garantido: revise janela/carga e planeje cenários de pico. A projeção é estimativa, não compromisso de capacidade.

## 5. Agir e validar

Estabeleça limites de aviso/crítico e prazo de expansão segundo tempo de resposta. Confirme necessidade, volume/failure domain, backup e efeito sobre custos antes de ampliar. Depois da mudança, confira capacidade física, limites dos arquivos e continuidade da coleta. Redução/limpeza tem risco próprio e não deve ser tratada como reversão automática de uma expansão.

## 6. Localizar crescimento por componente

Depois de identificar a tablespace que cresce, agregue os segmentos do próprio schema:

```sql
SELECT tablespace_name, segment_type,
       ROUND(SUM(bytes)/1024/1024,2) alocado_mb
FROM user_segments
GROUP BY tablespace_name, segment_type
ORDER BY alocado_mb DESC;
```

Para toda a PDB, uma conta autorizada pode usar DBA_SEGMENTS com owner e filtros de escopo. Use [LOBs](<Administrar segmentos LOB.md>) para relacionar segmentos às colunas, incluindo partições; não some uma linha por coluna a uma linha de segmento compartilhada sem conferir a chave. Em [ASM](<Administrar ASM e disk groups.md>), registre USABLE_FILE_MB, redundância e reserva; em file system, registre volume compartilhado, espaço real e crescimento de arquivos fora do banco. Nem queda de ocupação lógica nem shrink de objeto garantem redução do datafile.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [tablespaces_uso.sql](scripts/diagnostico/tablespaces_uso.sql) — Medir espaco permanente sem multiplicar extents livres.
- [datafiles_uso.sql](scripts/diagnostico/datafiles_uso.sql) — Medir alocado e livre por arquivo.
- [io_tablespaces.sql](scripts/diagnostico/io_tablespaces.sql) — Medir participacao acumulada de I/O por tablespace.
- [io_datafiles.sql](scripts/diagnostico/io_datafiles.sql) — Consultar I/O acumulado por datafile.
- [segmentos_maiores.sql](scripts/diagnostico/segmentos_maiores.sql) — Consultar os 50 maiores segmentos do schema.
- [quotas_tablespaces.sql](scripts/diagnostico/quotas_tablespaces.sql) — Consultar quotas de tablespace de um usuario.

## Roteiros de solução de problemas

- [08 · Falta de espaço permanente ou quota](solucao-de-problemas/08-espaco-permanente-e-quota.md).

## Referências oficiais

- [Gerenciar armazenamento](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/)
- [DBA_DATA_FILES](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_DATA_FILES.html)
- [DBA_FREE_SPACE](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_FREE_SPACE.html)
