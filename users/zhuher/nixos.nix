{
  # config,
  # lib,
  pkgs,
  ...
}:

let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmqp+RfNqw0LXFBRe0WNL+0+YzlMlfztMMzJmnGtMmw"
  ];
in
{
  environment = {
    localBinInPath = true;
    # systemPackages = with pkgs; [
    #   jujutsu
    #   zsh
    #   helix
    #   rsync
    #   lsd
    #   bat
    #   fd
    #   ripgrep
    # ];
  };
  documentation = {
    enable = true;
    doc.enable = true;
    info.enable = true;
    man.enable = true;
    dev.enable = true;
    nixos.enable = true;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
      };
      openFirewall = true;
    };
  };
  programs = {
    zsh.enable = true;
  };
  time = {
    timeZone = "Europe/Moscow";
  };
  users.users = {
    zhuher = {
      uid = 1000;
      isNormalUser = true;
      home = "/home/zhuher";
      extraGroups = [
        "input"
        "uinput"
        "wheel"
      ];
      shell = pkgs.zsh;
      initialHashedPassword = "$y$j9T$JkisRw2mJYAZo.1x69hqT/$iYOHZbyjknZCJ1MJqtbd2K5Id1xG5l1ZiQ06evYJCr.";
      openssh.authorizedKeys.keys = keys;
      linger = true;
    };
    root = {
      extraGroups = [
        "uinput"
        "input"
      ];
      initialHashedPassword = "$y$j9T$JkisRw2mJYAZo.1x69hqT/$iYOHZbyjknZCJ1MJqtbd2K5Id1xG5l1ZiQ06evYJCr.";
      openssh.authorizedKeys.keys = keys;
    };
  };
  nix = {
    checkAllErrors = true;
    checkConfig = true;
    enable = true;
    gc = {
      automatic = true;
      dates = "weekly";
      persistent = true;
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      persistent = true;
      dates = [ "weekly" ];
    };
    settings = {
      auto-optimise-store = true;
      cores = 0;
      sandbox = true;
      extra-substituters = [
        "https://cache.garnix.io"
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org"
        "https://cache.lix.systems"
      ];
      extra-trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      ];

    };
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };
  i18n = {
    defaultLocale = "C.UTF-8";
    extraLocaleSettings = {
      LC_COLLATE = "C.UTF-8";
      LC_CTYPE = "C.UTF-8";
      LC_MESSAGES = "C.UTF-8";
      LC_MONETARY = "C.UTF-8";
      LC_NUMERIC = "C.UTF-8";
      LC_TIME = "C.UTF-8";
    };
  };
  security.audit.enable = true;
  nixpkgs = {
    overlays = import ../../lib/overlays.nix;
    config.allowUnfree = true;
  };
  # ++ [ (import ./vim.nix { inherit inputs; }) ]
}
