# Coletar diagnósticos com AHF e TFA

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** Linux com AHF/TFA suportado já instalado; coleta local sob demanda, sem envio automático.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Registre versão exata do AHF, componentes presentes, problema, fuso, intervalo e espaço do repositório. As opções variam por versão; consulte help local. A partir do AHF 25.3, a documentação exige intervalo mínimo de 15 minutos para coleta/análise. Isso não exige instalar essa versão em outro ambiente sem verificar suporte.

Use conta autorizada para a coleta. Administração do daemon, instalação e SRDC têm exigências diferentes; não adicione o usuário ao acesso privilegiado só para contornar uma recusa. Pacotes podem conter SQL, parâmetros e dados sensíveis.

## 1. Conferir ferramenta e acesso

No host do incidente, com o executável oficial localizado pelo inventário:

```bash
tfactl version
tfactl status
tfactl access lsusers
tfactl diagcollect -help
```

Confira quais comandos são permitidos à conta usada. Não reinstale TFA antigo por cima de AHF existente. Se a ferramenta não estiver instalada, obtenha a distribuição oficial e siga o guia correspondente como mudança separada.

## 2. Delimitar a coleta

Escolha o menor período que inclua início/fim do problema e o componente necessário. Exemplo para uma hora recente, após revisar espaço e escopo:

```bash
tfactl diagcollect -database -last 1h -dryrun
```

Confira os arquivos previstos e a opção disponível na versão. Não use collectalldirs, cores ou coleta de todos os nós sem necessidade. AWR/ASH e demais componentes têm requisitos de uso próprios, mesmo quando acionados por uma ferramenta de diagnóstico.

## 3. Executar localmente

Depois de aceitar o escopo previsto:

```bash
tfactl diagcollect -database -last 1h
```

Leia o progresso, identificador, retorno e path final. Confira se o processo terminou e o arquivo está completo; uma coleta iniciada em background não está necessariamente concluída. Para um incidente antigo use from/to conforme help e fuso da instalação, sem copiar horários de outro incidente.

## 4. Inspecionar e validar

Liste membros e confirme host, período e componentes. Verifique permissões e revise dados antes de compartilhar. Se usar sanitização, confira sua disponibilidade e resultado na versão; não suponha que uma opção removeu todos os segredos. A localização do repositório deve vir da instalação, não de um path fixo do acervo.

Compare a coleta com a questão investigada: erro, trace e contexto precisam estar presentes. Siga [ADRCI](<Diagnosticar erros com ADRCI e alert log.md>) para inspeção dirigida. Enviar pacote ao suporte exige canal e destino definidos; este guia encerra na geração local.

## 5. Encerrar

Preserve evidências pelo prazo do incidente e monitore espaço. Retire somente coletas identificadas após a retenção, sem apagar o repositório inteiro nem parar o daemon que atende outros diagnósticos. Uma coleta não corrige o problema do banco.

## Referências oficiais

- [Coleta TFA](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/tfactl-command-reference/tfactl-diagcollect.html)
- [Referência TFACTL](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/tfactl-command-reference.html)
