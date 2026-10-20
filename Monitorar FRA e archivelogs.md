# Monitorar FRA e archivelogs

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; capacidade de recuperação e destinos de archive, incluindo dependências de standby.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Confirme banco, papel, containers, destinos e estratégia de backup/Data Guard. Arquivo antigo não significa arquivo dispensável. Nunca use `rm` para aliviar a FRA sem coordenar o repositório e as dependências de recuperação.

## 1. Conferir configuração, consumo e erros

```sql
SELECT name, database_role, log_mode FROM v$database;
SHOW PARAMETER db_recovery_file_dest
SHOW PARAMETER db_recovery_file_dest_size
SELECT name, space_limit, space_used, space_reclaimable, number_of_files FROM v$recovery_file_dest;
SELECT file_type, percent_space_used, percent_space_reclaimable, number_of_files
FROM v$recovery_area_usage ORDER BY file_type;
SELECT dest_id, status, destination, error FROM v$archive_dest WHERE destination IS NOT NULL;
```

FRA é um limite lógico além da capacidade física. Confirme ambos com `df -hT` ou ASM. Espaço reclaimable depende de elegibilidade e não deve ser tratado como reserva garantida para qualquer situação. Restore points garantidos podem reter flashback logs e pressionar a FRA.

## 2. Medir geração de redo arquivado

Escolha o `DEST_ID` local confirmado; abaixo, `1` é só o exemplo. A subconsulta elimina duplicações por registro de uma mesma sequence/incarnation:

```sql
SELECT dia, ROUND(SUM(bytes)/1024/1024) archive_mb
FROM (
  SELECT TRUNC(first_time) dia, resetlogs_id, thread#, sequence#,
         MAX(blocks*block_size) bytes
  FROM v$archived_log
  WHERE dest_id=1 AND archived='YES' AND first_time >= TRUNC(SYSDATE)-7
  GROUP BY TRUNC(first_time), resetlogs_id, thread#, sequence#
) GROUP BY dia ORDER BY dia;
```

Esses valores representam geração registrada, não ocupação física atual nem todas as cópias. Um control file com histórico curto limita a análise. Compare dias de pico e janela de retenção, não só a média.

## 3. Conferir proteção antes de limpar

Em RMAN:

```rman
SHOW ALL;
LIST BACKUP OF ARCHIVELOG ALL;
CROSSCHECK ARCHIVELOG ALL;
LIST EXPIRED ARCHIVELOG ALL;
REPORT OBSOLETE;
```

Investigue armazenamento inacessível antes de remover registros EXPIRED. Confira backup/cópia independente, sequences necessárias à recuperação e à aplicação em **todos os standbys exigidos**. `DELETE OBSOLETE` e a política de exclusão de archives têm objetivos/regras diferentes.

## 4. Tratar pressão ou falha de arquivamento

1. Preserve alert log e erro do destino; confirme montagem, permissão e capacidade.
2. Se os archives ainda forem necessários, providencie capacidade/destino suportado ou acelere a proteção prevista.
3. Só remova arquivos elegíveis por RMAN conforme política aprovada e limites confirmados. Não deixe `DELETE ARCHIVELOG ALL` sem filtro como receita de emergência.
4. Para ampliar `DB_RECOVERY_FILE_DEST_SIZE`, confirme espaço físico e escopo do parâmetro; isso sozinho não aumenta disco nem resolve destino indisponível.
5. Se alterar destino, confirme a configuração nova com um archive planejado e status/erro, conforme [backup](<Informações e parâmetros de backup.md>).

## 5. Aceitar e acompanhar

Confirme retomada do arquivamento, erro resolvido, aplicação normal, backups completos e atraso de standby dentro da meta. Registre projeção de esgotamento e responsáveis. Remoção de archives é irreversível sem cópia válida; uma regra de retenção menor não é um plano de retorno.

## 6. Distinguir idade, expiração e obsolescência

| Conceito | Interpretação operacional |
|---|---|
| Arquivo antigo | Pode continuar necessário ao ponto de recuperação ou a um standby |
| EXPIRED | Repositório não encontrou o arquivo no CROSSCHECK; confirme storage e acesso |
| OBSOLETE | Avaliação da política de retenção RMAN, distinta da política de exclusão de archives |
| Espaço reclaimable | Estimativa conforme regras e dependências, não espaço físico livre garantido |

Antes de qualquer limpeza, confira última restauração testada, peças e chaves, destino inacessível e atraso de cada standby exigido. Uma rotina de exclusão por SYSDATE-N, isolada dessas condições, não entra na automação. Se não houver arquivo elegível, a ação pode ser ampliar capacidade, corrigir acesso ou concluir a proteção pendente. Compare capacidade útil de [ASM](<Administrar ASM e disk groups.md>) quando esse for o armazenamento.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [fra_uso.sql](scripts/diagnostico/fra_uso.sql) — Consultar limite, uso e elegibilidade de recuperacao da FRA.

## Roteiros de solução de problemas

- [11 · FRA cheia ou falha de arquivamento](solucao-de-problemas/11-fra-e-arquivamento.md).
- [19 · Standby atrasado ou com gap de archives](solucao-de-problemas/19-data-guard-atraso-e-gap.md).

## Referências oficiais

- [FRA](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/)
- [V$RECOVERY_AREA_USAGE](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-RECOVERY_AREA_USAGE.html)
- [V$ARCHIVED_LOG](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-ARCHIVED_LOG.html)
