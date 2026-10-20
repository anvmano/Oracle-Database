# 01 · Falha de conexão, listener ou serviço

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-12541 indica ausência de listener no endereço tentado; ORA-12514 indica serviço não conhecido pelo listener; ORA-12154 aponta para resolução do identificador. Esses sintomas não comprovam perda de dados.

## Arquivos do projeto

[listener e Oracle Net](<../Configurar listener e conexões Oracle Net.md>), [CDB/PDBs](<../Administrar CDB e PDBs.md>), [SRVCTL](<../Operar recursos Oracle com SRVCTL.md>), [servicos_banco.sql](../scripts/diagnostico/servicos_banco.sql), [identidade_banco.sql](../scripts/diagnostico/identidade_banco.sql).

## Roteiro de solução

1. Registre a string sem senha, host, porta, serviço, erro completo e se o problema afeta todos os clientes.
2. Para resolução de nome, confira cliente, `TNS_ADMIN`, alias/DNS e o descritor realmente utilizado. Compare com o serviço cadastrado, não com um SID presumido.
3. No host correto, consulte `lsnrctl status` e `lsnrctl services`, usando o nome do listener real quando ele não for o padrão. Confira também alcance de rede e porta.
4. Com uma conexão administrativa disponível, confira serviço, papel e abertura da PDB. Use `servicos_banco.sql` com `p_nome` opcional; uma instância ativa não garante que a PDB esteja aberta ou o serviço ativo.
5. Corrija o ramo encontrado: descritor do cliente, caminho de rede, serviço/PDB ou registro. A partida de listener/banco/PDB deve seguir a topologia do ambiente; o guia SRVCTL cobre recursos sob Restart.

## Confirmar a retomada

Conectar pelo mesmo serviço e caminho da aplicação e executar a operação de saúde esperada. `tnsping` sozinho não autentica nem comprova acesso à PDB. Se o banco não abre ou há erros de arquivos, use o incidente de disponibilidade/recuperação correspondente, sem repetir partidas indiscriminadas.

## Referências oficiais

- [ORA-12541](https://docs.oracle.com/en/error-help/db/ora-12541/).
- [ORA-12514](https://docs.oracle.com/en/error-help/db/ora-12514/).
- [ORA-12154](https://docs.oracle.com/en/error-help/db/ora-12154/).

[Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 02 →](02-conta-bloqueada-senha-expirada.md)
