# Administrar segmentos LOB

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; inventário de LOBs e carga pequena em tabela própria, sem movimentação de segmentos de aplicação.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use APP_LAB na LABPDB, CREATE TABLE e quota limitada em tablespace apropriada. BasicFiles e SecureFiles têm características e requisitos próprios. Compressão, deduplicação e criptografia não são habilitadas por este exercício; confira disponibilidade e direitos antes de utilizá-las. Não faça UPDATE/COMMIT em uma tabela real para testar carga de LOB.

## 1. Relacionar tabela e segmento

```sql
SELECT table_name, column_name, segment_name, index_name, tablespace_name,
       securefile, in_row, partitioned
FROM user_lobs ORDER BY table_name, column_name;
SELECT segment_name, segment_type, tablespace_name, bytes/1024/1024 alocado_mb
FROM user_segments
WHERE segment_type LIKE 'LOB%'
ORDER BY bytes DESC;
```

Para partições/subpartições, confira também USER_LOB_PARTITIONS/USER_LOB_SUBPARTITIONS e os segmentos efetivos. A consulta simples não representa sozinha todos os casos particionados. Bytes alocados não equivalem ao tamanho lógico dos valores armazenados.

## 2. Criar um objeto exclusivo

Confirme que T_LOB_DBA_LAB ainda não existe e que a tablespace padrão tem capacidade:

```sql
CREATE TABLE T_LOB_DBA_LAB (id NUMBER PRIMARY KEY, conteudo CLOB);
INSERT INTO T_LOB_DBA_LAB VALUES (1,TO_CLOB('texto ficticio do laboratorio'));
SELECT id, DBMS_LOB.GETLENGTH(conteudo) caracteres FROM T_LOB_DBA_LAB;
ROLLBACK;
```

Após ROLLBACK, a tabela continua existindo e deve ter zero linhas. DDL confirma transações conforme suas regras; execute esse teste em sessão dedicada, sem trabalho de aplicação pendente. GETLENGTH de CLOB mede caracteres; BLOB mede bytes.

## 3. Planejar carga de arquivo ou manutenção

Uma carga por BFILE exige DIRECTORY no servidor, grants mínimos, arquivo de teste e tratamento de abertura/fechamento e exceções. Não deduza que o caminho do desktop é acessível ao servidor. Este roteiro não lê arquivos externos nem instala um carregador genérico.

Para mover/reorganizar LOB, primeiro estime cópia temporária, redo, bloqueios, índices, partições, backup e compatibilidade. Reclaim de espaço no segmento não garante redução do datafile. Não faça shrink/move de todos os LOBs por um percentual de fragmentação isolado.

## 4. Validar e encerrar

Compare o inventário antes/depois e confirme zero linhas da transação revertida. Vincule crescimento de LOB ao [guia de capacidade](<Monitorar capacidade e crescimento do banco.md>). A tabela vazia pode ser preservada para estudos; sua remoção é uma etapa separada limitada ao objeto fictício confirmado, sem PURGE automático. Dados reais e nomes de segmentos de clientes não pertencem ao Git.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [lob_segmentos.sql](scripts/diagnostico/lob_segmentos.sql) — Medir segmentos LOB agregando particoes antes do join.

## Referências oficiais

- [Administração de LOBs](https://docs.oracle.com/en/database/oracle/oracle-database/19/adlob/)
- [DBMS_LOB](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_LOB.html)
- [DBA_LOBS](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_LOBS.html)
