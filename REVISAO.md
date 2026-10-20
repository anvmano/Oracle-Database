# Registro da revisão e expansão do acervo Oracle

[← Índice](README.md)

**Data:** 20/10/2026  
**Tipo:** revisão documental e verificações locais; sem execução em uma instância Oracle.

## Cobertura e preservação

- Os 38 textos originais (37 tutoriais e README) foram lidos integralmente e reescritos em UTF-8/Markdown. Cada assunto mantém seu arquivo reconhecível.
- A tabela abaixo relaciona cada original ao destino e descreve as correções. Os tutoriais não foram apenas renomeados.
- O ZIP foi ignorado, conforme solicitado; não foi recriado nem usado como fonte desta revisão.
- A imagem `banco de dados imagem git.jpg` foi inspecionada visualmente e preservada byte a byte. É uma ilustração, sem passos técnicos a corrigir; não foi usada como banner do índice.
- Os originais foram preservados em uma cópia temporária fora da pasta de trabalho antes das alterações. Essa cópia não é uma política permanente de backup.

## O que foi conferido

Sintaxe e coerência de comandos, usuários, homes, paths, containers, sequência e resultado esperado de cada procedimento, com referências primárias por assunto. Foram retirados IDs pessoais, senhas fixas de exemplo, links encurtados e operações destrutivas apresentadas como limpeza/solução genérica. Pré-requisitos e versões históricas ficaram explícitos.

As listas extensas de help de Data Pump foram substituídas por referência aos parâmetros, exemplos revisados e `help=y` da versão instalada; assim, defaults antigos não aparecem como universais. Caminhos alternativos incorretos foram corrigidos ou substituídos por um procedimento completo com escopo explícito.

## Limites que continuam exigindo confirmação no ambiente

1. Não houve instalação, patch, upgrade, DDL, carga, backup nem restauração em Oracle real. A confirmação documental não é homologação operacional.
2. Não estão disponíveis neste acervo o ambiente de destino, suas mídias/patches, certificação autenticada ou README do pacote no My Oracle Support. IDs históricos de RU/RUR/BP não foram apresentados como indicação atual ou identidade homologada de um pacote.
3. RAC, Data Guard, ASM em migração de plataforma, TDE e configurações de CDB/PDB exigem os requisitos específicos apontados pelos guias. Valores de memória, quotas, discos, portas e limites são exemplos ou decisões dimensionadas, não prescrições universais.
4. Menus do OCI/VirtualBox podem variar; o roteiro identifica o recurso e a condição que devem ser conferidos, sem depender apenas da posição antiga de uma tela.

## Verificações locais da revisão inicial

O teste `python tests/validar_acervo.py` confere cobertura, links locais, títulos/fences Markdown, regressões de comandos, todos os limites horários da saudação e coerência entre CSV, tabela e control file SQL*Loader. Quando Bash está disponível, confere a sintaxe dos blocos e executa **somente o relatório de SO com coletores simulados**, incluindo cenário de falha. Não executa nenhum comando Oracle ou de alteração Linux.

```text
OK: 38 textos originais cobertos; 39 Markdown; 155 links locais válidos.
OK: regressões dos comandos, saudação (24 horas) e exemplo CSV/control/schema.
OK: sintaxe de 84 blocos Bash; relatório simulado e propagação de falha.
Oracle/Linux real, certificação e pacotes MOS não são executados por este teste.
```

## Cobertura da revisão inicial por arquivo

