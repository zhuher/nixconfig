{
  lib,
  pkgs,
  config,
  currentSystemUser,
  ...
}: let
  env = config.environment.variables;
in {
  nix.settings.sandbox = "relaxed";
  services.openssh.enable = false;
  environment = {
    shellAliases = {
      cnr = "cargo nextest run";
    };
    variables = {
      RUSTC_WRAPPER = "${lib.getExe pkgs.sccache}";
      SCCACHE_DIR = "${config.users.users."${currentSystemUser}".home}/.cache/sccache";
      SCCACHE_CACHE_SIZE = "100G";
    };
    systemPackages = with pkgs; [
      (writeZig zig "hello-zig" ''
        const std = @import("std");
        pub fn main() void {
          std.debug.print("hello from a nix package!", .{});
        }
      '' "-O ReleaseSafe")
      sccache
      # zhuk.emacs # FIXME cannot read a hardcoded rgb.txt from build directory
      jujutsu-wrapped
    ];
  };
  homebrew = {
    casks = ["dbeaver-community"];
  };
  programs = {
    xstarbound.enable = lib.mkForce false;
    zsh.interactiveShellInit = ''
      ulimit -n 65535
    '';
  };
  security.pki = {
    installCACerts = true;
    certificates = [
      (
        builtins.readFile "${builtins.trace env.HOME env.HOME}/ca_cert.pem" # https://tbawor.sh/posts/nix-on-macos/#step-1-export-trusted-certificates-from-macos-keychain
      )
    ];
    certificateFiles = [
      "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      # "${builtins.trace env.HOME env.HOME}/ca_cert.pem"
    ];
  };
  system.defaults.dock.orientation = lib.mkForce "left";
  local.dock.entries = [
    {path = "/Applications/Mail.app";}
    {path = "/Applications/Calendar.app";}
    {path = "/Applications/Orion.app";}
    {path = "${pkgs.zhuk.ghostty}/Applications/Ghostty.app";}
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
    "ssh-keys/work" = {
      inherit sopsFile;
      mode = "0400";
      path = "${env.HOME}/.ssh/work.pub";
      owner = currentSystemUser;
    };
    ssh-hosts = {
      mode = "0400";
      path = "${env.HOME}/.ssh/hosts";
      owner = currentSystemUser;
      inherit sopsFile;
    };
  };
}
