# Aumentar swap e volumes LVM

[← Índice](README.md)

**Escopo:** Linux/LVM; ampliação de swap e filesystems XFS/ext4 identificados.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Exemplo para Linux com LVM, volume group `ol` e swap em LV. **Não é um roteiro para reduzir volumes.** Confirme backups, console de contingência, montagem e espaço. Os nomes `/dev/sdb`, `ol`, `swap` e `tmp` devem ser substituídos pelos dispositivos reais verificados por serial/WWN; não aplique a um disco com dados existentes.

## 1. Inventariar — root

```bash
lsblk -f
blkid
pvs
vgs
lvs -a -o +devices
findmnt /tmp
swapon --show
free -h
df -hT
```

Se adicionar um disco virtual, faça-o pelo hipervisor conforme seu suporte a hotplug, redescubra os dispositivos e confira a identidade. Havendo espaço livre no VG existente, não é necessário criar outro PV.

## 2. Adicionar capacidade ao VG, se necessário

Somente no **novo disco vazio confirmado**, crie partição com tipo Linux LVM pelo `fdisk`/`parted` apropriado ao layout MBR/GPT. Confira o resultado e a leitura da nova tabela antes de seguir. Exemplo apenas se `/dev/sdb1` for a nova partição correta:

```bash
pvcreate /dev/sdb1
vgextend ol /dev/sdb1
pvs
vgs
```

`pvcreate` inicializa metadados; não aceite força de sobrescrita como resposta genérica a uma assinatura existente.

## 3. Ampliar swap

Confira a RAM disponível antes de `swapoff`: páginas precisam voltar à memória; se não couberem, a operação pode falhar e ameaçar a estabilidade. Planeje janela/redução de carga. Guarde o UUID atual, configuração do `/etc/fstab` e eventual parâmetro de resume.

Para acrescentar **4 GiB**, com espaço livre suficiente e LV confirmado:

```bash
swapoff /dev/mapper/ol-swap
```

**Só continue se a saída/código confirmarem sucesso** e a área não estiver em `swapon --show`:

```bash
lvextend -L +4G /dev/mapper/ol-swap &&
mkswap /dev/mapper/ol-swap
```

`mkswap` recria a assinatura e pode gerar novo UUID. Se `/etc/fstab` ou resume usarem UUID, atualize-os para o valor recém-confirmado (ou siga o procedimento documentado para preservar o UUID). Não presuma que o próximo boot encontrará a swap pelo UUID antigo.

```bash
swapon /dev/mapper/ol-swap
swapon --show
free -h
```

Use `lvextend`, em vez de `lvresize -L 8G`, para deixar explícito que a operação é ampliação; um tamanho absoluto inferior ao atual não é uma ampliação.

## 4. Ampliar filesystem já existente em /tmp

Confira com `findmnt` que `/tmp` é realmente o LV indicado, e não `tmpfs`, outro mount ou diretório do filesystem raiz. Escolha **um** comando de crescimento após aumentar o LV, com tipo identificado:

```bash
lvextend -L +5G /dev/mapper/ol-tmp
```

- XFS montado em `/tmp`: `xfs_growfs /tmp`.
- ext4 compatível no LV confirmado: `resize2fs /dev/mapper/ol-tmp`.

Confira `lvs`, `findmnt /tmp` e `df -hT /tmp`. Crescer o LV sozinho não necessariamente aumenta o filesystem. XFS não admite redução pelo mesmo procedimento.

## 5. Criar um novo /tmp dedicado, se esse for o plano

Em uma janela com os consumidores interrompidos, crie um LV **novo** e confirme que ele não existe nem possui dados antes de formatar. Exemplo de tamanho a ajustar:

```bash
lvcreate -L 20G -n tmp ol &&
mkfs.xfs /dev/ol/tmp
blkid /dev/ol/tmp
```

Faça backup do conteúdo/configuração e planeje a transição: montar um filesystem sobre `/tmp` esconde o conteúdo anterior. Adicione ao `/etc/fstab` uma entrada usando o UUID **real**, tipo e opções compatíveis com os instaladores. Não copie um UUID de exemplo. Opções como `noexec` precisam ser conciliadas com requisitos dos produtos.

Monte somente o destino planejado; confira `findmnt /tmp` e garanta proprietário root e modo `1777` na raiz de `/tmp`. **Não** aplique `chown -R oracle`/`chmod -R 775` a `/tmp`.

Antes de reiniciar, valide a entrada e a montagem conforme as ferramentas da versão. `lvremove` não desfaz uma criação preservando dados: destrói o LV. Não o inclua como correção automática de um erro de montagem.

## Referências oficiais

- [Administração Oracle Linux](https://docs.oracle.com/en/operating-systems/oracle-linux/)
- [LVM e armazenamento OL7](https://docs.oracle.com/en/operating-systems/oracle-linux/7/stordev/)
