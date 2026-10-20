# Oracle DBA · Índice dos 20 roteiros de solução de problemas

[← Índice do projeto](README.md) · [Catálogo de scripts](scripts/CATALOGO.md) · [Como executar os arquivos](scripts/README.md)

**Escopo:** administração Oracle Database 19c, com diagnóstico apoiado nos arquivos deste projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

Esta é uma seleção prática de **20 situações recorrentes na operação de bancos Oracle**, escolhidas pela relevância administrativa e pela cobertura do acervo. A numeração serve para navegação; não representa frequência estatística, uma pesquisa dos ambientes do mantenedor ou uma classificação universal de todos os SGBDs. O método combina sintomas, evidências, identificação da causa e acompanhamento do efeito da correção. A Oracle relaciona SQL de alto consumo, contenção, memória e regressão de desempenho entre os problemas comuns de sua metodologia de desempenho. [Método Oracle de desempenho](https://docs.oracle.com/en/database/oracle/oracle-database/19/tdppt/oracle-database-performance-method.html).

Os arquivos de diagnóstico coletam informações; os de manutenção alteram um alvo; os geradores apenas produzem DDL. Os roteiros individuais não executam automaticamente todos esses grupos nem acrescentam uma exigência de nova validação dos scripts. **Confirmar a retomada** significa observar o resultado da solução durante o incidente.

Cada problema tem um arquivo Markdown próprio na pasta `solucao-de-problemas/`, com sintomas, passos de solução, arquivos relacionados e fontes oficiais. Este índice concentra a navegação e a preparação compartilhada.

## Encontrar o problema

| Nº | Problema | Sinal ou erro frequente | Roteiro |
|---|---|---|---|
| <a id="problema-01"></a>01 | Falha de conexão, listener ou serviço | ORA-12541, ORA-12514, ORA-12154 | [Conexão](solucao-de-problemas/01-conexao-listener-servico.md) |
| <a id="problema-02"></a>02 | Conta bloqueada ou senha expirada | ORA-28000, ORA-28001 | [Conta](solucao-de-problemas/02-conta-bloqueada-senha-expirada.md) |
| <a id="problema-03"></a>03 | Privilégio insuficiente ou objeto não acessível | ORA-01031, ORA-00942 | [Acesso](solucao-de-problemas/03-privilegios-e-acesso-a-objetos.md) |
| <a id="problema-04"></a>04 | Limite de processos ou sessões atingido | ORA-00020, ORA-00018 | [Conexões e recursos](solucao-de-problemas/04-limite-de-processos-e-sessoes.md) |
| <a id="problema-05"></a>05 | SQL lento e alto consumo de CPU ou I/O | Aumento de latência, leituras ou esperas | [Desempenho](solucao-de-problemas/05-sql-lento-cpu-e-io.md) |
| <a id="problema-06"></a>06 | Bloqueios, transações presas e deadlocks | Esperas de lock, ORA-00054, ORA-00060 | [Concorrência](solucao-de-problemas/06-bloqueios-transacoes-e-deadlocks.md) |
| <a id="problema-07"></a>07 | Plano ruim associado a estatísticas ausentes ou alteradas | Regressão após carga/coleta, estimativas inadequadas | [Estatísticas](solucao-de-problemas/07-estatisticas-e-regressao-de-plano.md) |
| <a id="problema-08"></a>08 | Falta de espaço permanente ou quota | ORA-01653, ORA-01654, ORA-01950, ORA-01536 | [Tablespaces e quota](solucao-de-problemas/08-espaco-permanente-e-quota.md) |
| <a id="problema-09"></a>09 | Falta de espaço para operações temporárias | ORA-01652 | [TEMP](solucao-de-problemas/09-espaco-temporario.md) |
| <a id="problema-10"></a>10 | Pressão de UNDO ou perda de versão para leitura | ORA-30036, ORA-01555 | [UNDO](solucao-de-problemas/10-pressao-de-undo-e-ora-01555.md) |
| <a id="problema-11"></a>11 | FRA cheia ou falha de arquivamento | ORA-19809, ORA-19804, ORA-00257 | [FRA e archives](solucao-de-problemas/11-fra-e-arquivamento.md) |
| <a id="problema-12"></a>12 | Falta de memória compartilhada ou pressão de PGA | ORA-04031, ORA-04030, ORA-04036 | [SGA e PGA](solucao-de-problemas/12-memoria-sga-e-pga.md) |
| <a id="problema-13"></a>13 | Excesso de cursores abertos por sessão | ORA-01000 | [Cursores](solucao-de-problemas/13-excesso-de-cursores.md) |
| <a id="problema-14"></a>14 | Índice ou partição de índice inutilizável | ORA-01502, UNUSABLE | [Índices](solucao-de-problemas/14-indices-inutilizaveis.md) |
| <a id="problema-15"></a>15 | Objeto inválido ou erro de compilação | ORA-04063, ORA-06508 | [Objetos](solucao-de-problemas/15-objetos-invalidos.md) |
| <a id="problema-16"></a>16 | Job falhando, atrasado ou sem execução | FAILED, BROKEN, ausência de execução esperada | [Agendamento](solucao-de-problemas/16-jobs-com-falha-ou-atraso.md) |
| <a id="problema-17"></a>17 | Exportação/importação Data Pump falhando ou parada | ORA-39070, ORA-31640, erros no log do job | [Data Pump](solucao-de-problemas/17-falhas-no-data-pump.md) |
| <a id="problema-18"></a>18 | Backup RMAN falhando ou não acontecendo | FAILED, erros RMAN/ORA, ausência de execução | [Backup](solucao-de-problemas/18-falhas-no-backup-rman.md) |
| <a id="problema-19"></a>19 | Standby atrasado ou com gap de archives | Transport lag, apply lag, gap ou erro de destino | [Data Guard](solucao-de-problemas/19-data-guard-atraso-e-gap.md) |
| <a id="problema-20"></a>20 | Corrupção de blocos ou falha de leitura de dados | ORA-01578; ORA-01110 identifica o arquivo associado | [Corrupção](solucao-de-problemas/20-corrupcao-de-blocos.md) |

## Roteiro comum de atendimento

1. **Delimitar o impacto:** horário e fuso, aplicação/operação afetada, mensagem completa, usuários e início do sintoma. Diferencie uma sessão, uma PDB, uma instância e o serviço inteiro.
2. **Confirmar o alvo:** banco/DBID, papel, container, serviço e instância. Para sessões, registre também SID, SERIAL e usuário; em RAC, a instância é parte da identificação.
3. **Ler as evidências antes de alterar:** contexto da aplicação, logs, scripts do caso e mudanças recentes. Contadores acumulados precisam de amostras comparáveis; valores históricos ou zero linhas não descrevem necessariamente o incidente atual.
4. **Escolher o ramo correspondente à causa:** erro de configuração, capacidade física, carga legítima, vazamento, código, permissão ou recuperação. A mesma mensagem pode exigir ações diferentes.
5. **Aplicar a correção delimitada:** use o tutorial relacionado, preserve a configuração/DDL/estatísticas anteriores quando cabível e acompanhe efeitos nas transações e consumidores.
6. **Confirmar a retomada:** repetir a operação afetada e observar o período relevante. Se não houver melhora, retorne à hipótese e às evidências; não acumule alterações sem saber qual produziu efeito.
7. **Evitar recorrência:** ajustar capacidade, código, agendamento, monitoramento ou processo que originou o problema.

Se não for possível conectar ao banco, comece pelas evidências de rede, listener, gerenciador de recursos e logs; os scripts SQL só entram quando houver uma conexão administrativa apropriada. Para processos gerenciados por Oracle Restart/RAC, siga o procedimento do gerenciador existente.

### Preparar uma investigação com a biblioteca

Em uma conexão dedicada, a partir da raiz do projeto:

```sql
@scripts/iniciar_sessao.sql
@scripts/diagnostico/identidade_banco.sql
BEGIN
  :p_owner := 'APP_LAB';
  :p_dias := 1;
END;
/
```

`APP_LAB` é exemplo: use o usuário/schema/principal requerido pelo caso. Execute apenas os arquivos indicados para o problema. Ao mudar de caso ou conexão, reinicialize e preencha os binds novamente. Os scripts com período aceitam `p_dias` entre 1 e 31.

| Bind | Como usar na investigação |
|---|---|
| `p_owner` | Schema, usuário ou grantee exato, conforme o cabeçalho do arquivo. Não é sempre o usuário conectado. |
| `p_nome` | Alvo exato do script: pode ser tabela, objeto, job, profile ou parâmetro. Deixe NULL somente quando o arquivo o declarar opcional. |
| `p_sql_id` | SQL_ID real obtido nas evidências, com 13 caracteres minúsculos. |
| `p_spid` | Processo do servidor, quando usar a associação por processo do SO. |
| Binds de manutenção | São próprios de cada ação. Consulte [manutenção](scripts/manutencao/README.md); não preencha confirmação ou alvo como parte da coleta genérica. |

As consultas locais usam o container conectado; relatórios V$ são locais à instância e GV$ identificam instâncias nas linhas. FRA/RMAN/redo e Data Guard usam o escopo root/non-CDB indicado nos cabeçalhos. ASM exige conexão separada à instância ASM. Os exemplos de criação de objetos dos tutoriais são exercícios; durante um incidente, use o procedimento aplicável ao objeto real, sem criar tabelas de laboratório na aplicação.

## Limites de cobertura e como continuar

Os arquivos existentes sustentam a coleta e os caminhos de solução dos 20 casos. Algumas correções são deliberadamente pontuais: abrir uma PDB, desbloquear uma conta, conceder acesso, ampliar arquivo, reconstruir índice, retomar Data Pump ou recuperar blocos seguem o tutorial/ambiente; não há um executador genérico dessas ações.

Se surgirem ORA-00600/ORA-07445, falhas persistentes de I/O ou necessidade de recuperação sem fonte disponível, preserve ADR/trace, versão/RU, contexto e mudanças recentes. O [guia AHF/TFA](<Coletar diagnosticos com AHF e TFA.md>) oferece coleta para encaminhamento técnico. A lista não tenta converter erros internos distintos em uma correção única.

Para investigação preventiva, use o [checklist diário](<Checklist diario do banco Oracle.md>). Para encontrar outras consultas, use o [catálogo de 90 tarefas](scripts/CATALOGO.md).

## Referências oficiais

As referências de causa/ação estão na seção de fontes oficiais do arquivo de cada problema. Foram usadas documentação Oracle 19c e páginas oficiais de mensagens de erro; as páginas do portal podem exibir também outras releases. Aplique a descrição e as opções correspondentes à versão do banco em atendimento.

- [Mensagens de erro Oracle](https://docs.oracle.com/en/error-help/db/).
- [Método de desempenho e problemas comuns](https://docs.oracle.com/en/database/oracle/oracle-database/19/tdppt/oracle-database-performance-method.html).
- [Introdução ao SQL tuning](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/introduction-to-sql-tuning.html).
- [Scheduler](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/scheduling-jobs-with-oracle-scheduler.html).
- [Data Pump Import](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/datapump-import-utility.html).
- [Troubleshooting RMAN](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/troubleshooting-rman-operations.html).
- [Troubleshooting Data Guard](https://docs.oracle.com/en/database/oracle/oracle-database/19/dgbkr/troubleshooting-oracle-data-guard-broker.html).
