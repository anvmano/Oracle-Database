# Executar recuperação pontual com RMAN

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; recuperação planejada de banco inteiro ou extração de tabela em laboratório isolado.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Defina o evento, ponto desejado e transações que deixarão de existir no banco recuperado. Confirme backup anterior ao ponto, cadeia de archives, incarnation, SCN e relógio de origem. Um limite definido depois do restore pode selecionar backups novos demais; configure-o **antes de restore e recover**.

Use primeiro o [teste de restauração em host isolado](<Testar restauracao completa em laboratorio.md>). Os comandos de banco inteiro pressupõem esse destino, control file correto em MOUNT, paths próprios e mapeamento dos arquivos concluído. Não devem ser executados na origem para testar uma hipótese.

## 1. Escolher o ponto

Prefira um SCN registrado no experimento. No limite `UNTIL SCN N`, o SCN é exclusivo; planeje o número para incluir os commits desejados e excluir o evento indesejado. Para `UNTIL SEQUENCE`, a sequence também é limite exclusivo e a thread importa. Em RAC, não deduza o estado de todas as threads pelo número de uma delas.

Datas precisam do formato explícito e da interpretação de horário coerente com a origem. Não use horário do navegador/computador pessoal sem conferir o fuso do banco e a evidência do evento.

## 2. Recuperar banco inteiro — modelo RMAN

Substitua os marcadores por números/caminhos confirmados; esse bloco não é uma sequência pronta para produção:

```text
RUN {
  SET UNTIL SCN SCN_ALVO_EXCLUSIVO;
  SET NEWNAME FOR DATABASE TO NEW;
  RESTORE DATABASE;
  SWITCH DATAFILE ALL;
  RECOVER DATABASE;
}
```

O uso de `NEW` pressupõe OMF configurado no destino. Para layout preservado ou outro mapeamento, siga a forma específica do restore. Não aplique o bloco em MOUNT a um banco de origem sem plano de perda/retorno aprovado.

Alternativas ao SCN, **uma de cada vez**, no mesmo ponto do RUN:

```rman
SET UNTIL TIME "TO_DATE('2026-10-20 10:00:00','YYYY-MM-DD HH24:MI:SS')";
SET UNTIL SEQUENCE 123 THREAD 1;
```

Essas linhas exemplificam sintaxe, não representam um alvo real nem devem ser combinadas. Depois do recover bem-sucedido, confira nomes de redo/tempfiles/containers e abra conforme o cenário com RESETLOGS. Valide a evidência anterior/posterior ao evento e faça novo backup se o banco continuar em uso.

## 3. Extrair uma tabela sem importar automaticamente

Se o objetivo for recuperar uma tabela elegível, avalie o suporte/restrições do `RECOVER TABLE` da versão. O RMAN precisa de destino auxiliar e espaço para arquivos auxiliares/Data Pump. Exemplo de modelo para uma tabela de LABPDB:

```text
RECOVER TABLE APP_LAB.T_RESTORE_LAB
  OF PLUGGABLE DATABASE LABPDB
  UNTIL SCN SCN_ALVO_EXCLUSIVO
  AUXILIARY DESTINATION '/u02/aux_table'
  DATAPUMP DESTINATION '/u04/table_dump'
  DUMP FILE 't_restore_recuperada.dmp'
  NOTABLEIMPORT;
```

Este fluxo cria dados auxiliares e um dump, mas não importa a tabela automaticamente devido a NOTABLEIMPORT. Não use diretórios que contenham arquivos de outros bancos. Examine o dump/DDL e importe em schema/tabela de conferência por [IMPDP](IMPDP.md), antes de decidir como reconciliar dados com a aplicação. Recuperar uma tabela isolada pode deixar dependências de negócio inconsistentes; não sobrescreva a atual sem avaliar o conjunto.

## 4. Aceitação e retorno

Registre ponto solicitado e obtido, peças, logs, linhas esperadas/presentes e transações excluídas. Compare dependências e testes funcionais. Se o ponto estiver errado, repita o exercício desde uma base íntegra e controlada; não avance/retroceda o mesmo banco improvisando RESETLOGS/incarnations. Para restaurar o estado anterior da origem, use o plano separado de backup/retorno, não um ROLLBACK SQL.

## Referências oficiais

- [SET](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/SET.html)
- [RECOVER](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/RECOVER.html)
- [Recuperação RMAN](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/)
