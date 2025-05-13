{ pkgs, currentSystemUser, ... }:
{
  imports = [ ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = currentSystemUser;
    startMenuLaunchers = true;
    wslConf.interop.appendWindowsPath = true;
    wslConf.network.generateHosts = true;
    wslConf.user.default = currentSystemUser;
  };

  nix = {
    package = pkgs.lix;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };
  environment.enableAllTerminfo = true;
  services.openssh.ports = [ 2022 ];

  networking.hostName = "nix-wsl";

  system.stateVersion = "25.05";
  systemd.user.services."bg3check" = {
    enable = true;
    script = ''
      set -eu
      ${pkgs.zsh}/bin/zsh "/home/${currentSystemUser}/nixconfig/baldcron-wsl.sh"
    '';
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ProtectSystem = "full";
      ProtectHostname = "true";
      ProtectKernelTunables = "true";
      RestrictRealtime = "true";
      Type = "oneshot";
    };
    startAt = "*:0/30";
  };
}
