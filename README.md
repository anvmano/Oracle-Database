# Oracle Database · Guias e biblioteca DBA

**Escopo:** 82 tutoriais, 90 tarefas SQL em 17 assuntos e roteiros para 20 problemas recorrentes de administração Oracle.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts previamente tratado pelo mantenedor.

Guias de estudo e operação assistida para **Oracle Database, Linux e OCI**. O acervo reúne 37 tutoriais históricos revisados e 45 novos guias, todos em Markdown, com comandos por ambiente, verificações e fontes oficiais. Há também modelo de tutorial, cenário de laboratório e regras de contribuição.

## Como usar

1. Leia escopo e pré-requisitos do guia antes de copiar comandos.
2. Substitua nomes, paths, dispositivos, serviços e identificadores pelos valores **confirmados no ambiente**. Endereços `192.0.2.0/24`, `198.51.100.0/24` e `203.0.113.0/24` são exemplos de documentação.
3. Execute somente o cenário escolhido. Exemplos alternativos de criação, restauração ou exclusão não formam uma sequência única.
4. Confira o resultado de cada fase antes de avançar. Em erro, preserve logs e diagnostique a causa.
5. Homologue em laboratório representativo antes de aplicar a um ambiente com dados importantes.

| Bloco | Onde executar |
|---|---|
| `bash` | Shell Linux do usuário indicado no passo |
| `powershell` | PowerShell no computador indicado |
| `sql` | SQL*Plus/cliente SQL, conectado ao banco e container indicados |
| `rman` | Prompt RMAN, conectado ao alvo correto |
| `ini`, `text`, `csv` | Conteúdo de arquivo/configuração ou exemplo de saída; não colar no shell |

## Alcance da revisão

**Revisão documental em 20/10/2026.** Foram conferidos sintaxe, sequência, consistência interna, efeitos operacionais e referências disponíveis. Não foram executados instalação, patch, DDL, carga, backup ou recuperação em uma instância Oracle. Certificação, licenciamento, valores de dimensionamento e README de cada patch precisam ser confirmados para a combinação real.

Os guias 12.1, 18c, APEX 19.2, EM 13.3 e RU/RUR 19.5 preservam o contexto histórico do acervo; não representam seleção de versões/patches atuais. RAC e mudanças de plataforma exigem procedimentos próprios. Os novos guias de Data Guard definem um cenário de 19c single instance; não devem ser aplicados automaticamente a outras topologias.

Consulte o [registro da revisão](REVISAO.md) para cobertura, alterações e limites. O ZIP não integra o acervo revisado. A imagem original foi inspecionada e preservada; não é necessária para executar os roteiros.

## Resolver um problema

O [índice dos 20 roteiros de solução](SOLUCAO_DE_PROBLEMAS.md) leva a um arquivo Markdown para cada problema, na pasta `solucao-de-problemas/`. Cada roteiro parte do sintoma/erro e indica os scripts, os tutoriais e a sequência de diagnóstico, correção e confirmação da retomada. Inclui conexão, contas, permissões, desempenho, bloqueios, espaço, memória, jobs, Data Pump, RMAN, Data Guard e corrupção de blocos. A seleção é operacional; a numeração não representa um ranking estatístico.

## Biblioteca SQL e PL/SQL

Os tutoriais agora têm uma [biblioteca de scripts por tarefa](scripts/README.md): **77 consultas de diagnóstico, 7 intervenções e 6 geradores de DDL**, mais o inicializador. Os arquivos executáveis ficam em `.sql`; instruções, limites e exemplos ficam em Markdown. Encontre a tarefa no [catálogo por assunto](scripts/CATALOGO.md) e leia seus parâmetros. O mantenedor informou que o conteúdo dos scripts já foi tratado; nova validação não é pendência para a publicação.

- [Diagnóstico](scripts/diagnostico/README.md): sessões, bloqueios, espaço, memória, backup, jobs, segurança e outros assuntos DBA.
- [Manutenção](scripts/manutencao/README.md): estatísticas com preservação anterior, recompilação, encerramento local de sessão e estado de job.
- [Geradores](scripts/geradores/README.md): DDL de objetos, índices, constraints, grants e comandos de recompilação para revisão.
- [Critérios da curadoria](scripts/CURADORIA.md) e [publicação no GitHub](scripts/PUBLICACAO.md).

## Sistema operacional e scripts

- [Instalação oracle linux](<Instalação oracle linux.md>)
- [Firewall no linux](<Firewall no linux.md>)
- [Aumentar swap e partições](<Aumentar swap e partições.md>)
- [Script monitorar SO](<Script monitorar SO.md>)
- [script startup automatico](<script startup automatico.md>)

## Instalação e gerenciamento

