# Biblioteca de scripts Oracle DBA

**Escopo:** Oracle Database 19c e SQL*Plus 19c; 77 consultas, 7 intervenções e 6 geradores, mais o inicializador.  
**Organização editorial:** 20/10/2026 · conteúdo previamente tratado, conforme informado pelo mantenedor.

Biblioteca organizada por tarefa, com implementação em `.sql` e instruções em Markdown. Os scripts são novas implementações genéricas dos assuntos identificados no acervo privado. Cadernos misturados foram separados por efeito; consultas equivalentes deram origem a uma versão canônica. Não houve importação integral de coleções, scripts de aplicações ou conteúdo de clientes.

| Grupo | Resultado | Catálogo |
|---|---|---|
| Diagnóstico | Consulta metadados e contadores; não intervém | [77 consultas](diagnostico/README.md) |
| Manutenção | Altera um alvo explicitamente conferido | [7 intervenções](manutencao/README.md) |
| Geradores | Imprime DDL para revisão; não o executa | [6 geradores](geradores/README.md) |

## Encontrar a informação

Comece pelo **[catálogo por assunto](CATALOGO.md)**: 90 tarefas em 17 assuntos, com links para o SQL correspondente. Não é necessário baixar ou publicar um arquivo por vez: o repositório inteiro é distribuído junto, mantendo os scripts independentes. Consulte o [guia para obter e atualizar o projeto](PUBLICACAO.md).

**Estado do conteúdo:** o mantenedor informou que os scripts já foram tratados. Uma nova validação não é requisito desta organização ou da publicação. Este registro não atribui nova execução Oracle a esta etapa.

Para partir de um sintoma, consulte o [índice dos 20 roteiros individuais](../SOLUCAO_DE_PROBLEMAS.md). Cada problema tem seu arquivo e indica quais arquivos usar, como interpretar as evidências e qual procedimento de correção seguir.

## Preparar a sessão

1. Abra uma **conexão dedicada**, sem transações de aplicação pendentes. Use a autenticação aprovada no ambiente, sem colocar credenciais em arquivos versionados.
2. Use SQL*Plus 19c conectado ao banco/container indicado. No SQL Developer, comandos SQL*Plus pertencem à execução como script/F5; execução de instrução/F9 não interpreta o arquivo inteiro. Em outro cliente, utilize o modo de script e os recursos compatíveis com os comandos do cabeçalho.
3. A partir da raiz deste projeto, execute o inicializador abaixo. Ele declara e limpa todos os binds. Execute-o novamente quando mudar de tarefa ou conexão.
4. Confira banco, container, usuário e pré-requisitos. Preencha somente os parâmetros da tarefa e execute o arquivo escolhido.

```sql
@scripts/iniciar_sessao.sql
@scripts/diagnostico/identidade_banco.sql
BEGIN
  :p_owner := 'APP_LAB';
END;
/
@scripts/diagnostico/objetos_invalidos.sql
```

O exemplo usa um schema fictício. Na manutenção, use usuário local não mantido pela Oracle. Na manutenção e nos geradores, `p_owner` deve ser o próprio usuário conectado, com identificador convencional em maiúsculas, e `CURRENT_SCHEMA` deve corresponder a esse usuário. As consultas aceitam o filtro exato disponível em cada cabeçalho. `p_nome=NULL` só amplia consultas que declaram esse parâmetro como opcional; os scripts não convertem silenciosamente nomes com aspas/minúsculas.

## Contrato comum

- **Entradas:** variáveis bind, sem substituição textual SQL*Plus e sem argumentos posicionais. A variável deve existir mesmo quando seu valor é NULL; por isso o inicializador é obrigatório. Para períodos, `p_dias` de 1 a 31; o padrão é um dia. Entradas obrigatórias ausentes, período inválido e formato inválido de SQL_ID causam erro antes da consulta.
- **Falhas:** todo arquivo define `WHENEVER SQLERROR/OSERROR EXIT FAILURE ROLLBACK`. Erro SQL/SO encerra o cliente com código de falha; sucesso mantém a sessão. Erros do próprio cliente, como determinados `SP2-`, não são todos cobertos por `WHENEVER`: confira também o log e a existência dos arquivos. Nada reconecta ou oculta exceções.
- **Estado do cliente:** formatação e binds persistem. `SET DEFINE OFF` evita substituição textual. `SET SQLBLANKLINES ON` permite blocos com linhas vazias. Não há CONNECT, HOST, SPOOL automático ou execução de DDL gerado. Inicie uma sessão dedicada para não misturar esse estado com trabalho de aplicação.
- **Escopo:** conecte à PDB da aplicação para consultas por schema. Os scripts com V$ mostram a instância local; os com GV$ declaram a instância nas linhas e preservam as chaves de associação. Coletas em root/non-CDB e ASM têm exceção explícita no cabeçalho e no catálogo. Consultar a partir de uma PDB não dá visibilidade completa da CDB.
- **Privilégios:** os cabeçalhos listam views/APIs necessárias. Um administrador deve conceder apenas o acesso aprovado; os scripts não concedem privilégios. Para fixed views, o administrador usa os objetos subjacentes `SYS.V_$...`/`SYS.GV_$...` correspondentes, quando aplicável. Não usar SYS/SYSDBA nem conceder DBA para contornar erros. Manutenção de objetos próprios usa conexão do dono e direitos específicos.
- **Saída:** texto SQL, ações de jobs, nomes de arquivos, parâmetros e grants podem revelar dados do ambiente. Guarde resultados fora do Git. Nenhuma saída real acompanha a biblioteca. Zero linhas, NULL e falta de privilégio têm significados diferentes e não constituem atestado de saúde.
- **Licenciamento:** as consultas não dependem de AWR/ASH/SQL Tuning Advisor. Isso não determina o licenciamento de toda a instalação. Consulte o [guia de inventário](<../Inventariar recursos e packs Oracle.md>).

## Manutenção editorial e publicação

As ferramentas locais existentes em [tests/](../tests/validar_acervo.py) são apoio para quem futuramente alterar o acervo. O [roteiro Oracle](../tests/oracle/README.md) permanece como referência opcional; não é pendência nem condição para publicar este conjunto.

Para contribuir, atualize o SQL canônico, sua entrada no catálogo e o tutorial relacionado. Não execute toda a pasta em lote: os arquivos têm ambientes e efeitos diferentes. O [guia de atualização](PUBLICACAO.md) explica como obter o conjunto e enviar mudanças relacionadas em um commit.

Os originais privados foram preservados. Duplicatas, misturas de assuntos e material excluído são descritos no [registro público da curadoria](CURADORIA.md), sem nomes/caminhos de clientes. A relação detalhada dos arquivos de origem continua fora deste projeto.

Voltar ao [índice do projeto](../README.md).
