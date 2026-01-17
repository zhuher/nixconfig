{
  currentSystemUser,
  pkgs,
  ...
}: let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmqp+RfNqw0LXFBRe0WNL+0+YzlMlfztMMzJmnGtMmw"
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
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
      };
      openFirewall = true;
    };
  };
  users.users = {
    "${currentSystemUser}" = {
      uid = 1000;
      isNormalUser = true;
      home = "/home/${currentSystemUser}";
      extraGroups = [
        "wheel"
      ];
      initialHashedPassword = "$6$rounds=6901337$dkuHV9Y6YarEavnp$nfsXc1d3F5T/RbzUPtHSvYKw8NSr1lQpLVyxfx6PgCgdlbSEvpPy9D4utNZ6Khf1VU8b0UrpdqM4sBECJsU8q1";
      openssh.authorizedKeys.keys = keys;
      linger = true; # run user's units independent of login
    };
    root = {
      extraGroups = [
      ];
      initialHashedPassword = "$6$rounds=6901337$YAbU3RUwNYFvWBXh$vqAhp0Y8Heiuwwdf0EbYMa.l61WwhNveASUIPf2KBwE8/k/PSUGxxMM9Xd7kYDkM/m0446w8Cts8iN0Kst81D0";
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
