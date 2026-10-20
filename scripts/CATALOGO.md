# Catálogo de scripts por assunto

**Organização editorial:** 20/10/2026 · conteúdo previamente tratado, conforme informado pelo mantenedor.

**90 tarefas em 17 assuntos.** O catálogo reúne os arquivos; não os executa. Escolha a pergunta, consulte os parâmetros e abra apenas a tarefa desejada. Os mesmos arquivos também estão nos [índices por finalidade](README.md).

## Encontrar pelo assunto

| Assunto | Tarefas |
|---|---:|
| [Arquitetura, parâmetros, NLS e versão](#ambiente) | 5 |
| [Sessões, bloqueios, processos e cursores](#sessoes) | 9 |
| [SQL, planos e contadores de desempenho](#sql) | 5 |
| [SGA, PGA e caches](#memoria) | 8 |
| [Tablespaces, datafiles, segmentos e LOBs](#armazenamento) | 5 |
| [Redo, FRA, UNDO e TEMP](#redo-undo-temp) | 5 |
| [Backup, recuperação e corrupções registradas](#backup) | 6 |
| [Scheduler, janelas e jobs legados](#jobs) | 5 |
| [Objetos, dependências, colunas e DDL](#objetos) | 8 |
| [Índices, PKs, FKs e constraints](#indices) | 9 |
| [Estatísticas e preservação do estado anterior](#estatisticas) | 7 |
| [Usuários, privilégios, profiles, auditoria e TDE](#seguranca) | 7 |
| [Serviços, links, sinônimos e ACLs de rede](#rede) | 4 |
| [ASM: disk groups e discos](#asm) | 2 |
| [Data Guard: papel, transporte e gap](#data-guard) | 2 |
| [Data Pump e objetos DIRECTORY](#datapump) | 2 |
| [ADR e alert log](#adr) | 1 |

## Começar por uma necessidade

| Necessidade | Caminho sugerido |
|---|---|
| Partir de um erro ou sintoma | [Índice dos 20 roteiros individuais](../SOLUCAO_DE_PROBLEMAS.md). |
| Descobrir onde estou conectado | [Identidade do banco](diagnostico/identidade_banco.sql), depois o assunto desejado. |
| Investigar lentidão | [Sessões ativas](diagnostico/sessoes_ativas.sql), [SQL por ID](diagnostico/sql_por_id.sql), [linhas do plano](diagnostico/planos_cursor.sql) e [bloqueadores](diagnostico/bloqueadores.sql). |
| Investigar falta de espaço | [Tablespaces](diagnostico/tablespaces_uso.sql), [datafiles](diagnostico/datafiles_uso.sql), [segmentos](diagnostico/segmentos_maiores.sql) e [FRA](diagnostico/fra_uso.sql). |
| Examinar estrutura de tabelas | [Colunas](diagnostico/colunas_tabela.sql), [constraints](diagnostico/constraints_status.sql), [FKs](diagnostico/foreign_keys_colunas.sql) e [colunas dos índices](diagnostico/indices_colunas.sql). |
| Acompanhar backup | [Execuções RMAN](diagnostico/rman_execucoes.sql), [operações em andamento](diagnostico/rman_em_execucao.sql) e [peças registradas](diagnostico/backup_pecas.sql). |
| Examinar jobs | [Definições e histórico](diagnostico/scheduler_execucoes.sql), [execuções atuais](diagnostico/scheduler_em_execucao.sql) e [janelas](diagnostico/scheduler_janelas.sql). |
| Disponibilizar a biblioteca | [Publicação do conjunto no GitHub](PUBLICACAO.md). |

Consulta, intervenção e geração de DDL continuam distintas em cada assunto. Um roteiro de investigação não é autorização para executar uma intervenção; confira objetivo e alvo da tarefa escolhida. A preparação comum está em [iniciar_sessao.sql](iniciar_sessao.sql).

<a id="ambiente"></a>

## Arquitetura, parâmetros, NLS e versão

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [identidade_banco.sql](diagnostico/identidade_banco.sql) | Consulta | Confirmar identidade, papel, abertura e container |
| [parametros_instancia.sql](diagnostico/parametros_instancia.sql) | Consulta | Consultar parametros suportados modificados ou selecionados |
| [nls.sql](diagnostico/nls.sql) | Consulta | Comparar NLS de banco, instancia e sessao |
| [timezone_banco.sql](diagnostico/timezone_banco.sql) | Consulta | Consultar timezone de banco, sessao e arquivo de timezone |
| [componentes_registrados.sql](diagnostico/componentes_registrados.sql) | Consulta | Consultar componentes instalados e seus estados |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="sessoes"></a>

## Sessões, bloqueios, processos e cursores

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [sessoes_ativas.sql](diagnostico/sessoes_ativas.sql) | Consulta | Listar sessoes ativas e o cursor filho corrente |
| [sessao_por_processo.sql](diagnostico/sessao_por_processo.sql) | Consulta | Relacionar processo do servidor a sessao |
| [bloqueadores.sql](diagnostico/bloqueadores.sql) | Consulta | Relacionar espera e bloqueador entre instancias |
| [objetos_bloqueados.sql](diagnostico/objetos_bloqueados.sql) | Consulta | Relacionar locks de objetos a sessoes |
| [sessao_io.sql](diagnostico/sessao_io.sql) | Consulta | Consultar contadores de I/O por sessao |
| [limites_recursos.sql](diagnostico/limites_recursos.sql) | Consulta | Consultar consumo atual e maximo de recursos da instancia |
| [operacoes_longas.sql](diagnostico/operacoes_longas.sql) | Consulta | Consultar progresso instrumentado de operacoes longas |
| [cursores_sessao.sql](diagnostico/cursores_sessao.sql) | Consulta | Contar entradas de cursores por sessao e tipo |
| [encerrar_sessao.sql](manutencao/encerrar_sessao.sql) | Intervenção | Solicitar encerramento de uma sessao local identificada |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="sql"></a>

## SQL, planos e contadores de desempenho

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [sql_por_id.sql](diagnostico/sql_por_id.sql) | Consulta | Consultar texto e contadores por cursor filho |
| [planos_cursor.sql](diagnostico/planos_cursor.sql) | Consulta | Consultar linhas de plano por SQL_ID e cursor filho |
| [esperas_sistema.sql](diagnostico/esperas_sistema.sql) | Consulta | Consultar contadores acumulados de eventos de espera |
| [io_tablespaces.sql](diagnostico/io_tablespaces.sql) | Consulta | Medir participacao acumulada de I/O por tablespace |
| [io_datafiles.sql](diagnostico/io_datafiles.sql) | Consulta | Consultar I/O acumulado por datafile |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="memoria"></a>

## SGA, PGA e caches

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [sga_componentes.sql](diagnostico/sga_componentes.sql) | Consulta | Consultar componentes SGA sem misturar backup RMAN |
| [latches.sql](diagnostico/latches.sql) | Consulta | Consultar contadores acumulados de latches |
| [hit_ratios.sql](diagnostico/hit_ratios.sql) | Consulta | Revisar indicadores historicos de cache com divisor protegido |
| [biblioteca_cache.sql](diagnostico/biblioteca_cache.sql) | Consulta | Consultar contadores do library cache |
| [dicionario_cache.sql](diagnostico/dicionario_cache.sql) | Consulta | Consultar contadores de caches do dicionario |
| [shared_pool_reserved.sql](diagnostico/shared_pool_reserved.sql) | Consulta | Consultar espaco reservado e falhas de alocacao |
| [pga_workareas.sql](diagnostico/pga_workareas.sql) | Consulta | Consultar execucoes de workareas por faixa de memoria |
| [sga_redimensionamentos.sql](diagnostico/sga_redimensionamentos.sql) | Consulta | Consultar operacoes de redimensionamento da SGA |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="armazenamento"></a>

## Tablespaces, datafiles, segmentos e LOBs

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [tablespaces_uso.sql](diagnostico/tablespaces_uso.sql) | Consulta | Medir espaco permanente sem multiplicar extents livres |
| [datafiles_uso.sql](diagnostico/datafiles_uso.sql) | Consulta | Medir alocado e livre por arquivo |
| [segmentos_maiores.sql](diagnostico/segmentos_maiores.sql) | Consulta | Consultar os 50 maiores segmentos do schema |
| [quotas_tablespaces.sql](diagnostico/quotas_tablespaces.sql) | Consulta | Consultar quotas de tablespace de um usuario |
| [lob_segmentos.sql](diagnostico/lob_segmentos.sql) | Consulta | Medir segmentos LOB agregando particoes antes do join |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="redo-undo-temp"></a>

## Redo, FRA, UNDO e TEMP

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [transacoes_undo.sql](diagnostico/transacoes_undo.sql) | Consulta | Medir UNDO por transacao com tamanho de bloco real |
| [temp_uso.sql](diagnostico/temp_uso.sql) | Consulta | Relacionar segmentos temporarios a sessoes |
| [fra_uso.sql](diagnostico/fra_uso.sql) | Consulta | Consultar limite, uso e elegibilidade de recuperacao da FRA |
| [redo_archives.sql](diagnostico/redo_archives.sql) | Consulta | Consultar grupos redo e sequencias arquivadas |
| [redo_switches.sql](diagnostico/redo_switches.sql) | Consulta | Contar switches de redo por hora, thread e encarnacao |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="backup"></a>

## Backup, recuperação e corrupções registradas

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [rman_execucoes.sql](diagnostico/rman_execucoes.sql) | Consulta | Consultar execucoes RMAN no periodo |
| [rman_em_execucao.sql](diagnostico/rman_em_execucao.sql) | Consulta | Consultar operacoes RMAN ainda marcadas como running |
| [rman_configuracao.sql](diagnostico/rman_configuracao.sql) | Consulta | Consultar configuracoes RMAN persistidas |
| [backup_pecas.sql](diagnostico/backup_pecas.sql) | Consulta | Consultar pecas de backup registradas no periodo |
| [corrupcao_blocos.sql](diagnostico/corrupcao_blocos.sql) | Consulta | Consultar corrupcoes registradas pelo banco |
| [recyclebin.sql](diagnostico/recyclebin.sql) | Consulta | Consultar objetos presentes na lixeira |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="jobs"></a>

## Scheduler, janelas e jobs legados

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [scheduler_execucoes.sql](diagnostico/scheduler_execucoes.sql) | Consulta | Consultar definicoes e logs do Scheduler |
| [jobs_legados.sql](diagnostico/jobs_legados.sql) | Consulta | Consultar DBMS_JOB sem confundir com Scheduler |
| [scheduler_em_execucao.sql](diagnostico/scheduler_em_execucao.sql) | Consulta | Consultar jobs Scheduler em execucao |
| [scheduler_janelas.sql](diagnostico/scheduler_janelas.sql) | Consulta | Consultar janelas e resource plans do Scheduler |
| [alterar_estado_job.sql](manutencao/alterar_estado_job.sql) | Intervenção | Habilitar ou desabilitar um job local proprio |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="objetos"></a>

## Objetos, dependências, colunas e DDL

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [objetos_invalidos.sql](diagnostico/objetos_invalidos.sql) | Consulta | Listar objetos invalidos e seus erros |
| [objetos_por_tipo.sql](diagnostico/objetos_por_tipo.sql) | Consulta | Contar objetos por tipo e estado |
| [objetos_dependencias.sql](diagnostico/objetos_dependencias.sql) | Consulta | Consultar dependencias diretas de um objeto |
| [visoes_materializadas.sql](diagnostico/visoes_materializadas.sql) | Consulta | Consultar estado e atualizacao de materialized views |
| [colunas_tabela.sql](diagnostico/colunas_tabela.sql) | Consulta | Consultar tipos, tamanhos e nulabilidade de colunas |
| [recompilar_objeto.sql](manutencao/recompilar_objeto.sql) | Intervenção | Recompilar um objeto proprio por tipo permitido |
| [gerar_recompilacao.sql](geradores/gerar_recompilacao.sql) | Gera DDL | Gerar comandos para objetos invalidos sem executa-los |
| [extrair_ddl_objeto.sql](geradores/extrair_ddl_objeto.sql) | Gera DDL | Extrair DDL de um objeto proprio |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="indices"></a>

## Índices, PKs, FKs e constraints

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [indices_status.sql](diagnostico/indices_status.sql) | Consulta | Consultar indices e particoes indisponiveis |
| [tabelas_sem_pk.sql](diagnostico/tabelas_sem_pk.sql) | Consulta | Localizar tabelas sem primary key no schema |
| [tabelas_sem_indices.sql](diagnostico/tabelas_sem_indices.sql) | Consulta | Localizar tabelas sem indices registrados |
| [constraints_status.sql](diagnostico/constraints_status.sql) | Consulta | Consultar estado e validacao de constraints |
| [foreign_keys_colunas.sql](diagnostico/foreign_keys_colunas.sql) | Consulta | Relacionar colunas de FKs as chaves referenciadas |
| [indices_colunas.sql](diagnostico/indices_colunas.sql) | Consulta | Consultar colunas e ordem dos indices |
| [indices_uso.sql](diagnostico/indices_uso.sql) | Consulta | Consultar registros de monitoramento de indices |
| [extrair_indices_tabela.sql](geradores/extrair_indices_tabela.sql) | Gera DDL | Extrair DDL dos indices de uma tabela propria |
| [extrair_constraints_tabela.sql](geradores/extrair_constraints_tabela.sql) | Gera DDL | Extrair constraints definidas em uma tabela propria |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="estatisticas"></a>

## Estatísticas e preservação do estado anterior

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [estatisticas_pendentes.sql](diagnostico/estatisticas_pendentes.sql) | Consulta | Identificar estatisticas ausentes, stale ou bloqueadas |
| [estatisticas_historico.sql](diagnostico/estatisticas_historico.sql) | Consulta | Consultar datas do historico de estatisticas por tabela |
| [estatisticas_automaticas.sql](diagnostico/estatisticas_automaticas.sql) | Consulta | Consultar estado da tarefa automatica de estatisticas |
| [criar_tabela_estatisticas.sql](manutencao/criar_tabela_estatisticas.sql) | Intervenção | Criar repositorio de estatisticas no proprio schema |
| [exportar_estatisticas_tabela.sql](manutencao/exportar_estatisticas_tabela.sql) | Intervenção | Exportar estatisticas de uma tabela sem sobrescrever statid |
| [coletar_estatisticas_tabela.sql](manutencao/coletar_estatisticas_tabela.sql) | Intervenção | Preservar e coletar estatisticas de uma tabela propria |
| [importar_estatisticas_tabela.sql](manutencao/importar_estatisticas_tabela.sql) | Intervenção | Restaurar estatisticas exportadas da mesma tabela |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="seguranca"></a>

## Usuários, privilégios, profiles, auditoria e TDE

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [privilegios_usuario.sql](diagnostico/privilegios_usuario.sql) | Consulta | Listar concessoes diretas para usuario ou role |
| [usuarios.sql](diagnostico/usuarios.sql) | Consulta | Consultar estado das contas sem hashes ou senhas |
| [profiles_limites.sql](diagnostico/profiles_limites.sql) | Consulta | Consultar limites configurados em profiles |
| [auditoria_politicas.sql](diagnostico/auditoria_politicas.sql) | Consulta | Consultar configuracao de politicas de auditoria unificada |
| [tde_wallet_status.sql](diagnostico/tde_wallet_status.sql) | Consulta | Consultar estado do keystore TDE sem exportar chaves |
| [extrair_privilegios_usuario.sql](geradores/extrair_privilegios_usuario.sql) | Gera DDL | Extrair grants diretos do usuario conectado |
| [extrair_grants_objeto.sql](geradores/extrair_grants_objeto.sql) | Gera DDL | Extrair grants publicados em um objeto proprio |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="rede"></a>

## Serviços, links, sinônimos e ACLs de rede

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [database_links.sql](diagnostico/database_links.sql) | Consulta | Consultar metadados de database links sem senhas |
| [sinonimos.sql](diagnostico/sinonimos.sql) | Consulta | Consultar destinos de sinonimos |
| [servicos_banco.sql](diagnostico/servicos_banco.sql) | Consulta | Consultar servicos registrados no container |
| [acl_rede.sql](diagnostico/acl_rede.sql) | Consulta | Consultar entradas de ACL de rede para um principal |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="asm"></a>

## ASM: disk groups e discos

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [asm_capacidade.sql](diagnostico/asm_capacidade.sql) | Consulta | Consultar capacidade util dos disk groups |
| [asm_discos.sql](diagnostico/asm_discos.sql) | Consulta | Consultar estado e capacidade dos discos ASM |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="data-guard"></a>

## Data Guard: papel, transporte e gap

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [data_guard_status.sql](diagnostico/data_guard_status.sql) | Consulta | Consultar papel e transporte Data Guard |
| [data_guard_gap.sql](diagnostico/data_guard_gap.sql) | Consulta | Consultar gap bloqueante registrado no standby |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="datapump"></a>

## Data Pump e objetos DIRECTORY

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [datapump_jobs.sql](diagnostico/datapump_jobs.sql) | Consulta | Consultar jobs Data Pump existentes |
| [directories.sql](diagnostico/directories.sql) | Consulta | Consultar objetos DIRECTORY visiveis |

[Voltar aos assuntos](#encontrar-pelo-assunto).

<a id="adr"></a>

## ADR e alert log

| Arquivo | Finalidade | Informação disponibilizada |
|---|---|---|
| [alertas_recentes.sql](diagnostico/alertas_recentes.sql) | Consulta | Consultar erros e avisos do ADR no periodo |

[Voltar aos assuntos](#encontrar-pelo-assunto).

## Organização do conteúdo

Cada tarefa tem um arquivo canônico. Nomes diferentes para consultas equivalentes não exigem cópias públicas; consultas com objetivos distintos permanecem separadas. Os cadernos originais não são um roteiro único de execução. A [curadoria](CURADORIA.md) descreve a incorporação e os originais continuam preservados fora do projeto.
