# Carregar um CSV com SQL*Loader

[← Índice](README.md)

**Escopo:** Carga convencional de laboratório em tabela dedicada; arquivos e tabela com quatro campos.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

SQL*Loader lê um arquivo de dados e um **control file de carga**, que não é o control file do banco. No exemplo, use UTF-8, serviço `ORCLPDB` e usuário proprietário `APP_OWNER` com `CREATE SESSION`, tabela existente e quota suficiente. Os arquivos são lidos no computador em que `sqlldr` é executado.

Este exemplo usa carga convencional e APPEND. Pode haver commits parciais; interromper por erro não desfaz automaticamente as linhas já confirmadas. Faça backup e planeje idempotência antes de repetir uma carga.

## 1. Preparar uma tabela de laboratório

Conectado como `APP_OWNER` ao destino certo:

```sql
CREATE TABLE CARGA_ARTIGOS (
  ID NUMBER,
  TITULO VARCHAR2(100 CHAR),
  TEXTO VARCHAR2(200 CHAR),
  FONTE VARCHAR2(100 CHAR)
);
```

Crie apenas se for uma tabela de teste nova; não sobrescreva objetos existentes.

## 2. Criar arquivos consistentes

`artigos.dat`, com **quatro campos**, sem cabeçalho:

```csv
1,Ben Kenobi,Texto de exemplo,Kawasaki news article
2,Oracle Database,Outro texto,Manual interno
```

`artigos.ctl`, no mesmo diretório de execução:

```text
OPTIONS (ERRORS=0, ROWS=100)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'artigos.dat'
BADFILE 'artigos.bad'
DISCARDFILE 'artigos.dsc'
APPEND
INTO TABLE CARGA_ARTIGOS
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  ID INTEGER EXTERNAL,
  TITULO CHAR,
  TEXTO CHAR,
  FONTE CHAR
)
```

`TRAILING NULLCOLS` aceita campos finais ausentes como nulos, se a tabela permitir. Ajuste charset para o arquivo real; não declare WE8ISO8859P1 para um CSV UTF-8. Aumentar `ERRORS` para um número enorme esconde uma política de tolerância e não corrige dados inválidos.

## 3. Executar e guardar retorno

No Bash do cliente com Oracle Client/Database e `sqlldr` no PATH:

```bash
sqlldr userid=APP_OWNER@ORCLPDB control=artigos.ctl log=artigos.log
rc=$?
printf 'Codigo de saida: %s\n' "$rc"
```

A senha será solicitada. Os códigos devem ser conferidos na documentação da plataforma; em Unix, zero indica sucesso e código de aviso não deve ser tratado como carga integral sem revisar rejeições. Não passe a senha literal na linha de comando. Se usar `DATA=...`, confira o efeito de precedência no comando em vez de definir arquivos contraditórios no control file.

## 4. Validar

Leia `artigos.log`, número de linhas carregadas/rejeitadas/descartadas e motivo de cada falha. `.bad` contém registros rejeitados quando aplicável; `.dsc` trata descartes conforme filtros de carga, não todos os erros. Esses arquivos podem conter dados sensíveis.

```sql
SELECT COUNT(*) FROM CARGA_ARTIGOS;
SELECT id, titulo, texto, fonte FROM CARGA_ARTIGOS ORDER BY id;
```

Em uma tabela de teste inicialmente vazia, o exemplo deve produzir duas linhas. Teste separadamente uma linha com ID inválido, confirme erro/rejeição e o estado dos dados já gravados. Antes de repetir, defina limpeza controlada, chave única ou outro mecanismo apropriado para não duplicar linhas com APPEND.

## Referências oficiais

- [SQL*Loader — control file](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-sql-loader-control-file-contents.html)
- [SQL*Loader — comando e retornos](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-sql-loader-commands.html)
