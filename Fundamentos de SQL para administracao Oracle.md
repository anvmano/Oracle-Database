# Fundamentos de SQL para administração Oracle

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; consultas administrativas de leitura e transações em tabela fictícia de APP_LAB.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Conecte APP_LAB à LABPDB e confirme CREATE TABLE e quota limitada. Os exemplos não exigem DBA. Use sessão dedicada sem transações pendentes; criação de tabela é DDL e tem efeitos de commit implícito. Confirme que T_SQL_DBA_LAB ainda não existe antes de criá-la.

## 1. Confirmar o contexto e consultar o dicionário

```sql
SELECT SYS_CONTEXT('USERENV','SESSION_USER') usuario,
       SYS_CONTEXT('USERENV','CON_NAME') container FROM dual;
SELECT object_type, status, COUNT(*) quantidade
FROM user_objects GROUP BY object_type, status ORDER BY object_type, status;
```

USER mostra objetos próprios; ALL mostra objetos acessíveis; DBA/CDB exigem privilégios e escopo administrativo apropriado. Não peça SELECT ANY DICTIONARY se uma view do próprio schema resolve o trabalho.

## 2. Preparar dados fictícios

```sql
CREATE TABLE T_SQL_DBA_LAB (
  id NUMBER PRIMARY KEY, grupo VARCHAR2(20), valor NUMBER, criado_em DATE);
INSERT INTO T_SQL_DBA_LAB VALUES (1,'BACKUP',10,DATE '2026-10-20');
INSERT INTO T_SQL_DBA_LAB VALUES (2,'BACKUP',NULL,DATE '2026-10-20');
INSERT INTO T_SQL_DBA_LAB VALUES (3,'JOB',5,DATE '2026-10-21');
COMMIT;
```

Essas três linhas passam a ser a base do exercício. Não repita os INSERTs sobre a mesma tabela, pois a PK deve impedir a duplicação. COMMIT confirma a transação; não pode ser desfeito por ROLLBACK posterior.

## 3. Filtrar e agregar sem esconder ausência

```sql
SELECT grupo, COUNT(*) linhas, COUNT(valor) valores_preenchidos, SUM(valor) soma
FROM T_SQL_DBA_LAB GROUP BY grupo ORDER BY grupo;
SELECT id FROM T_SQL_DBA_LAB WHERE valor IS NULL;
SELECT id FROM T_SQL_DBA_LAB
WHERE criado_em >= DATE '2026-10-20' AND criado_em < DATE '2026-10-21'
ORDER BY id;
```

Esperado: BACKUP tem 2 linhas, 1 valor preenchido e soma 10; JOB tem 1 linha e soma 5. O filtro NULL retorna id=2; o intervalo retorna IDs 1 e 2. `= NULL` não substitui IS NULL. Prefira limites de intervalo e binds tipados a conversões implícitas de data.

## 4. Relacionar views com chaves corretas

```sql
SELECT t.table_name, o.status, t.num_rows, t.last_analyzed
FROM user_tables t JOIN user_objects o
  ON o.object_name=t.table_name AND o.object_type='TABLE'
WHERE t.table_name='T_SQL_DBA_LAB';
```

NUM_ROWS vem de estatísticas e pode ser NULL/desatualizado; não é COUNT(*) em tempo real. Ao consultar vários schemas/containers, inclua owner/container nas chaves necessárias para não multiplicar linhas. Estime o custo antes de contar tabelas grandes.

## 5. Controlar uma alteração de teste

```sql
UPDATE T_SQL_DBA_LAB SET valor=99 WHERE id=1;
SELECT valor FROM T_SQL_DBA_LAB WHERE id=1;
ROLLBACK;
SELECT valor FROM T_SQL_DBA_LAB WHERE id=1;
```

O segundo SELECT deve retornar 10. Confira a quantidade de linhas afetadas antes de confirmar mudanças reais. A tabela permanece para exercícios de LogMiner no cenário separado adequado. Remoção de objetos é etapa independente, com nome e alvo conferidos, sem limpeza automática em massa.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [colunas_tabela.sql](scripts/diagnostico/colunas_tabela.sql) — Consultar tipos, tamanhos e nulabilidade de colunas.

## Referências oficiais

- [SQL Language Reference](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/)
- [Transações](https://docs.oracle.com/en/database/oracle/oracle-database/19/cncpt/transactions.html)
- [Data Dictionary](https://docs.oracle.com/en/database/oracle/oracle-database/19/cncpt/data-dictionary-and-dynamic-performance-views.html)
