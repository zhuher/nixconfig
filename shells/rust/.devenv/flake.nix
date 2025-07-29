{
  description = "A Nix-flake-based Rust development environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/76eec3925eb9bbe193934987d3285473dbcfad50";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {nixpkgs, ...} @ inputs: let
    overlays = with inputs; [
      rust-overlay.overlays.default
    ];
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (
        system:
          f rec {
            pkgs = import nixpkgs {inherit overlays system;};
            mkStableRust = branch:
            # stable, beta, nightly
            ver:
            # x.xx.x version string for stable, YYYY-MM-DD for beta/nightly(beta does not happen every day)
              pkgs.rust-bin.${branch}.${ver}.default.override {
                extensions = [
                  "cargo"
                  "clippy"
                  "rust"
                  "rust-analyzer"
                  "rust-docs"
                  "rust-src"
                  "rust-std"
                  "rustc"
                  "rustfmt"
                  #note: components available for aarch64-apple-darwin: cargo clippy clippy-preview llvm-tools llvm-tools-preview rls rls-preview rust rust-analysis rust-analyzer rust-analyzer-preview rust-docs rust-src rust-std rustc rustc-dev rustfmt rustfmt-preview
                ];
              };
          }
      );
  in {
    devShells = forEachSupportedSystem (
      {
        pkgs,
        mkStableRust,
      }: {
        default = pkgs.mkShellNoCC {
          shellHook = ''
            export CARGO_HOME="$(pwd)/.direnv/cago" # crico y estriper...
            export SHELL_PKGS_REV=76eec3925eb9bbe193934987d3285473dbcfad50
          '';
          packages = with pkgs; [
            git
            bacon
            (mkStableRust stable "1.92.0")
          ];
          RUST_BACKTRACE = 1;
        };
      }
    );
  };
}
