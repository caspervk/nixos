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
  # https://wiki.nixos.org/wiki/Imapsync

  # INCOMING mail is delegated to mail.caspervk.net by each domain, e.g.
  # vkristensen.dk.
  #
  # vkristensen.dk.zone:
  #
  # @                         IN  MX    10 mail.caspervk.net.
  #
  # For anti-spam purposes, mail.caspervk.net MUST be an A/AAAA record (not
  # CNAME) and the IP-addresses MUST point back to mail.caspervk.net using a
  # reverse pointer record:
  #
  # caspervk.net.zone:
  #
  # mail                      IN  A     49.13.33.75
  # 75.33.13.49.in-addr.arpa. IN  PTR   mail.caspervk.net.

  # OUTGOING mail is sent through icloud because email is a racket where the
  # big providers only accept mail from the other big providers. Perfect
  # SPF/DKIM? Well fuck you. If you're lucky we'll send you to spam, otherwise
  # it's straight to /dev/null. What happened to the decentralised internet!?
  # At least give me a chance until you've actually seen me send spam??
  # https://www.icloud.com/icloudplus/customdomain
  #
  # Anyway.. Each domain delegates SPF and DMARC to mail.caspervk.net so we
  # only have to define the policies once, and adds icloud's dkim key:
  #
  # vkristensen.dk.zone:
  #
  # @                         IN  TXT   "v=spf1 redirect=mail.caspervk.net"
  # _dmarc                    IN  CNAME _dmarc.mail.caspervk.net.
  # sig1._domainkey           IN  CNAME sig1.dkim.caspervk.net.at.icloudmailadmin.com.
  #
  # The SPF and DMARC policies are defined centrally.
  #
  # caspervk.net.zone:
  #
  #  mail                     IN  TXT   "v=spf1 ..."
  # _dmarc.mail               IN  TXT   "v=DMARC1; ..."

  # Online verification tools:
  # https://dmarcchecker.app
  # https://www.mail-tester.com/
  # https://mxtoolbox.com/deliverability

  # Client Setup
  # Account: casper@vkristensen.dk
  # IMAP: mail.caspervk.net:993 (SSL/TLS)
  # SMTP: mail.caspervk.net:465 (SSL/TLS) TODO!

  mailserver = {
    enable = true;
    # Firewall is handled manually in networking.nix
    openFirewall = false;
    # Don't run a local DNS resolver
    localDnsResolver = false;
    # The fully qualified domain name of the mail server. Used for TLS and must
    # have a matching reverse-DNS record.
    fqdn = "mail.caspervk.net";
    # TLS Certificate
    # https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/merge_requests/303
    certificateScheme = "manual";
    certificateFile = "${config.security.acme.certs."caspervk.net".directory}/fullchain.pem";
    keyFile = "${config.security.acme.certs."caspervk.net".directory}/key.pem";
    # Use more than 2048-bit DKIM keys
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
        aliases = secrets.hosts.sigma.mail.aliases;
      };
    };
    # https://nixos-mailserver.readthedocs.io/en/latest/migrations.html
    stateVersion = 3;
  };

  # Only allow mail delivery through wg-sigma-public. Note that this does not
  # tell it to use the correct routing table. For proper internet access, the
  # correct routing table is also configured by routingPolicyRules in
  # networking.nix. lan0 is additionally allowed to enable mail submission from
  # lan hosts.
  systemd.services.postfix = {
    serviceConfig = {
      RestrictNetworkInterfaces = "lo lan0 wg-sigma-public";
    };
  };

  # Disable rspamd filtering
  # https://nixos-mailserver.readthedocs.io/en/latest/rspamd-tuning.html
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
