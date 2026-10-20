# Modelo de tutorial

[← Índice](README.md) · [Regras de contribuição](CONTRIBUTING.md)

**Escopo:** modelo reutilizável; substituir as orientações pelo procedimento específico.  
**Revisão documental:** preencher a data real; não afirmar teste em banco sem executá-lo.

## Antes de começar

Descreva objetivo e resultado observável. Declare versão/RU, SO, arquitetura, edição/recursos, host/container e conta necessária. Liste capacidade, dependências, backups e pré-condições reais. Relacione os guias anteriores sem repetir seu conteúdo inteiro.

Identifique se as operações consultam, alteram, interrompem ou removem recursos. Mostre como conferir o alvo e como interromper o fluxo se o ambiente divergir. Não use um aviso genérico como substituto de uma verificação concreta.

## 1. Conferir o ambiente

Inclua consultas/comandos de inventário e o resultado esperado. Exemplo não destrutivo para uma sessão SQL conectada:

```sql
SELECT SYS_CONTEXT('USERENV','DB_NAME') banco,
       SYS_CONTEXT('USERENV','CON_NAME') container,
       SYS_CONTEXT('USERENV','SESSION_USER') usuario FROM dual;
```

Explique como comparar os valores com o cenário. Se houver arquivos/discos, confira identidade, existência, montagem, permissões e ausência de sobreposição antes do comando que os modifica.

## 2. Preparar

Especifique backups/configuração anterior, diretórios novos, privilégios mínimos e entradas substituíveis. Use exemplos coerentes com [LABORATORIO](LABORATORIO.md) ou declare a variação. Não invente um dump, keystore, serviço ou arquivo de resposta que não tenha sido preparado em uma etapa anterior.

## 3. Executar

Apresente passos numerados e blocos identificados: `bash`, `powershell`, `sql`, `rman`, `ini`, `csv` ou `text`. Em prompts especializados, use `text` e explique que é ADRCI/DGMGRL. Bloco `text` com marcadores é modelo, não comando pronto. Separe cenários alternativos e pare na primeira falha.

Para scripts, torne ambiente/erros explícitos e inclua teste de comportamento para a lógica nova. Não use NOFILENAMECHECK, FORCE, NOPROMPT, remoção em massa ou privilégios amplos como resposta automática a um problema.

## 4. Validar

Defina evidências: estado/versão, arquivos esperados, linhas/objetos, código de saída e teste funcional. Compare com a situação anterior. Diferencie retorno do comando, conclusão do job e sucesso da aplicação. Liste o que ainda não foi comprovado.

## 5. Retorno e encerramento

Explique como voltar à configuração anterior ou recuperar dados pelo plano específico. DDL, exclusão de arquivo, RESETLOGS e commit não são desfeitos por um ROLLBACK comum. Indique o que preservar e quando a limpeza dos objetos de teste é permitida. Não acrescente a limpeza destrutiva ao mesmo bloco da execução principal.

## Evidência de teste

| Campo | Preencher com |
|---|---|
| Ambiente | SO, versão/RU, edição e topologia |
| Escopo testado | Fluxo nominal, casos de falha e retorno realmente executados |
| Resultado | Evidências e critérios de aceitação |
| Data | Data e fuso da execução |
| Limites | Condições não exercitadas ou dependentes de certificação |

Se não houve execução, mantenha explicitamente o estado **execução em laboratório pendente**.

## Referências oficiais

Substitua esta orientação por links diretos e verificados para os comandos/requisitos da versão. Diferencie documentação pública, README do pacote e certificação autenticada. Ponto de partida: [documentação Oracle Database](https://docs.oracle.com/en/database/oracle/oracle-database/).
