# Usar Flashback e restore points

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; exercícios independentes em laboratório, conforme edição e suporte de cada recurso.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Flashback Query, Flashback Table e Flashback Database são recursos diferentes. Confira disponibilidade/licenciamento, privilégios, undo, FRA, archives e restrições do recurso escolhido. Um restore point comum marca um SCN; um **guaranteed restore point** tem efeito sobre preservação de flashback logs e consumo de espaço. Nenhum substitui backup contra perda física do armazenamento.

## 1. Consultar dados anteriores — Flashback Query

No schema de teste, registre um SCN antes de uma alteração controlada em tabela existente. Depois de COMMIT, consulte o estado anterior com o SCN real:

```text
SELECT * FROM APP_LAB.T_RESTORE_LAB AS OF SCN SCN_CONFIRMADO;
```

A consulta depende da disponibilidade de undo e das restrições de DDL/objeto. Erro de snapshot antigo não é resolvido retroativamente elevando apenas UNDO_RETENTION. Compare com o estado corrente antes de decidir recuperar/reconciliar linhas.

## 2. Reverter uma tabela — operação diferente

Para Flashback Table, confirme privilégios, undo, constraints e suporte do objeto. O comando afeta o conteúdo inteiro da tabela e depende de row movement; não é uma consulta histórica. Modelo, após preservar a situação atual:

```text
ALTER TABLE APP_LAB.T_RESTORE_LAB ENABLE ROW MOVEMENT;
FLASHBACK TABLE APP_LAB.T_RESTORE_LAB TO SCN SCN_CONFIRMADO;
```

Planeje bloqueios/consumidores e avalie tabelas relacionadas; gatilhos e outras dependências seguem as regras Oracle do recurso. Registre o estado original de row movement para decidir sua manutenção depois. Não execute como etapa seguinte obrigatória à consulta acima.

## 3. Preparar Flashback Database — administrador

Use um banco de laboratório inteiro, em ARCHIVELOG, FRA configurada/dimensionada, espaço físico e backup testado. Preserve a configuração anterior. Quando o fluxo exigir preparação em MOUNT, após parada planejada:

```sql
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE FLASHBACK ON;
ALTER DATABASE OPEN;
SELECT flashback_on FROM v$database;
```

Defina a meta de retenção segundo a janela pretendida e a capacidade; ela não garante qualquer ponto arbitrário. Para o exercício, crie um nome novo:

```sql
CREATE RESTORE POINT LAB_ANTES_MUDANCA GUARANTEE FLASHBACK DATABASE;
SELECT name, scn, guarantee_flashback_database, storage_size FROM v$restore_point;
```

Em CDB/PDB, restore points por container têm escopos/requisitos diferentes; este exemplo é do banco inteiro no root, não da PDB isolada.

## 4. Reverter o banco — somente se esse for o objetivo

Após alteração de teste registrada, interrompa consumidores e confirme que toda mudança posterior ao ponto deve ser descartada. No laboratório, como SYSDBA:

```sql
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
FLASHBACK DATABASE TO RESTORE POINT LAB_ANTES_MUDANCA;
ALTER DATABASE OPEN RESETLOGS;
```

Se houver erro, preserve diagnóstico e não force abertura. Restrições de datafiles, redo, flashback logs e mudanças de estrutura precisam ser avaliadas. Valide evidências e serviços, registre a nova incarnation e faça backup apropriado.

## 5. Encerrar proteção e monitorar FRA

Somente após aceitação e término da necessidade de retorno, remova o **restore point exato** com `DROP RESTORE POINT LAB_ANTES_MUDANCA;`. Revise `V$RESTORE_POINT` e a FRA; apagar o ponto garantido retira essa proteção. Desabilitar Flashback Database, quando desejado, exige uma decisão separada e revisão do estado anterior. Nunca deixe pontos garantidos indefinidamente sem capacidade/monitoramento.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [recyclebin.sql](scripts/diagnostico/recyclebin.sql) — Consultar objetos presentes na lixeira.

## Referências oficiais

- [Flashback e recuperação](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/)
- [FLASHBACK DATABASE](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/FLASHBACK-DATABASE.html)
- [FLASHBACK TABLE](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/FLASHBACK-TABLE.html)