| Original | Documento revisado | Correções e esclarecimentos |
|---|---|---|
| Acessar instancia no OCI | [Acessar instancia no OCI.md](<Acessar instancia no OCI.md>) | Validação da chave do servidor, usuário correto, rede e uso explícito de sudo. |
| Aplicando o Bundle Patch Oracle 12cr1 | [Aplicando o Bundle Patch Oracle 12cr1.md](<Aplicando o Bundle Patch Oracle 12cr1.md>) | Subpatches e IDs tratados como históricos; sequência completa ligada ao guia principal; exclusão de catbundle e rollback automáticos. |
| Aplicar RU no Oracle 19c | [Aplicar RU no Oracle 19c.md](<Aplicar RU no Oracle 19c.md>) | Parada, aplicação, tratamento de falha, pré-checks, PDBs, datapatch e catálogo corrigidos. |
| Atualização Apex | [Atualização Apex.md](<Atualização Apex.md>) | Versão/mídia coerentes, container, backup, imagens/ORDS e exclusão de schema condicionada à instalação real. |
| Aumentar swap e partições | [Aumentar swap e partições.md](<Aumentar swap e partições.md>) | Identificação de discos, crescimento sem redução, swapoff/UUID, mountpoint XFS, permissões /tmp e remoção destrutiva. |
| Comandos para restore | [Comandos para restore.md](<Comandos para restore.md>) | Cenários separados, nomes/sintaxe corrigidos, RESETLOGS condicionado, limite exclusivo de sequence, autobackup/SPFILE e perdas explicitadas. |
| Comandos sobre tablespace | [Comandos sobre tablespace.md](<Comandos sobre tablespace.md>) | Sintaxe, paths, crescimento por arquivo, temporary/undo, TDE, restrições de remoção e significado das views. |
| Command Line Interface (CLI) | [Command Line Interface (CLI).md](<Command Line Interface (CLI).md>) | Instaladores corrigidos; perfis e credenciais sem identificadores pessoais; ações em maiúsculas e parada normal. |
| Criar Chave SSH | [Criar Chave SSH.md](<Criar Chave SSH.md>) | Separação pública/privada; formato OpenSSH; frase secreta; origem oficial do PuTTY; validação. |
| Criar Instancia no OCI | [Criar Instancia no OCI.md](<Criar Instancia no OCI.md>) | Arquitetura, dimensionamento, IAM, identificação de recursos, acesso SSH e validação da criação. |
| Criar maquina para EM 13 | [Criar maquina para EM 13.md](<Criar maquina para EM 13.md>) | Template/versionamento, credenciais SYS/SYSMAN, parâmetros de portas, chmod, configuração de repositório e validação do OMS. |
| Criar VCN no OCI | [Criar VCN no OCI.md](<Criar VCN no OCI.md>) | Inclusão de regras de segurança, associação da rota e escolha explícita entre sub-rede pública e privada. |
| EXPDP | [EXPDP.md](<EXPDP.md>) | Diretório no servidor, datas corretas, prompt de senha, modos consistentes, transporte autocontido e validação. |
| Firewall no linux | [Firewall no linux.md](<Firewall no linux.md>) | Serviço/porta, runtime/permanent, reload e remoção específicos; teste remoto e origem restrita. |
| IMPDP | [IMPDP.md](<IMPDP.md>) | Opção de export removida, remaps corretos, SQLFILE/path, filters, tabelas existentes e transporte revisados. |
| Informações e parâmetros de backup | [Informações e parâmetros de backup.md](<Informações e parâmetros de backup.md>) | FRA, ARCHIVELOG, escopo de parâmetros, backup sem exclusão automática, validação e proteção de arquivos/chaves. |
| Instalação do Oracle 19c no OCI | [Instalação do Oracle 19c no OCI.md](<Instalação do Oracle 19c no OCI.md>) | Segurança mantida, fonte oficial, home /opt consistente, remoção de limpeza destrutiva e duplicação de startup. |
| Instalação GRID (12c) | [Instalação GRID (12c).md](<Instalação GRID (12c).md>) | Proprietário/grupos, ASMLIB, root.sh, redundância, CRSCTL/SRVCTL e distinção entre metadados e backup. |
| Instalação Oracle 12c | [Instalação Oracle 12c.md](<Instalação Oracle 12c.md>) | Mídia/pacote/capitalização corrigidos; grupos e limites coerentes; pré-requisitos obrigatórios; listener, DBCA e consultas por versão. |
| Instalação Oracle 18c | [Instalação Oracle 18c.md](<Instalação Oracle 18c.md>) | Mídia/pacote/capitalização corrigidos; grupos e limites coerentes; pré-requisitos obrigatórios; listener, DBCA e consultas por versão. |
| Instalação Oracle 19c | [Instalação Oracle 19c.md](<Instalação Oracle 19c.md>) | Mídia/pacote/capitalização corrigidos; grupos e limites coerentes; pré-requisitos obrigatórios; listener, DBCA e consultas por versão. |
| Instalação Oracle 19c em Silent mode | [Instalação Oracle 19c em Silent mode.md](<Instalação Oracle 19c em Silent mode.md>) | Response files corretos, inventário/home separados, nomes e parâmetros coerentes; proteção de senhas e verificação por fase. |
| Instalação oracle linux | [Instalação oracle linux.md](<Instalação oracle linux.md>) | Particionamento e swap dimensionados; hostname separado do SID; retirada de desativação indiscriminada e RPMs antigos fixos. |
| Migrando uma VM do VB para o OCI | [Migrando uma VM do VB para o OCI.md](<Migrando uma VM do VB para o OCI.md>) | Compartimento, OpenSSL e chaves; boot preservado; usuário SSH e criação de instância opcionais; validação antes/depois. |
| multiplexando control file | [multiplexando control file.md](<multiplexando control file.md>) | Lista completa, SPFILE/PFILE, preparação de destino, cópia corrente e validação; restauração RMAN separada. |
| Multiplexar grupos de redo logs | [Multiplexar grupos de redo logs.md](<Multiplexar grupos de redo logs.md>) | Grupos inventariados, nomes consistentes, separação física e validação dos membros/estados. |
| Parametros do GLOGIN | [Parametros do GLOGIN.md](<Parametros do GLOGIN.md>) | Intervalos da saudação, editor, ausência de privilégio em V$INSTANCE e impacto sobre scripts. |
| Parametros RMAN | [Parametros RMAN.md](<Parametros RMAN.md>) | Autobackup %F, semântica de retenção/otimização, paralelismo e distinção EXPIRED/OBSOLETE corrigidos. |
| README.md | [README.md](<README.md>) | Índice local por assunto, convenções, trilhas de leitura, limites de validação e remoção de badges sem base local. |
| Release Update Revision 19.5 | [Release Update Revision 19.5.md](<Release Update Revision 19.5.md>) | Identidade não presumida, base/conflitos conferidos, retirada de rollback automático e validação binária/SQL. |
| RUR Oracle 19.5 | [RUR Oracle 19.5.md](<RUR Oracle 19.5.md>) | Título/objetivo distinguem RUR e rollback; ID confirmado, consulta antes da parada, OPatch correto e pós-rollback SQL. |
| Script monitorar SO | [Script monitorar SO.md](<Script monitorar SO.md>) | Shebang, tabelas sem posições fixas, RAM/swap separadas, coleta finita e propagação de falhas. |
| script startup automatico | [script startup automatico.md](<script startup automatico.md>) | Homes consistentes, controle único, espera pela parada, dependências de montagem e validação real além do status systemd. |
| SQLLoader | [SQLLoader.md](<SQLLoader.md>) | Exemplo consistente, charset, tolerância a erro, senha no prompt, commits parciais e validação de rejeições. |
| Upgrade do oracle 12c para 19.3 | [Upgrade do oracle 12c para 19.3.md](<Upgrade do oracle 12c para 19.3.md>) | Origem elegível, homes e pré-checks, consulta data_upgraded, preservação de GRID_HOME e retorno planejado. |
| upgrade-rollback de patch (12cr1) | [upgrade-rollback de patch (12cr1).md](<upgrade-rollback de patch (12cr1).md>) | Inclusão de opatch apply; aplicação/reversão separadas; parada correta; datapatch, catbundle, catálogo e validação por container. |
| User _ Profile _ Roles _ Grants | [User _ Profile _ Roles _ Grants.md](<User _ Profile _ Roles _ Grants.md>) | Sintaxe GRANT/REVOKE, separação de tipos de privilégio, complexidade de senha, RESOURCE_LIMIT e quota ilimitada. |
| visualizar DDL | [visualizar DDL.md](<visualizar DDL.md>) | Owner explícito, tipos/dependências corretos, spool, restauração de transforms e alternativa para schema completo. |

