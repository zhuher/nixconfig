{
  config,
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
    __spec = let
      specName = builtins.head (builtins.attrNames (config.specialisation or {none = 1;}));
    in
      mkOption {
        type = types.str;
        default = builtins.trace specName specName;
        description = ''The specialisation in use. For debugging only.'';
      };
  };
}
