# OCI Command Line Interface (CLI)

[← Índice](README.md)

**Escopo:** OCI CLI; comandos conforme o help da versão instalada.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## 1. Instalar

Escolha **um** método compatível com seu sistema. Não misture instalação por pacote, instalador e Homebrew no mesmo executável.

### Windows / PowerShell

Baixe o instalador oficial para uma pasta de trabalho e examine-o antes da execução. A política abaixo vale somente para a sessão atual e respeita políticas da organização:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.ps1 -OutFile install.ps1
Get-Content .\install.ps1
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
.\install.ps1
```

Para aceitar os valores padrão, a última linha pode ser `.\install.ps1 -AcceptAllDefaults`. Reabra o terminal se o PATH tiver sido atualizado. O MSI oficial é outra opção indicada no Quickstart.

### Linux / Unix

```bash
curl --fail --location --output install-oci-cli.sh https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
less install-oci-cli.sh
bash install-oci-cli.sh
```

Para modo sem perguntas, use `bash install-oci-cli.sh --accept-all-defaults`. Em Oracle Linux, a alternativa por RPM deve seguir o pacote/canal indicado no Quickstart para a versão do SO; `python36-oci-cli` não é um nome universal para todas as versões.

### macOS / Homebrew

```bash
brew update
brew install oci-cli
oci --version
```

Atualização: `brew upgrade oci-cli`. Remoção: `brew uninstall oci-cli`. Em instalações por RPM, remova com `yum`/`dnf` o pacote efetivamente instalado; não use essa remoção para uma instalação feita pelo script.

## 2. Validar a instalação

```text
oci --version
oci --help
oci compute instance action --help
```

## 3. Autenticar com sessão de navegador

```text
oci session authenticate
oci session validate --profile LAB --auth security_token
oci iam region list --profile LAB --auth security_token
oci session refresh --profile LAB --auth security_token
```

Escolha a região correta e crie o perfil `LAB` no primeiro comando, ou substitua esse nome nos demais. O arquivo padrão fica em `~/.oci/config` (no Windows, `%USERPROFILE%\.oci\config`). Tokens expiram; autentique novamente se a renovação não for possível. Não é necessário abrir todo uso da CLI como administrador.

## 4. Alternativa: chave de assinatura da API

```text
oci setup config
```

Informe OCIDs do **usuário** e do **tenancy**, região, diretório `~/.oci` e nome da chave. O diretório de chaves não é o arquivo `config`. Cadastre somente a chave pública em **User → API keys** e confira a impressão digital. Use `--profile LAB` com autenticação por API key; nesse modo, não adicione `--auth security_token`. Guarde a chave privada e sua frase secreta de forma protegida.

## 5. Consultar e operar uma instância

Primeiro copie o OCID da instância correta. Exemplos no PowerShell para o perfil de sessão:

```powershell
$instanceOcid = 'SUBSTITUIR_PELO_OCID_DA_INSTANCIA'
oci compute instance get --instance-id $instanceOcid --profile LAB --auth security_token
```

Confirme nome, compartimento e estado na resposta antes de executar **uma** ação:

```powershell
oci compute instance action --action START --instance-id $instanceOcid --profile LAB --auth security_token
```

Para desligamento normal, substitua `START` por `SOFTSTOP`; para reinício normal, por `SOFTRESET`. Combine isso com a parada ordenada do banco. `STOP` e `RESET` são ações forçadas e não devem ser o primeiro recurso. Consulte novamente `instance get` até confirmar o estado esperado; a aceitação da requisição não significa que a transição terminou.

## Referências oficiais

- [Instalação e configuração](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
- [Ações de Compute](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/compute/instance/action.html)
- [Sessões](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clitoken.htm)
