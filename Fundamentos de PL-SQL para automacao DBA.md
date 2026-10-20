# Fundamentos de PL/SQL para automação DBA

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; procedure de leitura com direitos do invocador e teste de erro em APP_LAB.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use APP_LAB na LABPDB, com CREATE PROCEDURE e quota quando necessária. O exemplo só consulta objetos visíveis ao próprio usuário e não precisa de DBA. Não execute DDL genérico concatenando nomes de cliente, filtros livres ou parâmetros sem validação.

## 1. Conferir objetos e criar uma procedure exclusiva

Se P_LAB_CONTAR_OBJETOS já existir, leia sua definição e não o substitua. Exemplo novo:

```sql
CREATE PROCEDURE P_LAB_CONTAR_OBJETOS(p_tipo IN VARCHAR2, p_total OUT NUMBER)
AUTHID CURRENT_USER AS
BEGIN
  IF p_tipo IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001,'Informe o tipo de objeto');
  END IF;
  SELECT COUNT(*) INTO p_total FROM user_objects
  WHERE object_type=UPPER(TRIM(p_tipo));
END;
/
SHOW ERRORS PROCEDURE P_LAB_CONTAR_OBJETOS
```

AUTHID CURRENT_USER torna explícito o contexto do invocador. Em aplicações com direitos do definidor, privilégios diretos têm regras próprias; não mude AUTHID como atalho para esconder falta de concessão. A procedure não executa COMMIT/ROLLBACK e não deve confirmar trabalho do chamador.

## 2. Executar e conferir o resultado

```sql
SET SERVEROUTPUT ON
DECLARE
  n NUMBER;
  esperado NUMBER;
BEGIN
  P_LAB_CONTAR_OBJETOS('TABLE',n);
  SELECT COUNT(*) INTO esperado FROM user_objects WHERE object_type='TABLE';
  IF n<>esperado THEN
    RAISE_APPLICATION_ERROR(-20002,'Contagem divergente');
  END IF;
  DBMS_OUTPUT.PUT_LINE('Tabelas proprias: '||n);
END;
/
```

O teste verifica o contrato do parâmetro OUT, sem fixar uma contagem que depende dos exercícios já executados. Saída DBMS_OUTPUT não substitui código de erro e registro operacional de uma automação real.

## 3. Testar a falha esperada

```sql
DECLARE
  n NUMBER;
BEGIN
  P_LAB_CONTAR_OBJETOS(NULL,n);
  RAISE_APPLICATION_ERROR(-20003,'A chamada deveria ter falhado');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE<>-20001 THEN RAISE; END IF;
    DBMS_OUTPUT.PUT_LINE('Entrada nula recusada');
END;
/
```

Somente o erro esperado é aceito; os demais são propagados. Não use WHEN OTHERS THEN NULL em rotina administrativa. Para entradas em branco ou tipos não reconhecidos, defina o contrato antes de ampliar a procedure; neste exemplo um tipo sem correspondência retorna zero.

## 4. Levar a um job somente depois do teste

Siga [Scheduler](<Criar e monitorar jobs com DBMS_SCHEDULER.md>) para preparar uma rotina apropriada a job, pois esta procedure tem parâmetro OUT e não é diretamente o mesmo STORED_PROCEDURE sem argumentos do guia. Planeje repetição, efeitos parciais, logs e transações antes de automatizar manutenção.

## 5. Validar e encerrar

Confirme compilação, teste nominal e recusa de entrada nula. Nenhum dado de aplicação é alterado. Preserve o código para estudo; se retirar a procedure, confirme dependentes e proprietário antes do DROP específico. DDL não é revertido pelo ROLLBACK do chamador.

## Referências oficiais

- [PL/SQL Language Reference](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/)
- [Tratamento de erros](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/plsql-error-handling.html)
- [AUTHID](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/invokers-rights-and-definers-rights-authid-property.html)
