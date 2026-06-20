# Dock configuration module for nix-darwin
# Original source: https://gist.github.com/antifuchs/10138c4d838a63c0a05e725ccd7bccdd
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.local.dock;
  inherit (pkgs) stdenv;
  zsh = getExe pkgs.zsh;
  dockutil = getExe pkgs.dockutil;
in {
  options = {
    local.dock.enable = mkOption {
      description = "Enable dock configuration";
      default = stdenv.isDarwin;
      example = false;
    };
    local.dock.entries = mkOption {
      description = "Entries on the Dock";
      type = with types;
        listOf (submodule {
          options = {
            path = mkOption {
              type = str;
              description = "Path to the application or folder";
            };
            section = mkOption {
              type = str;
              default = "apps";
              description = "Dock section (apps, others, recently_added)";
            };
            options = mkOption {
              type = str;
              default = "";
              description = "Additional dockutil options";
            };
          };
        });
      default = [];
    };
    local.dock.username = mkOption {
      description = "Username to apply the dock settings to";
      default = config.system.primaryUser;
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    let
      normalize = path:
        if hasSuffix ".app" path
        then path + "/"
        else path;

      entryURI = path:
        "file://"
        + (
          builtins.replaceStrings
          [
            " "
            "!"
            "\""
            "#"
            "$"
            "%"
            "&"
            "'"
            "("
            ")"
          ]
          [
            "%20"
            "%21"
            "%22"
            "%23"
            "%24"
            "%25"
            "%26"
            "%27"
            "%28"
            "%29"
          ]
          (normalize path)
        );

      wantURIs = concatMapStrings (entry: "${entryURI entry.path}\n") cfg.entries;

      createEntries =
        concatMapStrings (
          entry: "${dockutil} --no-restart --add '${entry.path}' --section ${entry.section} ${entry.options}\n"
        )
        cfg.entries;

      subody = pkgs.writeText "dock.zsh" ''
        haveURIs="$(${dockutil} --list | ${getExe' pkgs.coreutils "cut"} -f2)"
        if ! diff -wu <(echo -n "$haveURIs") <(echo -n '${wantURIs}') >&2 ; then
          echo >&2 -e "\033[33mResetting Dock.\033[0m"
          ${dockutil} --no-restart --remove all
          ${createEntries}
          killall Dock
        fi
        echo >&2 -e "\033[32mDock setup complete.\033[0m"
      '';
    in {
      system.activationScripts.postActivation.text = ''
        echo >&2 -e "\033[34mSetting up the Dock for ${cfg.username}...\033[0m"
        su ${cfg.username} -c '${zsh} ${subody}'
      '';
    }
  );
}
