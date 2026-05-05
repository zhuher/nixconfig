{
  lib,
  pkgs,
  config,
  isDarwin,
  isWSL,
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
        #[TODO]
        type = types.bool;
        default = true;
        description = "Whether to use my own nvim.lua";
      };
      package = mkOption {
        type = types.package;
        default =
          if cfg.nvim.own
          then pkgs.zhuk.nvim-wrapped
          else config.programs.nvf.settings.vim.build.finalPackage;
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
