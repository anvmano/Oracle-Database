# Criar um par de chaves SSH

[← Índice](README.md)

**Escopo:** Windows/OpenSSH ou PuTTY; instâncias Linux no OCI.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use um par exclusivo para o laboratório. A chave **pública** vai para a instância; a **privada** permanece no computador. Chaves de assinatura da API OCI são diferentes de chaves SSH.

## 1. Gerar com OpenSSH

No PowerShell com o cliente OpenSSH instalado, crie o diretório e gere uma chave RSA em um nome ainda inexistente:

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.ssh" | Out-Null
ssh-keygen -t rsa -b 3072 -f "$env:USERPROFILE\.ssh\oracle_lab"
Get-Content "$env:USERPROFILE\.ssh\oracle_lab.pub"
```

Defina uma frase secreta no prompt. Se o arquivo já existir, escolha outro nome; não sobrescreva uma chave usada por outras instâncias.

## 2. Alternativa: PuTTYgen

1. Obtenha PuTTY/PuTTYgen no site oficial.
2. Selecione **RSA**, 3072 bits e **Generate**.
3. Defina uma frase secreta e salve a chave privada em `.ppk`.
4. Copie integralmente o campo **Public key for pasting into OpenSSH authorized_keys file** para cadastrar no OCI. Esse texto tem o formato esperado; o arquivo de **Save public key** pode usar outro formato.
5. Para uma chave OpenSSH já criada, use **Load** e salve uma cópia privada `.ppk` para o PuTTY, quando necessário.

## 3. Validar e armazenar

```powershell
ssh-keygen -lf "$env:USERPROFILE\.ssh\oracle_lab.pub"
```

Guarde a impressão digital e uma cópia protegida da chave privada. Nunca envie a chave privada ao OCI nem a inclua neste acervo.

## Referências oficiais

- [PuTTY oficial](https://www.chiark.greenend.org.uk/~sgtatham/putty/)
- [Chaves para instâncias OCI](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/managingkeypairs.htm)
