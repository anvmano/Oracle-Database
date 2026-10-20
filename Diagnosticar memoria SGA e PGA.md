# Diagnosticar memória SGA e PGA

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c/Linux; coleta de memória e análise de parâmetros, sem redimensionamento automático.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Confirme host, banco, container, número de instâncias e memória disponível para todo o conjunto. SGA, PGA, memória dos demais processos e cache do SO não são parcelas intercambiáveis. Em CDB, distinguir limites de instância e PDB. Registre horários e carga para comparar medições do banco e do SO.

## 1. Inventariar a configuração

Como administrador no container pretendido:

```sql
SELECT name, value, isdefault, issys_modifiable
FROM v$parameter
WHERE name IN ('memory_target','memory_max_target','sga_target','sga_max_size',
               'pga_aggregate_target','pga_aggregate_limit','use_large_pages')
ORDER BY name;
SELECT component, current_size, min_size, max_size, user_specified_size
FROM v$memory_dynamic_components WHERE current_size>0 ORDER BY component;
```

MEMORY_TARGET configura AMM; SGA_TARGET com PGA administrada separadamente é outro desenho. Não altere os dois mecanismos sem entender o modo ativo. Valores zero ou herdados precisam ser interpretados no escopo correto.

## 2. Medir pressão de memória

```sql
SELECT name, value, unit FROM v$pgastat ORDER BY name;
SELECT name, bytes, resizeable FROM v$sgainfo ORDER BY name;
SELECT sid, serial#, username, status FROM v$session WHERE type='USER';
```

Use séries temporais: pico de PGA, alocações, workareas e erros ORA-04030/04031 precisam de correlação com a carga. PGA_AGGREGATE_TARGET não é teto rígido de consumo. Não some RSS de processos Oracle como se memória compartilhada não fosse contada repetidamente.

## 3. Confrontar com o Linux

Como usuário autorizado no host correspondente:

```bash
free -h
vmstat 1 5
df -h /dev/shm
grep -E 'MemAvailable|SwapTotal|SwapFree|HugePages|Hugepagesize' /proc/meminfo
```

MemAvailable, atividade de swap e pressão sustentada ajudam mais que apenas memória livre. Não limpe caches para produzir uma comparação artificial. AMM e HugePages têm restrições próprias na plataforma; dimensione pela documentação e pelo modo escolhido. Não copie SHMALL, tamanho de /dev/shm ou percentual de RAM de outro host.

## 4. Planejar mudança e retorno

Antes de qualquer ALTER SYSTEM ou ajuste de SO, preserve SPFILE/PFILE, valores por escopo e configuração do host. Avalie IS_SYS_MODIFIABLE, valores mínimos, disponibilidade física, containers e necessidade de restart. Faça uma mudança de cada vez em janela definida, com critérios de abortar e retornar à configuração preservada. Não proponha reinício como primeira resposta a uma medição isolada.

## 5. Validar

Compare a mesma carga antes/depois e inclua CPU, I/O, tempo de resposta e erros. Menos swap ou hit ratio maior não prova ganho funcional por si só. Encerre a coleta e proteja resultados. Para investigar uma sessão/carga específica, siga [trace](<Rastrear SQL com DBMS_MONITOR e TKPROF.md>) e [AHF/TFA](<Coletar diagnosticos com AHF e TFA.md>).

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [sga_componentes.sql](scripts/diagnostico/sga_componentes.sql) — Consultar componentes SGA sem misturar backup RMAN.
- [latches.sql](scripts/diagnostico/latches.sql) — Consultar contadores acumulados de latches.
- [hit_ratios.sql](scripts/diagnostico/hit_ratios.sql) — Revisar indicadores historicos de cache com divisor protegido.
- [biblioteca_cache.sql](scripts/diagnostico/biblioteca_cache.sql) — Consultar contadores do library cache.
- [dicionario_cache.sql](scripts/diagnostico/dicionario_cache.sql) — Consultar contadores de caches do dicionario.
- [shared_pool_reserved.sql](scripts/diagnostico/shared_pool_reserved.sql) — Consultar espaco reservado e falhas de alocacao.
- [pga_workareas.sql](scripts/diagnostico/pga_workareas.sql) — Consultar execucoes de workareas por faixa de memoria.
- [sga_redimensionamentos.sql](scripts/diagnostico/sga_redimensionamentos.sql) — Consultar operacoes de redimensionamento da SGA.

## Roteiros de solução de problemas

- [12 · Falta de memória compartilhada ou pressão de PGA](solucao-de-problemas/12-memoria-sga-e-pga.md).

## Referências oficiais

- [Memória Oracle](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/managing-memory.html)
- [HugePages no Linux](https://docs.oracle.com/en/database/oracle/oracle-database/19/unxar/administering-oracle-database-on-linux.html)
- [V$PGASTAT](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-PGASTAT.html)
