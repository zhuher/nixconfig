{
  lib,
  pkgs,
  isWSL,
  config,
  isDarwin,
  configRoot,
  ...
}: let
  cfg = config.zhuk;
in {
  options.zhuk = with lib; {
    configRoot = mkOption {
      type = types.str;
      default = configRoot;
      description = "Absolute path to the live nixconfig checkout, falling back to the flake store path.";
    };
    git = {
      secrets = mkOption {
        type = types.bool;
        default = true;
      };
    };
    jj = {
      secrets = mkOption {
        type = types.bool;
        default = true;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.zhuk.mkJujutsu-wrapped false null cfg.nvim.package;
      };
    };
    lixVer = mkOption {
      type = types.enum [
        "git"
        "latest"
        "stable"
      ];
      default = "git";
    };
    nvidia = mkOption {
      type = types.bool;
      default = !(isDarwin || isWSL);
    };
    _spec = mkOption {
      type = types.str;
      default = "Default";
    };
    nvim = {
      own = mkOption {
        type = types.bool;
        default = true;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.zhuk.nvim-wrapped;
      };
    };
    emacs = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
    # wine = {
    #   wayland = mkOption {
    #     type = types.bool;
    #     default = false;
    #     description = "Use Wine Wow64 Wayland build instead of staging";
    #   };
    #   package = mkOption {
    #     type = types.package;
    #     default =
    #       if cfg.wine.wayland
    #       then pkgs.wineWow64Packages.waylandFull
    #       else pkgs.wineWow64Packages.stagingFull;
    #   };
    # };
  };
}
