{
  isWSL,
  isDarwin,
  isLinux,
  inputs,
  ...
}:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  eval-pkgs =
    dir:
    lib.lists.imap0 (i: v: (pkgs.callPackage v) { }) (
      lib.lists.ifilter0 (i: v: lib.hasSuffix ".nix" v) (lib.filesystem.listFilesRecursive dir)
    );
  symlink = config.lib.file.mkOutOfStoreSymlink;
  hf = "${config.home.homeDirectory}/nixconfig/users/zhuher";
  nvimpkg = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = (
    pkgs.writeShellScriptBin "manpager" (
      if isDarwin then
        ''
          sh -c 'sed -u -e "s/\\x1B\[[0-9;]*m//g; s/.\\x08//g" | bat -p -lman'
        ''
      else
        ''
          sh -c "col -bx | bat -l man -p"
        ''
    )
  );
  custom-pkgs = (eval-pkgs "${hf}/../../pkgs/darwin");
in
{
  # sops = {
  #   defaultSopsFile = ./secrets.yaml;
  #   age.sshKeyPaths = [ ~/.ssh/age ];
  #   secrets.lmao = {};
  # };
  manual.manpages.enable = true;
  home = {
    stateVersion = "24.05";
    # packages {{{
    packages = lib.mkMerge [
      # everywhere {{{
      (with pkgs; [
        nvimpkg
        sops
        age
        ssh-to-age
        bat
        fastfetch
        fd
        fzf
        lsd
        ripgrep
        rsync
        wget
        nixfmt-rfc-style
        gnumake
        statix
        vulnix
        nil
        gnupg
        jq
        btop
        man-pages
        man-pages-posix
        nodePackages_latest.nodejs
        coreutils
        emacs-lsp-booster
        asm-lsp
        nushell
        lua-language-server
        zig
        (writeShellScriptBin "zhukmacs" ''exec emacsclient -cta ''' "$@"'')
        (writeShellScriptBin "rider" ''
          # Access the input file through the $1 variable
          PATH=/etc/profiles/per-user/zhuher/bin/:$PATH /etc/profiles/per-user/zhuher/bin/rider2emacs "$@" -cn --eval '(select-frame-set-input-focus (selected-frame))' &> /Users/zhuher/log/rider2emacs.log
          echo "Running rider2emacs with arguments $*" >> /Users/zhuher/log/rider2emacs.log
          	      '')
      ])
      # everywhere }}}
      # darwin {{{
      (lib.mkIf isDarwin (
        with pkgs;
        [
          dockutil
          ffmpeg
          # mas # installed through homebrew as that version is used for App Store apps anyways
          monitorcontrol
          libjxl
          apparency
          appcleaner
          qbittorrent
          keka
          iina
          raycast
          anki-bin
          moonlight-qt
          tldr
          watchexec
          prismlauncher
          cataclysm-dda-git
          crawl
          ice-bar
        ]
        ++ custom-pkgs
      ))
      # darwin }}}
      # linux {{{
      (lib.mkIf (!isDarwin) (
        with pkgs;
        [
          zip
          p7zip
          unzip
          valgrind
          linux-manual
          # libxml2
          keepassxc
          steamcmd
          cron
          qbittorrent-cli
        ]
      ))
      # non-wsl {{{
      (lib.mkIf isLinux
        # with pkgs;
        [
          # ladybird
          # steamPackages.steamcmd
          # lutris
          # qbittorrent
        ]
      )

      # non-wsl }}}
      # linux }}}
    ];
    # packages }}}
    # environment for managed shells {{{
    sessionVariables = {
      LC_TIME = "nl_NL.UTF-8";
      LC_NUMERIC = "POSIX";
      LC_MONETARY = "POSIX";
      LC_COLLATE = "en_US.UTF-8";
      LC_CTYPE = "POSIX";
      PAGER = "delta";
      MANPAGER = "${manpager}/bin/manpager";
    } // (lib.mkIf (!isDarwin) { MANROFFOPT = "-c"; });
    # environment for managed shells }}}

    # $HOME/ {{{
    file =
      # everywhere {{{
      {
        ".gdbinit".source = symlink "${hf}/gdbinit";
        ".inputrc".source = symlink "${hf}/inputrc";
        ".gnupg/gpg.conf".source = symlink "${hf}/gpg.conf";
        ".ssh/misc.pub".source = symlink "${hf}/misc.pub";
        ".ssh/pers.pub".source = symlink "${hf}/pers.pub";
        ".ssh/gh.pub".source = symlink "${hf}/gh.pub";
        ".ssh/config".text =
          lib.optionalString isDarwin ''
            Host *
              IdentityAgent "~/Library/Group Containers/group.strongbox.mac.mcguill/agent.sock"
          ''
          + ''
            Include "${hf}/sshconfig"
            Include hosts'';
        ".tmux.conf".source = symlink "${hf}/tmux.conf";
      }
      # everywhere }}}
      # WSL {{{
      // lib.optionalAttrs isWSL {
      }
      # WSL }}}
      # darwin {{{
      // lib.optionalAttrs isDarwin {
        "Library/Application Support/Code/User/settings.json".source = symlink "${hf}/vscode.json";
        "Library/Preferences/clangd/config.yaml".source = symlink "${hf}/clangd.yaml";
        "Library/Application Support/jj/config.toml".source = symlink "${hf}/jj.toml";
      }
    # darwin }}}
    ;
    # $HOME/ }}}
  };

  # $HOME/.config {{{
  xdg.enable = true;
  xdg.configFile =
    # everywhere {{{
    {
      "bat/config".source = symlink "${hf}/bat";
      "rustfmt/rustfmt.toml".source = symlink "${hf}/rustfmt.toml";
      "gh/config.yml".source = lib.mkForce (symlink "${hf}/gh.yml");
      "wezterm/wezterm.lua".source = symlink "${hf}/wezterm.lua";
      "helix/config.toml".source = symlink "${hf}/hx.conf.toml";
      "helix/languages.toml".source = symlink "${hf}/hx.langs.toml";
      "nvim/init.lua".source = symlink "${hf}/nvim.lua";
      "git/ignore".text = ''.DS_Store'';
      "qBittorrent/qBittorrent.ini".source = symlink "${hf}/qbittorrent.ini";
      "zsh/.p10k.zsh".source = symlink "${hf}/zsh/p10k.zsh";
      # "emacs/early-init.el".source = symlink "${hf}/early-zhukmacs.el";
      # "emacs/init.el".source = symlink "${hf}/zhukmacs.el";
      # "emacs/zhukmacs.org".source = symlink "${hf}/zhukmacs.org";
    }
    # everywhere }}}
    # darwin {{{
    // lib.optionalAttrs (isDarwin) { "ghostty/config".source = symlink "${hf}/ghostty"; }
    # darwin }}}
    # linux {{{
    // lib.optionalAttrs (isLinux) {
      "sway/config".source = symlink "${hf}/sway.conf";
      "jj/config.toml".source = symlink "${hf}/jj.toml";
    }
  # linux }}}
  ;
  # #HOME/.config }}}
  # programs {{{
  programs = {
    # firefox {{{
    firefox = {
      enable = !isWSL;
      # package = pkgs.librewolf;
    };
    # firefox }}}
    # helix {{{
    helix = {
      enable = true;
      defaultEditor = false;
      package = pkgs.helix;
    };
    # helix }}}
    # # vscode {{{
    vscode = {
      enable = isDarwin;
    };
    # vscode }}}
    # zsh {{{
    zsh = {
      enable = true;
      dotDir = ".config/zsh";
      # oh-my-zsh = {
      #   enable = true;
      #   plugins = [ "shrink-path" ];
      # };
      envExtra =
        ''
          source ${hf}/zsh/.env
        ''
        + lib.optionalString (isWSL) ''
          getip() { ip r | grep 'link src' | awk '{ print $9 }' }
        '';
      # loginExtra = '''';
      initExtraFirst = ''
        if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
        fi
        HISTIGNORE="pwd:ls:cd";
        source ${hf}/zsh/.rc-extra.zsh
      '';
      initExtra =
        ''
          setopt nullglob
          for file in ${hf}/zsh/extras/{*,.*}.zsh; source $file
        ''
        + lib.optionalString (isWSL) ''
          macgame2dir() { steamcmd +force_install_dir "$2" +@sSteamCmdForcePlatformType macos +login mrtoster007 +app_update "$1" +quit }
          bg2dir() { macgame2dir 1086940 "$1" }
        '';
    };
    # zsh }}}
    # zoxide {{{
    zoxide = {
      enable = true;
      enableFishIntegration = false;
      options = [
      ];
      package = pkgs.zoxide;
    };
    # zoxide }}}
    # fzf {{{
    fzf = {
      package = pkgs.fzf;
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = false;
      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [
        "--ansi --preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'"
      ];
      historyWidgetOptions = [
        "--sort"
        "--exact"
      ];
    };
    # fzf }}}
    # VCS {{{
    jujutsu = {
      enable = true;
    };
    git = {
      enable = true;
      userName = "Herman Zhukov";
      userEmail = "societyofbruh@gmail.com";
      ignores = [
        ".vscode"
        ".git"
        ".jj"
      ];
      aliases = {
        log-pretty = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        root = "rev-parse --show-toplevel";
      };
      extraConfig = {
        http.postBuffer = 157286400;
        branch.autosetuprebase = "always";
        color.ui = true;
        core.askPass = ""; # needs to be empty to use terminal for ask pass
        credential.helper = "store"; # want to make this more secure
        github.user = "zhuher";
        push.default = "tracking";
        init.defaultBranch = "main";
        pull.rebase = true;
        rebase.autoStash = true;
      };
      delta = {
        enable = true;
        options = {
          navigate = true;
          features = "decorations";
          line-numbers = true;
          side-by-side = true;
          syntax-theme = "base16";
          keep-plus-minus-markers = true;
          decorations = {
            commit-decoration-style = "blue ol";
            commit-style = "raw";
            file-style = "omit";
            hunk-header-decoration-style = "blue box";
            hunk-header-file-style = "yellow";
            hunk-header-style = "file line-number syntax";
            hyperlinks = true;
          };
        };
      };
    };
    gh = {
      enable = true;
      package = pkgs.gh;
    };
    # VCS }}}
    # direnv {{{
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      config = {
        global = {
          warn_timeout = "30s";
        };
        whitelist = {
          exact = [ "$HOME/.envrc" ];
        };
      };
    };
    # direnv }}}
    # tmux {{{
    tmux = {
      enable = true;
      package = pkgs.tmux;
      newSession = true;
    };
    # tmux }}}
    # wezterm {{{
    wezterm = {
      enable = true;
      enableZshIntegration = true;
      package = pkgs.wezterm;
    };
    # wezterm }}}
  };
  # programs }}}
}
