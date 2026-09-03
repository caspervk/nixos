{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  # https://wiki.nixos.org/wiki/Firefox
  # https://firefox-admin-docs.mozilla.org/reference/policies/
  # https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections
  programs.firefox = {
    enable = true;
    policies = {
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      # Firefox's captive portal feature tests whether your network connection
      # requires logging in, for example, on a public Wi-Fi hotspot, by
      # regularly connecting to https://detectportal.firefox.com/success.txt.
      CaptivePortal = false;
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      # The system resolver already uses encrypted DNS
      DNSOverHTTPS = {
        Enabled = false;
      };
      DontCheckDefaultBrowser = true;
      EnableTrackingProtection = {
        Category = "strict";
      };
      # Don't show bullshit on the new-tab page
      FirefoxHome = {
        Highlights = false;
        Search = false;
        SponsoredStories = false;
        SponsoredTopSites = false;
        Stories = false;
        Weather = false;
      };
      # Don't send what I'm typing in the address bar to Mozilla to show
      # sponsored suggestions.
      FirefoxSuggest = {
        WebSuggestions = false;
      };
      Homepage = {
        # Restore previous windows and tabs on startup
        StartPage = "previous-session";
      };
      HttpsOnlyMode = "enabled";
      OfferToSaveLogins = false;
      PictureInPicture = {
        Enabled = false;
      };
      # https://searchfox.org/firefox-main/source/modules/libpref/init/StaticPrefList.yaml
      Preferences = (
        builtins.mapAttrs (_: value: {
          Value = value;
          Status = "locked";
        })
        {
          # Don't tell Google about websites I visit or files I download
          "browser.safebrowsing.downloads.enabled" = false;
          "browser.safebrowsing.downloads.remote.enabled" = false;
          "browser.safebrowsing.malware.enabled" = false;
          "browser.safebrowsing.phishing.enabled" = false;
          # Don't tell Kagi about what I'm typing in the address bar unless I
          # explicitly opt-in using a search engine alias or ctrl-k.
          "browser.search.suggest.enabled" = true;
          "browser.urlbar.suggest.searches" = false;
          # Don't show the Firefox logo on the new-tab page
          "browser.newtabpage.activity-stream.hideLogo" = true;
          # Don't put ads for Firefox Relay in email fields
          "signon.firefoxRelay.feature" = "disabled";
          # Don't make Firefox a window manager
          "browser.tabs.splitView.enabled" = false;
          # Don't translate language I know
          "browser.translations.neverTranslateLanguages" = "da";
          # Tell websites not to sell or share information and opt-out of targeted
          # advertising.
          # https://support.mozilla.org/en-US/kb/global-privacy-control
          "privacy.globalprivacycontrol.enabled" = true;
        }
      );
      SanitizeOnShutdown = {
        Cache = true;
        Cookies = true;
        Exceptions = inputs.secrets.modules.firefox.SanitizeOnShutdown.Exceptions;
        Sessions = true;
      };
      SearchEngines = {
        Add = [
          {
            Name = "Kagi";
            URLTemplate = "https://kagi.com/search?q={searchTerms}";
            IconURL = "https://kagi.com/favicon.ico";
            Alias = "k";
            SuggestURLTemplate = "https://kagisuggest.com/api/autosuggest?q={searchTerms}";
          }
        ];
        Default = "Kagi";
        Remove = [
          "Bing"
          "DuckDuckGo"
          "Google"
          "Perplexity"
        ];
      };
      # Don't show recommendations for extensions and features based on the
      # kind of sites visited, suggestions in the address bar, and information
      # about Mozilla products in Settings.
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        FirefoxLabs = false;
        MoreFromMozilla = false;
        UrlbarInterventions = false;
      };
      ExtensionSettings = {
        # Block installation of all extensions not specified here
        "*" = {
          installation_mode = "blocked";
        };
        # British English Dictionary (Marco Pinto)
        "marcoagpinto@mail.telepac.pt" = {
          installation_mode = "normal_installed";
        };
        # Danish Dictionary for the Spell Checker
        "danish@dictionaries.addons.mozilla.org" = {
          installation_mode = "normal_installed";
        };
        # Buster: Captcha Solver for Humans
        "{e58d3966-3d76-4cd9-8552-1582fbc800c1}" = {
          installation_mode = "normal_installed";
          default_area = "menupanel";
        };
        # KeePassXC-Browser
        "keepassxc-browser@keepassxc.org" = {
          installation_mode = "normal_installed";
          default_area = "navbar";
        };
        # Reddit Enhancement Suite
        "jid1-xUfzOsOFlzSOXg@jetpack" = {
          installation_mode = "normal_installed";
          default_area = "menupanel";
        };
        # SponsorBlock for YouTube
        "sponsorBlocker@ajay.app" = {
          installation_mode = "normal_installed";
          default_area = "menupanel";
        };
        # Tor Snowflake
        "{b11bea1f-a888-4332-8d8a-cec2be7d24b9}" = {
          installation_mode = "normal_installed";
          default_area = "menupanel";
        };
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          installation_mode = "normal_installed";
          private_browsing = true;
          default_area = "navbar";
        };
        # Vimium
        #   Scroll step size: 120px
        #   Use smooth scrolling: false
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          installation_mode = "normal_installed";
          private_browsing = true;
          default_area = "menupanel";
        };
      };
    };
  };

  # Firefox doesn't merge policies - but will only load a single one - so as
  # soon as `programs.firefox.policies` (/etc/firefox/policies/policies.json)
  # is defined, it won't attempt to load extraPolicies
  # (lib/firefox/distribution/policies.json). We use bubblewrap to override the
  # /etc/firefox/policies/ directory with an empty tmpfs.
  # https://wiki.archlinux.org/title/Bubblewrap#No-op
  # https://github.com/NixOS/nixpkgs/blob/nixos-26.05/pkgs/applications/networking/browsers/firefox/wrapper.nix
  environment.systemPackages = [
    (
      let
        firefox = pkgs.wrapFirefox pkgs.firefox-unwrapped {
          extraPolicies = lib.recursiveUpdate config.programs.firefox.policies {
            SanitizeOnShutdown = {
              Exceptions =
                config.programs.firefox.policies.SanitizeOnShutdown.Exceptions
                ++ [
                  "https://google.com"
                ];
            };
          };
        };
      in
        pkgs.writeShellScriptBin "firefox-magenta" ''
          exec ${pkgs.bubblewrap}/bin/bwrap \
            --dev-bind / / \
            --tmpfs /etc/firefox/policies/ \
            ${firefox}/bin/firefox -P magenta "$@"
        ''
    )
  ];
}
