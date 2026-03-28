{pkgs, ...}: {
  nixpkgs.overlays = [
    (final: _prev: {
      # my-new-package = prev.my-new-package.override {
      #   nix = final.lixPackageSets.stable.lix;
      # }; # Adapt to your specific use case.
      inherit
        (final.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        ;
    })
  ];

  nix.package = pkgs.lixPackageSets.stable.lix;
}
