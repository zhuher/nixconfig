{
  description = "A Nix-flake-based C & Zig development environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/eaeed9530c76ce5f1d2d8232e08bec5e26f18ec1";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zls-overlay = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zig-overlay.follows = "zig-overlay";
    };
  };
  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                inputs.zig-overlay.overlays.default
                (final: prev: {
                  zls = inputs.zls-overlay.packages.${system}.default;
                })
              ];
            };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              zigpkgs."master"
              zls
              subunit
              lldb_19
              lcov
              check
            ];
          };
        }
      );
    };
}
