# Diagnosticar objetos inválidos

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; inventário e recompilação seletiva de objetos próprios na LABPDB.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use APP_LAB para consultar e compilar seus objetos. DBA_OBJECTS/DBA_ERRORS exigem privilégios adicionais; as variantes USER atendem o exercício. Registre mudança recente, erro, dependências e estado anterior. Não recompile todos os schemas nem gere/execute DDL em lote para resolver uma contagem isolada.

## 1. Inventariar tipo, estado e erro

```sql
SELECT object_name, object_type, status, last_ddl_time
FROM user_objects WHERE status='INVALID' ORDER BY object_type, object_name;
SELECT name, type, line, position, text
FROM user_errors ORDER BY name, type, sequence;
```

Preserve os erros completos. Contagem de inválidos pode incluir objetos sem uso ou falhas conhecidas; compare com a linha de base, sem declarar tudo normal por ser antigo.

## 2. Examinar dependências

```sql
SELECT name, type, referenced_owner, referenced_name, referenced_type
FROM user_dependencies WHERE name='P_JOB_LAB'
ORDER BY referenced_owner, referenced_name;
```

O exemplo usa a procedure do [guia Scheduler](<Criar e monitorar jobs com DBMS_SCHEDULER.md>), se ela tiver sido criada. Confira existência de tabelas, grants diretos exigidos pelo PL/SQL, assinaturas de pacotes e dependências remotas. Privilégio por role pode não resolver código com direitos do definidor.

## 3. Corrigir a causa e compilar o objeto escolhido

Se P_JOB_LAB existir e a mudança estiver planejada:

```sql
ALTER PROCEDURE P_JOB_LAB COMPILE;
SHOW ERRORS PROCEDURE P_JOB_LAB
SELECT object_name, object_type, status FROM user_objects
WHERE object_name='P_JOB_LAB';
```

Para views, packages, package bodies e triggers, a sintaxe/impacto é diferente. Não transforme OBJECT_TYPE livre em comando dinâmico sem lista permitida, identificação segura e revisão. Recompilação pode invalidar dependentes e disputar locks; programe a janela.

## 4. Quando o escopo é pós-upgrade

UTL_RECOMP/utlrp são ferramentas administrativas de escopo maior. Se o plano de upgrade as exigir, confirme pré-condições, SYSDBA, consumo e ausência de DDL concorrente, conforme a documentação. Não execute UTL_RECOMP global em resposta a uma única procedure inválida de aplicação.

## 5. Validar e retornar

Repita USER_ERRORS e compare o inventário, executando teste funcional autorizado. VALID não prova que a lógica produz o resultado correto. Se houve alteração de código/grant, preserve a versão anterior e aplique o retorno previsto; ROLLBACK não desfaz DDL. Não substitua código de produção por um corpo vazio só para zerar inválidos.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [objetos_invalidos.sql](scripts/diagnostico/objetos_invalidos.sql) — Listar objetos invalidos e seus erros.
- [objetos_por_tipo.sql](scripts/diagnostico/objetos_por_tipo.sql) — Contar objetos por tipo e estado.
- [objetos_dependencias.sql](scripts/diagnostico/objetos_dependencias.sql) — Consultar dependencias diretas de um objeto.
- [recompilar_objeto.sql](scripts/manutencao/recompilar_objeto.sql) — Recompilar um objeto proprio por tipo permitido.
- [visoes_materializadas.sql](scripts/diagnostico/visoes_materializadas.sql) — Consultar estado e atualizacao de materialized views.

## Roteiros de solução de problemas

- [15 · Objeto inválido ou erro de compilação](solucao-de-problemas/15-objetos-invalidos.md).

## Referências oficiais

- [UTL_RECOMP](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/UTL_RECOMP.html)
- [Dependências de objetos](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/managing-schema-objects.html)
