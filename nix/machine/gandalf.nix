{
  lib,
  pkgs,
  config,
  currentSystemUser,
  ...
}: let
  env = config.environment.variables;
in {
  homebrew = {
    brews = [
      "virtualenv"
    ];
    casks = [
      "moonlight"
      # "parsec" # VPN
      # "tor-browser" VPN
    ];
    masApps = {
      # "GarageBand" = 682658836;
      # "Warframe" = 1520001008; # only mobile devices (why???)
      "Pages" = 409201541;
      "Numbers" = 409203825;
      # "DaisyDisk" = 411643860; # using a version from their website as it's more powerful
      # "Customize Search Engine" = 6445840140; # [TODO]: Return to this maybe
      "Telegram" = 747648890;
      # "Xcode" = 497799835;
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
  users.users.${currentSystemUser}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQ9MGKngwot96l+oEd7B3IF8db64kwWTjx1R/85ORs6"
  ];
  programs.zsh.interactiveShellInit = ''
    alias -- emg='open -a EmacsClient'
    source ${config.sops.secrets.secret-script-1.path}
  '';
  sops = let
    sopsFile = ../../secrets/gandalf.yaml;
  in {
    secrets = {
      ssh-hosts = {
        inherit sopsFile;
        mode = "0400";
        path = "${env.HOME}/.ssh/hosts";
        owner = currentSystemUser;
      };
      copilot-hosts = {
        path = "/Users/zhuher/.config/github-copilot/hosts.json";
        inherit sopsFile;
        mode = "0400";
        owner = currentSystemUser;
      };
      "ssh-keys/work" = {
        inherit sopsFile;
        mode = "0400";
        owner = currentSystemUser;
      };
      "ssh-keys/gh" = {
        inherit sopsFile;
        path = "${env.HOME}/.ssh/gh.pub";
        mode = "0400";
        owner = currentSystemUser;
      };
      "ssh-keys/pers" = {
        inherit sopsFile;
        path = "${env.HOME}/.ssh/pers.pub";
        mode = "0400";
        owner = currentSystemUser;
      };
      "ssh-keys/misc" = {
        inherit sopsFile;
        path = "${env.HOME}/.ssh/misc.pub";
        mode = "0400";
        owner = currentSystemUser;
      };
      secret-script-1 = {
        inherit sopsFile;
        mode = "0400";
        owner = currentSystemUser;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    zls
    zig
    nodejs-slim
    gh
    ffmpeg
    # cataclysm-dda-git
    crawl
    zhuk.monero-cli
    zhuk.thorium-browser
    zhuk.tile-thumbnails
    zhuk.alex313031-codium
    qbittorrent
    zhuk.emacsen.darwin
    rtorrent
    prismlauncher
    iina
    libjxl
    ice-bar # [ERROR] Crashes when using the floating ice bar.
    appcleaner
  ];
  local.dock.entries = [
    {path = "/Applications/Safari.app";}
    {path = "/Applications/Moonlight.app";}
    {path = "/Applications/Telegram.app";}
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
  launchd.user.agents.zhukmacs.serviceConfig = let
    zsh = lib.getExe pkgs.zsh;
    emacs = lib.getExe' pkgs.zhuk.emacsen.darwin "emacs";
  in {
    AbandonProcessGroup = true;
    Disabled = false;
    KeepAlive = true;
    Label = "zhuk.gnu.emacs.daemon";
    ProcessType = "Interactive";
    RunAtLoad = true;
    StandardOutPath = "${env.HOME}/Library/Logs/Zhukmacs.log";
    StandardErrorPath = "${env.HOME}/Library/Logs/Zhukmacs-Errors.log";
    ProgramArguments = [
      "${zsh}"
      "-ilc"
      "${emacs} --fg-daemon"
    ];
  };
}
