# Administrar Data Guard com Broker

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c single instance, primário ORCL_PRI e standby ORCL_STB previamente validados.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Conclua [o standby físico](<Criar standby fisico com Data Guard.md>). Confirme mesmos DB_NAME/DBID, DB_UNIQUE_NAME distintos, transporte/aplicação e parâmetros persistentes. Planeje backups, janela e contatos da aplicação para cada troca de papel. Este guia não habilita Fast-Start Failover nem cria observer.

Sem Oracle Restart, serviços estáticos e `StaticConnectIdentifier` válidos são necessários para operações que reiniciam instâncias. Configure aliases e password files; o Broker não corrige autenticação, DNS ou listener incorretos por existir.

## 1. Preparar o controle por Broker

Registre configurações atuais, locais dos arquivos Broker e faça cópia de segurança. Em cada banco:

```sql
SHOW PARAMETER dg_broker_config_file
ALTER SYSTEM SET dg_broker_start=TRUE SCOPE=BOTH;
```

Na migração do gerenciamento manual para Broker, confira a exigência sobre destinos de transporte `SERVICE=` não gerenciados. O modelo de laboratório usa DEST_2: em janela com capacidade de archive assegurada, preserve a string atual e retire **apenas o destino que será transferido ao Broker**, no(s) membro(s) correspondente(s), conforme o guia. Isso pode pausar transporte até a configuração ser habilitada; não apague destinos de backup/outros standbys indiscriminadamente.

## 2. Criar a configuração — DGMGRL

Inicie `dgmgrl` e conecte com senha no prompt:

```text
CONNECT sys@ORCL_PRI;
CREATE CONFIGURATION LAB_DG AS PRIMARY DATABASE IS ORCL_PRI CONNECT IDENTIFIER IS ORCL_PRI;
ADD DATABASE ORCL_STB AS CONNECT IDENTIFIER IS ORCL_STB MAINTAINED AS PHYSICAL;
ENABLE CONFIGURATION;
SHOW CONFIGURATION;
SHOW DATABASE VERBOSE ORCL_PRI;
SHOW DATABASE VERBOSE ORCL_STB;
```

Confira se nomes/configuração já existem antes de criar. Após habilitar, verifique os destinos gerados e retomada de transporte/apply; se falhar, preserve o erro e recupere o gerenciamento pelo plano anterior, evitando dois controladores concorrentes.

## 3. Validar rede, configuração e prontidão

```text
VALIDATE DATABASE VERBOSE ORCL_PRI;
VALIDATE DATABASE VERBOSE ORCL_STB;
VALIDATE NETWORK CONFIGURATION FOR ALL;
VALIDATE STATIC CONNECT IDENTIFIER FOR ORCL_PRI;
VALIDATE STATIC CONNECT IDENTIFIER FOR ORCL_STB;
```

Revise `DGConnectIdentifier` e `StaticConnectIdentifier` de cada membro, incluindo host, porta e serviço estático real. Os defaults dependem do ambiente; ajuste as propriedades pelo guia quando divergem. Esses checks não substituem acompanhar lag, DATUM_TIME, gaps, SRLs e teste funcional.

## 4. Switchover planejado

1. Confirme saúde, ausência de gaps relevantes e prontidão de ambos para a mudança.
2. Interrompa/drene consumidores conforme o plano e confirme serviços pós-troca.
3. No DGMGRL conectado ao membro apropriado, com destino validado:

```text
SWITCHOVER TO ORCL_STB;
SHOW CONFIGURATION;
SHOW DATABASE VERBOSE ORCL_PRI;
SHOW DATABASE VERBOSE ORCL_STB;
```

Valide que ORCL_STB virou PRIMARY e ORCL_PRI virou PHYSICAL STANDBY com apply. Teste serviço/aplicação no novo primário e backups. Trocar de volta exige nova avaliação e outro switchover planejado; não execute imediatamente só para esconder falha de teste.

## 5. Failover e reintegração — contingência separada

Failover é diferente de switchover. Antes dele, confirme indisponibilidade real, perda de dados possível e **isole o antigo primário** para impedir duas cópias primárias aceitando escrita. A perda depende do modo de proteção e do redo efetivamente recebido/aplicado; ASYNC não promete RPO zero.

Somente na contingência confirmada, o comando é `FAILOVER TO ORCL_STB;` quando ORCL_STB for o destino correto naquele momento. Não o execute como etapa obrigatória após o switchover de teste. Direcione clientes e valide o novo primário.

Reinstatement pode ser possível com flashback e condições atendidas; use `REINSTATE DATABASE` apenas para o membro identificado como elegível pelo Broker. Caso contrário, reconstrua o standby a partir do primário atual. Não reconecte o antigo primário como banco gravável nem emita OPEN RESETLOGS para tentar fazê-lo acompanhar.

## 6. Operação e retirada

Registre health, papel, atraso, erros e alterações. Antes de remover/desabilitar a configuração, documente como transporte/apply passarão a ser gerenciados: remover Broker não é equivalente a remover o Data Guard inteiro. Confirme serviços estáticos, passwords e arquivos de configuração em backups; mantenha um ensaio periódico de troca de papéis e de contingência isolada.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [data_guard_status.sql](scripts/diagnostico/data_guard_status.sql) — Consultar papel e transporte Data Guard.

## Roteiros de solução de problemas

- [19 · Standby atrasado ou com gap de archives](solucao-de-problemas/19-data-guard-atraso-e-gap.md).

## Referências oficiais

- [Comandos Broker](https://docs.oracle.com/en/database/oracle/oracle-database/19/dgbkr/oracle-data-guard-broker-commands.html)
- [Gerenciar membros e validar](https://docs.oracle.com/en/database/oracle/oracle-database/19/dgbkr/managing-oracle-data-guard-broker-configuration-members.html)
