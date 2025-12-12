{...}: {
  home-manager.users.caspervk = {
    programs.fish.shellAliases = {
      sm = "bw get totp e2be31fb-135f-4b28-88cd-b094000ddb67 | wl-copy; gcloud --project magenta-os2mo-production compute ssh --tunnel-through-iap saltmaster";
    };
  };
}
