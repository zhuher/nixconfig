{
  description = "A Nix-flake-based Go development environment";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/76eec3925eb9bbe193934987d3285473dbcfad50";
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
            export SHELL_PKGS_REV=76eec3925eb9bbe193934987d3285473dbcfad50
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
