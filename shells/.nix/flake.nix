{
  description = "We do da config flake with this one";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/9cf7092bdd603554bd8b63c216e8943cf9b12512";
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
              overlays = with inputs; [];
            };
          }
      );
  in {
    devShells = forEachSupportedSystem (
      {pkgs}: {
        default = pkgs.mkShellNoCC {
          # shellHook = ''
          # NIX_CONFIG="extra-experimental-features='nix-command flakes'"
          # '';
          packages = with pkgs; [
            just
            nh
            jq
            git
            gnused
            # Add your development environment packages here
          ];
        };
      }
    );
  };
}
