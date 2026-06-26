{
  pkgs,
  currentSystemUser,
  ...
}: {
  programs.steam = {
    enable = true;
    package = pkgs.jovian-chaotic.steam;
    extraCompatPackages = with pkgs; [
      proton-cachyos_x86_64_v3
    ];
  };

  programs.gamemode = {
    enable = true;
    settings.general.inhibit_screensaver = 0;
  };

  environment.systemPackages = with pkgs; [
    python315
    (heroic.override {
      extraPkgs = pkgs':
        with pkgs'; [
          gamemode
          proton-ge-custom
        ];
    })
  ];

  users.users.${currentSystemUser}.extraGroups = ["gamemode"];

  systemd.user.tmpfiles = {
    enable = true;
    rules = let
      steaminstalldir = "%h/.local/share/Steam";
      compatdir = "${steaminstalldir}/compatibilitytools.d";
      steamdir = "%h/.steam";
      heroictoolsdir = "%h/.local/share/Heroic/tools/proton";
    in [
      "d ${compatdir} - - - - -"
      "L+ ${compatdir}/Ge-Proton - - - - ${pkgs.proton-ge-custom.outPath}"
      "d ${steamdir} - - - - -"
      "L ${steamdir}/root - - - - ${steaminstalldir}"
      "L ${steamdir}/steam - - - - ${steaminstalldir}"
      "d ${heroictoolsdir} - - - - -"
      "L+ ${heroictoolsdir}/proton-ge-custom - - - - ${pkgs.proton-ge-custom.outPath}"
    ];
  };
}
