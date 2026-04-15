{
  pkgs,
  config,
  ...
}: {
  nixpkgs.overlays = [
    (final: _prev: {
      inherit
        (final.lixPackageSets.git)
        nix-eval-jobs
        nix-fast-build
        nixpkgs-review
        # nil callPackage
        ;
      lpkgs =
        final.lixPackageSets.${config.zhuk.lixVer};
    })
  ];
  programs.direnv.nix-direnv.package = pkgs.lpkgs.nix-direnv;
  nix.package = pkgs.lpkgs.lix;
}
