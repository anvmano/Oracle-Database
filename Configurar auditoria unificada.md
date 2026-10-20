# Configurar e consultar auditoria unificada

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; política local de DML em PDB de laboratório, administração e consulta separadas.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use uma conta com `AUDIT_ADMIN` para administrar políticas e `AUDIT_VIEWER` para leitura conforme a política de privilégios. Confirme mixed/pure unified auditing, RU, container e políticas já habilitadas. `V$OPTION` com Unified Auditing FALSE não significa ausência de qualquer auditoria: pode haver modo misto.

```sql
SHOW CON_NAME
SELECT parameter, value FROM v$option WHERE parameter='Unified Auditing';
SELECT * FROM audit_unified_enabled_policies;
```

Este roteiro não relinka binários nem muda globalmente o modo de auditoria. Políticas e trilhas podem conter dados pessoais/SQL; dimensione retenção, acesso e destino de arquivamento antes de ampliar coleta.

## 1. Preparar o objeto de teste — APP_LAB

Na LABPDB, crie uma tabela nova e exclusiva:

```sql
CREATE TABLE T_AUDIT_LAB (id NUMBER PRIMARY KEY, descricao VARCHAR2(100));
```

## 2. Criar e habilitar a política — administrador de auditoria na mesma PDB

```sql
CREATE AUDIT POLICY LAB_DML_POLICY
  ACTIONS INSERT ON APP_LAB.T_AUDIT_LAB,
          UPDATE ON APP_LAB.T_AUDIT_LAB,
          DELETE ON APP_LAB.T_AUDIT_LAB;
AUDIT POLICY LAB_DML_POLICY BY APP_LAB;
```

Confira que o nome da política não existia e examine `AUDIT_UNIFIED_POLICIES`/`AUDIT_UNIFIED_ENABLED_POLICIES`. Esse escopo não audita todo o banco, todos os SELECTs nem todas as tentativas de login. Evite políticas amplas sem estimar volume e requisito.

## 3. Gerar evento e conferir — sessões separadas

Reconecte APP_LAB à PDB e execute:

```sql
INSERT INTO T_AUDIT_LAB VALUES (1,'evento de auditoria');
COMMIT;
```

Como leitor autorizado da trilha na PDB:

```sql
SELECT event_timestamp, dbusername, action_name, object_schema,
       object_name, return_code, unified_audit_policies
FROM unified_audit_trail
WHERE object_schema='APP_LAB' AND object_name='T_AUDIT_LAB'
  AND event_timestamp >= SYSTIMESTAMP-INTERVAL '1' HOUR
ORDER BY event_timestamp;
```

Compare horário/usuário/objeto e RETURN_CODE. Registro de uma ação auditada não prova que a transação foi confirmada; auditoria e estado de negócio são evidências diferentes. Em coleta assíncrona, use o mecanismo documentado de flush apenas se necessário, sem concluir que falta de linha imediata é política inválida.

## 4. Retenção e arquivamento

Defina destino protegido, período obrigatório, extração verificável e armazenamento de evidências. `DBMS_AUDIT_MGMT` permite gerenciamento/limpeza da trilha, mas a marca de último evento arquivado precisa refletir **o que foi realmente preservado**, com semântica UTC conforme a API. Não use simplesmente `SYSDATE-90` como prova de arquivamento nem apague arquivos/tabelas internas.

Teste restauração/acesso à evidência arquivada e só então configure a rotina de limpeza compatível com a release. Documente responsável e limites para não perder eventos necessários.

## 5. Retirar a política de laboratório

Depois de guardar a evidência e confirmar o escopo, como administrador da mesma PDB:

```sql
NOAUDIT POLICY LAB_DML_POLICY BY APP_LAB;
DROP AUDIT POLICY LAB_DML_POLICY;
```

Confira que outras políticas continuam habilitadas. Remover a política não implica apagar os registros já produzidos. Excluir a tabela de teste é uma operação independente e só deve ocorrer após verificar suas dependências/conteúdo.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [auditoria_politicas.sql](scripts/diagnostico/auditoria_politicas.sql) — Consultar configuracao de politicas de auditoria unificada.

## Referências oficiais

- [Guia de segurança](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/)
- [Política de exemplo](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/tutorial-auditing-nondatabase-users.html)
- [DBMS_AUDIT_MGMT](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_AUDIT_MGMT.html)
