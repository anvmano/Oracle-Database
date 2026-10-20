# Manutenção · scripts Oracle DBA

**Organização editorial:** 20/10/2026 · conteúdo previamente tratado, conforme informado pelo mantenedor.

Leia primeiro o [contrato de execução](../README.md) e prepare a sessão com [iniciar_sessao.sql](../iniciar_sessao.sql).

## Antes de intervir

Escopo restrito: usuário local não mantido pela Oracle, schema próprio, PDB aberta READ WRITE ou non-CDB PRIMARY READ WRITE. Root, seed, standby e usuários comuns são recusados. Todas as intervenções conferem DBID/container dentro do mesmo bloco da ação. A confirmação específica é consumida antes da validação: repita a preparação deliberadamente para uma nova execução.

Use os privilégios específicos e confira o alvo da operação. `ROLLBACK` em erro não desfaz DDL nem todas as APIs. Não há exclusão, purge, rebuild em massa, coleta em todos os schemas ou alteração automática de parâmetros.

### Parâmetros de intervenção

Após inicializar e consultar `identidade_banco.sql`, copie o **DBID e container realmente conferidos** para os binds. O exemplo apenas mostra o preparo, sem chamar manutenção:

```sql
BEGIN
  :p_owner := 'APP_LAB';
  :p_nome := 'TABELA_LAB';
  :p_dbid_esperado := 1234567890;
  :p_container_esperado := 'LABPDB';
  :p_stat_table := 'STATS_LAB';
  :p_statid := 'ANTES_COLETA_01';
  :p_confirmacao := 'COLETAR_STATS';
END;
/
```

O DBID fictício deve ser substituído após conferência. Não preencha os valores esperados por uma consulta automática dentro do script: isso eliminaria a confirmação independente do alvo.

| Arquivo | Confirmação exata | Efeito e retorno |
|---|---|---|
| `criar_tabela_estatisticas.sql` | `CRIAR_STAT_TABLE` | Cria uma tabela de estatísticas pelo DBMS_STATS, exige quota e nome livre. Não remove ao terminar. |
| `exportar_estatisticas_tabela.sql` | `EXPORTAR_STATS` | Insere no repositório existente com statid novo; registre tabela, statid, data e contexto fora do Git. |
| `coletar_estatisticas_tabela.sql` | `COLETAR_STATS` | Exporta antes e coleta com degree 1. Em falha, preserve repositório; a exportação pode ter persistido. Retorno: importar o backup correto. |
| `importar_estatisticas_tabela.sql` | `IMPORTAR_STATS` | Restaura as estatísticas da tabela do statid conferido. Não desfaz dados e pode mudar planos. |
| `recompilar_objeto.sql` | `RECOMPILAR` | Compila um objeto/tipo, verifica status e erros. Dependentes podem invalidar. Preserve a fonte anterior para restaurar uma alteração de código. |
| `encerrar_sessao.sql` | `ENCERRAR` | KILL SESSION local, sem IMMEDIATE. Exige SID, SERIAL e usuário conferidos. Não há retorno da sessão; rollback/reconexão exigem acompanhamento. |
| `alterar_estado_job.sql` | `ALTERAR_JOB` | ENABLE/DISABLE de job próprio simples, não em execução. Repor o estado anterior não desfaz trabalho que tenha iniciado. |

### Estatísticas

Use um repositório criado pela API e uma tabela permanente, própria, não particionada, não externa, não aninhada, sem estatísticas bloqueadas. A coleta exige estatísticas anteriores para preservar; a primeira coleta de tabela sem estatísticas fica no tutorial, com decisão explícita. Não há `force` para ignorar locks. O mesmo statid não é sobrescrito.

1. Crie o repositório uma vez (`p_nome` é o nome da tabela de estatísticas nesse arquivo).
2. Para exportação/coleta/importação, `p_nome` passa a ser a tabela de aplicação, `p_stat_table` o repositório e `p_statid` um identificador novo de até 30 caracteres.
3. Consulte as estatísticas antes e depois; guarde a relação tabela/statid. A mera presença de linhas com esse statid não garante que ele pertence à tabela desejada; o DBMS_STATS faz a seleção do objeto e pode rejeitar um conjunto incompatível.
4. Se precisar retornar, use a importação deliberada do mesmo objeto. Preserve a exportação até avaliar o plano e o comportamento da aplicação.

Exportar, coletar e importar usam APIs que podem confirmar trabalho independentemente da transação chamadora. Backup e coleta não são atômicos; `ROLLBACK` não é o mecanismo de retorno.

### Sessões, compilação e jobs

KILL exige conexão administrativa **não mantida pela Oracle**, leitura autorizada das views e `ALTER SYSTEM`; a sessão alvo deve estar no mesmo container/instância, pertencer a usuário local não mantido pela Oracle e ter SID/SERIAL ainda válidos. Preencha também `p_instancia_esperada` com o número da instância do alvo conferido na consulta (INST_ID/INSTANCE_NUMBER). A rotina o compara à instância local antes de agir. Os privilégios não são concedidos pelo arquivo. Em RAC, conecte à instância do alvo; não há montagem automática de comando remoto.

Recompilação aceita apenas PROCEDURE, FUNCTION, VIEW, PACKAGE, PACKAGE BODY e TRIGGER. A especificação de package e seu body são alvos distintos. Não compila TYPE nem objetos em todos os schemas. Falhas permanecem erros, inclusive quando o DDL executa mas o objeto continua inválido.

Para jobs, confira `job_action`, agendamento e estado usando a consulta de Scheduler. Só entram jobs locais simples PLSQL_BLOCK/STORED_PROCEDURE, sem program/schedule nomeados, credencial ou destino externo. **ENABLE pode executar imediatamente um agendamento vencido.** Não há parada forçada de job.

