# Obter e atualizar a biblioteca no GitHub

O projeto está disponível em [anvmano/Oracle-Database](https://github.com/anvmano/Oracle-Database). README e catálogo organizam o conjunto; os scripts continuam independentes por tarefa.

O mantenedor informou que os scripts já foram tratados. Uma nova validação não é pendência de publicação. Execute somente a tarefa escolhida, seguindo seu contrato de execução.

## Obter o conjunto

Abra um terminal no diretório em que deseja guardar o projeto:

```powershell
git clone https://github.com/anvmano/Oracle-Database.git
Set-Location -LiteralPath Oracle-Database
```

Também é possível usar **Code → Download ZIP** no GitHub para obter o conteúdo atual sem o histórico Git. O ZIP é gerado pelo GitHub; não deve ser versionado neste projeto.

| Objetivo | Entrada |
|---|---|
| Encontrar um script | [90 tarefas em 17 assuntos](CATALOGO.md). |
| Resolver um incidente | [20 roteiros individuais](../SOLUCAO_DE_PROBLEMAS.md). |
| Estudar um procedimento | [Índice dos tutoriais](../README.md). |
| Preparar o cliente e os parâmetros | [Contrato da biblioteca](README.md). |
| Entender as intervenções | [Manutenção](manutencao/README.md). |
| Revisar DDL sem executá-lo | [Geradores](geradores/README.md). |

Não existe um script para executar toda a biblioteca em lote.

## Preparar uma atualização

Na sua cópia do repositório, confira o estado e crie uma branch para a mudança:

```powershell
git status --short
git switch -c codex/ajuste-biblioteca
```

Se houver trabalho pendente, preserve-o antes de trocar de branch. Ao mudar uma tarefa, atualize o SQL canônico, o índice do grupo, o catálogo por assunto e o tutorial relacionado. Consulte [CONTRIBUTING.md](../CONTRIBUTING.md).

Revise o conteúdo e a identidade do commit:

```powershell
git diff --check
git diff --stat
git diff
git config --get user.name
git config --get user.email
```

Não inclua coletas reais, credenciais, dumps, wallets, caminhos internos ou catálogos privados. O `.gitignore` não remove arquivos já rastreados nem conteúdo de commits antigos. Material de terceiros exige condições de redistribuição compatíveis; a [GPLv3](../LICENSE) não licencia automaticamente esses materiais.

## Criar o commit e enviar

Selecione os arquivos relacionados à mudança; não é necessário um commit por script. Substitua os caminhos abaixo pelos arquivos revisados:

```text
git add -- CAMINHO-DO-SQL CAMINHO-DO-INDICE CAMINHO-DO-TUTORIAL
git diff --cached --check
git diff --cached
git commit -m "Corrige roteiro e script Oracle DBA"
git remote -v
git push -u origin codex/ajuste-biblioteca
```

Confira o destino antes do envio. Para contribuidores sem permissão no repositório, envie a branch ao próprio fork e abra um pull request. Ao revisar, informe o que mudou e quais checagens foram realmente executadas; não atribua execução Oracle a verificações textuais ou simulações locais.

## Informações sensíveis em commits antigos

Remover um arquivo no commit atual não elimina suas versões anteriores. Se uma credencial tiver sido usada em ambiente real, seu responsável deve revogá-la ou trocá-la; apagar o histórico não a torna segura novamente.

A limpeza de um histórico já compartilhado exige preservar uma cópia privada, selecionar os trechos a anonimizar, reescrever as referências afetadas e coordenar a atualização dos clones e do remoto. Os hashes mudam, e cópias externas podem continuar contendo o material. Não use `push --force` como procedimento rotineiro de atualização.

Voltar ao [índice da biblioteca](README.md).
