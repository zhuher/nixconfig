{
  pkgs,
  lib,
  config,
  currentSystemUser,
  currentSystemName,
  isWSL,
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
    ./lix.nix
    ./options.nix
    ../module/zen-browser.nix
  ];
  nixpkgs.overlays = [
    (final: _prev: {})
  ];

  programs.xstarbound = {
    enable = lib.mkDefault true;
    localMods = {
      enable = false;
      dir = let
        bts = pkgs.lib.boolToString;
      in
        {
          "${bts true}" = "${env.HOME}/Library/Application Support/Steam/steamapps/workshop/content/211820";
          "${bts false}" =
            {
              "${bts true}" = "/mnt/c/Program Files (x86)/Steam/steamapps/workshop/content/211820";
            }."${bts isWSL}";
        }."${bts isDarwin}";
    };
    bootconfig.settings = {
      assetDirectories = [
        # Starbound assets
        # "./xsb-assets/"
        # "./Resources/xsb-assets/"
        # "./xSB Client.app/Contents/Resources/xsb-assets/"
        # Steam-installed Starbound directory on Darwin:
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
          exact = ["${env.HOME}/.envrc"];
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
      ++ [pkgs.maple-mono.variable];
  };
  networking.hostName = reportSpec currentSystemName;

  programs.zsh = let
    inherit (lib) getExe getExe';
    inherit (pkgs) steamcmd coreutils;
  in {
    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    enableGlobalCompInit = false;
    promptInit = ''
      setopt PROMPT_SUBST
      PROMPT='%B%F{green}%*%f@%F{blue}%U%m%u%f %F{yellow}%~%f %(?.%F{green}>.%F{red}[%?]>)%f%b '
    '';
    shellInit =
      ''''
      + lib.optionalString isWSL ''
        getip() { ip r | grep 'link src' | awk '{ print $9 }' }
      '';
    interactiveShellInit = ''
      export DIRCOLORS_EXE="${getExe' coreutils "dircolors"}"
      export ZSH_DIR="${pkgs.zsh}"
      export ZIG_SHELL_COMPLETIONS_DIR="${pkgs.zig-shell-completions}"
      export ZSH_AUTOSUGGESTIONS_DIR="${pkgs.zsh-autosuggestions}"
      export ZSH_FAST_SYNTAX_HIGHLIGHTING_DIR="${pkgs.zsh-fast-syntax-highlighting}"
      export ZSH_HISTORY_SUBSTRING_SEARCH_DIR="${pkgs.zsh-history-substring-search}"
      [[ "$USER" == "${currentSystemUser}" ]] && { source "$NH_FLAKE/configs/zsh/rc.zsh"; source ${pkgs.grc + "/etc/grc.zsh"} }
      ${lib.optionalString isWSL ''
        macgame2dir() { ${getExe steamcmd} +force_install_dir "$2" +@sSteamCmdForcePlatformType macos +login mrtoster007 +app_update "$1" +quit }
        bg2dir() { macgame2dir 1086940 "$1" }
      ''}
    '';
  };

  users.users."${currentSystemUser}".shell = pkgs.zsh;
  environment = let
    inherit (lib) getExe' getExe;
  in {
    inherit shells;
    systemPackages = with pkgs;
      [
        television
        nix-tree
        zoxide
        config.zhuk.jj.package
        zig
        zls
        comma
        gnugrep
        age
        alejandra
        zhuk.bat-wrapped
        coreutils
        delta
        (writeShellScriptBin "devinit" ''nix flake init -t ${env.NH_FLAKE}#$1 && cp ${env.NH_FLAKE}/shells/$1/.envrc{,.local} ./'')
        eza
        fd
        git
        gnutar
        jq
        just
        nh
        lpkgs.nil
        config.zhuk.nvim.package
        ripgrep
        rsync
        sops
        ssh-to-age
        zhuk.tmux-wrapped
        wget
        grc
        zhuk.gnupg-wrapped
        # (amneziawg-tools.overrideAttrs (prev: {
        #   postFixup =
        #     prev.postFixup
        #     + ''
        #       sed -i 's/\bwg\b/awg/g;s#/wireguard#/amneziawg#g' $out/bin/.awg-quick-wrapped
        #     '';
        # }))
        carapace
        forgejo-cli
      ]
      ++ shells;
    pathsToLink = ["/share/zsh"];
    shellAliases =
      rec {
        l = "${getExe pkgs.eza} --all --oneline --classify=auto --colour=auto --icons=auto --hyperlink";
        ls = "${getExe pkgs.eza} --all --bytes --smart-group --modified --oneline --long --classify=auto --colour=auto --icons=auto --hyperlink";
        lstr = "${ls} --tree --ignore-glob '.git|.jj|.direnv' --group-directories-first";
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
      // (
        if isDarwin
        then {uv = "diskutil ap unlockVolume";}
        else {}
      );
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
