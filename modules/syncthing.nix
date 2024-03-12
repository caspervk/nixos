{...}: {
  # Syncthing is a continuous file synchronization program. It synchronizes
  # files between two or more computers in real time. It's basically a
  # self-hosted Dropbox for Linux users, but without FTP, curlftpfs, and SVN.
  # https://nixos.wiki/wiki/Syncthing

  services.syncthing = {
    enable = true;
    user = "caspervk";
    group = "users";
    # The directory where synchronised directories will exist
    dataDir = "/home/caspervk";
    settings = {
      # Devices ignore their own IDs, allowing for a single configuration.
      # TODO: Syncthing generates a private key and ID the first time it is
      # started. On first install, add the devices' ID here and apply to the
      # other ones. When we get a proper secret management scheme, such as
      # agenix, the private keys should be managed declaratively as well.
      devices = {
        "android" = {id = "IBP6YKY-KGWYPCH-J3CHAQ5-GKCIQ3U-X2L7S7V-BH635EE-ZEDQHN2-ZB4CBAP";};
        "lambda" = {
          id = "WES3JH4-S34HTC5-42YZHUJ-MX3Z6PA-PFO72KA-YIJMDOB-GQWZXZ3-I7BBTAS";
          addresses = ["tcp://lambda.caspervk.net"];
        };
        "omega" = {id = "EZIQ7SI-Y6BBLUY-QI4EEYU-UNIXPSG-R6X5E77-AA2UC7S-VRV2LKQ-RNBOGQT";};
        "zeta" = {id = "GQRNHAQ-MMRQYMD-P4RCA6I-5DJ3HXO-J2N2GVP-UGI55YR-HD3EYSO-ERU5QQV";};
      };
      folders = {
        "keepass" = {
          path = "~/keepass";
          devices = ["android" "lambda" "omega" "zeta"];
        };
        "sync" = {
          path = "~/sync";
          devices = ["lambda" "omega" "zeta"];
        };
      };
    };
  };
}
