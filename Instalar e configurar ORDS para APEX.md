# Instalar e configurar ORDS para APEX

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** ORDS 25.3 em Linux, configuração fora dos binários e instalação interativa em PDB compatível.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Este roteiro fixa ORDS **25.3** para referência reproduzível; não afirma que seja a versão mais recente. Confirme a combinação suportada de ORDS, Java, Database, APEX e container web. O guia antigo de APEX 19.2 é histórico e não demonstra compatibilidade automática com ORDS 25.3. Java deve atender à lista de versões suportadas dessa release, cujo mínimo indicado é Java 17.

Faça backup de configuração anterior, banco/PDB e aplicações APEX. Use usuário de SO próprio do serviço, acesso restrito aos diretórios e banco/serviço identificados. Portas só devem ser expostas às origens necessárias. Instalação/upgrades de metadados ORDS alteram o banco.

## 1. Preparar software e configuração

Baixe mídia oficial, confira checksum e extraia em diretório de versão, por exemplo `/opt/ords/25.3`, com escrita reservada à administração do software. Prepare `/home/ords/config` pertencente ao usuário de serviço, modo restrito; não o coloque dentro do ZIP/binários nem no Git.

Como usuário de serviço, usando o Java certificado:

```bash
export PATH=/opt/ords/25.3/bin:$PATH
java -version
ords --version
ords --help
ords --config /home/ords/config install --help
```

Se a instalação já existir, inventarie pools/credenciais e siga o fluxo de atualização, sem criar um pool duplicado para tentar resolver erro.

## 2. Instalar interativamente

```bash
ords --config /home/ords/config install
```

1. Selecione o pool e tipo de conexão adequados.
2. Informe host, porta e **serviço da PDB** onde o APEX está instalado.
3. Use a credencial administrativa requerida pela versão no prompt; não passe senha na linha de comando/arquivo versionado.
4. Confira as opções de instalação do banco, usuários/proxy, privilégios e APEX.
5. Guarde o log, sem divulgar credenciais, e confirme sucesso antes de iniciar o servidor.

Não use `java -jar ords.war install` como comando moderno equivalente. Não desbloqueie contas/APEX gateway por uma receita antiga sem conferir o requisito da versão.

## 3. Configurar imagens e porta de teste

Use a pasta `images` da **mesma mídia APEX instalada no banco**, legível pelo serviço ORDS. Confira propriedades aceitas por `config --help`/guia antes de mudar um pool existente. Exemplo de standalone:

```bash
ords --config /home/ords/config config set standalone.static.path /home/ords/apex/images
ords --config /home/ords/config config set standalone.http.port 8080
ords --config /home/ords/config serve
```

Antes de serve, mantenha TCP/8080 bloqueada para redes não autorizadas. Para teste remoto HTTP, use túnel SSH protegido e acesso local; não envie credenciais pela internet em HTTP. Para uso permanente, configure HTTPS/certificado e nome público pelo modo suportado (standalone ou proxy/container certificado), incluindo cabeçalhos e URL externa, e teste a cadeia TLS. Não exponha uma instalação padrão como se TLS estivesse pronto.

## 4. Validar

No acesso local/protegido, confira `/ords/`, login em workspace, aplicação de teste e carregamento de `/i/` conforme o prefixo APEX configurado. Falta de CSS/imagens pode indicar mídia estática incompatível; não é motivo para reinstalar todo o banco.

Confira pools, conexões, logs, limites, sessão, endpoints REST autorizados e permissões do usuário do SO. Teste HTTPS/hostname e ausência de exposição de credenciais. Se habilitar REST em schemas, faça-o somente para o escopo desejado; ORDS instalado não autoriza publicar todos os objetos.

## 5. Operação e retorno

Configure partida/parada pelo mecanismo de serviço do host, sem rodar como root, e registre home de software/configuração, Java e logs. Pare o serviço antes de alterar binários e preserve a configuração fora deles. Repor apenas o ZIP antigo pode ser insuficiente após upgrade de metadados no banco: use o plano de compatibilidade/backup da versão antes de tentar downgrade. Não execute uninstall como correção genérica de erro de conexão.

## Referências oficiais

- [ORDS 25.3 — instalação e requisitos](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/25.3/ordig/)
- [Checklist ORDS](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/25.3/ordig/installing-REST-data-services.html)
