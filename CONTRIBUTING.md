# Contribuir com o acervo

[← Índice](README.md) · [Modelo de tutorial](MODELO_DE_TUTORIAL.md) · [Laboratório](LABORATORIO.md)

## 1. Escolher o escopo

Antes de criar um arquivo, confira o índice e os guias relacionados. Amplie um guia existente se o assunto for o mesmo; separe quando houver objetivo, pré-requisitos ou risco distintos. Use nomes reconhecíveis e extensão `.md` para guias; os scripts executáveis ficam em `.sql`, seguindo o catálogo da biblioteca.

Cada tutorial deve identificar versão/RU, plataforma, edição/recursos aplicáveis, arquitetura (single instance/RAC, CDB/PDB, file system/ASM), usuário executor e objetivo. Os exemplos devem usar dados fictícios e um cenário reproduzível de laboratório.

## 2. Escrever o procedimento

Use [MODELO_DE_TUTORIAL](MODELO_DE_TUTORIAL.md). Separe shell, SQL*Plus, RMAN, ADRCI, DGMGRL e conteúdo de arquivos. Explique em qual host/container cada bloco roda e quais valores devem ser substituídos. Use placeholders visíveis em blocos `text` quando a sequência não puder ser executada sem completar informações.

- Inclua verificações antes de alterar dados, arquivos, serviços ou configuração.
- Identifique caminhos e recursos existentes antes de criar, sobrescrever, remover ou formatar.
- Mostre resultado esperado, critérios de erro, aceitação e retorno.
- Não coloque senha, chave, OCID pessoal, IP interno real, dump, log de produção ou wallet no Git.
- Prefira senhas no prompt ou mecanismos de credenciais aprovados; não as coloque em argumentos/histórico.
- Preserve erros/códigos de saída em scripts; uma coleta parcial não deve parecer sucesso.
- Cite documentação primária da versão. README de patch e certificação autenticados não podem ser substituídos por suposição.

## 3. Distinguir revisão de teste real

Use `Revisão documental` quando apenas fontes/sintaxe foram conferidas. Só escreva `Testado em laboratório` depois de registrar versão/RU, cenário, data, comandos, resultados e testes de falha relevantes. Uma fonte HTTP 200 não homologa os comandos; um `bash -n` não executa SQL.

Materiais Oracle, sistemas operacionais e recursos licenciados têm seus próprios requisitos; o acervo não concede direito de uso do software ou de packs.

## 4. Validar e atualizar navegação

Requisitos locais do verificador: Python 3.10 ou superior; Bash para checagem de shell e simulações. Nenhum banco é acessado por esses testes.

```bash
python tests/validar_acervo.py
```

Se Bash não estiver no PATH, configure `ORACLE_DOCS_BASH` com o caminho de um GNU Bash confiável, conforme seu sistema. Um resultado PENDENTE não deve ser registrado como check executado. Os testes de simulação da automação não executam RMAN/SQL*Plus reais.

Inclua o novo guia no README, confira links locais/UTF-8/fences e atualize o registro de revisão. Amplie a lista de cobertura do teste quando adicionar um guia. Scripts com lógica nova relevante devem ter teste pequeno de comportamento, incluindo falha e prevenção de efeitos indevidos quando aplicável.

## 5. Preparar a publicação

Em um checkout Git real, revise `git status`, `git diff` e o conteúdo preparado com `git diff --cached`. Adicione arquivos de forma consciente; `.gitignore` não remove segredos já rastreados nem substitui a revisão. Se uma credencial tiver sido publicada, trate sua revogação/rotação e o histórico pelo processo adequado, não só por um commit de exclusão.

Descreva o objetivo, validações e limites da mudança. Não inclua mídia Oracle nem evidências de produção. O acervo adota [GPLv3](LICENSE), conforme a escolha do mantenedor; preserve atribuição e termos próprios de materiais de terceiros.

## Contribuir com scripts

Mantenha o SQL executável em `scripts/` e a orientação em Markdown, seguindo o [contrato da biblioteca](scripts/README.md). Escolha um dos três grupos pelo efeito: consulta, intervenção ou geração de texto. Evite cadernos com tarefas misturadas e não publique originais de clientes, saídas reais, credenciais ou coleções de terceiros sem verificar seus termos.

Use binds inicializados, filtros e chaves corretos de instância/container. Toda intervenção deve validar alvo e contexto antes da ação, propagar erros e explicar retorno/irreversibilidade. Atualize catálogo, tutorial relacionado e testes. Mantenha o [catálogo por assunto](scripts/CATALOGO.md) sincronizado. O mantenedor considera o conteúdo atual previamente tratado; uma nova validação não é condição para organizar ou publicar o acervo. O [roteiro Oracle](tests/oracle/README.md) continua disponível como referência opcional para alterações futuras.
