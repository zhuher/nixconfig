{
  pkgs,
  currentSystemUser,
  ...
}: {
  # https://wiki.nixos.org/wiki/Prism_Launcher
  environment.systemPackages = with pkgs; [
    (prismlauncher.override {
      # Add binary required by some mod
      # additionalPrograms = [ffmpeg];
      jdks = [
        openjdk8
        openjdk11
        openjdk17
        openjdk21
        openjdk25
      ];
    })
  ];
  # https://wiki.nixos.org/wiki/GameMode
  programs.gamemode = {
    enable = true;
    settings.general.inhibit_screensaver = 0;
  };
  users.users.${currentSystemUser}.extraGroups = ["gamemode"];
  boot.kernelParams = ["transparent_hugepage=madvise"];
}
