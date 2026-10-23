# Referência opcional para exercícios em Oracle

**Estado:** referência opcional. O mantenedor informou que os scripts já foram tratados e não exige nova validação para publicação.

Para quem optar por usar este roteiro no futuro, ele utiliza uma instância **Oracle 19c de laboratório**, com dados descartáveis. Sua execução não integra as pendências de publicação. Não há conexão automática, senha no projeto ou execução desse roteiro pelo verificador local.

## Preparar

1. Use uma PDB descartável READ WRITE em banco PRIMARY, com usuário local `APP_LAB`, não mantido pela Oracle. Registre versão/RU, cliente, serviço, DBID, container e instância.
2. Um administrador deve revisar e fornecer quota e privilégios necessários. O fluxo cria tabela, procedure, job e repositório próprios; precisa de CREATE SESSION/TABLE/PROCEDURE/JOB, EXECUTE nas APIs usadas e leitura de `V_$DATABASE`/`V_$PDBS`. Não conceda DBA para contornar um erro. Não execute como SYS.
3. Abra SQL*Plus 19c dedicado, a partir da raiz do projeto, e execute `@scripts/iniciar_sessao.sql`. Consulte `@scripts/diagnostico/identidade_banco.sql`, se houver os acessos adicionais do cabeçalho, ou confira a identidade com o administrador.
4. Preencha `p_dbid_esperado` e `p_container_esperado` com os valores conferidos. Para o fluxo, preencha `p_confirmacao='HOMOLOGAR_BIBLIOTECA'`. O fluxo não obtém automaticamente esses valores esperados.
5. Confira que os nomes reservados `T_BIB_TEST`, `PK_BIB_TEST`, `T_BIB_IOT`, `PK_BIB_IOT`, `CK_BIB_IOT`, `FK_BIB_IOT`, `S_BIB_TEST`, `P_BIB_TEST` e `J_BIB_TEST` estão livres no schema. O teste recusa colisões e não remove objetos preexistentes. O fluxo exige `PUBLISH=TRUE`, `PREFERENCE_OVERRIDES_PARAMETER=FALSE` e ausência de estatísticas pendentes nas operações de estatísticas; ele não muda essas preferências.

## Fluxo nominal com alterações

Execute [validar_fluxo.sql](validar_fluxo.sql) com `@tests/oracle/validar_fluxo.sql`. Ele usa os scripts reais via `@@`, em uma conexão explicitamente preparada, e verifica:

- criação de repositório pela API, exportação e coleta com preservação anterior;
- estatísticas de 10 linhas antes, 20 após coleta e retorno para 10 após importação;
- constraints: tabela sem constraints, somente NOT NULL, PK de IOT, FK de saída, CHECK e PK de tabela heap; ausência exportável retorna NULL;
- recompilação de uma procedure própria e verificação do estado;
- cinco geradores, incluindo DDL de tabela, índice, constraints, grants e recompilação;
- habilitação e desabilitação de um job local com início futuro e confirmação de estado.

O fluxo interrompe em erro e preserva os objetos/evidências. Não executa KILL SESSION. Não remove os objetos ao terminar; confirme que o job está desabilitado e faça a limpeza manual pelo administrador após guardar as evidências. Uma segunda execução exige essa limpeza deliberada. O job usa `BEGIN NULL; END;` e início 30 dias no futuro; seu agendamento deve continuar sendo conferido no laboratório.

## Falhas esperadas — cliente novo por caso

Os scripts encerram SQL*Plus em erro. Por isso cada caso deve começar com uma conexão dedicada nova e o inicializador. Confira **código de saída diferente de zero e mensagem esperada**, além da ausência de alteração no alvo; uma falha de privilégio anterior à guarda não demonstra que a guarda funcionou.

