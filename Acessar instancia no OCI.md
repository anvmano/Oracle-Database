# Acessar uma instância Linux no OCI

[← Índice](README.md)

**Escopo:** Instância Linux com OpenSSH ou PuTTY; usuário conforme a imagem.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Confirme que a VM está **Running**, possui um caminho de rede acessível e permite TCP/22 a partir da sua origem. Tenha a chave privada correspondente à pública cadastrada. Leia o usuário e o endereço em **Compute → Instances → detalhes da instância**.

## 1. Conectar por OpenSSH

Exemplo no PowerShell; substitua o endereço de documentação pelo IP real:

```powershell
ssh -i "$env:USERPROFILE\.ssh\oracle_lab" opc@203.0.113.10
```

Antes de aceitar a primeira conexão, compare a impressão digital da chave do servidor por um canal confiável, como a saída de inicialização/console da instância ou seu inventário de administração. Se ela mudar sem explicação, interrompa a conexão e investigue.

## 2. Alternativa com PuTTY

1. Em **Session**, preencha endereço, porta `22` e protocolo **SSH**.
2. Em **Connection → SSH → Auth → Credentials** (ou **Auth**, conforme a versão), selecione a chave privada `.ppk`.
3. Volte a **Session**, salve a sessão e clique em **Open**.
4. Confira a impressão digital e entre com o usuário informado pelo Console. Não presuma `root` para imagens importadas.

## 3. Validar identidade e elevar privilégio quando necessário

```bash
whoami
hostname -f
ip -brief address
sudo -l
```

Use `sudo comando` para a tarefa administrativa. Se um procedimento exigir uma sessão root, execute `sudo -i` e encerre-a com `exit` ao terminar.

## Diagnóstico

| Sintoma | Verificar |
|---|---|
| Timeout | IP, rota, gateway, NSG/security list e firewall |
| Permission denied (publickey) | Usuário, par de chaves e permissões de `authorized_keys` |
| Host key changed | Reconstrução legítima da VM ou destino incorreto; confirmar antes de alterar `known_hosts` |

## Referências oficiais

- [Acesso SSH ao OCI](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/accessinginstance.htm)
