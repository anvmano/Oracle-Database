# Diagnosticar erros com ADRCI e alert log

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c/ADR; coleta de diagnóstico, sem limpeza automática de evidências.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Registre erro, horário com fuso, operação, serviço, host e última mudança conhecida. Use o proprietário do software ou acesso de diagnóstico autorizado. Logs/traces podem conter SQL, caminhos e dados sensíveis; armazene e compartilhe por canal aprovado.

## 1. Localizar os diretórios reais — SQL*Plus

```sql
SELECT name, value FROM v$diag_info ORDER BY name;
```

`Diag Trace`, `Diag Alert` e `Default Trace File` têm papéis distintos. Não presuma um caminho de alert log baseado no nome de outra instância ou em maiúsculas/minúsculas de outro host.

## 2. Selecionar o ADR home — shell e ADRCI

No shell do home correto, execute `adrci`. No prompt ADRCI:

```text
show base
show homes
```

Escolha **um home real retornado**, por exemplo:

```text
set homepath diag/rdbms/orcl/ORCL
show alert -tail 100 -term
show incident
show problem
```

Não copie o home de exemplo se o ambiente retorna outro. Para acompanhar novas entradas, `show alert -tail 20 -f` permanece ativo até interrupção pelo operador; não o use como coleta batch com término esperado.

## 3. Correlacionar a falha

1. Identifique a primeira ocorrência e as mensagens imediatamente anteriores/posteriores.
2. Confira se há incident ID, trace associado, erro de SO ou destino de armazenamento.
3. Correlacione com aplicação, jobs, espaço, arquivos, listener e mudança recente.
4. Para um incidente específico, consulte o help e detalhes com `show incident -mode detail`/filtro apropriado; não conclua que toda mensagem ORA gera incidente ADR.

Para coleta finita em batch, com home real substituído:

```bash
adrci exec="set homepath diag/rdbms/orcl/ORCL; show alert -tail 100 -term" > alert_recente.txt
```

Confira código de saída e conteúdo. Para filtro de período/erro, use a sintaxe `-p` documentada no help da versão e preserve a consulta usada junto da evidência.

## 4. Empacotar e preservar

Para incidente a encaminhar ao suporte, siga o fluxo IPS do ADRCI: crie um pacote a partir do **incident ID confirmado**, confira seu conteúdo e gere em diretório protegido com espaço. Não envie automaticamente o pacote para terceiros. Guarde número do chamado e o intervalo de coleta.

Não execute `purge` antes de preservar as evidências e revisar retenção/capacidade. O plano de retenção é manutenção separada; excluir logs não corrige a causa do erro.

## 5. Aceitação e encerramento

O resultado deve permitir ligar erro → horário → instância/container → trace/incidente → hipótese verificável. Esse guia não aplica correções no banco; qualquer intervenção deve registrar impacto, validação e retorno próprios. Encerre ADRCI com `exit` e proteja os arquivos de coleta.

## 6. Conferir filtros antes de automatizar alertas

Como administrador autorizado no container e ADR home corretos, exemplo de seleção do último dia:

```sql
SELECT originating_timestamp, message_text
FROM v$diag_alert_ext
WHERE originating_timestamp >= SYSTIMESTAMP-INTERVAL '1' DAY
  AND REGEXP_LIKE(message_text,'ORA-[0-9]{5}')
  AND NOT REGEXP_LIKE(message_text,'^LAB_INFO_A:')
  AND NOT REGEXP_LIKE(message_text,'^LAB_INFO_B:')
ORDER BY originating_timestamp;
```

LAB_INFO_A/B são prefixos **sintéticos** para exercitar duas exclusões, não classificação real de erro Oracle. No teste, `ORA-01578: exemplo` deve passar e mensagens ORA com cada prefixo sintético devem ser excluídas. Usar OR entre as duas negações deixa passar uma mensagem que só corresponde a uma exclusão. Não exclua códigos ORA universalmente: até mensagens informativas precisam de contexto e o texto pode conter múltiplos erros.

Defina início/fim e fuso de cada coleta, evitando intervalos sobrepostos ou lacunas; um contador positivo não identifica qual erro ocorreu. Bancos/ADR homes múltiplos exigem confirmar o escopo disponível na versão; resultado vazio por falta de privilégio/escopo não é saúde comprovada. Para coleta ampliada local, veja [AHF/TFA](<Coletar diagnosticos com AHF e TFA.md>).

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [alertas_recentes.sql](scripts/diagnostico/alertas_recentes.sql) — Consultar erros e avisos do ADR no periodo.

## Roteiros de solução de problemas

- [06 · Bloqueios, transações presas e deadlocks](solucao-de-problemas/06-bloqueios-transacoes-e-deadlocks.md).
- [20 · Corrupção de blocos ou falha de leitura de dados](solucao-de-problemas/20-corrupcao-de-blocos.md).

## Referências oficiais

- [ADRCI](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-adr-command-interpreter-adrci.html)
- [V$DIAG_INFO](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-DIAG_INFO.html)