| Caso | Preparação | Resultado esperado |
|---|---|---|
| Confirmação ausente/incorreta | Qualquer manutenção, contexto e nome válidos, token NULL/incorreto | ORA-20001; sem ação. |
| DBID/container divergente | Token correto, altere um valor esperado | ORA-20002; sem ação. |
| Root, seed, standby, PDB READ ONLY | Contexto isolado apropriado, token correto | Recusa da guarda ou proteção nativa; não force abertura/papel para testar. |
| Outro owner, CURRENT_SCHEMA divergente, usuário comum ou mantido pela Oracle | Contexto isolado e direitos de leitura das views | ORA-20003 ou recusa anterior de contexto; não alterar conta protegida. |
| Nome inválido ou tipo fora da lista | Recompilação, com contexto correto | ORA-20004/20013 antes do DDL. |
| Repositório já existente | Criação com `p_nome` usado | ORA-20009; não remover nem sobrescrever. |
| Statid repetido | Exportação/coleta com statid usado | ORA-20010; preserva a exportação anterior. |
| Tabela sem stats, particionada, externa ou bloqueada | Exportação/coleta | Recusa de escopo ou ORA-20008/20011; sem desbloqueio automático. |
| Importação sem backup | Statid inexistente | ORA-20012; sem importação. |
| Estatísticas não publicadas | Preferência efetiva PUBLISH=FALSE no alvo | ORA-20021 em exportação/coleta/importação, antes da API de alteração; nenhuma preferência modificada. |
| Estatísticas pendentes preexistentes | Alvo com linhas em USER_TAB_PENDING_STATS e PUBLISH=TRUE | ORA-20022; pendências preservadas, sem exportação/coleta/importação. |
| Preferências sobrepõem parâmetros | PUBLISH=TRUE, sem pendências, PREFERENCE_OVERRIDES_PARAMETER=TRUE | ORA-20023 na coleta antes da exportação; não altera preferências nem coleta com degree inesperado. |
| Backup de outro objeto | Statid existente de tabela diferente | API deve recusar/sem conjunto compatível; conferir stats do alvo. |
| Compilação com erro | Procedure própria que fique INVALID | Falha nativa/ORA-20015; não anunciar sucesso; consultar USER_ERRORS. |
| Sessão divergente ou própria | KILL com SID/SERIAL incorretos ou própria sessão | ORA-20016/20017; nenhuma sessão encerrada. |
| Instância divergente | KILL com `p_instancia_esperada` diferente de INSTANCE_NUMBER | ORA-20016; nenhuma sessão encerrada. |
| Job em execução/externo/sem correspondência | Alteração de estado | ORA-20019/20020 ou recusa nativa em corrida; sem FORCE. |
| Privilégio insuficiente | Conta de teste sem uma permissão necessária | Falha nativa e código de saída de falha, sem reconexão/grant automático. |
| Gerador para outro owner/tipo proibido | Altere owner/tipo no gerador | ORA-20030/20031; nenhum DDL executado. |

Repetir o token após uma falha exige novo preparo. Verifique que `p_confirmacao` foi consumido quando a validação chegou ao bloco. Erros de compilação/privilégio podem ocorrer antes de o bloco começar; por isso abrir uma nova sessão é parte do teste.

## Diagnóstico e bordas

Execute cada uma das [77 consultas](../../scripts/diagnostico/README.md) no escopo/privilégio do seu cabeçalho. Registre sucesso, zero linhas legítimo ou falha esperada com justificativa; não converta ausência em saúde. Os cenários mínimos são:

| Família | Caso a conferir em Oracle |
|---|---|
| Identidade/usuários/privilégios/NLS/parâmetros | Conferir container/instância/owner, grants diretos e valores de sessão. |
| Sessões/SQL/processos/bloqueios | Cursor filho correto, SQL fora do cache, SID repetido em RAC quando disponível, sessão encerrada durante coleta. |
| UNDO/TEMP | Tamanho real do bloco, sessão ausente/reutilizada e nenhuma transação/segmento temporário. |
| Tablespaces/datafiles/I/O | Múltiplos arquivos/extents, arquivo cheio sem linha de espaço livre, offline, read only, autoextend e contadores zero. |
| SGA/PGA/latches/hit ratio | Contadores desde startup, NULL/zero e amostragem de intervalo independente. |
| FRA/RMAN/redo/corrupções | Root/non-CDB, histórico vazio, várias cópias de archive e FRA desconfigurada; não apagar arquivos. |
| Data Guard/ASM | Conexões separadas adequadas; primary/standby, ausência de lag aplicável e redundância ASM. |
| Scheduler/DBMS_JOB/Data Pump | Owners com mesmo nome de job, job removido, histórico vazio e job não ativo. |
| Objetos/stats/índices/LOB/dependências | INVALID sem erros de compilação, stats bloqueadas, partições UNUSABLE, LOB particionado/diferido e dependência dinâmica ausente. |
| ADR/auditoria | Janela de tempo e tipos de mensagem, política habilitada/desabilitada, privilégios e volume. |

## Geradores e encerramento de sessão

Nos geradores, valide conteúdo completo do CLOB, terminadores, saída sem índices/grants e erros de objeto inexistente. Teste tamanho maior que SET LONG para reconhecer truncamento; não execute a saída automaticamente. Confira que nenhum transform DBMS_METADATA da sessão foi alterado. Confira duplicações quando DDL de tabela e índices/constraints forem extraídos separadamente.

O caso nominal de KILL exige **uma segunda conexão descartável**, usuário alvo local não mantido pela Oracle e privilégios específicos na conexão administrativa. Confirme instância, container, SID, SERIAL e usuário em uma nova leitura, preencha os binds incluindo `p_instancia_esperada` (número da instância do alvo) e use `p_confirmacao='ENCERRAR'`. Valide desconexão, eventual rollback e continuidade das demais sessões. Não há desfazer dessa sessão. Esse teste é separado do fluxo para impedir que um identificador copiado de outro ambiente vire alvo acidental.

Registre evidências fora do Git: parâmetros sem segredo, mensagens, retorno do cliente, comparação antes/depois e restauração aplicável. Só atualize o estado de homologação dos arquivos realmente executados, identificando versão/RU, topologia e cliente. Não marque toda a biblioteca como homologada com base em um único fluxo.

Voltar à [biblioteca](../../scripts/README.md).
