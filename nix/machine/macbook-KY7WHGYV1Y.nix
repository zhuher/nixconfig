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
    systemPackages = with pkgs; let
      # jujutsu-wrapped {{{
      jujutsu-wrapped = let
        # config {{{
        jjconf = (formats.toml {}).generate "jj.toml" {
          colors."commit_id prefix".bold = true;
          revsets.log = ''@ | ancestors(immutable_heads()..) | trunk()'';
          template-aliases = {
            "format_short_id(id)" = "id.shortest()";
            "format_timestamp(timestamp)" = ''timestamp ++ "(" ++ timestamp.ago() ++ ")"'';
          };
          ui = {
            default_command = ["log" "--no-pager" "--limit=6"];
            diff-editor = ["${lib.getExe' pkgs.nvim-wrapped "nvim"}" "-c" "DiffEditor $left $right $output"];
            pager = "${lib.getExe delta}";
            diff-formatter = ":git";
          };
          templates = {
            log_node = ''
              coalesce(
                if(!self, "🮀"),
                if(current_working_copy, "@"),
                if(root, "┴"),
                if(immutable, "●", "○"),
              )'';
          };
          op_log_node = ''if(current_operation, "@", "○")'';
          snapshot.max-new-file-size = 16777216;
          aliases = {
            my-inline-script = [
              "util"
              "exec"
              "--"
              "bash"
              "-c"
              ''
                #!/usr/bin/env bash
                set -euo pipefail
                echo "Look Ma, everything in one file!"
                echo "args: $@"
              ''
              ""
            ];
            yolo = [
              "util"
              "exec"
              "--"
              "bash"
              "-c"
              ''
                jj desc -m "$(curl -s "https://whatthecommit.com/index.txt")"
              ''
              ""
            ];
            pull-subs = [
              "util"
              "exec"
              "--"
              "bash"
              "-c"
              ''
                git submodule update --init
              ''
              ""
            ];
          };
        };
        # config }}}
      in
        symlinkJoin {
          name = "jujutsu-wrapped";
          paths = [jujutsu];
          nativeBuildInputs = [makeBinaryWrapper];
          buildInputs = [delta pkgs.nvim-wrapped];
          postBuild = ''
            wrapProgram $out/bin/jj \
            --set JJ_CONFIG "${"${jjconf}:${config.sops.secrets.jjsecrets.path}"}"
          '';
        };
      # jujutsu-wrapped }}}
    in [
      (writeZig zig "hello-zig" ''
        const std = @import("std");
        pub fn main() void {
          std.debug.print("hello from a nix package!", .{});
        }
      '' "-O ReleaseSafe")
      sccache
      zhuk.emacs # FIXME cannot read a hardcoded rgb.txt from build directory
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
