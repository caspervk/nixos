{ lib, pkgs, ... }: {
  networking = {
    firewall = {
      allowedTCPPorts = [ 1234 1337 8000 8080 ];
      allowedUDPPorts = [ 1234 1337 8000 8080 ];
    };
    nameservers = [ "127.0.0.53" ];  # resolved stub resolver
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";
    };
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
