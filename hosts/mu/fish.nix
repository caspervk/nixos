{ home-manager, ... }: {
  home-manager.users.caspervk = {
    programs.fish.shellAliases = {
      sm = "gcloud --project magenta-os2mo-production compute ssh --tunnel-through-iap saltmaster";
    };
  };
}
