# Migrar uma VM VirtualBox para OCI

[← Índice](README.md)

**Escopo:** Migração por imagem; comandos de preparação dependem do SO, firmware e versão do VirtualBox.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

O roteiro original era de VirtualBox 6.1 com Oracle Linux 7. Os menus e ajustes de boot variam com a versão. Use VirtualBox e Extension Pack **da mesma versão**, com suporte à integração OCI, e confira os termos de uso. Para um SO diferente, siga os requisitos de imagens personalizadas do OCI, não os comandos OL7 abaixo.

Faça backup da VM e teste mudanças em uma cópia. Migração de VM com banco também exige um plano de consistência/backup do banco; não exporte discos de uma instância Oracle em atividade como se fosse backup consistente.

## 1. Preparar chave de API e perfil

Use `oci setup config` do [guia CLI](<Command Line Interface (CLI).md>) ou gere uma chave RSA de assinatura da API. Em Bash/Git Bash com OpenSSL, usando nomes ainda inexistentes:

```bash
umask 077
mkdir -p ~/.oci
openssl genrsa -aes256 -out ~/.oci/oci_api_key.pem 2048
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c
```

Defina a frase secreta nos prompts. Cadastre **a pública** em API keys do usuário OCI e compare a impressão digital. MD5 aqui é o formato de identificação exigido pela API, não uma escolha para integridade de backups.

Crie um perfil Cloud no VirtualBox com os valores reais:

| Campo | Origem |
|---|---|
| `user` | OCID do usuário OCI |
| `tenancy` | OCID do tenancy |
| `compartment` | OCID do **compartimento**, não da instância |
| `region` | Identificador da região |
| `fingerprint` | Impressão digital da chave de API cadastrada |
| `key_file` | Caminho absoluto da chave privada no host |

Configure a frase secreta pelo mecanismo aceito na versão do VirtualBox. Não inclua chave ou senha no acervo. Verifique políticas IAM de Compute, imagens, Object Storage e rede no compartimento escolhido.

## 2. Preparar o sistema convidado

1. Use DHCP; retire amarrações a IP/MAC da rede de origem conforme o guia da imagem. Confira `ip address`, `ip route` e DNS.
2. Verifique suporte aos drivers paravirtualizados de disco/rede no kernel/initramfs. Use o procedimento de `dracut` documentado para seu SO e kernel; não suponha que `--add qemu` baste para todos os casos.
3. Habilite console serial conforme os requisitos de imagem OCI. Em OL7, preserve **todos** os parâmetros de boot existentes ao acrescentar opções como `console=ttyS0,115200`; não substitua toda a linha `GRUB_CMDLINE_LINUX`, pois pode remover opções de root/LVM.
4. Se a imagem exigir nomenclatura de interface diferente, ajuste configuração de rede, regras persistentes e boot de forma consistente. Não renomeie a interface ativa via SSH e não exclua regras udev indiscriminadamente.
5. Gere a configuração GRUB/initramfs nos destinos corretos para BIOS ou UEFI e kernel do convidado. O caminho BIOS `/boot/grub2/grub.cfg` não é universal.
6. Prepare um usuário administrativo com `sudo`, chave SSH e `authorized_keys` válidos antes da migração. Não presuma acesso remoto como `root` nem criação automática do usuário `opc` em imagem importada.
7. Reinicie a cópia local e confirme boot, rede, SSH e console serial. Só prossiga após essa verificação.

## 3. Exportar

1. Pare serviços e o banco de forma ordenada. Desligue a VM pelo SO/ACPI e confirme que não está em execução nem em estado salvo.
2. No VirtualBox, escolha exportar para OCI e selecione o perfil correto.
3. Selecione um bucket **privado**, de classe Standard, na região adequada. Não é necessário tornar a imagem pública.
4. Defina nome da imagem, modo de lançamento compatível, shape, tamanho de disco e compartimento.
5. A criação automática de uma instância é uma **opção** da exportação. Se habilitada, selecione VCN, sub-rede, NSG e decisão explícita sobre IP público; se desabilitada, lance depois a instância a partir da imagem.
6. Acompanhe a operação no Console OCI e os logs locais. No PowerShell do host:

```powershell
Get-Content -LiteralPath "$env:USERPROFILE\.VirtualBox\VBoxSVC.log" -Wait
```

## 4. Validar no destino

Confirme estado e diagnósticos de inicialização, volumes, DHCP, rotas, relógio, console serial e acesso com o usuário/chave preparados. Valide serviços e banco, incluindo backup e conectividade da aplicação. Mantenha a origem preservada até a aceitação da migração e evite iniciar simultaneamente duas cópias com a mesma identidade na rede.

## Referências oficiais

- [VirtualBox — integração Cloud](https://docs.oracle.com/en/virtualization/virtualbox/7.0/user/Introduction.html)
- [Requisitos de imagens Linux OCI](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/importingcustomimagelinux.htm)
- [Chaves de API](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm)
