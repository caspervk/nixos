{ home-manager, pkgs, ... }: {
  # https://nixos.wiki/wiki/Virt-manager

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true; # virt-manager requires dconf to remember settings
  environment.systemPackages = with pkgs; [ virt-manager ];

  # Make virt-manager use QEMU/KVM by default
  home-manager.users.caspervk = {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };

  # Persist libvirt data
  environment.persistence."/nix/persist" = {
    directories = [
      { directory = "/var/lib/libvirt"; user = "root"; group = "root"; mode = "0755"; }
    ];
  };
}
