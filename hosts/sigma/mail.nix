{
  config,
  secrets,
  simple-nixos-mailserver,
  ...
}: {
  imports = [
    simple-nixos-mailserver.nixosModule
  ];

  # Simple NixOS Mailserver.
  # https://nixos-mailserver.readthedocs.io
  # https://nixos.wiki/wiki/Imapsync
  #
  # DNS
  # Each domain delegates mail-handling to mail.caspervk.net using an MX
  # record. mail.caspervk.net MUST be an A/AAAA record *NOT* CNAME. For spam
  # purposes, the IP-addresses pointed to by mail.caspervk.net MUST point back
  # to mail.caspervk.net using reverse-DNS.
  # > dig mail.caspervk.net
  # > dig -x 1.2.3.4
  # Mail to e.g. vkristensen.dk should be delegated to mail.caspervk.net. Each
  # domain's DKIM key in /var/dkim/ MUST be added to its DNS zone.
  # > dig MX vkristensen.dk
  # > dig TXT vkristensen.dk
  # > dig TXT mail._domainkey.vkristensen.dk
  # > dig TXT _dmarc.vkristensen.dk
  #
  # Online verification tools:
  # https://www.mail-tester.com/
  # https://mxtoolbox.com/deliverability
  #
  # Client Setup
  # Account: casper@vkristensen.dk
  # IMAP: mail.caspervk.net:993 (SSL/TLS)
  # SMTP: mail.caspervk.net:465 (SSL/TLS)
  mailserver = {
    enable = true;
    # Firewall is handled manually in networking.nix
    openFirewall = false;
    # Don't run a local DNS resolver
    localDnsResolver = false;
    # Disable opportunistic TLS encryption and force instead. This only applies
    # to client connections from e.g. Thunderbird or K9. Submission from other
    # mailservers is always opportunistic TLS as per RFC.
    # https://docker-mailserver.github.io/docker-mailserver/latest/config/security/understanding-the-ports/
    enableImap = false;
    enableSubmission = false;
    # The fully qualified domain name of the mail server. Used for TLS and must
    # have a matching reverse-DNS record.
    fqdn = "mail.caspervk.net";
    # TLS Certificate
    # https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/merge_requests/303
    certificateScheme = "manual";
    certificateFile = "${config.security.acme.certs."caspervk.net".directory}/fullchain.pem";
    keyFile = "${config.security.acme.certs."caspervk.net".directory}/key.pem";
    # Use more than 1024-bit DKIM keys
    dkimKeyBits = 4096;
    # Rewrite the MessageID's hostname-part of outgoing emails to the
    # mailserver's FQDN. Avoids leaking local hostnames.
    rewriteMessageId = true;
    # The hierarchy separator for mailboxes used by dovecot for the namespace
    # 'inbox'. Dovecot defaults to "." but recommends "/".
    hierarchySeparator = "/";
    # The domains that this mail server serves
    domains = [
      "caspervk.net"
      "spervk.com"
      "sudomail.org"
      "vkristensen.dk"
    ];
    # The login account. All mail is delivered to the same account to ease
    # client configuration, but it is allowed to send mail as any of the
    # configured aliases. To generate a password use 'mkpasswd -sm bcrypt'.
    loginAccounts = {
      "casper@vkristensen.dk" = {
        hashedPasswordFile = config.age.secrets.mail-hashed-password-file.path;
        aliases = secrets.sigma.mail.aliases;
      };
    };
  };

  # Only allow mail delivery through through wg-sigma-public. Note that this
  # does not tell it to use the correct routing table. For proper internet
  # access, the correct routing table is also configured by
  # routingPolicyRuleConfig in networking.nix.
  systemd.services.postfix = {
    serviceConfig = {
      RestrictNetworkInterfaces = "lo wg-sigma-public";
    };
  };

  # Disable rspamd filtering[1]. The rspamd service cannot be disabled
  # completely due to [2].
  # [1]: https://nixos-mailserver.readthedocs.io/en/latest/rspamd-tuning.html
  # [2]: https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/merge_requests/249
  services.rspamd.extraConfig = ''
    actions {
      reject = null;
      add_header = null;
      greylist = null;
    }
  '';

  environment.persistence."/nix/persist" = {
    directories = [
      # The generated DKIM keys are manually added to each domain's DNS zone
      # and therefore need to be persisted.
      {
        directory = "/var/dkim";
        user = "opendkim";
        group = "opendkim";
        mode = "0755";
      }
      {
        directory = "/var/vmail";
        user = "virtualMail";
        group = "virtualMail";
        mode = "2770";
      }
    ];
  };

  age.secrets.mail-hashed-password-file = {
    file = "${secrets}/secrets/mail-hashed-password-file.age";
    mode = "400";
    owner = "root";
    group = "root";
  };
}
