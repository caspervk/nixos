{ config, ... }: {
  # https://nixos.wiki/wiki/Syncthing

  services.syncthing = {
    enable = true;
    user = "caspervk";
    group = "users";
    dataDir = "/home/caspervk";
    devices = {
      "lambda" = {
        id = "WES3JH4-S34HTC5-42YZHUJ-MX3Z6PA-PFO72KA-YIJMDOB-GQWZXZ3-I7BBTAS";
        addresses = [ "tcp://lambda.caspervk.net" ];
      };
      "omega" = { id = "EZIQ7SI-Y6BBLUY-QI4EEYU-UNIXPSG-R6X5E77-AA2UC7S-VRV2LKQ-RNBOGQT"; };
      "S10e" = { id = "DWC6YHB-FRYKFHD-FPOUITV-7GL2WZH-RSFOJXR-PHYXDO7-74NLBUZ-TZENVAC"; };
      "zeta" = { id = "GQRNHAQ-MMRQYMD-P4RCA6I-5DJ3HXO-J2N2GVP-UGI55YR-HD3EYSO-ERU5QQV"; };
    };
    folders = {
      "keepass" = {
        path = "~/keepass";
        devices = [ "lambda" "omega" "S10e" "zeta" ];
      };
      "sync" = {
        path = "~/sync";
        devices = [ "lambda" "omega" "zeta" ];
      };
    };
  };
}
