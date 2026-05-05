{
  description = "LMAO TOP TEXT";
  inputs = {
    apollo = {
      url = "github:zhuher/le-apollo-flake-fork";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "flake-path";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/e75f25705c2934955ee5075e62530d74aca973c6";
    nixos-wsl = {
      # Build a custom WSL installer
      url = "github:nix-community/NixOS-WSL"; # "/bc827c2924c46f2344d3168fd82c6711aaceb610"; # next commit broke mount root regex check
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "nvf/flake-compat";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nix-darwin.follows = "nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
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
    homebrew-iss-tap = {
      url = "github:jurplel/homebrew-tap";
      flake = false;
    };
    nfp = {
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "nvf/flake-parts";
    };
    # zig-overlay = {
    #   url = "github:bandithedoge/zig-overlay";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    gwfox = {
      url = "github:akkva/gwfox";
      flake = false;
    };
    flake-path = {
      url = "file+file:///dev/null"; # needs to be overriden
      flake = false;
    };
    xsb = {
      url = "github:zhuher/xStarbound/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {nixpkgs, ...} @ inputs: let
    overlays = [
      (final: _prev: {
        zen-browser = inputs.zen-browser.packages.${final.stdenv.hostPlatform.system}.twilight-unwrapped;
      })
      inputs.apollo.overlays.default
      inputs.emacs-overlay.overlays.default
      inputs.neovim-nightly-overlay.overlays.default
      inputs.sops-nix.overlays.default
      # inputs.zig-overlay.overlays.default
      (import ./nix/overlays.nix)
    ];
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    forEachSupportedSystem = overlays: f:
      nixpkgs.lib.genAttrs supportedSystems (
        system:
          f {
            pkgs = import nixpkgs {
              inherit overlays system;
            };
            inherit system;
          }
      );
    mkSystem = name: {
      system,
      user,
      isDarwin ? false,
      isWSL ? false,
    }: let
      opt = nixpkgs.lib.optional;
      systemFunc =
        if isDarwin
        then inputs.nix-darwin.lib.darwinSystem
        else nixpkgs.lib.nixosSystem;
    in
      systemFunc rec {
        inherit system;
        specialArgs = {inherit inputs isDarwin;};
        modules =
          [
            ./nix/configuration/shared.nix
            ./nix/machine/${name}.nix
            ./nix/home/shared.nix
            ./nix/home/${name}.nix
            inputs.xsb.nixosModules.default
            {
              config._module.args = {
                currentSystem = system;
                currentSystemUser = user;
                currentSystemName = name;
                inherit isWSL;
                inherit inputs;
              };
            }
            {
              nixpkgs = {
                config.allowUnfree = true;
                inherit overlays;
                flake.setFlakeRegistry = false; # set manually along with all other inputs
                flake.setNixPath = false; # ditto
              };
            }
          ]
          ++ opt isWSL inputs.nixos-wsl.nixosModules.wsl;
      };
  in {
    packages =
      forEachSupportedSystem
      overlays (
        {pkgs, ...}: {
          nvim = pkgs.zhuk.nvim-wrapped;
          tmux = pkgs.zhuk.tmux-wrapped;
        }
      );
    formatter = forEachSupportedSystem [] (
      {system, ...}:
        inputs.nfp.lib.mkFormatter {
          inherit system;
          inherit (inputs) nixpkgs;
          config = {
            tools = {
              deadnix.enable = true;
              alejandra.enable = true;
              statix.enable = true;
            };
          };
        }
    );
    checks = forEachSupportedSystem [] (
      {system, ...}: {
        nfp = inputs.nfp.lib.mkCheck {
          inherit system;
          inherit (inputs) nixpkgs;
          config = {
            tools = {
              deadnix.enable = true;
              alejandra.enable = true;
              statix.enable = true;
            };
          };
          checkFiles = ["./."];
        };
      }
    );
    nixosConfigurations = {
      celebrimbor = mkSystem "celebrimbor" {
        system = "x86_64-linux";
        user = "zhuher";
      };
      # wsl = mkSystem "wsl" {
      #   system = "x86_64-linux";
      #   user = "zhuher";
      #   isWSL = true;
      # };
    };
    darwinConfigurations = {
      macbook-KY7WHGYV1Y = mkSystem "macbook-KY7WHGYV1Y" {
        system = "aarch64-darwin";
        user = "ge.zhukov";
        isDarwin = true;
      };
      gandalf = mkSystem "gandalf" {
        system = "aarch64-darwin";
        user = "zhuher";
        isDarwin = true;
      };
    };
    # templates = builtins.mapAttrs (name: _type: {
    #   path = ./shells/${name};
    # }) (builtins.readDir ./shells);
  };
}