- [Instalação Oracle 12c](<Instalação Oracle 12c.md>)
- [Instalação Oracle 18c](<Instalação Oracle 18c.md>)
- [Instalação Oracle 19c](<Instalação Oracle 19c.md>)
- [Instalação Oracle 19c em Silent mode](<Instalação Oracle 19c em Silent mode.md>)
- [Instalação GRID (12c)](<Instalação GRID (12c).md>)
- [Criar maquina para EM 13](<Criar maquina para EM 13.md>)

## Atualizações e patches

- [Upgrade do oracle 12c para 19.3](<Upgrade do oracle 12c para 19.3.md>)
- [Atualização Apex](<Atualização Apex.md>)
- [upgrade-rollback de patch (12cr1)](<upgrade-rollback de patch (12cr1).md>)
- [Aplicando o Bundle Patch Oracle 12cr1](<Aplicando o Bundle Patch Oracle 12cr1.md>)
- [Aplicar RU no Oracle 19c](<Aplicar RU no Oracle 19c.md>)
- [Release Update Revision 19.5](<Release Update Revision 19.5.md>)
- [RUR Oracle 19.5](<RUR Oracle 19.5.md>)

## Oracle Cloud Infrastructure

- [Criar Chave SSH](<Criar Chave SSH.md>)
- [Criar VCN no OCI](<Criar VCN no OCI.md>)
- [Criar Instancia no OCI](<Criar Instancia no OCI.md>)
- [Acessar instancia no OCI](<Acessar instancia no OCI.md>)
- [Command Line Interface (CLI)](<Command Line Interface (CLI).md>)
- [Instalação do Oracle 19c no OCI](<Instalação do Oracle 19c no OCI.md>)
- [Migrando uma VM do VB para o OCI](<Migrando uma VM do VB para o OCI.md>)

## Backup, recuperação e proteção de arquivos

- [Informações e parâmetros de backup](<Informações e parâmetros de backup.md>)
- [Parametros RMAN](<Parametros RMAN.md>)
- [Comandos para restore](<Comandos para restore.md>)
- [multiplexando control file](<multiplexando control file.md>)
- [Multiplexar grupos de redo logs](<Multiplexar grupos de redo logs.md>)

## SQL e transferência de dados

- [Comandos sobre tablespace](<Comandos sobre tablespace.md>)
- [User _ Profile _ Roles _ Grants](<User _ Profile _ Roles _ Grants.md>)
- [visualizar DDL](<visualizar DDL.md>)
- [Parametros do GLOGIN](<Parametros do GLOGIN.md>)
- [EXPDP](<EXPDP.md>)
- [IMPDP](<IMPDP.md>)
- [SQLLoader](<SQLLoader.md>)



## Operação e diagnóstico

- [Arquitetura e componentes do Oracle](<Arquitetura e componentes do Oracle.md>)
- [Administrar CDB e PDBs](<Administrar CDB e PDBs.md>)
- [Configurar listener e conexões Oracle Net](<Configurar listener e conexões Oracle Net.md>)
- [Checklist diario do banco Oracle](<Checklist diario do banco Oracle.md>)
- [Diagnosticar erros com ADRCI e alert log](<Diagnosticar erros com ADRCI e alert log.md>)
- [Monitorar sessoes e bloqueios](<Monitorar sessoes e bloqueios.md>)
- [Monitorar TEMP e UNDO](<Monitorar TEMP e UNDO.md>)
- [Monitorar FRA e archivelogs](<Monitorar FRA e archivelogs.md>)
- [Monitorar capacidade e crescimento do banco](<Monitorar capacidade e crescimento do banco.md>)

## Automação, recuperação e catálogo

- [Automatizar backups RMAN](<Automatizar backups RMAN.md>)
- [Testar restauracao completa em laboratorio](<Testar restauracao completa em laboratorio.md>)
- [Clonar banco com RMAN DUPLICATE](<Clonar banco com RMAN DUPLICATE.md>)
- [Recuperacao pontual com RMAN](<Recuperacao pontual com RMAN.md>)
- [Flashback e restore points](<Flashback e restore points.md>)
- [Configurar recovery catalog RMAN](<Configurar recovery catalog RMAN.md>)

## Segurança, manutenção e desempenho

- [Configurar TDE e proteger wallets](<Configurar TDE e proteger wallets.md>)
- [Configurar auditoria unificada](<Configurar auditoria unificada.md>)
- [Criar e monitorar jobs com DBMS_SCHEDULER](<Criar e monitorar jobs com DBMS_SCHEDULER.md>)
- [Gerenciar estatisticas com DBMS_STATS](<Gerenciar estatisticas com DBMS_STATS.md>)
- [Diagnosticar SQL lento com DBMS_XPLAN](<Diagnosticar SQL lento com DBMS_XPLAN.md>)
- [Administrar indices e constraints](<Administrar indices e constraints.md>)

## Evolução e disponibilidade

