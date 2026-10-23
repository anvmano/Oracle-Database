# Gerar um relatório básico do sistema operacional

[← Índice](README.md)

**Escopo:** Relatório pontual em Linux; sem instalação ou coleta executada neste computador.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Script para Linux com Bash, `procps-ng` e ferramentas básicas (`df`, `awk`, `who`, `ps`). Não requer root para as consultas básicas. É um retrato pontual, não um sistema de alertas nem um diagnóstico de desempenho Oracle.

## 1. Salvar o script

Copie o bloco abaixo para `monitorar_so.sh`, em UTF-8 **sem BOM**, com quebras de linha LF:

```bash
#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

printf 'Relatorio: %s\n' "$(date -Is)"
printf '\nTempo de atividade\n'
uptime
printf '\nSessoes conectadas\n'
who
printf '\nDisco por filesystem\n'
df -hP
printf '\nMemoria e swap (MiB)\n'
free -m
printf '\nProcessos por CPU (amostra de ps)\n'
ps -eo pid,user,pcpu,pmem,comm --sort=-pcpu | awk 'NR <= 11'
```

A saída de `free` mantém RAM e swap separadas. `df` mantém uma linha por filesystem, sem achatar a tabela e ler colunas de outro volume. A amostra `ps` ordena por uso de CPU informado pela ferramenta; não mede um intervalo novo como `top` interativo. `comm` mostra o nome do comando sem seus argumentos. Usuários, sessões e caminhos ainda podem revelar informações do ambiente: revise antes de compartilhar.

## 2. Conferir sintaxe e executar

```bash
bash -n monitorar_so.sh
bash monitorar_so.sh
```

Confira que há cabeçalhos, espaço por filesystem, RAM/swap separadas e linhas de processos. Se desejar execução direta, use `chmod u+x monitorar_so.sh` e `./monitorar_so.sh`; a primeira linha deve permanecer intacta.

## 3. Salvar resultado e verificar falha

```bash
(
  set -e
  umask 077
  mkdir -p coletas
  chmod 700 coletas
  relatorio=$(mktemp coletas/relatorio_so_XXXXXXXX.txt)
  bash monitorar_so.sh > "$relatorio"
)
```

Execute na raiz da sua cópia do projeto ou em um diretório privado de trabalho. O diretório `coletas` fica acessível somente ao dono, e `mktemp` cria um arquivo novo com acesso restrito, sem sobrescrever relatórios anteriores. `/coletas/` e o padrão `relatorio_so_*.txt` são ignorados pelo Git do projeto; isso não retira arquivos já rastreados.

O código de saída deve ser zero. Comando ausente/falha de coleta interrompe o script e sinaliza falha, em vez de imprimir valores deslocados como se fossem válidos. O arquivo pode ficar parcial; não o trate como coleta completa quando houver erro. Para últimas conexões, consulte `last -n 3` separadamente, quando essa ferramenta e o histórico estiverem disponíveis.

## Roteiros de solução de problemas

- [04 · Limite de processos ou sessões atingido](solucao-de-problemas/04-limite-de-processos-e-sessoes.md).
- [12 · Falta de memória compartilhada ou pressão de PGA](solucao-de-problemas/12-memoria-sga-e-pga.md).

## Referências oficiais

- [Bash](https://www.gnu.org/software/bash/manual/bash.html)
- [GNU df](https://www.gnu.org/software/coreutils/manual/html_node/df-invocation.html)
- [procps-ng](https://gitlab.com/procps-ng/procps)
