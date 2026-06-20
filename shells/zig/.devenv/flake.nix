{
  description = "A Nix-flake-based Zig development environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/e75f25705c2934955ee5075e62530d74aca973c6";
    zig-overlay.url = "github:bandithedoge/zig-overlay/1653d9a6fb334b35085d3784264b3342e02fa5de";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {nixpkgs, ...} @ inputs: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (
        system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = with inputs; [
                zig-overlay.overlays.default
              ];
            };
          }
      );
  in {
    devShells = forEachSupportedSystem (
      {pkgs}: {
        default = pkgs.mkShellNoCC {
          shellHook = ''
            export ZIG_GLOBAL_CACHE_DIR="$(pwd)/.direnv/zig-cache"
            export ZIG_OVERLAY_REV=1653d9a6fb334b35085d3784264b3342e02fa5de
            export SHELL_PKGS_REV=e75f25705c2934955ee5075e62530d74aca973c6
          '';
          packages = let
            v = "master"; # 0_16_0 or master or mach_latest
          in
            with pkgs; [
              git
              zigpkgs.${v}."2026-06-12"
              zigpkgs.${v}."2026-06-12".zls
            ];
        };
      }
    );
  };
}
