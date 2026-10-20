# Publicar a biblioteca inteira no GitHub

A publicação é feita pelo **repositório completo**, em um commit. Os scripts continuam separados; README e catálogo organizam a navegação. Quem acessar poderá ler cada arquivo no navegador, clonar tudo ou baixar o conjunto.

O mantenedor informou que o conteúdo dos scripts já foi tratado. Nova validação não é uma pendência de publicação. O trabalho desta etapa é a organização do material.

## O que será disponibilizado

| Parte | Conteúdo |
|---|---|
| [Índice principal](../README.md) | Tutoriais e entrada para a biblioteca. |
| [Índice dos roteiros de solução](../SOLUCAO_DE_PROBLEMAS.md) | 20 arquivos individuais com diagnóstico, solução e referências. |
| [Catálogo por assunto](CATALOGO.md) | 90 tarefas em 17 assuntos, com links para cada SQL. |
| [Diagnóstico](diagnostico/README.md) | 77 consultas. |
| [Manutenção](manutencao/README.md) | 7 intervenções independentes. |
| [Geradores](geradores/README.md) | 6 geradores que produzem DDL para revisão. |
| [Inicializador](iniciar_sessao.sql) | Parâmetros bind e configuração comum do cliente. |
| [Licença](../LICENSE) | GPLv3 definida pelo mantenedor. |

O catálogo privado de origem e seus caminhos não fazem parte da publicação. Não copie a pasta de trabalho profissional inteira para este repositório.

## Primeiro envio

1. Abra o PowerShell na pasta do projeto. É necessário ter o Git disponível no terminal e autenticação do GitHub configurada pelo método escolhido na conta.
2. Confira os arquivos preparados e a identidade que assinará o commit. Se a identidade ainda não estiver configurada, use nome e e-mail reais escolhidos para os commits; um e-mail noreply da própria conta também pode ser utilizado. Não invente um endereço.

```powershell
Set-Location -LiteralPath 'D:\Documentos\03_Projetos\Repositorio Oracle git'
git status --short
git config --get user.name
git config --get user.email
```

Para cadastrar a identidade **somente neste repositório**, substitua os valores abaixo. São exemplos a preencher, não uma identidade cadastrada automaticamente:

```text
git config user.name "SEU NOME"
git config user.email "SEU EMAIL DE COMMITS"
```

3. O repositório local usa a branch `main`. Caso esteja trabalhando a partir de uma cópia nova sem `.git`, inicialize uma única vez:

```powershell
git init -b main
```

4. Prepare os arquivos e crie **um commit para o conjunto inteiro**. `git diff --cached --stat` mostra o que será incluído; não é necessário criar um commit por script.

```powershell
git add .
git diff --cached --stat
git commit -m 'Organiza guias e biblioteca de scripts Oracle DBA'
```

5. Crie um repositório vazio na conta/organização GitHub desejada e escolha a visibilidade pública. Como README, licença e arquivos já existem aqui, o destino deve começar vazio. Copie a URL do repositório e configure o remote. **Substitua a URL do exemplo**, mantendo os comandos separados:

```text
git remote add origin https://github.com/SEU-USUARIO/SEU-REPOSITORIO.git
git push -u origin main
```

Se `origin` já existir, consulte `git remote -v` e confirme o destino antes de alterá-lo. Se o destino já tiver histórico, integre-o deliberadamente; não use force push para sobrescrevê-lo.

## Depois da publicação

Abra o README no GitHub e use o [catálogo por assunto](CATALOGO.md) como entrada principal para os scripts. Cada link leva ao arquivo canônico. Não existe um script que execute toda a biblioteca.

Para atualizações, altere os arquivos relevantes e faça um novo commit com todas as mudanças relacionadas. Ao adicionar uma tarefa, inclua seu link no catálogo, no índice do grupo e no tutorial correspondente; aproveite o arquivo existente quando o objetivo for o mesmo.

O envio remoto depende da conta, da identidade de commit e da URL escolhidas pelo mantenedor. Não há credencial ou URL de destino preenchida neste guia.
