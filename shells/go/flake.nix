{
  description = "A Nix-flake-based Go development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/eaeed9530c76ce5f1d2d8232e08bec5e26f18ec1";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f { pkgs = import nixpkgs { inherit system; }; });
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              go
              gopls
              # Add your development environment packages here
            ];
          };
        }
      );
    };
}
