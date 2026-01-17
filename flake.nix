{
  description = "LMAO TOP TEXT";
  # inputs {{{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/76eec3925eb9bbe193934987d3285473dbcfad50";
    nixos-wsl = {
      # {{{
      # Build a custom WSL installer
      url = "github:nix-community/NixOS-WSL"; # "/bc827c2924c46f2344d3168fd82c6711aaceb610"; # next commit broke mount root regex check
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    sops-nix = {
      # {{{
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    home-manager = {
      # {{{
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    # darwinoids {{{
    nix-darwin = {
      # {{{
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle = {
      # {{{
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    }; # }}}
    homebrew-core = {
      # {{{
      url = "github:homebrew/homebrew-core";
      flake = false;
    }; # }}}
    homebrew-cask = {
      # {{{
      url = "github:homebrew/homebrew-cask";
      flake = false;
    }; # }}} # darwinoids }}}
    nfp = {
      # {{{
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nix-index-database = {
      # {{{
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    zig-overlay = {
      # {{{
      url = "github:bandithedoge/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    # lix = { # [ERROR]: *.lix.systems is somewhat unreachable in russia it seems...
    #   # {{{
    #   url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
    #   flake = false;
    # }; # }}}
    # lix-module = {
    #   # {{{
    #   url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.lix.follows = "lix";
    # }; # }}}
    gwfox = {
      # {{{
      url = "github:akkva/gwfox";
      flake = false;
    }; # }}}
    flake-path = {
      # {{{
      url = "file+file:///dev/null"; # needs to be overriden
      flake = false;
    }; # }}}
    xsb = {
      url = "github:zhuher/xStarbound/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  # inputs }}}
  outputs = {nixpkgs, ...} @ inputs: let
    overlays = [
      inputs.emacs-overlay.overlays.default
      inputs.neovim-nightly-overlay.overlays.default
      inputs.sops-nix.overlays.default
      inputs.zig-overlay.overlays.default
      # inputs.lix-module.overlays.default
      (import ./overlays.nix)
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
    # mkSystem {{{
    mkSystem = name: {
      system,
      user,
      isDarwin ? false,
      isWSL ? false,
    }: let
      systemFunc =
        if isDarwin
        then inputs.nix-darwin.lib.darwinSystem
        else nixpkgs.lib.nixosSystem;
    in
      systemFunc rec {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./configuration-shared.nix
          ./configuration-${
            if isDarwin
            then "darwin"
            else "nixos"
          }.nix
          ./machine-${name}.nix
          ./user-${user}.nix
          ./home-${name}.nix
          # sops-nix {{{
          inputs.sops-nix."${
            if isDarwin
            then "darwin"
            else "nixos"
          }Modules".sops
          # sops-nix }}}
          # home-manager {{{
          inputs.home-manager.darwinModules.home-manager
          ./home-shared.nix
          # home-manager }}}
          inputs.xsb.nixosModules.default
          # nix-index-database {{{
          inputs.nix-index-database."${
            if isDarwin
            then "darwin"
            else "nixos"
          }Modules".nix-index
          # nix-index-database }}}
          # module arguments {{{
          {
            config._module.args = {
              currentSystem = system;
              currentSystemUser = user;
              currentSystemName = name;
              inherit isWSL;
              inherit isDarwin;
              inherit inputs;
            };
          }
          # module arguments }}}
          # nixpkgs settings & overlays {{{
          (
            _: {
              nixpkgs = {
                config.allowUnfree = true;
                inherit overlays;
                flake.setFlakeRegistry = false; # set manually along with all other inputs
                flake.setNixPath = false; # ditto
              };
            }
          )
          # nixpkgs settings & overlays }}}
          # nixos-wsl {{{
          (
            if isWSL
            then inputs.nixos-wsl.nixosModules.wsl
            else {}
          )
          # nixos-wsl }}}
          # sops-nix {{{
          inputs.sops-nix."${
            if isDarwin
            then "darwin"
            else "nixos"
          }Modules".sops
          # sops-nix }}}
        ];
      };
    # mkSystem }}}
  in {
    # packages {{{
    packages =
      forEachSupportedSystem
      overlays (
        {pkgs, ...}: {
          nvim = pkgs.nvim-wrapped;
          tmux = pkgs.tmux-wrapped;
        }
      );
    # packages }}}
    # formatter {{{
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
    # formatter }}}
    # checks {{{
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
    # checks }}}
    nixosConfigurations = {
      wsl = mkSystem "wsl" {
        system = "x86_64-linux";
        user = "zhuher";
        isWSL = true;
      };
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
    templates = builtins.mapAttrs (name: _type: {
      path = ./shells/${name};
    }) (builtins.readDir ./shells);
  };
}
