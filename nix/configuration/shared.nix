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
  nixpkgs.overlays = [
    (final: _prev:
      with final; {
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
              diff-editor = ["${lib.getExe' config.zhuk.nvim.package "nvim"}" "-c" "DiffEditor $left $right $output"];
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
              pull-subs = [
                "util"
                "exec"
                "--"
                "bash"
                "-c"
                ''
                  git submodule update --recursive --init
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
            postBuild = ''
              wrapProgram $out/bin/jj \
              --prefix PATH : ${final.lib.makeBinPath (with final; [delta config.zhuk.nvim.package])} \
              --prefix JJ_CONFIG : "${jjconf}" ${
                lib.optionalString
                config.zhuk.jj.secrets
                ''--prefix JJ_CONFIG : "${config.sops.secrets.jjsecrets.path}"''
              }
            '';
          };
        # jujutsu-wrapped }}}
      })
  ];
  imports = [
    ./${
      if isDarwin
      then "darwin"
      else "nixos"
    }.nix
    ./lix.nix
    ./options.nix
  ];
  # xSB {{{
  programs.xstarbound = {
    enable = lib.mkDefault true;
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
      # extra-deprecated-features = ["broken-string-indentation" "or-as-identifier"];
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
  # zsh {{{
  programs.zsh = let
    inherit (lib) getExe getExe';
    inherit (pkgs) zoxide fzf steamcmd coreutils;
  in {
    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    enableGlobalCompInit = false;
    promptInit = ''
      setopt PROMPT_SUBST
      PROMPT='%B%F{green}%*%f@%F{blue}%U%m%u%f %F{yellow}%~%f %(?.%F{green}>.%F{red}[%?]>)%f%b '
    '';
    # '''';
    # ''[[ $TERM != "dumb" ]] && eval "$(''${getExe' starship "starship"} init zsh)"'';
    shellInit =
      ''''
      + lib.optionalString isWSL ''
        getip() { ip r | grep 'link src' | awk '{ print $9 }' }
      '';
    interactiveShellInit = ''
      export DIRCOLORS_EXE="${getExe' coreutils "dircolors"}"
      export ZSH_DIR="${pkgs.zsh}"
      export ZSH_FZF_TAB_DIR="${pkgs.zsh-fzf-tab}"
      export ZIG_SHELL_COMPLETIONS_DIR="${pkgs.zig-shell-completions}"
      export ZOXIDE_EXE="${getExe zoxide}"
      export ZSH_AUTOSUGGESTIONS_DIR="${pkgs.zsh-autosuggestions}"
      export ZSH_FAST_SYNTAX_HIGHLIGHTING_DIR="${pkgs.zsh-fast-syntax-highlighting}"
      export ZSH_HISTORY_SUBSTRING_SEARCH_DIR="${pkgs.zsh-history-substring-search}"
      export FZF_EXE="${getExe fzf}"
      [[ "$USER" == "${currentSystemUser}" ]] && { source "$NH_FLAKE/configs/zsh/rc.zsh"; source ${pkgs.grc + "/etc/grc.zsh"} }
      ${lib.optionalString isWSL ''
        macgame2dir() { ${getExe steamcmd} +force_install_dir "$2" +@sSteamCmdForcePlatformType macos +login mrtoster007 +app_update "$1" +quit }
        bg2dir() { macgame2dir 1086940 "$1" }
      ''}
    '';
  };
  # zsh }}}
  users.users."${currentSystemUser}".shell = pkgs.zsh;
  environment = let
    inherit (lib) getExe' getExe;
  in {
    inherit shells;
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
    in
      [
        jujutsu-wrapped
        zig
        zls
        (zen-browser.override
          {
            policies = {
              Cookies = {
                Locked = true;
                Behavior = "reject-tracker-and-partition-foreign";
              };
              DisableAppUpdate = true;
              # DisableMasterPasswordCreation = true;
              DisablePocket = true;
              # DisableSetDesktopBackground = true;
              DontCheckDefaultBrowser = true;
              EnableTrackingProtection = {
                Value = true;
                Locked = true;
                Cryptomining = true;
                Fingerprinting = true;
                EmailTracking = true;
                SuspectedFingerprinting = true;
                Category = "strict";
                # IF BaselineExceptions is true, Firefox will automatically apply exceptions required to avoid major website breakage. (Firefox 145)
                # If ConvenienceExceptionsis true, Firefox will apply exceptions automatically that are only required to fix minor issues and make convenience features available. (Firefox 145)
              };
              UseSystemPrintDialog = true;
              DisableTelemetry = true;
              OfferToSaveLoginsDefault = false;
              PasswordManagerEnabled = false;
              SanitizeOnShutdown = {FormData = true;};
              Extensions = {
                Uninstall = [];
                Install = [];
              };
              PictureInPicture = {
                Enabled = true;
                Locked = true;
              };
              DisableFirefoxStudies = true;
              UserMessaging = {
                ExtensionRecommendations = false;
                UrlbarInterventions = false;
                SkipOnboarding = true;
                MoreFromMozilla = false;
                FirefoxLabs = true;
                FeatureRecommendations = false;
              };
              NetworkPrediction = false;
              SearchEngines = {
                Remove = ["Bing" "Wikipedia"];
                Default = "Google";
                Add = [];
              };
              HttpsOnlyMode = "force_enabled";
              SSLVersionMin = "tls1.2";
              PostQuantumKeyAgreementEnabled = true;
              HttpAllowlist = [
                "http://localhost"
                "http://127.0.0.1"
              ];
              Preferences = let
                lock = Value: {
                  inherit Value;
                  Status = "locked";
                };
              in {
                "browser.translations.automaticallyPopup" = lock false;
                # "browser.startup.homepage" = lock "https://news.ycombinator.com";
                # "toolkit.legacyUserProfileCustomizations.stylesheets" = lock true;
                # "browser.warnOnQuitShortcut" = lock false;
                # "browser.sessionstore.closedTabsFromClosedWindows" = lock false;
                # "browser.sessionstore.closedTabsFromAllWindows" = lock false;
                # "security.OCSP.require" = lock false;
                # "browser.tabs.closeWindowWithLastTab" = lock false;
              };
              ExtensionSettings = with builtins; let
                extension = {
                  uuid,
                  install_url,
                  default_area ? "menupanel",
                  private_browsing ? false,
                }: {
                  name = install_url;
                  value = {
                    install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${uuid}/latest.xpi";
                    installation_mode = "force_installed";
                    inherit default_area private_browsing;
                  };
                };
                customExt = {
                  uuid,
                  install_url,
                  default_area ? "menupanel",
                  private_browsing ? false,
                }: {
                  name = uuid;
                  value = {
                    inherit install_url default_area private_browsing;
                    installation_mode = "force_installed";
                  };
                };
                a2 = uuid: install_url: {inherit uuid install_url;};
                a3 = uuid: install_url: private_browsing: {
                  inherit uuid install_url private_browsing;
                  default_area = "menupanel";
                };
                a4 = uuid: install_url: default_area: private_browsing: {
                  inherit
                    uuid
                    install_url
                    default_area
                    private_browsing
                    ;
                };
              in
                # extensions {{{
                listToAttrs (
                  [
                    (extension (a4 "adnauseam" "adnauseam@rednoise.org" "navbar" true))
                    (extension (a3 "libredirect" "7esoorv3@alefvanoon.anonaddy.me" true))
                    (extension (a3 "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}" true))
                    (extension (a3 "port-authority" "{6c00218c-707a-4977-84cf-36df1cef310f}" true))
                    (extension (a2 "search_by_image" "{2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c}"))
                    (extension (
                      a4 "terms-of-service-didnt-read" "jid0-3GUEt1r69sQNSrca5p8kx9Ezc3U@jetpack" "navbar" true
                    ))
                    # (extension (a2 "pstream-extension" "{0c3fcdbd-5e0f-40d5-8f6c-d5eef8ff2b7c}"))
                    # (extension (a2 "syncshare" "syncshare@naloaty.me"))
                    (extension (a2 "violentmonkey" "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}"))
                    (extension (a2 "vknext" "addon@vknext.net"))
                    (extension (a4 "xbs" "{019b606a-6f61-4d01-af2a-cea528f606da}" "navbar" false))
                    # (extension (a2 "augmented-steam" "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}"))
                    (extension (a2 "behind" "{d6005a62-1fdb-4cf2-b5ef-21b865d894f7}"))
                    # (extension (a2 "bookmark-dupes" "bookmarkdupes@martin-vaeth.org"))
                    (extension (a3 "canvasblocker" "CanvasBlocker@kkapsner.de" true))
                    (extension (a3 "chameleon-ext" "{3579f63b-d8ee-424f-bbb6-6d0ce3285e6a}" true))
                    # (extension (a4 "cookie-autodelete" "CookieAutoDelete@kennydo.com" "navbar" true))
                    # (extension (a2 "cookie-quick-manager" "{60f82f00-9ad5-4de5-b31c-b16a47c51558}"))
                    # (extension (a2 "cookies-txt" "{12cf650b-1822-40aa-bff0-996df6948878}"))
                    (extension (a3 "fastforwardteam" "addon@fastforward.team" true))
                    (extension (a4 "istilldontcareaboutcookies" "idcac-pub@guus.ninja" "navbar" true))
                    (extension (a2 "indie-wiki-buddy" "{cb31ec5d-c49a-4e5a-b240-16c767444f62}"))
                    (extension (a2 "tridactyl-vim" "tridactyl.vim@cmcaine.co.uk"))
                    # (extension (
                    #   a4 "localcdn-fork-of-decentraleyes" "{b86e4813-687a-43e6-ab65-0bde4ab75758}" "menupanel" true
                    # ))
                    (customExt (
                      a4 "{d19a89b9-76c1-4a61-bcd4-49e8de916403}"
                      "https://github.com/mullvad/browser-extension/releases/download/v0.9.7-firefox-beta/mullvad_proxy_extension-0.9.7.xpi"
                      "navbar"
                      true
                    ))
                    (customExt (
                      a2 "magnolia@12.34" "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-latest.xpi"
                    ))
                  ]
                  ++ (
                    if isDarwin
                    then [(extension (a4 "strongbox-autofill" "strongbox@phoebecode.com" "navbar" true))]
                    else [(extension (a4 "keepassxc-browser" "keepassxc-browser@keepassxc.org" "navbar" true))]
                  )
                ); # extensions }}}
              # To add additional extensions, find it on addons.mozilla.org, find
              # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
              # Then, download the XPI by filling it in to the install_url template, unzip it,
              # run `jq .browser_specific_settings.gecko.id manifest.json` or
              # `jq .applications.gecko.id manifest.json` to get the UUID
            };
          })
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
        fzf
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
        zsh-fzf-tab
        forgejo-cli
      ]
      ++ shells;
    pathsToLink = ["/share/zsh"];
    shellAliases =
      # {{{
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
        # nvi = ''${getExe' pkgs.zhuk.nvim-wrapped "nvim"} -u "${env.NH_FLAKE}/configs/nvim.lua"'';
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
        FZF_CTRL_R_OPTS = "--sort --exact";
        FZF_CTRL_T_COMMAND = "fd --type f";
        FZF_CTRL_T_OPTS = "--ansi --preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'";
      }
      # // (if !isDarwin then { MANROFFOPT = "-c"; } else { })
      ; # vvariables }}}
  };
}
