{
  config,
  secrets,
  ...
}: {
  # Mumble is a free, open source, low latency, high quality voice chat
  # application.
  # https://www.mumble.info/
  # https://www.mumble.info/blog/ (changelog)
  services.murmur = {
    enable = true;
    openFirewall = true;
    # https://wiki.mumble.info/wiki/Murmur.ini
    welcometext = "<b>Welcome!</b> Feel free to use <i>Temporary Channels</i> to create a password-protected channel.";
    users = 9001;
    bandwidth = 320000;
    # Explicitly bind on addresses to ensure UDP doesn't break with multiple
    # interfaces.
    hostName = "116.203.179.206 2a01:4f8:c2c:71c0::";
    # https://wiki.mumble.info/wiki/Obtaining_a_Let's_Encrypt_Murmur_Certificate
    sslCert = "${config.security.acme.certs."caspervk.net".directory}/fullchain.pem";
    sslKey = "${config.security.acme.certs."caspervk.net".directory}/key.pem";
    # Register server in the public server registry
    registerName = "Caspervk's Public Mumble";
    registerPassword = "$REGISTER_PASSWORD";
    registerUrl = "https://mumble.caspervk.net";
    registerHostname = "mumble.caspervk.net";
    extraConfig =
      # ini
      ''
        # Connect clients to the lobby instead of the root channel the first time
        # they connect.
        defaultchannel=1
      '';
    environmentFile = config.age.secrets.mumble-environment-file.path;
  };

  # Persist database
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/murmur";
        user = "murmur";
        group = "murmur";
        mode = "0700";
      }
    ];
  };

  age.secrets.mumble-environment-file = {
    file = "${secrets}/secrets/mumble-environment-file.age";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
