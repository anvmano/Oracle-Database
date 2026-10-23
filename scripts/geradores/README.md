# Geradores · scripts Oracle DBA

**Organização editorial:** 20/10/2026 · conteúdo previamente tratado, conforme informado pelo mantenedor.

Leia primeiro o [contrato de execução](../README.md) e prepare a sessão com [iniciar_sessao.sql](../iniciar_sessao.sql).

## Ler e revisar a saída

Os geradores consultam DBMS_METADATA ou montam comandos a partir de tipos permitidos. Não executam o texto produzido, não criam spool e não extraem senha/hash de usuário. São limitados ao schema conectado, com identificador convencional em maiúsculas.

```sql
@scripts/iniciar_sessao.sql
BEGIN
  :p_nome := 'TABELA_LAB';
  :p_tipo := 'TABLE';
END;
/
@scripts/geradores/extrair_ddl_objeto.sql
```

Resultados CLOB usam `SET LONG 10000000` e `LONGCHUNKSIZE 32767`. Isso limita a apresentação: confira se o DDL foi truncado e aumente o limite ou use exportação CLOB apropriada no cliente, quando necessário. Cabeçalhos, paginação e ausência de terminadores fazem a saída ser material para revisão, não um arquivo automaticamente executável.

As transformações DBMS_METADATA da sessão não são modificadas. Use sessão nova para defaults conhecidos. DDL de tabela pode incluir constraints/índices também emitidos por outros geradores: não concatene todas as saídas sem revisão. Ajuste storage, tablespaces, schema de destino, dependências e terminadores no artefato de implantação; a biblioteca não faz uma migração completa.

No gerador de constraints, `ddl_constraints=NULL` indica ausência de dependências exportáveis do tipo `CONSTRAINT`. A API não emite `NOT NULL` nem a primary key de uma IOT separadamente: obtenha esses itens no DDL da tabela. Somente ORA-31608 nessa chamada é tratado como ausência; outros erros continuam interrompendo o cliente. `ddl_fks` contém as FKs definidas na tabela, quando existentes.

`extrair_ddl_objeto.sql` usa nomes de tipo da API, como `PACKAGE_BODY` e `TYPE_BODY`. O gerador de recompilação usa o tipo exibido no dicionário, como `PACKAGE BODY`. Grants diretos não equivalem a todos os direitos efetivos (roles aninhadas, PUBLIC e grants de coluna não são expandidos).

## Catálogo

Também é possível procurar pelo [catálogo por assunto](../CATALOGO.md).

| Arquivo e objetivo | Binds | Views/APIs e direitos específicos | Tutorial e limite |
|---|---|---|---|
| [extrair_ddl_objeto.sql](extrair_ddl_objeto.sql) — Extrair DDL de um objeto proprio | p_owner; p_nome; p_tipo (TABLE/INDEX/VIEW/SEQUENCE/PROCEDURE/FUNCTION/PACKAGE/PACKAGE_BODY/TRIGGER/TYPE/TYPE_BODY) | USER_OBJECTS; EXECUTE DBMS_METADATA | [visualizar DDL](<../../visualizar DDL.md>). Sem conexao/senha ou execucao de DDL; saida pode exceder SET LONG. Transformacoes padrao da sessao devem ser preservadas. |
| [extrair_indices_tabela.sql](extrair_indices_tabela.sql) — Extrair DDL dos indices de uma tabela propria | p_owner; p_nome (tabela) | USER_TABLES, USER_INDEXES; EXECUTE DBMS_METADATA | [visualizar DDL](<../../visualizar DDL.md>). Indices de constraints podem conflitar com DDL da tabela; revisar sequencia e nao executar todos os geradores juntos. |
| [extrair_constraints_tabela.sql](extrair_constraints_tabela.sql) — Extrair constraints definidas em uma tabela propria | p_owner; p_nome (tabela) | USER_TABLES, USER_CONSTRAINTS; EXECUTE DBMS_METADATA | [visualizar DDL](<../../visualizar DDL.md>). NOT NULL e PK de IOT pertencem ao DDL da tabela. Inclui so FKs de saida; nao e migracao completa. |
| [extrair_privilegios_usuario.sql](extrair_privilegios_usuario.sql) — Extrair grants diretos do usuario conectado | p_owner; nenhum adicional | USER_SYS_PRIVS, USER_ROLE_PRIVS, USER_TAB_PRIVS_RECD; EXECUTE DBMS_METADATA | [visualizar DDL](<../../visualizar DDL.md>). Nao extrai CREATE USER, senha/hash, concessoes de colunas ou privilegios herdados. Saida e sensivel. |
| [gerar_recompilacao.sql](gerar_recompilacao.sql) — Gerar comandos para objetos invalidos sem executa-los | p_owner; p_nome opcional; p_tipo opcional (tipo Oracle com espaco) | USER_OBJECTS; EXECUTE DBMS_ASSERT | [visualizar DDL](<../../visualizar DDL.md>). Nao resolve ordem completa de dependencias; revise cada comando e confirme erros depois de compilar. |
| [extrair_grants_objeto.sql](extrair_grants_objeto.sql) — Extrair grants publicados em um objeto proprio | p_owner; p_nome (objeto) | USER_OBJECTS, USER_TAB_PRIVS; EXECUTE DBMS_METADATA | [visualizar DDL](<../../visualizar DDL.md>). Grants no objeto, diferente dos grants recebidos pelo usuario; nao executa GRANT e nao cobre grants de coluna. |

## Referências oficiais

[Oracle Database Reference 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html), [PL/SQL Packages and Types Reference](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/index.html), [SQL*Plus User’s Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqpug/index.html).

Voltar ao [índice da biblioteca](../README.md).
