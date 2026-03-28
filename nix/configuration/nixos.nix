{
  currentSystemUser,
  pkgs,
  ...
}: let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmqp+RfNqw0LXFBRe0WNL+0+YzlMlfztMMzJmnGtMmw"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQ9MGKngwot96l+oEd7B3IF8db64kwWTjx1R/85ORs6"
  ];
in {
  programs.nh = {
    enable = true;
    package = pkgs.nh;
  };
  environment = {
    localBinInPath = true;
  };
  documentation = {
    dev.enable = true;
    nixos.enable = true;
  };
  services = {
    openssh = {
      enable = true;
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
      ];
      initialHashedPassword = "$y$j9T$xye5QhLru1t0MXOaUZeFo.$lxYiEA6esvOlkuCM8TqS9RbTQChgGjD9eeeVXv4kZnD";
      openssh.authorizedKeys.keys = keys;
      linger = true; # run user's units independent of login
    };
    root = {
      extraGroups = [
      ];
      initialHashedPassword = "$y$j9T$acCG2bQZowJTAN5su9oOL1$0dJ4ZYLnYiKegKyGe9a9wNbICQUa3w3mQTWw2W4a9Q0";
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
  security.audit.enable = true;
}
