{
  lib,
  pkgs,
  config,
  currentSystemUser,
  ...
}: let
  env = config.environment.variables;
in {
  sops.defaultSopsFile = ../../secrets/gandalf.yaml;
  environment.systemPackages = with pkgs; [
    freenet
    zhuk.monero-cli
    zhuk.thorium-browser
    zhuk.tile-thumbnails
    qbittorrent
    prismlauncher
    appcleaner
  ];
  nix.settings = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  homebrew = {
    casks = [
      # gandalf-specific casks (common ones in os/darwin.nix)
      "ayugram"
    ];
    masApps = {
      # gandalf-specific apps (common ones in os/darwin.nix)
      "Pages" = 409201541;
      "Numbers" = 409203825;
    };
  };
  networking = {
    applicationFirewall.enableStealthMode = true;
    dns = [
      "9.9.9.11"
      "149.112.112.11"
      "2620:fe::11"
      "2620:fe::fe:11"
    ];
    knownNetworkServices = [
      "Thunderbolt Bridge"
      "Wi-Fi"
    ];
  };
  users.users.${currentSystemUser}.openssh = {
    authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQ9MGKngwot96l+oEd7B3IF8db64kwWTjx1R/85ORs6"
    ];
  };
  programs.zsh.interactiveShellInit = ''
    ${lib.optionalString config.zhuk.emacs.enable "alias -- emg='open -a EmacsClient'"}
    source ${config.sops.secrets.secret-script-1.path}
  '';
  launchd.user.agents.syncthing = {
    environment = {
      HOME = "${env.HOME}";
      STNORESTART = "1";
      STNOUPGRADE = "1";
    };
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      Label = "zhuk.net.syncthing";
      ProgramArguments = [
        "${lib.getExe pkgs.zhuk.syncthing}"
        "--no-browser"
      ];
      StandardOutPath = "${env.HOME}/Library/Logs/Syncthing.log";
      StandardErrorPath = "${env.HOME}/Library/Logs/Syncthing-Errors.log";
    };
  };
  sops.secrets = {
    copilot-hosts = {
      path = "/Users/zhuher/.config/github-copilot/hosts.json";
      mode = "0400";
      owner = currentSystemUser;
    };
    "ssh-keys/gh" = {
      path = "${env.HOME}/.ssh/gh.pub";
      mode = "0400";
      owner = currentSystemUser;
    };
    "ssh-keys/pers" = {
      path = "${env.HOME}/.ssh/pers.pub";
      mode = "0400";
      owner = currentSystemUser;
    };
    "ssh-keys/misc" = {
      path = "${env.HOME}/.ssh/misc.pub";
      mode = "0400";
      owner = currentSystemUser;
    };
    secret-script-1 = {
      mode = "0400";
      owner = currentSystemUser;
    };
    gitcreator = {
      mode = "0400";
      owner = currentSystemUser;
    };
  };
  local.dock.entries = [
    {path = "/Applications/Safari.app";}
    {path = "/Applications/Moonlight.app";}
    {path = "/Applications/AyuGram.app";}
    {path = "/Applications/Nix Apps/Ghostty.app";}
    {path = "/Applications/Mail.app";}
    {
      path = "/Applications";
      section = "others";
      options = "--sort name --view grid --display stack";
    }
    {
      path = "${env.HOME}/Downloads";
      section = "others";
      options = "--sort dateadded --view grid --display folder";
    }
  ];
}
