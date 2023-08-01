{ pkgs, ... }: {
  networking = {
    firewall = {
      allowedTCPPorts = [ 1234 1337 8000 8080 ];
      allowedUDPPorts = [ 1234 1337 8000 8080 ];
    };
    nameservers = [ "159.69.4.2#dns.caspervk.net" ];
    networkmanager = {
      enable = true;
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    fallbackDns = [ "159.69.4.2#dns.caspervk.net" ];
    extraConfig = ''
      DNSOverTLS=yes
    '';
  };

  services.vnstat.enable = true;
}
