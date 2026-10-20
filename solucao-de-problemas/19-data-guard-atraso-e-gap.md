# 19 · Standby atrasado ou com gap de archives

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

atraso de transporte/aplicação, erro de destino ou sequências faltantes. Lacuna vazia em uma consulta não garante sincronismo; o timestamp da medição precisa estar atual.

## Arquivos do projeto

[standby físico](<../Criar standby fisico com Data Guard.md>), [Broker](<../Administrar Data Guard com Broker.md>), [data_guard_status.sql](../scripts/diagnostico/data_guard_status.sql), [data_guard_gap.sql](../scripts/diagnostico/data_guard_gap.sql), [redo_archives.sql](../scripts/diagnostico/redo_archives.sql), [FRA](<../Monitorar FRA e archivelogs.md>).

## Roteiro de solução

1. Confirme nomes únicos/papéis de ambos os bancos. Colete estado no primary e no standby em root/non-CDB; a consulta de gap pertence ao standby.
2. Compare transport lag, apply lag, `DATUM_TIME`, erro de destino e sequências por thread/encarnação. Separe redo não enviado de redo recebido e não aplicado.
3. Se não transporta, investigue rede/serviço, autenticação, destino e espaço. Se recebe mas não aplica, examine apply, erros e gargalos do standby.
4. Para gap, localize os archives corretos no primary/backup e siga o procedimento de transferência/registro/aplicação. Se faltarem fontes, avalie recuperação adicional ou reconstrução no roteiro apropriado.
5. Em ambiente com Broker, use suas informações/logs e administração correspondente; não mantenha controles concorrentes sem decisão sobre quem gerencia transporte/apply.

## Confirmar a retomada

Atraso converge à meta com amostras atuais, sequências avançam e os erros cessam. Failover é decisão de contingência com possível perda de dados, não solução automática para lag.

## Referências oficiais

- [Troubleshooting Data Guard](https://docs.oracle.com/en/database/oracle/oracle-database/19/dgbkr/troubleshooting-oracle-data-guard-broker.html).

[← Problema 18](18-falhas-no-backup-rman.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 20 →](20-corrupcao-de-blocos.md)
