{
  lib,
  isDarwin,
  isWSL,
  ...
}: {
  options.zhuk = with lib; {
    git = {
      secrets = mkOption {
        type = types.bool;
        default = true;
        description = ''Whether to use git secrets'';
      };
    };
    jj = {
      secrets = mkOption {
        type = types.bool;
        default = true;
        description = ''Whether to use jj secrets'';
      };
    };
    lixVer = mkOption {
      type = types.enum ["git" "latest" "stable"];
      default = "git";
      description = ''What version of lix to use'';
    };
    nvidia = mkOption {
      type = types.bool;
      default = !(isDarwin || isWSL);
      description = ''Whether to set up the system to use an nvidia gpu'';
    };
    _spec = mkOption {
      type = types.str;
      default = "Default";
      description = ''Used specialisation'';
    };
  };
}
