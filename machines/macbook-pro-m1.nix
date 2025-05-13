{
  pkgs,
  currentSystemUser,
  config,
  lib,
  ...
}:
{
  # nix.useDaemon = true;
  # Auto upgrade nix package and the daemon service.
  nixpkgs.config.allowUnfree = true;
  fonts = {
    packages =
      with pkgs.nerd-fonts;
      [
        fantasque-sans-mono
        fira-code
        fira-mono
        hack
        im-writing
        jetbrains-mono
        liberation
        meslo-lg
        monaspace
        symbols-only
      ]
      ++ (with pkgs; [ maple-mono.variable ]);
  };

  nix = {
    enable = true; # let nix-darwin manage system nix
    package = pkgs.lix; # use lix instead of nixCpp
    checkConfig = true;
    gc = {
      options = "--delete-older-than 30d";
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 23;
        Minute = 0;
      };
    };
    optimise = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 23;
        Minute = 0;
      };
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
      allowed-impure-host-deps = /bin/sh /usr/lib/libSystem.B.dylib /usr/lib/system/libunc.dylib /dev/zero /dev/random /dev/urandom
      !include ${config.sops.secrets.access-tokens.path}
    '';
    settings = {
      # auto-optimise-store = true; #3549532663732bfd8999 3204d40543e9edaec4f2: `nix.settings.auto-optimise-store` is known to corrupt the Nix Store, please use `nix.optimise.automatic` instead.
      cores = 0;
      sandbox = true; # "relaxed";
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

      trusted-users = [
        "@admin"
        "${currentSystemUser}"
      ];

    };
    channel.enable = false;
  };
  programs = {

    # zsh is the default shell on Mac and we want to make sure that we're
    # configuring the rc correctly with nix-darwin paths.
    zsh.enable = true;

    nix-index.enable = true;
    # fish.enable = true;
  };

  environment = {
    shells = with pkgs; [
      zsh
      # fish
    ];
    systemPackages = [
      pkgs.cachix
      # emacmacs
    ];
    variables = {
      ZHUK_LATEST_NIXPKGS_HASH = "eaeed9530c76ce5f1d2d8232e08bec5e26f18ec1";
    };
  };
  documentation = {
    enable = true;
    doc.enable = true;
    info.enable = true;
    man.enable = true;
  };
  security.pam.services.sudo_local.touchIdAuth = true;
  # launchd.user.agents.emacs.serviceConfig = {# {{{
  #   Label = "gnu.emacs.daemon";
  #   KeepAlive = true;
  #   ProgramArguments = [
  #     "/bin/zsh"
  #     "-ilc"
  #     "emacs --fg-daemon"
  #   ];
  #   RunAtLoad = true;
  #   ProcessType = "Interactive";
  #   StandardErrorPath = "/tmp/emacs.err.log";
  #   StandardOutPath = "/tmp/emacs.out.log";
  # };# }}}
  networking = {
    search = [
      "adblock.dns.mullvad.net"
    ];
    computerName = "🐗Zhukbook🐔";
    dns = [
      "9.9.9.11"
      "149.112.112.11"
      "2620:fe::11"
      "2620:fe::fe:11"
    ];
    hostName = "Zhukbook";
    knownNetworkServices = [
      "Thunderbolt Bridge"
      "Wi-Fi"
    ];
    localHostName = "Zhukbook";
  };
  sops = {
    defaultSopsFile = ../users/${currentSystemUser}/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [
      ~/.ssh/age
    ];
    secrets.lmao.owner = currentSystemUser;
    secrets.copilot-hosts = {
      path = "/Users/${currentSystemUser}/.config/github-copilot/hosts.json";
      owner = currentSystemUser;
      mode = "0400";
    };
    secrets.wg-large-eagle = {
      path = "/etc/wireguard/large-eagle.conf";
      mode = "0400";
    };
    secrets.contact-info.mode = "0400";
    secrets.ssh-hosts = {
      mode = "0600";
      path = "/Users/${currentSystemUser}/.ssh/hosts";
      owner = currentSystemUser;
    };
    secrets.access-tokens = {
      mode = "0440";
      group = config.users.groups.keys.name;
    };
  };
  # names of scripts that would be run can be found at https://github.com/nix-darwin/nix-darwin/blob/eaff8219d629bb86e71e3274e1b7915014e7fb22/modules/system/activation-scripts.nix#L148-L155
  system.activationScripts.postActivation.text = ''
    # sops-nix links secrets at activation, so reading from them is to be done post-activation
       echo >&2 -e "\033[35mSetting LoginwindowText...\033[0m"
       defaults write /Library/Preferences/com.apple.loginwindow.plist LoginwindowText -string "$(cat ${config.sops.secrets.contact-info.path})"
       echo >&2 -e "\033[32mSetting LoginwindowText...done\033[0m"
  '';
}
