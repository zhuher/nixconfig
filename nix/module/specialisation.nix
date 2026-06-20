{
  lib,
  config,
  ...
}: {
  specialisation = let
    specList = builtins.attrNames config.specialisation;
    mkDefaultEntry = c: let
      specName = c.zhuk._spec;
      withDefault = ["Default"] ++ specList;
      specIdx = lib.lists.findFirstIndex (name: name == specName) 0 withDefault;
    in "default_entry: ${builtins.toString (specIdx + 3)}";
    mkSpec = name: extraAttrs: i:
      {
        zhuk._spec = name;
        environment.etc."specialisation".text = i.config.zhuk._spec; # for nh
        boot.loader.limine.extraConfig = mkDefaultEntry i.config;
      }
      // extraAttrs;
  in {
    sway.configuration = mkSpec "sway" {
      imports = [./sway.nix];
    };
  };
}
