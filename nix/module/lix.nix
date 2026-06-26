{
  pkgs,
  config,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      inherit
        (prev.lixPackageSets.${config.zhuk.lixVer})
        nix-eval-jobs
        nix-fast-build
        nixpkgs-review
        lix
        # nil
        # callPackage
        ;
      lpkgs =
        final.lixPackageSets.${config.zhuk.lixVer};
    })
  ];
  nix.package = pkgs.lix;
}
