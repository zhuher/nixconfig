{
  pkgs,
  lib,
  config,
  currentSystemUser,
  currentSystemName,
  isDarwin,
  inputs,
  ...
}: let
  env = config.environment.variables;
  shells = with pkgs; [nushell zsh fish];
  specMsg = "Evaluating specialisation: ${config.zhuk._spec}";
  reportSpec = builtins.trace specMsg;
in {
  imports = [
    ./${
      if isDarwin
      then "darwin"
      else "nixos"
    }.nix
    ../module/options.nix
    ../module/lix.nix
    ../module/zen-browser.nix
    ../module/zsh.nix
  ];
  nixpkgs.overlays = [
    (final: _prev: {}) # le exampleaux
  ];
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  programs.xstarbound = {
    enable = lib.mkDefault true;
    localMods = {
      enable = false;
      dir = "${env.HOME}/Library/Application Support/Steam/steamapps/workshop/content/211820/";
    };
    bootconfig.settings = {
      assetDirectories = [
        "${env.HOME}/Library/Application Support/Steam/steamapps/common/Starbound/assets/"
      ];
      storageDirectory = "${env.XDG_DATA_HOME}/xStarbound";
    };
  };
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      settings = {
        global = {
          warn_timeout = "30s";
        };
        whitelist = {
          # exact = ["${env.HOME}/.envrc"]; # don't really use it
        };
      };
    };
  };
  documentation.enable = true;
  documentation.doc.enable = true;
  documentation.info.enable = true;
  documentation.man.enable = true;
  time.timeZone = "Europe/Moscow";
  nix = {
    gc = {
      automatic = lib.mkDefault true;
    };
    optimise = {
      automatic = lib.mkDefault true;
    };
    registry = pkgs.lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = pkgs.lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    enable = true;
    package = lib.mkDefault pkgs.lix;
    checkConfig = true;
    settings = {
      auto-optimise-store = false;
      cores = 0;
      sandbox = lib.mkDefault true; # [INFO]: "relaxed" or bool;
      extra-trusted-public-keys = [
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
      ];
      trusted-users = [
        "@admin"
        "${currentSystemUser}"
      ];
      extra-experimental-features = ["nix-command" "flakes"];
      keep-outputs = true;
      keep-derivations = true;
    };
    channel.enable = false;
  };
  fonts = {
    packages = with pkgs.nerd-fonts;
      [
        fantasque-sans-mono
        # fira-code
        # fira-mono
        hack
        im-writing
        # jetbrains-mono
        # liberation
        meslo-lg
        # monaspace
        symbols-only
      ]
      ++ [pkgs.maple-mono.variable];
  };
  networking.hostName = reportSpec currentSystemName;

  users.users."${currentSystemUser}".shell = pkgs.zsh;
  environment = let
    inherit (lib) getExe' getExe;
  in {
    inherit shells;
    systemPackages = with pkgs;
      [
        television

        zig
        zls

        sops
        ssh-to-age
        age
        zhuk.gnupg-wrapped
        keepassxc

        zhuk.bat-wrapped
        zoxide
        coreutils
        delta
        ripgrep
        lstr
        eza
        fd
        jq
        wget
        rsync
        just
        zhuk.tmux-wrapped

        git
        config.zhuk.jj.package

        nh
        lpkgs.nil
        nix-tree

        config.zhuk.nvim.package

        grc
        carapace
        # (amneziawg-tools.overrideAttrs (prev: {
        #   postFixup =
        #     prev.postFixup
        #     + ''
        #       sed -i 's/\bwg\b/awg/g;s#/wireguard#/amneziawg#g' $out/bin/.awg-quick-wrapped
        #     '';
        # }))

        forgejo-cli
      ]
      ++ shells;
    pathsToLink = ["/share/zsh"];
    shellAliases =
      {
        l = "${getExe pkgs.eza} --all --oneline --classify=auto --colour=auto --icons=auto --hyperlink";
        ls = "${getExe pkgs.eza} --all --bytes --smart-group --modified --oneline --long --classify=auto --colour=auto --icons=auto --hyperlink";
        c = "clear";
        cd = "z";
        cp = "cp -irv";
        jjgf = "jj git fetch";
        jjl = "jj log -r '@ | ancestors(immutable_heads()..) | trunk()' --no-pager --limit=6";
        mv = "mv -iv";
        nv = "nvim";
        rm = "rm -irv";
        tmux = "TERM=xterm-256color tmux";
        sudo = "sudo ";
      }
      // lib.mkIf
      isDarwin
      {uv = "diskutil ap unlockVolume";};
    variables = let
      flake-path = builtins.readFile inputs.flake-path.outPath;
      nvimexe = getExe' config.zhuk.nvim.package "nvim";
    in rec {
      NIXPKGS_REV = "e75f25705c2934955ee5075e62530d74aca973c6";
      PAGER = "${pkgs.delta}/bin/delta";
      MANPAGER = "${nvimexe} +Man!";
      EDITOR = nvimexe;
      LANG = "C.UTF-8";
      HOME = config.users.users."${currentSystemUser}".home;
      XDG_CACHE_HOME = "${HOME}/.cache";
      XDG_CONFIG_HOME = "${HOME}/.config";
      XDG_DATA_HOME = "${HOME}/.local/share";
      XDG_STATE_HOME = "${HOME}/.local/state";
      NH_FLAKE = builtins.trace "Flake path is ${flake-path}" flake-path;
      ZDOTDIR = "${XDG_CONFIG_HOME}/zsh";
    };
  };
}
