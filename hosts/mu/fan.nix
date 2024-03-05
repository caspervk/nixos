{...}: {
  # Disable jet engine
  services.thinkfan = {
    enable = true;
    levels = [
      [0 0 70]
      [1 65 75]
      [2 70 80]
      [3 75 85]
      [6 80 90]
      [7 90 95]
      ["level auto" 95 32767]
    ];
  };
  boot.extraModprobeConfig = ''
    options thinkpad_acpi fan_control=1 experimental=1
  '';
}