## Catálogo

Também é possível procurar pelo [catálogo por assunto](../CATALOGO.md).

| Arquivo e objetivo | Binds | Views/APIs e direitos específicos | Tutorial e limite |
|---|---|---|---|
| [criar_tabela_estatisticas.sql](criar_tabela_estatisticas.sql) — Criar repositorio de estatisticas no proprio schema | p_owner; p_dbid_esperado; p_container_esperado; p_confirmacao=CRIAR_STAT_TABLE; p_nome (novo repositorio) | V$DATABASE, V$PDBS, USER_USERS, USER_OBJECTS; EXECUTE em DBMS_STATS; CREATE TABLE e quota | [Gerenciar estatisticas com DBMS_STATS](<../../Gerenciar estatisticas com DBMS_STATS.md>). DDL pode confirmar transacoes; repositorio ocupa quota. Nao ha DROP automatico. |
| [exportar_estatisticas_tabela.sql](exportar_estatisticas_tabela.sql) — Exportar estatisticas de uma tabela sem sobrescrever statid | p_owner; p_dbid_esperado; p_container_esperado; p_confirmacao=EXPORTAR_STATS; p_nome; p_stat_table; p_statid | V$DATABASE, V$PDBS, USER_USERS, USER_TABLES, USER_EXTERNAL_TABLES, USER_TAB_STATISTICS; EXECUTE DBMS_STATS/DBMS_ASSERT; repositorio proprio | [Gerenciar estatisticas com DBMS_STATS](<../../Gerenciar estatisticas com DBMS_STATS.md>). Exporta dados no repositorio; registre a relacao tabela/statid. API pode confirmar trabalho. |
| [coletar_estatisticas_tabela.sql](coletar_estatisticas_tabela.sql) — Preservar e coletar estatisticas de uma tabela propria | p_owner; p_dbid_esperado; p_container_esperado; p_confirmacao=COLETAR_STATS; p_nome; p_stat_table; p_statid (novo) | V$DATABASE, V$PDBS, USER_USERS, USER_TABLES, USER_EXTERNAL_TABLES, USER_TAB_STATISTICS; EXECUTE DBMS_STATS/DBMS_ASSERT; repositorio proprio | [Gerenciar estatisticas com DBMS_STATS](<../../Gerenciar estatisticas com DBMS_STATS.md>). Pode gerar I/O e mudar planos. Backup e coleta nao sao uma transacao atomica; retorne com IMPORT, nunca ROLLBACK. |
| [importar_estatisticas_tabela.sql](importar_estatisticas_tabela.sql) — Restaurar estatisticas exportadas da mesma tabela | p_owner; p_dbid_esperado; p_container_esperado; p_confirmacao=IMPORTAR_STATS; p_nome; p_stat_table; p_statid previamente conferido | V$DATABASE, V$PDBS, USER_USERS, USER_TABLES, USER_EXTERNAL_TABLES, USER_TAB_STATISTICS; EXECUTE DBMS_STATS/DBMS_ASSERT; repositorio proprio | [Gerenciar estatisticas com DBMS_STATS](<../../Gerenciar estatisticas com DBMS_STATS.md>). Confira a origem do statid; existencia de linhas nao prova que o backup e da tabela. A API pode falhar ou alterar planos. |
| [recompilar_objeto.sql](recompilar_objeto.sql) — Recompilar um objeto proprio por tipo permitido | p_owner; p_dbid_esperado; p_container_esperado; p_confirmacao=RECOMPILAR; p_nome; p_tipo (PROCEDURE/FUNCTION/VIEW/PACKAGE/PACKAGE BODY/TRIGGER) | V$DATABASE, V$PDBS, USER_USERS, USER_OBJECTS, USER_ERRORS; EXECUTE DBMS_ASSERT; direito de compilar objeto proprio | [Diagnosticar objetos invalidos](<../../Diagnosticar objetos invalidos.md>). DDL confirma transacoes e pode invalidar dependentes; nao recompila schema inteiro nem mascara falha. |
| [encerrar_sessao.sql](encerrar_sessao.sql) — Solicitar encerramento de uma sessao local identificada | p_owner; p_dbid_esperado; p_container_esperado; p_confirmacao=ENCERRAR; p_sid; p_serial; p_usuario_alvo; p_instancia_esperada (numero) | V$DATABASE, V$PDBS, USER_USERS, V$SESSION, V$INSTANCE, DBA_USERS; ALTER SYSTEM; EXECUTE DBMS_ASSERT | [Monitorar sessoes e bloqueios](<../../Monitorar sessoes e bloqueios.md>). Somente instancia local; sem IMMEDIATE/FORCE. Rollback pode demorar; reconexao exige acao da aplicacao. |
| [alterar_estado_job.sql](alterar_estado_job.sql) — Habilitar ou desabilitar um job local proprio | p_owner; p_dbid_esperado; p_container_esperado; p_confirmacao=ALTERAR_JOB; p_nome; p_acao=ENABLE ou DISABLE | V$DATABASE, V$PDBS, USER_USERS, USER_SCHEDULER_JOBS, USER_SCHEDULER_RUNNING_JOBS; EXECUTE DBMS_SCHEDULER/DBMS_ASSERT | [Criar e monitorar jobs com DBMS_SCHEDULER](<../../Criar e monitorar jobs com DBMS_SCHEDULER.md>). ENABLE pode disparar trabalho vencido; revisar JOB_ACTION antes. API confirma; desfazer estado nao desfaz trabalho executado. |

## Referências oficiais

[Oracle Database Reference 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html), [PL/SQL Packages and Types Reference](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/index.html), [SQL*Plus User’s Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqpug/index.html).

Voltar ao [índice da biblioteca](../README.md).
