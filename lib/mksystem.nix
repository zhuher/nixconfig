# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{
  nixpkgs,
  overlays,
  inputs,
}:

name:
{
  system,
  user,
  isDarwin ? false,
  isWSL ? false,
}:

let
  isLinux = !isDarwin && !isWSL;
  machine = ../machines/${name}.nix;
  userOS = ../users/${user}/${if isDarwin then "darwin" else "nixos"}.nix;
  userHome = ../users/${user}/home-manager.nix;
  i3 = ../users/${user}/i3.nix;
  headlessX = ../users/${user}/headless-x.nix;
  sway = ../users/${user}/sway.nix;

  systemFunc = if isDarwin then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager = inputs.home-manager."${if isDarwin then "darwin" else "nixos"}Modules";
in
systemFunc rec {
  inherit system;

  specialArgs = inputs;

  modules = [
    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    {
      nixpkgs = {
        overlays = overlays;
        flake = {
          setFlakeRegistry = true;
          setNixPath = true;
        };
      };
    }

    (if isDarwin then inputs.nix-homebrew.darwinModules.nix-homebrew else { })
    (
      if isDarwin then
        {
          nix-homebrew = {
            enable = true;
            user = "${user}";
            taps = {
              "homebrew/homebrew-core" = inputs.homebrew-core;
              "homebrew/homebrew-cask" = inputs.homebrew-cask;
              "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
            };
            mutableTaps = false;
            autoMigrate = true;
          };
        }
      else if isWSL then
        inputs.nixos-wsl.nixosModules.wsl
      else
        { }
    )
    inputs.sops-nix."${if isDarwin then "darwin" else "nixos"}Modules".sops
    (if isLinux then sway else { })
    machine
    userOS
    home-manager.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${user} = import userHome {
          inherit
            inputs
            isWSL
            isDarwin
            isLinux
            ;
        };
        sharedModules = [
          inputs.nix-index-database.hmModules.nix-index
          inputs.sops-nix.homeManagerModules.sops
        ];
      };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        isWSL = isWSL;
        inputs = inputs;
      };
    }
  ];
}
