{
  pkgs,
  config,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      inherit
        (final.lpkgs)
        nix-eval-jobs
        nix-fast-build
        nixpkgs-review
        # nil
        # callPackage
        ;
      lix = final.lpkgs.lix.overrideAttrs (old: {
        patches =
          old.patches
          ++ [];
      });
      lpkgs =
        prev.lixPackageSets.${config.zhuk.lixVer};
    })
  ];
  nix.package = pkgs.lix;
}
