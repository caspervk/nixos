# nixos

## Installation
Follow the [NixOS manual](https://nixos.org/manual/nixos/stable/index.html#ch-installation) to obtain and boot
the installation medium. Use the graphical ISO image since it ships with useful programs such as `nmtui`; the
installation can still be done through the terminal.

### Disk Partitioning
For [impermanence](https://nixos.wiki/wiki/Impermanence), partitioning should be done as outlined in the [tmpfs
as root](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/) blogpost, but with `/nix` as a [LUKS-encrypted file
system](https://nixos.org/manual/nixos/stable/index.html#sec-luks-file-systems). The boot partition will not be
encrypted, since that is poorly supported by systemd-boot. Persistent files will be saved under `/nix/persist`.

The following is based on the [tmpfs as root](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/) blogpost, the NixOS
manual's [partitioning](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual-partitioning),
[formatting](https://nixos.orgmanual/nixos/stable/index.html#sec-installation-manual-partitioning-formatting) and
[LUKS-Encrypted File Systems](https://nixos.org/manual/nixos/stable/index.html#sec-luks-file-systems) sections,
ArchWiki's [LVM on LUKS](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS),
the unofficial NixOS wiki [Full Disk Encryption](https://nixos.wiki/wiki/Full_Disk_Encryption), and [this GitHub
gist](https://gist.github.com/martijnvermaat/76f2e24d0239470dd71050358b4d5134).

We create a 1GiB EFI boot partition (`/dev/sda1`) and the rest will be our LUKS-encrypted volume:
```bash
# Create partition table
parted /dev/sda -- mklabel gpt

# Create /boot partition
parted /dev/sda -- mkpart ESP fat32 1MiB 1024MiB
parted /dev/sda -- set 1 esp on

# Create /nix partition
parted /dev/sda -- mkpart primary 1024MiB 100%

# Create and open LUKS-encrypted container
cryptsetup --type=luks2 luksFormat --label=crypted /dev/sda2
cryptsetup open /dev/sda2 crypted

# Create LVM volume group
pvcreate /dev/mapper/crypted
vgcreate vg /dev/mapper/crypted

# Create root logical volume
lvcreate -l 100%FREE vg -n root

# Format partitions
mkfs.fat -F32 -n BOOT /dev/sda1
mkfs.ext4 -L nix /dev/vg/root
```

The result should be the following (`lsblk -f`):
```text
NAME          FSTYPE      FSVER            LABEL
sda
├─sda1        vfat        FAT32            BOOT
└─sda2        crypto_LUKS 2                crypted
  └─crypted   LVM2_member LVM2 001
    └─vg-root ext4        1.0              nix
```

### Installation
Whereas the [NixOS manual](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual-installing) mounts
the newly-created `nixos` partition to `/mnt`, we will follow the _tmpfs as root_ blogpost and mount `/mnt` as `tmpfs`:
```bash
mount -t tmpfs none /mnt
mount --mkdir /dev/disk/by-label/BOOT /mnt/boot
mount --mkdir /dev/disk/by-label/nix /mnt/nix
mkdir -p /mnt/nix/persist/
```

The remaining installation can be done (more or less) according to the [NixOS
manual](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual-installing).
```bash
cd /mnt/nix
git clone https://git.caspervk.net/caspervk/nixos.git tmp
cd tmp/
nixos-generate-config --root /mnt --show-hardware-config
vim hosts/omega/hardware.nix
git add .  # nix sometimes ignores files outside version control
nixos-install --no-root-passwd --flake .#omega

# Make sure to set a password
mkpasswd > /mnt/nix/persist/passwordfile
chmod 400 /mnt/nix/persist/passwordfile
```


## Hardware Configuration
`hosts/*/hardware.nix`, while initially generated by `nixos-generate-config --show-hardware-config`, _is_ manually
modified.


## Impermanence
To find out which of our darlings will be erased on reboot do `tree -x /`.


## Upgrading
```bash
sudo nixos-rebuild switch --flake .#omega
```
