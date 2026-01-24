{
  lib,
  pkgs,
  config,
  currentSystemUser,
  ...
}: let
  env = config.environment.variables;
in {
  environment.systemPackages = with pkgs; [
    # dbeaver-bin
  ];
  homebrew = {
    casks = ["dbeaver-community"];
  };
  programs.xstarbound.enable = lib.mkForce false;
  security.pki.certificateFiles = [
    ./ca_cert.pem # https://tbawor.sh/posts/nix-on-macos/#step-1-export-trusted-certificates-from-macos-keychain
  ];
  system.defaults.dock.orientation = lib.mkForce "left";
  local.dock.entries = [
    {path = "/Applications/Mail.app";}
    {path = "/Applications/Calendar.app";}
    {path = "/Applications/Orion.app";}
    {path = "/Applications/Nix Apps/Ghostty.app";}
    {path = "/Applications/Толк.app";}
    {path = "/Applications/Time.app";}
    # {path = "/Applications/Microsoft Outlook.app";}
    {path = "/Applications/Cisco/Cisco Secure Client.app";}
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

  sops.secrets = let
    sopsFile = ../../secrets/ws.yaml;
  in {
    jjsecrets.sopsFile = sopsFile;
    gitsecrets.sopsFile = sopsFile;
    ssh-hosts = {
      mode = "0400";
      path = "${env.HOME}/.ssh/hosts";
      owner = currentSystemUser;
      inherit sopsFile;
    };
  };
}