## Referências externas da revisão inicial

Foram consultados 68 endereços distintos: 66 responderam HTTP 200 na checagem automatizada. Disponibilidade HTTP confirma o endereço, não a aplicabilidade de todo procedimento a um ambiente. O portal MOS público não dá acesso ao conteúdo de cada patch autenticado.

- [https://www.gnu.org/software/bash/manual/bash.html](https://www.gnu.org/software/bash/manual/bash.html): HTTP Error 403: Forbidden. A indisponibilidade nesta sessão não foi tratada como comprovação do conteúdo.
- [https://www.gnu.org/software/coreutils/manual/html_node/df-invocation.html](https://www.gnu.org/software/coreutils/manual/html_node/df-invocation.html): HTTP Error 403: Forbidden. A indisponibilidade nesta sessão não foi tratada como comprovação do conteúdo.

As fontes relevantes estão ao final de cada guia.


## Expansão do acervo — 20/10/2026

Foram acrescentados os 25 tutoriais e os cinco apoios solicitados, mantendo títulos, escopo, pré-requisitos, passos, comandos por ambiente, validação/retorno e fontes oficiais. O índice passa a reunir **62 tutoriais**: 37 históricos revisados e 25 novos. São **67 arquivos Markdown** no total, incluindo README, este registro e os três apoios em Markdown.

Os novos tutoriais têm estado **execução em laboratório pendente**. Não foram instalados bancos, ORDS, Data Guard, wallets, jobs nem serviços, e não foram executados comandos Oracle. Os testes locais usam ferramentas simuladas e diretórios temporários. Eles não substituem a homologação dos fluxos em instâncias reais.

### Arquivos acrescentados

| Arquivo | Tipo |
|---|---|
| [Arquitetura e componentes do Oracle.md](<Arquitetura e componentes do Oracle.md>) | Tutorial |
| [Administrar CDB e PDBs.md](<Administrar CDB e PDBs.md>) | Tutorial |
| [Configurar listener e conexões Oracle Net.md](<Configurar listener e conexões Oracle Net.md>) | Tutorial |
| [Checklist diario do banco Oracle.md](<Checklist diario do banco Oracle.md>) | Tutorial |
| [Diagnosticar erros com ADRCI e alert log.md](<Diagnosticar erros com ADRCI e alert log.md>) | Tutorial |
| [Monitorar sessoes e bloqueios.md](<Monitorar sessoes e bloqueios.md>) | Tutorial |
| [Monitorar TEMP e UNDO.md](<Monitorar TEMP e UNDO.md>) | Tutorial |
| [Monitorar FRA e archivelogs.md](<Monitorar FRA e archivelogs.md>) | Tutorial |
| [Automatizar backups RMAN.md](<Automatizar backups RMAN.md>) | Tutorial |
| [Testar restauracao completa em laboratorio.md](<Testar restauracao completa em laboratorio.md>) | Tutorial |
| [Clonar banco com RMAN DUPLICATE.md](<Clonar banco com RMAN DUPLICATE.md>) | Tutorial |
| [Recuperacao pontual com RMAN.md](<Recuperacao pontual com RMAN.md>) | Tutorial |
| [Flashback e restore points.md](<Flashback e restore points.md>) | Tutorial |
| [Configurar recovery catalog RMAN.md](<Configurar recovery catalog RMAN.md>) | Tutorial |
| [Configurar TDE e proteger wallets.md](<Configurar TDE e proteger wallets.md>) | Tutorial |
| [Configurar auditoria unificada.md](<Configurar auditoria unificada.md>) | Tutorial |
| [Criar e monitorar jobs com DBMS_SCHEDULER.md](<Criar e monitorar jobs com DBMS_SCHEDULER.md>) | Tutorial |
| [Gerenciar estatisticas com DBMS_STATS.md](<Gerenciar estatisticas com DBMS_STATS.md>) | Tutorial |
| [Diagnosticar SQL lento com DBMS_XPLAN.md](<Diagnosticar SQL lento com DBMS_XPLAN.md>) | Tutorial |
| [Administrar indices e constraints.md](<Administrar indices e constraints.md>) | Tutorial |
| [Atualizar banco com AutoUpgrade.md](<Atualizar banco com AutoUpgrade.md>) | Tutorial |
| [Instalar e configurar ORDS para APEX.md](<Instalar e configurar ORDS para APEX.md>) | Tutorial |
| [Criar standby fisico com Data Guard.md](<Criar standby fisico com Data Guard.md>) | Tutorial |
| [Administrar Data Guard com Broker.md](<Administrar Data Guard com Broker.md>) | Tutorial |
| [Monitorar capacidade e crescimento do banco.md](<Monitorar capacidade e crescimento do banco.md>) | Tutorial |
| [CONTRIBUTING.md](<CONTRIBUTING.md>) | Apoio |
| [MODELO_DE_TUTORIAL.md](<MODELO_DE_TUTORIAL.md>) | Apoio |
| [LABORATORIO.md](<LABORATORIO.md>) | Apoio |
| [.gitignore](<.gitignore>) | Apoio |
| [LICENSE](<LICENSE>) | Apoio |

### Licença e atribuição

O mantenedor escolheu expressamente GPLv3. LICENSE contém o texto oficial integral e não modificado, obtido em https://www.gnu.org/licenses/gpl-3.0.txt, com SHA-256 `3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986`. O README identifica GPL-3.0-only. Materiais de terceiros e software Oracle preservam suas condições próprias; não foi atribuída nova autoria nem alterada a imagem original.

### Verificações da expansão

Além do verificador anterior, `tests/validar_expansao.py` verifica os novos arquivos e a GPLv3, testa o .gitignore em um **repositório temporário**, e simula dez cenários da rotina RMAN: sucesso, configuração ausente, diretório de trabalho ausente, montagem ausente, destino ausente, concorrência, DBID incorreto, banco fora do estado esperado, erro SQL*Plus e erro RMAN. Nenhum binário Oracle é chamado nos testes.

```text
OK: .gitignore protege segredos/artefatos e permite exemplos .sql/.ctl/.sh.
OK: automação RMAN simulada em 10 cenários; nenhuma conexão Oracle ou alteração Linux.
OK: 38 textos originais e 25 novos tutoriais cobertos; 67 Markdown; 296 links locais válidos.
OK: regressões dos comandos, saudação (24 horas) e exemplo CSV/control/schema.
OK: sintaxe de 101 blocos Bash; relatório simulado e propagação de falha.
Oracle/Linux real, certificação e pacotes MOS não são executados por este teste.
```

### Referências da expansão

A checagem automatizada encontrou 121 endereços externos distintos, dos quais 119 responderam HTTP 200. Os dois manuais GNU abaixo não tiveram conteúdo confirmado nesta sessão; o texto oficial GPLv3 foi obtido separadamente com HTTP 200 e hash conferido. Disponibilidade HTTP não confirma aplicabilidade técnica a um ambiente.

- [https://www.gnu.org/software/bash/manual/bash.html](https://www.gnu.org/software/bash/manual/bash.html): <urlopen error timed out>.
- [https://www.gnu.org/software/coreutils/manual/html_node/df-invocation.html](https://www.gnu.org/software/coreutils/manual/html_node/df-invocation.html): <urlopen error timed out>.


### Preparação para Git

Foram criados .gitignore, regras de contribuição e licença; nenhuma mídia, dump, segredo ou evidência real foi adicionada. Esta pasta continua sem inicialização Git, commit, remoto ou push. Antes de publicar, revise o conteúdo preparado e os direitos dos materiais de terceiros; .gitignore não remove itens já rastreados.


## Incorporação de assuntos operacionais — 20/10/2026

Acrescentados **20 guias técnicos**, totalizando **82 tutoriais e 87 arquivos Markdown**, e complementados **14 tutoriais existentes**. O escopo permanece administração de banco de dados. Não foram criados modelos de GMUD, relatórios, política de backup ou documentação de implantação. MODELO_DE_TUTORIAL.md, já existente como apoio editorial, foi preservado.

O inventário privado da coleção profissional serviu para selecionar assuntos. Os textos publicados usam exemplos próprios, fictícios e referências oficiais; nenhum documento de cliente, log real, chave, instalador ou coleção de terceiros foi incorporado. Origem e relatório privados foram preservados fora do projeto.

### Guias acrescentados

- [Administrar ASM e disk groups](<Administrar ASM e disk groups.md>)
- [Administrar database links e sinonimos](<Administrar database links e sinonimos.md>)
- [Administrar segmentos LOB](<Administrar segmentos LOB.md>)
- [Analisar desempenho com Statspack](<Analisar desempenho com Statspack.md>)
- [Analisar relatorios AWR e ASH](<Analisar relatorios AWR e ASH.md>)
- [Coletar diagnosticos com AHF e TFA](<Coletar diagnosticos com AHF e TFA.md>)
- [Configurar ACLs de rede no Oracle](<Configurar ACLs de rede no Oracle.md>)
- [Configurar backup RMAN no OCI Object Storage](<Configurar backup RMAN no OCI Object Storage.md>)
- [Diagnosticar character set e NLS](<Diagnosticar character set e NLS.md>)
- [Diagnosticar corrupcao de blocos](<Diagnosticar corrupcao de blocos.md>)
- [Diagnosticar memoria SGA e PGA](<Diagnosticar memoria SGA e PGA.md>)
- [Diagnosticar objetos invalidos](<Diagnosticar objetos invalidos.md>)
- [Fundamentos de PL-SQL para automacao DBA](<Fundamentos de PL-SQL para automacao DBA.md>)
- [Fundamentos de SQL para administracao Oracle](<Fundamentos de SQL para administracao Oracle.md>)
- [Inventariar recursos e packs Oracle](<Inventariar recursos e packs Oracle.md>)
- [Investigar alteracoes com LogMiner](<Investigar alteracoes com LogMiner.md>)
- [Monitorar Oracle com Zabbix](<Monitorar Oracle com Zabbix.md>)
- [Operar recursos Oracle com SRVCTL](<Operar recursos Oracle com SRVCTL.md>)
- [Rastrear SQL com DBMS_MONITOR e TKPROF](<Rastrear SQL com DBMS_MONITOR e TKPROF.md>)
- [Transportar tablespaces entre bancos](<Transportar tablespaces entre bancos.md>)

### Tutoriais complementados

- [Automatizar backups RMAN.md](<Automatizar backups RMAN.md>)
- [Monitorar FRA e archivelogs.md](<Monitorar FRA e archivelogs.md>)
- [EXPDP.md](<EXPDP.md>)
- [IMPDP.md](<IMPDP.md>)
- [Checklist diario do banco Oracle.md](<Checklist diario do banco Oracle.md>)
- [Diagnosticar erros com ADRCI e alert log.md](<Diagnosticar erros com ADRCI e alert log.md>)
- [Gerenciar estatisticas com DBMS_STATS.md](<Gerenciar estatisticas com DBMS_STATS.md>)
- [Criar e monitorar jobs com DBMS_SCHEDULER.md](<Criar e monitorar jobs com DBMS_SCHEDULER.md>)
- [User _ Profile _ Roles _ Grants.md](<User _ Profile _ Roles _ Grants.md>)
- [Monitorar capacidade e crescimento do banco.md](<Monitorar capacidade e crescimento do banco.md>)
- [script startup automatico.md](<script startup automatico.md>)
- [Instalação GRID (12c).md](<Instalação GRID (12c).md>)
- [Criar standby fisico com Data Guard.md](<Criar standby fisico com Data Guard.md>)
- [Testar restauracao completa em laboratorio.md](<Testar restauracao completa em laboratorio.md>)

### Alcance da validação

Revisão documental e checks locais; **execução em laboratório pendente** em todos os novos guias. A sintaxe Bash e as simulações existentes continuam sem chamar ferramentas Oracle. Os testes de SQL portável usam SQLite com dados sintéticos e adaptação de literais de data/limite temporal; verificam resultados de agregação/NULL, intervalo, rollback, filtros de alerta e chave de junção de jobs, sem validar semântica completa de Oracle. Os blocos de teste PL/SQL estão documentados para futura execução em Oracle, não executados nesta revisão.

A revisão confere versão/contexto declarado, serviços, pré-condições, alterações, validação, retorno, coerência dos links e ausência dos caminhos internos da coleção nos novos textos. Fontes oficiais precisam continuar sendo conferidas para a RU, edição, topologia e direitos do ambiente real. AWR/ASH e template Zabbix não são habilitados por esta edição. Nenhum Git init, commit ou push foi executado.

### Resultado dos checks desta incorporação

- `python tests/validar_acervo.py`: aprovado com 87 Markdown, 435 links internos e sintaxe de 113 blocos Bash.
- Simulações preservadas: relatório de SO com propagação de erro, dez cenários de RMAN e comportamento do .gitignore em Git temporário.
- Fixtures SQLite aprovadas: agregação/NULL, intervalo de datas, retorno de UPDATE por rollback, duas exclusões de alertas e junção de jobs por owner/nome, preservando jobs sem execução ativa.
- As 48 URLs distintas de referências dos 20 novos guias responderam HTTP 200 após correção de três caminhos. O endpoint fictício do exemplo OCI não faz parte dessas referências. HTTP 200 verifica disponibilidade, sem certificar comandos ou cenário.
- Comparação com a cópia anterior: 20 tutoriais e um verificador novos; 14 tutoriais, README, LABORATORIO, REVISAO e verificador de expansão alterados. Nenhum arquivo anterior removido; LICENSE, imagem e MODELO_DE_TUTORIAL preservados.

## Biblioteca SQL por tarefa · 20/10/2026

Incorporados 37 diagnósticos, 7 intervenções e 5 geradores, mais inicializador SQL*Plus. O [catálogo](scripts/README.md) detalha pré-requisitos, parâmetros, escopo e efeitos. Foram separados cadernos mistos, corrigidas associações de sessões e granularidade de espaço, protegidos divisores e substituídas listas de clientes por alvos próprios explicitamente validados.

Os originais continuam fora do Git e não foram alterados. A [curadoria](scripts/CURADORIA.md) distingue triagem do acervo de revisão dos scripts efetivamente incorporados. Verificação local com dados sintéticos não confirma compilação/efeito Oracle. A [homologação](tests/oracle/README.md) permanece pendente; nenhum DDL/API foi executado contra uma instância real. O projeto continua sem publicação Git automática.

## Organização para disponibilização · 20/10/2026

A biblioteca foi ampliada para 90 tarefas em 17 assuntos (77 consultas, 7 intervenções e 6 geradores), além do inicializador. Criados [catálogo por assunto](scripts/CATALOGO.md) e [guia de publicação](scripts/PUBLICACAO.md), mantendo os SQLs separados e os caminhos anteriores. Os tutoriais relacionados apontam para os arquivos canônicos.

**Orientação atual do mantenedor:** os scripts já foram tratados; nova validação não é pendência ou condição de publicação. As menções anteriores a homologação pendente registram o estado documental da etapa anterior e ficam superadas por esta orientação quanto aos scripts. Não foi atribuída nova execução Oracle a esta organização editorial.

## Roteiros de solução de problemas · 20/10/2026

Criado o [guia de 20 problemas recorrentes](SOLUCAO_DE_PROBLEMAS.md), com sinais/erros, arquivos existentes, sequência de investigação, decisões de correção e critérios de retomada. A seleção cobre operação Oracle DBA e não alega uma classificação estatística de frequência. As referências de causa/ação são oficiais e aparecem junto dos casos.

O guia foi integrado ao índice principal, ao catálogo, à biblioteca e ao checklist diário. Não houve alteração de scripts SQL nem execução de comandos em banco. A confirmação da retomada descrita nos roteiros é parte do atendimento ao incidente, sem reintroduzir homologação dos scripts como pendência de publicação.

## Separação dos 20 roteiros · 20/10/2026

Os 20 casos passaram a ter arquivos próprios em `solucao-de-problemas/`. O [guia original](SOLUCAO_DE_PROBLEMAS.md) foi mantido como índice e preparação comum, com seus links numerados anteriores preservados. Cada arquivo contém os passos e critérios de retomada do caso, fontes oficiais e navegação entre problemas.

Foram ajustados links relativos para scripts/tutoriais e acrescentadas referências diretas aos roteiros nos tutoriais relacionados. Índice principal, catálogo, biblioteca e checklist apontam para a nova organização. Nenhum conteúdo SQL foi alterado ou executado nesta separação.
