# Administrar índices e constraints

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; inventário e experimento em APP_LAB, sem reconstrução ou exclusão em massa.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Índice é estrutura de acesso; constraint expressa regra de integridade. PK/UK podem depender de índice, mas criar um índice não cria automaticamente toda regra de negócio. Use `T_PLANO_LAB` do [exercício SQL](<Diagnosticar SQL lento com DBMS_XPLAN.md>), backup/definição dos objetos e janela apropriada. DDL confirma transações implicitamente.

## 1. Inventariar índices e regras

```sql
SELECT index_name, table_name, index_type, uniqueness, status, visibility FROM user_indexes;
SELECT index_name, column_name, column_position FROM user_ind_columns ORDER BY index_name,column_position;
SELECT constraint_name, table_name, constraint_type, status, validated,
       deferrable, deferred, index_name FROM user_constraints;
SELECT constraint_name, column_name, position FROM user_cons_columns ORDER BY constraint_name,position;
```

Para particionados, confira estados por partição/subpartição: STATUS global pode não expressar todas as condições. Antes de alterar índice de PK/UK, identifique a constraint e referências externas.

## 2. Testar um candidato pequeno

Se não houver índice equivalente e a hipótese de acesso justificar, como APP_LAB:

```sql
CREATE INDEX IX_PLANO_CATEGORIA ON T_PLANO_LAB(categoria);
```

Confira espaço de índice/TEMP, impacto de DML e resultado real pelo DBMS_XPLAN. Nome de coluna repetido em índices diferentes não prova redundância: ordem, unicidade, filtros/expressões e dependências importam. Não use REBUILD como manutenção obrigatória baseada só em idade ou fragmentação presumida.

## 3. Criar uma regra de teste

Somente depois de conferir que todos os dados atuais satisfazem a regra e que o nome é novo:

```sql
ALTER TABLE T_PLANO_LAB ADD CONSTRAINT CK_PLANO_CATEGORIA CHECK (categoria BETWEEN 0 AND 9);
SELECT constraint_name, status, validated FROM user_constraints WHERE table_name='T_PLANO_LAB';
```

CHECK com intervalo não proíbe NULL por si só; se a regra exigir valor obrigatório, planeje NOT NULL também. Para FK, confirme a chave referenciada, efeitos de exclusão e concorrência; índice em FK pode ajudar certas operações, mas não é criado automaticamente em todo caso.

## 4. Manutenção e mudanças de estado

`ENABLE NOVALIDATE` e `ENABLE VALIDATE` têm garantias diferentes sobre dados já existentes. Desabilitar constraint pode admitir dados inválidos; reconstruir índice pode consumir espaço e afetar carga. Opções ONLINE/particionamento e índices especiais dependem de versão, edição e licenciamento. Não acrescente uma opção sem confirmar suporte.

Para investigar um índice aparentemente sem uso, considere janela e representatividade da coleta, jobs raros e constraints. Índice invisível ainda ocupa espaço e recebe manutenção de DML; não é uma cópia de backup nem garante teste isolado para todas as configurações de sessão.

## 5. Validar e retornar o experimento

Confirme integridade, consultas relevantes, DML, locks e espaço. Para retirar **apenas** os objetos deste teste, após identificar dependências e guardar DDL, use `DROP INDEX IX_PLANO_CATEGORIA;` e `ALTER TABLE T_PLANO_LAB DROP CONSTRAINT CK_PLANO_CATEGORIA;` em mudanças controladas. Não elimine a PK nem índices preexistentes. Voltar uma constraint exige reconciliar quaisquer dados inválidos criados enquanto ela estava desabilitada.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [indices_status.sql](scripts/diagnostico/indices_status.sql) — Consultar indices e particoes indisponiveis.
- [tabelas_sem_pk.sql](scripts/diagnostico/tabelas_sem_pk.sql) — Localizar tabelas sem primary key no schema.
- [tabelas_sem_indices.sql](scripts/diagnostico/tabelas_sem_indices.sql) — Localizar tabelas sem indices registrados.
- [constraints_status.sql](scripts/diagnostico/constraints_status.sql) — Consultar estado e validacao de constraints.
- [foreign_keys_colunas.sql](scripts/diagnostico/foreign_keys_colunas.sql) — Relacionar colunas de FKs as chaves referenciadas.
- [indices_colunas.sql](scripts/diagnostico/indices_colunas.sql) — Consultar colunas e ordem dos indices.
- [indices_uso.sql](scripts/diagnostico/indices_uso.sql) — Consultar registros de monitoramento de indices.

## Roteiros de solução de problemas

- [14 · Índice ou partição de índice inutilizável](solucao-de-problemas/14-indices-inutilizaveis.md).

## Referências oficiais

- [Índices](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/managing-indexes.html)
- [Constraints](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/constraint.html)
- [CREATE INDEX](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-INDEX.html)
