{...}: {
  programs.firefox = {
    policies = {
      SanitizeOnShutdown = {
        Exceptions = [
          "https://google.com"
        ];
      };
    };
  };
}
