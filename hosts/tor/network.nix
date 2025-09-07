{lib, ...}: {
  networking = {
    # Use dns.caspervk.net IPv6 address ::2 for uncensored DNS
    nameservers = lib.mkForce [
      "2a01:4f8:1c0c:70d1::2#dns.caspervk.net"
    ];
  };

  # The NixOS firewall enables stateful connection tracking by default, which
  # can be bad for performance.
  # https://github.com/NixOS/nixpkgs/blob/2e88dbad29664f78b4c7f89f9b54d2dd2faef8e6/nixos/modules/services/networking/firewall-iptables.nix#L139
  networking.firewall.enable = false;

  systemd.network = {
    networks."10-lan" = {
      matchConfig.Name = "ens18";
      address = [
        "31.133.0.235/24"
        "2001:67c:2044:c141::1:6431:1/64"
      ];
      routes = [
        {Gateway = "31.133.0.1";}
        {Gateway = "2001:67c:2044:c141::1";}
      ];
    };
  };
}
