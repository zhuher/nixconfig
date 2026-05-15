{
  lib,
  pkgs,
  isWSL,
  config,
  isDarwin,
  ...
}: let
  cfg = config.zhuk;
in {
  options.zhuk = with lib; {
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
  };
}
