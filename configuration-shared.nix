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
in {
  # xSB {{{
  imports = [
  ];
  programs.xstarbound = {
    enable = true;
    # package = let
    #   curSys = pkgs.stdenv.hostPlatform.system;
    # in
    #   inputs.xsb.packages.${curSys}.default.override {
    #     xstarbound-unwrapped =
    #       inputs.xsb.packages.${curSys}.xstarbound-unwrapped.override
    #       {clangStdenv = pkgs.ccacheStdenv;};
    #   };
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
  }; # xSB }}}
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      settings = {
        global = {
          warn_timeout = "30s";
        };
        whitelist = {
          exact = ["${config.environment.variables.HOME}/.envrc"];
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
    extraOptions = ''
      !include ${config.sops.secrets.access-tokens.path}
    '';
    # gc = {
    #   interval = {
    #     Weekday = 0;
    #     Hour = 23;
    #     Minute = 0;
    #   };
    #   automatic = true;
    # };
    optimise.interval = {
      Weekday = 0;
      Hour = 23;
      Minute = 0;
    };
    registry = pkgs.lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = pkgs.lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    enable = false; # because using determinate nix
    package = pkgs.lix; # use lix instead of cppNix
    checkConfig = true;
    optimise.automatic = lib.mkDefault true;
    settings = {
      auto-optimise-store = false;
      cores = 0;
      sandbox = lib.mkDefault true; # [INFO]: "relaxed" or bool;
      extra-substituters = [
        "https://cache.garnix.io"
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
  networking.hostName = currentSystemName;
  # zsh {{{
  programs.zsh = let
    inherit (lib) getExe getExe';
    inherit (pkgs) zoxide fzf steamcmd coreutils;
    env = config.environment.variables;
  in {
    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    enableGlobalCompInit = false;
    promptInit = ''
      setopt PROMPT_SUBST
      PROMPT='%B%F{green}%*%f@%F{blue}%U%m%u%f %F{yellow}%~%f %(?.%F{green}>.%F{red}[%?]>)%f%b '
    ''; # ''''; # ''[[ $TERM != "dumb" ]] && eval "$(''${getExe' starship "starship"} init zsh)"'';
    shellInit =
      ''''
      + lib.optionalString isWSL ''
        getip() { ip r | grep 'link src' | awk '{ print $9 }' }
      '';
    interactiveShellInit = ''
      eval "$(${getExe' coreutils "dircolors"})"
      HELPLDIR="${pkgs.zsh}/share/zsh/$ZSH_VERSION/help"
      path+="${pkgs.zsh-fzf-tab}/share/fzf-tab"
      fpath+="${pkgs.zsh-fzf-tab}/share/fzf-tab"
      fpath+="${env.NH_FLAKE}/zsh/comp"

      autoload -Uz compinit
      mkdir -p ${env.XDG_CACHE_HOME}/zsh
      source "${env.NH_FLAKE}/zsh/comp.zsh"

      if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
        autoload -Uz -- "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
        ghostty-integration
        unfunction ghostty-integration
      fi
      fpath+="${pkgs.zig-shell-completions}/share/zsh/site-functions"

      if [[ -n ${env.XDG_CACHE_HOME}/zsh/zcompdump-$ZSH_VERSION(#qN.mh+24) ]]; then
        compinit -d "${env.XDG_CACHE_HOME}/zsh/zcompdump-$ZSH_VERSION"
      else
        compinit -C
      fi

      eval "$(${getExe zoxide} init zsh)"
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,underline"
      ZSH_AUTOSUGGEST_STRATEGY=(history)

      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

      setopt nullglob
      source "${env.NH_FLAKE}/zsh/rc.zsh"

      HISTSIZE=9999999999
      HISTFILE="${env.ZDOTDIR}/hist"
      SAVEHIST=9999999999
      mkdir -p "$(dirname "$HISTFILE")"
      chmod 600 "$HISTFILE"

      setopt HIST_FCNTL_LOCK APPEND_HISTORY HIST_IGNORE_DUPS
      unsetopt HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS
      setopt HIST_IGNORE_SPACE HIST_EXPIRE_DUPS_FIRST SHARE_HISTORY EXTENDED_HISTORY

      if [[ $options[zle] = on ]]; then
        source <(${getExe fzf} --zsh)
      fi

      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
      bindkey "^[[A" history-substring-search-up
      bindkey "^[[B" history-substring-search-down
      ${lib.optionalString false ''[[ $TERM != "dumb" ]] && exec ${getExe pkgs.nushell}''}
      ed() { pushd "$(${getExe zoxide} query $1)"; $EDITOR; popd }
      ${lib.optionalString isWSL ''
        macgame2dir() { ${getExe steamcmd} +force_install_dir "$2" +@sSteamCmdForcePlatformType macos +login mrtoster007 +app_update "$1" +quit }
        bg2dir() { macgame2dir 1086940 "$1" }
      ''}
      [[ -s "${pkgs.grc}/etc/grc.zsh" ]] && source ${pkgs.grc}/etc/grc.zsh
    '';
  };
  # zsh }}}
  users.users."${currentSystemUser}".shell = pkgs.zsh;
  environment = let
    inherit (lib) getExe' getExe;
  in {
    shells = with pkgs; [
      zsh
      nushell
    ];
    systemPackages = with pkgs; let
      # gnupg-wrapped {{{
      mapArgs = args: let
        lines = builtins.filter (el: !(builtins.isList el || el == "")) (builtins.split "\n" args);
        words = builtins.filter (el: !builtins.isList el) (builtins.concatLists (builtins.map (line: builtins.split " " line) lines));
        flags = map (w: "--add-flags " + w) words;
        result = builtins.concatStringsSep " " flags;
      in
        result;
      mappedArgs = mapArgs ''
        --list-options show-photos,show-usage,show-ownertrust,show-policy-urls,show-std-notations,show-keyserver-urls,show-uid-validity,show-unusable-uids,show-unusable-subkeys,show-unusable-sigs,show-keyring,show-sig-expire,show-sig-subpackets,sort-sigs
        --display-charset utf-8
        --compress-level 9
        --bzip2-compress-level 9
        --no-random-seed-file
        --no-greeting
        --require-secmem
        --require-cross-certification
        --expert
        --armor
        --with-fingerprint
        --with-fingerprint
        --with-subkey-fingerprint
        --with-keygrip
        --with-key-origin
        --with-wkd-hash
        --with-secret
        --pinentry-mode loopback
        --full-timestrings
        --passphrase-repeat 4
        --no-symkey-cache
        --with-sig-list
        --keyid-format 0xlong
      '';
      gnupg-wrapped = symlinkJoin {
        name = "gnupg-wrapped";
        paths = [gnupg];
        nativeBuildInputs = [makeBinaryWrapper];
        postBuild = ''
          wrapProgram $out/bin/gpg \
          ${mappedArgs}
        '';
      };
      # gnupg-wrapped }}}
      # jujutsu-wrapped {{{
      jujutsu-wrapped = let
        # config {{{
        jjconf = (formats.toml {}).generate "jj.toml" {
          colors."commit_id prefix".bold = true;
          revsets.log = ''@ | ancestors(immutable_heads()..) | trunk()'';
          template-aliases = {
            "format_short_id(id)" = "id.shortest()";
            "format_timestamp(timestamp)" = ''timestamp ++ "(" ++ timestamp.ago() ++ ")"'';
          };
          ui = {
            default_command = ["log" "--no-pager" "--limit=6"];
            diff-editor = ["${lib.getExe' pkgs.nvim-wrapped "nvim"}" "-c" "DiffEditor $left $right $output"];
            pager = "${lib.getExe delta}";
            diff-formatter = ":git";
          };
          templates = {
            log_node = ''
              coalesce(
                if(!self, "🮀"),
                if(current_working_copy, "@"),
                if(root, "┴"),
                if(immutable, "●", "○"),
              )'';
          };
          op_log_node = ''if(current_operation, "@", "○")'';
          snapshot.max-new-file-size = 16777216;
          aliases = {
            my-inline-script = [
              "util"
              "exec"
              "--"
              "bash"
              "-c"
              ''
                #!/usr/bin/env bash
                set -euo pipefail
                echo "Look Ma, everything in one file!"
                echo "args: $@"
              ''
              ""
            ];
            yolo = [
              "util"
              "exec"
              "--"
              "bash"
              "-c"
              ''
                jj desc -m "$(curl -s "https://whatthecommit.com/index.txt")"
              ''
              ""
            ];
          };
        };
        # config }}}
      in
        symlinkJoin {
          name = "jujutsu-wrapped";
          paths = [jujutsu];
          nativeBuildInputs = [makeBinaryWrapper];
          buildInputs = [delta pkgs.nvim-wrapped];
          postBuild = ''
            wrapProgram $out/bin/jj \
            --set JJ_CONFIG "${"${jjconf}:${config.sops.secrets.jjsecrets.path}"}"
          '';
        };
      # jujutsu-wrapped }}}
    in [
      hyperfine
      gnugrep
      age
      alejandra
      bat-wrapped
      btop
      coreutils
      delta
      (writeShellScriptBin "devinit" ''nix flake init -t ${env.NH_FLAKE}#$1 && cp ${env.NH_FLAKE}/shells/$1/.envrc{,.local} ./'')
      eza
      fastfetch
      fd
      fzf
      git
      gnutar
      jq
      jujutsu-wrapped
      just
      nh
      nil
      nushell
      nvim-wrapped
      ripgrep
      rsync
      sops
      ssh-to-age
      tmux-wrapped
      wget
      yazi
      zoxide
      grc
      gnupg-wrapped
      # (amneziawg-tools.overrideAttrs (prev: {
      #   postFixup =
      #     prev.postFixup
      #     + ''
      #       sed -i 's/\bwg\b/awg/g;s#/wireguard#/amneziawg#g' $out/bin/.awg-quick-wrapped
      #     '';
      # }))

      carapace
      nushell
      zsh
      zsh-fzf-tab
    ];
    pathsToLink = ["/share/zsh"];
    shellAliases =
      # {{{
      rec {
        l = "${getExe pkgs.eza} --all --oneline --classify=auto --colour=auto --icons=auto --hyperlink";
        ls = "${getExe pkgs.eza} --all --bytes --smart-group --modified --oneline --long --classify=auto --colour=auto --icons=auto --hyperlink";
        lstr = "${ls} --tree --ignore-glob '.git|.jj|.direnv' --group-directories-first";
        aa = "awg-quick";
        c = "clear";
        cd = "z";
        cp = "cp -irv";
        jjgf = "jj git fetch";
        jjl = "jj log -r '@ | ancestors(immutable_heads()..) | trunk()' --no-pager --limit=6";
        mv = "mv -iv";
        nv = "nvim";
        rm = "rm -irv";
        tmux = "TERM=xterm-256color tmux";
        # make sudo use aliases (https://github.com/sukhmancs/nixos-configs/blob/c4dbf10fb95f3237130a0b1a899a688ca9c77d32/machines/nebula/homes/zsh/aliases.nix#L12)
        sudo = "sudo ";
      }
      // (
        if isDarwin
        then {uv = "diskutil ap unlockVolume";}
        else {}
      ); # shellAliases }}}
    variables =
      # {{{
      let
        manpager = pkgs.writeShellScriptBin "manpager" (
          if isDarwin
          then ''
            sh -c 'sed -u -e "s/\\x1B\[[0-9;]*m//g; s/.\\x08//g" | bat -p -lman'
          ''
          else ''
            cat "$1" | col -bx | bat --language man --style plain
          ''
        );
        flake-path = builtins.readFile inputs.flake-path.outPath;
      in rec {
        NIXPKGS_REV = "76eec3925eb9bbe193934987d3285473dbcfad50";
        PAGER = "${pkgs.delta}/bin/delta";
        MANPAGER = "${manpager}/bin/manpager";
        EDITOR = getExe' pkgs.nvim-wrapped "nvim";
        LANG = "C.UTF-8";
        HOME = config.users.users."${currentSystemUser}".home;
        XDG_CACHE_HOME = "${HOME}/.cache";
        XDG_CONFIG_HOME = "${HOME}/.config";
        XDG_DATA_HOME = "${HOME}/.local/share";
        XDG_STATE_HOME = "${HOME}/.local/state";
        NH_FLAKE = builtins.trace "Flake path is ${flake-path}" flake-path;
        ZDOTDIR = "${XDG_CONFIG_HOME}/zsh";
        FZF_CTRL_R_OPTS = "--sort --exact";
        FZF_CTRL_T_COMMAND = "fd --type f";
        FZF_CTRL_T_OPTS = "--ansi --preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'";
      }
      # // (if !isDarwin then { MANROFFOPT = "-c"; } else { })
      ; # vvariables }}}
  };
}
