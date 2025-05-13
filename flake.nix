{
  description = "LMAO TOP TEXT";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/eaeed9530c76ce5f1d2d8232e08bec5e26f18ec1";
    nixos-wsl = {
      # Build a custom WSL installer
      url = "github:nix-community/NixOS-WSL/bc827c2924c46f2344d3168fd82c6711aaceb610"; # next commit broke mount root regex check
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-darwin.follows = "nix-darwin";
      };
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }@inputs:
    let
      overlays = [
        inputs.nur.overlays.default
        inputs.emacs-overlay.overlays.default
        inputs.rust-overlay.overlays.default
        inputs.neovim-nightly-overlay.overlays.default
        inputs.nixpkgs-firefox-darwin.overlay
        inputs.sops-nix.overlays.default
      ];
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
              inherit overlays system;
            };
          }
        );
      mkSystem = import ./lib/mksystem.nix { inherit overlays nixpkgs inputs; };
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              jujutsu
            ];
          };
        }
      );
      nixosConfigurations = {

        vm-aarch64 = mkSystem "vm-aarch64" {
          system = "aarch64-linux";
          user = "zhuher";
        };

        pc-amd64 = mkSystem "pc-amd64" {
          system = "x86_64-linux";
          user = "zhuher";
        };

        wsl = mkSystem "wsl" {
          system = "x86_64-linux";
          user = "zhuher";
          isWSL = true;
        };
      };

      darwinConfigurations.macbook-pro-m1 = mkSystem "macbook-pro-m1" {
        system = "aarch64-darwin";
        user = "zhuher";
        isDarwin = true;
      };

      templates = (
        builtins.mapAttrs (x: y: {
          description = "Nix flake-based ${x} development environment LMAO BOTTOM TEXT";
          path = ./shells + "/${x}";
        }) (builtins.readDir ./shells)
      );
    };
}
