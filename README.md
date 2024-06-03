# nixos

## Installation
Follow the [NixOS
manual](https://nixos.org/manual/nixos/stable/index.html#ch-installation) to
obtain and boot the installation medium. Use the graphical ISO image since it
ships with useful programs such as `nmtui`; the installation can still be done
through the terminal.

### Disk Partitioning
For [impermanence](https://nixos.wiki/wiki/Impermanence), partitioning should
be done as outlined in the [tmpfs as
root](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/) blogpost, but with
`/nix` as a [LUKS-encrypted file
system](https://nixos.org/manual/nixos/stable/index.html#sec-luks-file-systems).
The boot partition will not be encrypted, since that is poorly supported by
systemd-boot. Persistent files will be saved under `/nix/persist`. To find out
which of our darlings will be erased on reboot do `tree -x /` or `ncdu -x /`.

The following is based on the [tmpfs as
root](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/) blogpost, the NixOS
manual's
[partitioning](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual-partitioning),
[formatting](https://nixos.orgmanual/nixos/stable/index.html#sec-installation-manual-partitioning-formatting)
and [LUKS-Encrypted File
Systems](https://nixos.org/manual/nixos/stable/index.html#sec-luks-file-systems)
sections, ArchWiki's [LVM on
LUKS](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS),
the unofficial NixOS wiki [Full Disk
Encryption](https://nixos.wiki/wiki/Full_Disk_Encryption), and [this GitHub
gist](https://gist.github.com/martijnvermaat/76f2e24d0239470dd71050358b4d5134).

We create a 1GiB EFI boot partition (`/dev/sda1`) and the rest will be our
LUKS-encrypted volume:
```fish
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

Whereas the [NixOS
manual](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual-installing)
mounts the newly-created `nixos` partition to `/mnt`, we will follow the _tmpfs
as root_ blogpost and mount `/mnt` as `tmpfs`:
```fish
mount -t tmpfs none /mnt
mount --mkdir /dev/disk/by-label/BOOT /mnt/boot
mount --mkdir /dev/disk/by-label/nix /mnt/nix
mkdir -p /mnt/nix/persist/
```

### Secrets
All files in the Nix store are world-readable, so it is not a suitable place
for including cleartext secrets, even if we had a scheme to securely transfer
them to each system. [Agenix](https://github.com/ryantm/agenix) solves this
issue by encrypting the secrets using
[age](https://github.com/FiloSottile/age), and then decrypting and symlinking
them using the system's SSH host key during system activation.

All secrets, and other private configuration such as DNS zonefiles, are stored
in a separate, private [repo](https://git.caspervk.net/caspervk/nixos-secrets).
To bootstrap a new system, we must generate a host key manually during
installation:
```fish
mkdir -p /mnt/nix/persist/etc/ssh/
ssh-keygen -A -f /mnt/nix/persist
nc alpha.caspervk.net 1337 < /mnt/nix/persist/etc/ssh/ssh_host_ed25519.pub
```
Then, on an existing system, add the new host's public key to `secrets.nix` in
the `nixos-secrets` repo and **rekey** all secrets. When managing secrets, the
Keepass recovery key is used like so:
```fish
set AGE_KEY_FILE (mktemp); read -s > $AGE_KEY_FILE
agenix -i $AGE_KEY_FILE --rekey
agenix -i $AGE_KEY_FILE -e foo.age
```

The new system needs to be able to pull the `nixos-secrets` repo temporarily
during installation:
```fish
ssh-keygen -t ed25519
nc alpha.caspervk.net 1337 < /root/.ssh/id_ed25519.pub
# https://git.caspervk.net/caspervk/nixos-secrets/settings/keys
```
After bootstrapping, servers will auto-upgrade using the shared `autoUpgrade`
SSH key. Desktops will need to add `~caspervk/.ssh/id_ed25519.pub` either as a
deploy key for the `nixos-secrets` repo, or to the entire git user.

### Installation
The remaining installation can be done (more or less) according to the [NixOS
manual](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual-installing).
```fish
cd /mnt/nix
git clone https://git.caspervk.net/caspervk/nixos.git
cd nixos/
nixos-generate-config --root /mnt --show-hardware-config
vim hosts/omega/hardware.nix
git add .  # nix sometimes ignores files outside version control
nixos-install --no-root-passwd --flake .#omega
```

### Hardware Configuration
`hosts/*/hardware.nix`, while initially generated by `nixos-generate-config
--show-hardware-config`, _is_ manually modified.

### Upgrading
Nixpkgs uses `stateVersion` so sparingly that auditing the entire nixpkgs repo
is [easy
enough](https://sourcegraph.com/search?q=context:global+repo:%5Egithub%5C.com/NixOS/nixpkgs%24+lang:Nix+stateVersion+AND+24.05&patternType=keyword&sm=0).
Important changes to home-manager is available at
<https://nix-community.github.io/home-manager/release-notes.xhtml> and
<https://github.com/nix-community/home-manager/blob/master/modules/misc/news.nix>.


## Useful Commands
```fish
# development
sudo nixos-rebuild switch --flake . --override-input secrets ./../nixos-secrets/

# start build environment with user's default shell instead of bash
nix develop --command $SHELL

# nix shell with python packages
# https://discourse.nixos.org/t/nix-shell-for-python-packages/16575
# https://github.com/NixOS/nix/issues/5567
nix shell --impure --expr 'with builtins.getFlake "nixpkgs"; with legacyPackages.${builtins.currentSystem}; python3.withPackages (ps: with ps; [ numpy ])'
```

### Debugging
```nix
# load flake into repl
nix repl . --override-input secrets ./../nixos-secrets/

# print a configuration option
:p nixosConfigurations.omega.options.services.openssh.ports.declarationPositions  # declaration
:p nixosConfigurations.omega.options.services.openssh.ports.default  # declaration default
:p nixosConfigurations.omega.options.services.openssh.ports.definitionsWithLocations  # overwrites
:p nixosConfigurations.omega.options.services.openssh.ports.value  # current value
# print derivation package names
:p builtins.map (d: d.name) outputs.nixosConfigurations.omega.options.environment.systemPackages.value

# print version of package in nixpkgs
:p inputs.nixpkgs.outputs.legacyPackages.${builtins.currentSystem}.openssh.version
```


## References
  - https://github.com/nix-community/srvos/tree/29a48ae201fbd69b6b71acdae5e19fa2ceaa8181
