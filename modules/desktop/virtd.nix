{ home-manager, pkgs, ... }: {
  # https://nixos.wiki/wiki/Virt-manager

  virtualisation.libvirtd.enable = true;
  environment.systemPackages = with pkgs; [ virt-manager ];

  # Virt-manager requires dconf to remember settings
  programs.dconf.enable = true;

  # Make virt-manager use QEMU/KVM by default
  home-manager.users.caspervk = {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };

  # Allow our user to use libvird
  users.extraGroups.libvirtd.members = [ "caspervk" ];

  # Persist libvirt data
  environment.persistence."/nix/persist" = {
    directories = [
      { directory = "/var/lib/libvirt"; user = "root"; group = "root"; mode = "0755"; }
    ];
  };
}
