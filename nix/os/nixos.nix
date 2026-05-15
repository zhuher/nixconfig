{
  currentSystemUser,
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmqp+RfNqw0LXFBRe0WNL+0+YzlMlfztMMzJmnGtMmw"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQ9MGKngwot96l+oEd7B3IF8db64kwWTjx1R/85ORs6"
  ];
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.nix-index-database.nixosModules.nix-index
    inputs.hjem.nixosModules.hjem
    # inputs.nvf.nixosModules.nvf
    # ../module/nvim.nix
    ../module/nvidia.nix
  ];
  programs.nh = {
    enable = true;
    package = pkgs.nh;
  };
  environment = {
    enableAllTerminfo = true;
    localBinInPath = true;
    variables = {
      XDG_RUNTIME_DUR = "/var/run/user/${builtins.toString config.users.users.${currentSystemUser}.uid}";
    };
  };
  documentation = {
    dev.enable = true;
    nixos.enable = true;
  };
  services = {
    openssh = {
      enable = true;
      ports = [23];
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
      openFirewall = true;
    };
  };
  networking.networkmanager.enable = true;
  users.users = {
    "${currentSystemUser}" = {
      uid = 1000;
      isNormalUser = true;
      home = "/home/${currentSystemUser}";
      extraGroups = [
        "wheel"
        "input"
        "video"
      ];
      initialHashedPassword = lib.mkDefault "$y$j9T$xye5QhLru1t0MXOaUZeFo.$lxYiEA6esvOlkuCM8TqS9RbTQChgGjD9eeeVXv4kZnD";
      openssh.authorizedKeys.keys = keys;
      linger = true; # run user's units independent of login
    };
    root = {
      extraGroups = [
      ];
      initialHashedPassword = lib.mkDefault "$y$j9T$acCG2bQZowJTAN5su9oOL1$0dJ4ZYLnYiKegKyGe9a9wNbICQUa3w3mQTWw2W4a9Q0";
      openssh.authorizedKeys.keys = keys;
    };
  };
  nix = {
    checkAllErrors = true;
    gc = {
      automatic = false;
      dates = "daily";
      persistent = true;
    };
    optimise = {
      persistent = true;
      dates = ["daily"];
    };
  };
  i18n = {
    defaultLocale = "C.UTF-8";
    extraLocaleSettings = {
      LC_ALL = "C.UTF-8";
    };
  };
  security.audit = {
    backlogLimit = 8192;
    enable = true;
  };
}
