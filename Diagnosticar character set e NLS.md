# Diagnosticar character set e NLS

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; identificação de codificação e parâmetros de sessão, sem conversão de character set.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Registre cliente/driver, terminal, encoding do arquivo, serviço, PDB e exemplos fictícios do sintoma. Texto incorreto pode resultar de entrada, armazenamento, conversão ou exibição. Alterar NLS_LANG para o charset do banco sem verificar os bytes do cliente pode agravar o problema. JDBC Thin e clientes OCI não usam todas as configurações da mesma forma.

## 1. Comparar banco e sessão

No serviço correto:

```sql
SELECT parameter, value FROM nls_database_parameters
WHERE parameter IN ('NLS_CHARACTERSET','NLS_NCHAR_CHARACTERSET') ORDER BY parameter;
SELECT parameter, value FROM nls_session_parameters
WHERE parameter IN ('NLS_LANGUAGE','NLS_TERRITORY','NLS_DATE_FORMAT',
                    'NLS_NUMERIC_CHARACTERS','NLS_LENGTH_SEMANTICS') ORDER BY parameter;
SELECT SYS_CONTEXT('USERENV','CON_NAME') container FROM dual;
```

Não consulte nem atualize SYS.PROPS$ para tentar converter o banco. Parâmetros de sessão afetam apresentação/interpretação; não reescrevem dados já armazenados.

## 2. Eliminar conversões implícitas

```sql
SELECT DATE '2026-10-20' data_tipificada,
       TO_CHAR(DATE '2026-10-20','YYYY-MM-DD') data_texto FROM dual;
SELECT TO_NUMBER('1234.50','9999D99','NLS_NUMERIC_CHARACTERS=''.,''') valor
FROM dual;
```

Prefira binds tipados no código de aplicação. Literais de data com máscara implícita e strings numéricas dependentes da sessão podem produzir resultados diferentes. A coluna DATA_TIPIFICADA continua DATE, mesmo que o cliente a mostre em outro formato.

## 3. Comparar caracteres e bytes

Como APP_LAB em sessão com cliente corretamente configurado, use uma string fictícia que represente o sintoma:

```sql
SELECT LENGTH('ação') caracteres, LENGTHB('ação') bytes,
       DUMP('ação',1016) representacao FROM dual;
```

O número de bytes depende do charset e da entrada real; não fixe um resultado universal. Confirme round-trip com o driver/aplicação pretendido e, quando necessário, coluna/tabela exclusiva de teste. Uma string já corrompida no arquivo SQL não vira correta ao consultar DUMP.

## 4. Relacionar com Data Pump e encerrar

Compare charset, NCHAR, versões de timezone, tipos e semântica BYTE/CHAR de origem/destino antes de [exportar](EXPDP.md) ou [importar](IMPDP.md). Log sem erro não dispensa conferência dos valores e comprimentos. Conversão do character set é projeto próprio, com ferramentas suportadas, análise de compatibilidade e recuperação testada; não é um ALTER DATABASE incluído neste diagnóstico.

Este exercício não modifica parâmetros. Se fizer um teste ALTER SESSION separado, registre os valores anteriores e retorne-os ou encerre a sessão dedicada. Mudança de sessão não corrige dados já convertidos de forma incorreta.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [nls.sql](scripts/diagnostico/nls.sql) — Comparar NLS de banco, instancia e sessao.
- [timezone_banco.sql](scripts/diagnostico/timezone_banco.sql) — Consultar timezone de banco, sessao e arquivo de timezone.

## Referências oficiais

- [Ambiente de globalização](https://docs.oracle.com/en/database/oracle/oracle-database/19/nlspg/setting-up-globalization-support-environment.html)
- [Conversões SQL](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/TO_NUMBER.html)