- [Atualizar banco com AutoUpgrade](<Atualizar banco com AutoUpgrade.md>)
- [Instalar e configurar ORDS para APEX](<Instalar e configurar ORDS para APEX.md>)
- [Criar standby fisico com Data Guard](<Criar standby fisico com Data Guard.md>)
- [Administrar Data Guard com Broker](<Administrar Data Guard com Broker.md>)


## Monitoramento e desempenho operacional

- [Monitorar Oracle com Zabbix](<Monitorar Oracle com Zabbix.md>)
- [Administrar ASM e disk groups](<Administrar ASM e disk groups.md>)
- [Analisar desempenho com Statspack](<Analisar desempenho com Statspack.md>)
- [Rastrear SQL com DBMS_MONITOR e TKPROF](<Rastrear SQL com DBMS_MONITOR e TKPROF.md>)
- [Diagnosticar memoria SGA e PGA](<Diagnosticar memoria SGA e PGA.md>)
- [Analisar relatorios AWR e ASH](<Analisar relatorios AWR e ASH.md>)


## Investigação, recuperação e transporte

- [Investigar alteracoes com LogMiner](<Investigar alteracoes com LogMiner.md>)
- [Diagnosticar corrupcao de blocos](<Diagnosticar corrupcao de blocos.md>)
- [Configurar backup RMAN no OCI Object Storage](<Configurar backup RMAN no OCI Object Storage.md>)
- [Transportar tablespaces entre bancos](<Transportar tablespaces entre bancos.md>)
- [Coletar diagnosticos com AHF e TFA](<Coletar diagnosticos com AHF e TFA.md>)


## Administração de objetos e acesso

- [Configurar ACLs de rede no Oracle](<Configurar ACLs de rede no Oracle.md>)
- [Administrar database links e sinonimos](<Administrar database links e sinonimos.md>)
- [Diagnosticar objetos invalidos](<Diagnosticar objetos invalidos.md>)
- [Administrar segmentos LOB](<Administrar segmentos LOB.md>)
- [Diagnosticar character set e NLS](<Diagnosticar character set e NLS.md>)
- [Operar recursos Oracle com SRVCTL](<Operar recursos Oracle com SRVCTL.md>)
- [Inventariar recursos e packs Oracle](<Inventariar recursos e packs Oracle.md>)


## SQL e PL/SQL para tarefas de DBA

- [Fundamentos de SQL para administracao Oracle](<Fundamentos de SQL para administracao Oracle.md>)
- [Fundamentos de PL-SQL para automacao DBA](<Fundamentos de PL-SQL para automacao DBA.md>)

## Laboratório e contribuição

- [Cenário de laboratório](LABORATORIO.md)
- [Modelo de tutorial](MODELO_DE_TUTORIAL.md)
- [Como contribuir e preparar a publicação](CONTRIBUTING.md)
- [Licença GPLv3](LICENSE)

## Caminhos de leitura

- **Laboratório novo:** SO → rede/SSH → instalação do banco → backup → teste de recuperação.
- **Atualização:** inventário → requisitos/README → backup e retorno testados → patch/upgrade → validação da aplicação.
- **Transporte de dados:** escopo e consistência → export → inspeção do DDL → import em destino isolado → conferência funcional.

## Verificação local do acervo

Execute `python tests/validar_acervo.py`. O teste confere cobertura dos documentos, links locais, estrutura Markdown e regressões dos exemplos; testa a saudação, a amostra SQL*Loader e a automação de backup com ferramentas simuladas. O teste também verifica o comportamento do .gitignore em um repositório Git temporário, sem inicializar esta pasta. Também exercita consultas portáveis com dados fictícios em SQLite para conferir filtros, agregações, transações e junção de jobs. Isso não valida o dialeto nem a execução Oracle. Ele não acessa Oracle nem homologa um procedimento em banco real.

## Origem

Acervo original identificado como [anvmano/Oracle-Database](https://github.com/anvmano/Oracle-Database). Mantidos os assuntos e nomes reconhecíveis, com extensão `.md`. O material original não incluía um arquivo de licença, embora seu README exibisse GPLv3. O mantenedor confirmou GPLv3 para o acervo, agora registrada integralmente em [LICENSE](LICENSE) (SPDX: GPL-3.0-only). Preserve atribuição e termos próprios de materiais de terceiros; a licença do acervo não concede licença dos softwares Oracle ou de mídias externas. Os 20 guias operacionais adicionais foram redigidos com exemplos próprios a partir dos assuntos identificados no acervo profissional e de referências oficiais. Não foram importados documentos de clientes, modelos de documentação, mídias, credenciais ou coleções de código de terceiros. Python é usado somente nos verificadores locais.

## Referências oficiais

- [Oracle Database — documentação](https://docs.oracle.com/en/database/oracle/oracle-database/)
- [Oracle Linux](https://docs.oracle.com/en/operating-systems/oracle-linux/)
- [OCI](https://docs.oracle.com/en-us/iaas/Content/home.htm)
