{
  description = "A Nix-flake-based Go development environment";
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
          shellHook = ''
            export GOPATH="$(pwd)/.direnv/gopath"
            export SHELL_PKGS_REV=9cf7092bdd603554bd8b63c216e8943cf9b12512
          '';
          packages = with pkgs; [
            git
            go
            gopls
            # Add your development environment packages here
          ];
        };
      }
    );
  };
}
