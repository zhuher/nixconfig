{
  lib,
  pkgs,
  config,
  currentSystemUser,
  ...
}: {
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
  sops = {
    secrets = {
      ssh-hosts = {
        sopsFile = ./gandalf.yaml;
        mode = "0400";
        path = "/Users/${currentSystemUser}/.ssh/hosts";
        owner = currentSystemUser;
      };
      copilot-hosts = {
        path = "/Users/zhuher/.config/github-copilot/hosts.json";
        sopsFile = ./gandalf.yaml;
        mode = "0400";
        owner = currentSystemUser;
      };
      ssh-keys-work = {
        sopsFile = ./gandalf.yaml;
        mode = "0400";
        owner = currentSystemUser;
      };
      ssh-keys-gh = {
        sopsFile = ./gandalf.yaml;
        path = "/Users/${currentSystemUser}/.ssh/gh.pub";
        mode = "0400";
        owner = currentSystemUser;
      };
      ssh-keys-pers = {
        sopsFile = ./gandalf.yaml;
        path = "/Users/${currentSystemUser}/.ssh/pers.pub";
        mode = "0400";
        owner = currentSystemUser;
      };
      ssh-keys-misc = {
        sopsFile = ./gandalf.yaml;
        path = "/Users/${currentSystemUser}/.ssh/misc.pub";
        mode = "0400";
        owner = currentSystemUser;
      };
      secret-script-1 = {
        sopsFile = ./gandalf.yaml;
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
    StandardOutPath = "/Users/${currentSystemUser}/Library/Logs/Zhukmacs.log";
    StandardErrorPath = "/Users/${currentSystemUser}/Library/Logs/Zhukmacs-Errors.log";
    ProgramArguments = [
      "${zsh}"
      "-ilc"
      "${emacs} --fg-daemon"
    ];
  };
}
