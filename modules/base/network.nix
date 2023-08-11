{ lib, pkgs, ... }: {
  networking = {
    firewall = {
      allowedTCPPorts = [ 1234 1337 8000 8080 ];
      allowedUDPPorts = [ 1234 1337 8000 8080 ];
    };
    nameservers = [ "127.0.0.53" ]; # resolved stub resolver
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";
    };
  };

  # TODO: these systemd networkd settings will be the default once
  # https://github.com/NixOS/nixpkgs/pull/202488 is merged.
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    fallbackDns = [ "159.69.4.2#dns.caspervk.net" "2a01:4f8:1c0c:70d1::1#dns.caspervk.net" ];
    extraConfig = ''
      DNS=159.69.4.2#dns.caspervk.net 2a01:4f8:1c0c:70d1::1#dns.caspervk.net
      DNSOverTLS=yes
    '';
  };

  services.vnstat.enable = true;
}
