# Executar um checklist diário do banco Oracle

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; triagem administrativa sem alterações automáticas e sem AWR/ASH.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Defina responsável, frequência, janela observada, limites e canal de escalonamento do ambiente. Compare com a linha de base; uma contagem isolada não significa incidente. Execute as consultas com conta de monitoramento autorizada, no container correto, e proteja o relatório gerado.

## 1. Disponibilidade e identidade

```sql
SELECT instance_name, status, startup_time, host_name FROM v$instance;
SELECT name, db_unique_name, database_role, open_mode, log_mode FROM v$database;
SELECT name, open_mode, restricted FROM v$pdbs ORDER BY con_id;
```

Confirme papel e modo previstos, não apenas processo PMON. Em non-CDB, ignore a consulta de PDBs. Teste uma conexão pelo serviço da aplicação e, quando possível, uma operação de saúde autorizada da própria aplicação.

## 2. Espaço e proteção

```sql
SELECT tablespace_name, used_percent FROM dba_tablespace_usage_metrics ORDER BY used_percent DESC;
SELECT name, space_limit, space_used, space_reclaimable FROM v$recovery_file_dest;
SELECT dest_id, status, destination, error FROM v$archive_dest WHERE destination IS NOT NULL;
SELECT start_time, end_time, input_type, status FROM v$rman_backup_job_details
WHERE start_time >= SYSDATE-1 ORDER BY start_time;
```

Confira também `df -hT`, limites de autoextend, TEMP e UNDO. View RMAN local não comprova cópia externa nem restauração testada; ausência de registro no período precisa ser confrontada com agenda e histórico preservado.

## 3. Falhas e sessões

```sql
SELECT sid, serial#, username, sql_id, event, blocking_session
FROM v$session WHERE blocking_session IS NOT NULL;
SELECT owner, job_name, status, error#, actual_start_date
FROM dba_scheduler_job_run_details
WHERE log_date >= SYSTIMESTAMP-INTERVAL '1' DAY AND status <> 'SUCCEEDED'
ORDER BY log_date;
SELECT owner, object_type, COUNT(*) quantidade FROM dba_objects
WHERE status='INVALID' GROUP BY owner, object_type;
```

Confira [alert log](<Diagnosticar erros com ADRCI e alert log.md>) desde a última coleta, incluindo erros repetidos, falhas de I/O e reinícios. Compare inválidos com o inventário anterior antes de reexecutar recompilações.

## 4. Registrar e encaminhar

| Verificação | Evidência mínima | Ação quando divergir |
|---|---|---|
| Disponibilidade | Host, instância, serviço, PDB e horário | Confirmar impacto e acionar responsável |
| Backup | Execução esperada, término, cópia e último teste de restore | Investigar e preservar capacidade de recuperação |
| Espaço | Usado, limite, taxa de crescimento e filesystem | Projetar esgotamento e planejar expansão |
| Jobs/locks/logs | Objeto/sessão/erro e duração | Correlacionar com aplicação e mudança recente |

Registre resultado, responsável e chamado/incidente. Não mate sessões, apague archives, aumente arquivos ou reinicie o banco automaticamente como parte do checklist. O retorno deste guia é apenas encerrar a coleta; intervenções têm procedimentos e planos próprios.

## 5. Encaminhar cada achado ao diagnóstico correto

O [índice dos 20 roteiros individuais](SOLUCAO_DE_PROBLEMAS.md) encaminha cada sintoma a um arquivo próprio, com diagnóstico, decisões de correção e critérios para confirmar a retomada.

| Sinal | Próximo passo |
|---|---|
| Coleta ausente ou item sem suporte | [Zabbix](<Monitorar Oracle com Zabbix.md>), identidade, permissão e timestamp |
| Disk group sem capacidade útil | [ASM](<Administrar ASM e disk groups.md>) e armazenamento físico |
| Objetos inválidos novos | [Dependências e compilação](<Diagnosticar objetos invalidos.md>) |
| Sessão cara sem causa definida | [Trace](<Rastrear SQL com DBMS_MONITOR e TKPROF.md>) ou janela de desempenho autorizada |

Não calcule TEMP/UNDO como se fossem tablespaces permanentes comuns. Uma tablespace cheia e com autoextend habilitado pode estar próxima de esgotar o disco compartilhado. Compare estado, limite e taxa de crescimento; campos ausentes não são consumo zero. As consultas de saúde terminam na coleta e no encaminhamento, sem executar a manutenção gerada por outro script.

## Referências oficiais

- [Guia de administração](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/)
- [Referência das views](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/)
