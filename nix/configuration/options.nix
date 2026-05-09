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
        description = "Whether to use git secrets";
      };
    };
    jj = {
      secrets = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to use jj secrets";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.zhuk.mkJujutsu-wrapped false null cfg.nvim.package;
        description = "What jj package to use";
      };
    };
    lixVer = mkOption {
      type = types.enum [
        "git"
        "latest"
        "stable"
      ];
      default = "git";
      description = "What version of lix to use";
    };
    nvidia = mkOption {
      type = types.bool;
      default = !(isDarwin || isWSL);
      description = "Whether to set up the system to use an nvidia gpu";
    };
    _spec = mkOption {
      type = types.str;
      default = "Default";
      description = "Used specialisation";
    };
    nvim = {
      own = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to use my own nvim.lua";
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
        description = "Whether to enable emacs";
      };
    };
  };
}
