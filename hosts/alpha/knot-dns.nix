{
  config,
  secrets,
  ...
}: {
  # Knot DNS is a high-performance authoritative-only DNS server which supports
  # all key features of the modern domain name system.
  # https://www.knot-dns.cz/
  # https://knot.readthedocs.io/en/master/
  services.knot = {
    enable = true;
    keyFiles = [
      config.age.secrets.acme-knot-key-file.path
    ];
    settings = {
      server = {
        listen = [
          "116.203.179.206@53"
          "2a01:4f8:c2c:71c0::@53"
        ];
      };
      policy = [
        {
          id = "default";
          # Disallow zone enumeration by using NSEC3 instead of NSEC
          # https://dnsinstitute.com/documentation/dnssec-guide/ch06s02.html
          nsec3 = "on";
        }
      ];
      acl = [
        {
          # Allow zone updates using the 'acme' TSIG key
          # https://knot.readthedocs.io/en/master/configuration.html#restricting-dynamic-updates
          id = "acme";
          key = "acme";
          action = "update";
          # Dynamic updates are restricted to TXT records matching the given
          # list of domain names. The list is considered relative to the zone
          # name unless it is a FQDN (i.e. ends in a dot).
          update-type = ["TXT"];
          update-owner = "name";
          update-owner-match = "equal";
          update-owner-name = [
            "_acme-challenge"
          ];
        }
      ];
      template = [
        {
          id = "default";
          # Enable extra zone semantic error checks
          semantic-checks = "on";
          # Enable ACME ACL on all zones
          acl = ["acme"];
          # Enable automatic DNSSEC signing on all zones. The KSK must be
          # configured in the parent zone through the registrar. Either the
          # DNSKEY or DS, depending on registrar:
          #
          # > sudo keymgr caspervk.net dnskey
          # [<zone> <record-type> <key-type> <protocol> <algorithm-type> <public-key>]
          #
          # OR
          #
          # > sudo keymgr caspervk.net ds
          # [<zone> <record-type> <key-tag> <algorithm-type> <digest-type> <digest>]
          #
          # https://knot.readthedocs.io/en/master/configuration.html#automatic-dnssec-signing
          #
          # DNSSEC can be validated using:
          #  - https://dnssec-debugger.verisignlabs.com
          #  - https://dnsviz.net
          dnssec-signing = "on";
          dnssec-policy = "default";
          # Knot overwrites the zonefiles with auto-generated DNSSEC records by
          # default. Configure it to never overwrite, and store changes in the
          # journal (database) instead. This also allows Knot to handle the SOA
          # serial for us automatically, so we no longer need to update it.
          # https://knot.readthedocs.io/en/master/operation.html#handling-zone-file-journal-changes-serials
          zonefile-sync = -1;
          zonefile-load = "difference-no-serial";
          journal-content = "all";
        }
      ];
      zone = [
        {
          domain = "caspervk.net";
          file = "${secrets}/hosts/alpha/knot/caspervk.net.zone";
        }
        {
          domain = "sortseer.dk";
          file = "${secrets}/hosts/alpha/knot/sortseer.dk.zone";
        }
        {
          domain = "spervk.com";
          file = "${secrets}/hosts/alpha/knot/spervk.com.zone";
        }
        {
          domain = "sudomail.org";
          file = "${secrets}/hosts/alpha/knot/sudomail.org.zone";
        }
        {
          domain = "vkristensen.dk";
          file = "${secrets}/hosts/alpha/knot/vkristensen.dk.zone";
        }
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [53];
    allowedUDPPorts = [53];
  };

  # Persist state
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/knot";
        user = "knot";
        group = "knot";
        mode = "0700";
      }
    ];
  };

  age.secrets.acme-knot-key-file = {
    file = "${secrets}/secrets/acme-knot-key-file.age";
    mode = "400";
    owner = "knot";
    group = "knot";
  };
}
