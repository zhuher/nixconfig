{
  lib,
  pkgs,
  config,
  isDarwin,
  currentSystemUser,
  ...
}: {
  hjem.users.${currentSystemUser} = let
    env = config.environment.variables;
    inherit (lib) getExe getExe';
    dig = getExe' pkgs.dnsutils "dig";
    LAPS =
      if isDarwin
      then "Library/Application Support"
      else ".config";
  in {
    enable = true;
    xdg.config.files = {
      "nushell/autoload/mutable.nu".source = "${config.zhuk.configRoot}/configs/nu/mutable.nu";
      "nushell/autoload/deosb.nu".source = "${config.zhuk.configRoot}/configs/nu/deosb.nu";
      "nushell/env.nu".text = ''
        const zhukcfg = $nu.default-config-dir
        # # just
        # if (not ($"($zhukcfg)/just.nu" | path exists)) {
        #   ${getExe pkgs.just} --completions nushell | save --force $"($zhukcfg)/just.nu"
        # }
        # # zoxide
        if (not ($"($zhukcfg)/zoxide.nu" | path exists)) {
          ${getExe pkgs.zoxide} init nushell | save --force $"($zhukcfg)/zoxide.nu"
        }
      '';
      "nushell/config.nu".text = ''
        def prepath [path: string] {
          $env.PATH | find -v $path | prepend $path
        }
        $env.PATH = prepath "/opt/homebrew/bin"
        $env.PATH = prepath "/opt/homebrew/sbin"
        $env.PATH = prepath "/Users/${currentSystemUser}/.nix-profile/bin"
        $env.PATH = prepath "/etc/profiles/per-user/${currentSystemUser}/bin"
        $env.PATH = prepath "/nix/var/nix/profiles/default/bin"
        $env.PATH = prepath "/run/current-system/sw/bin"
        ${lib.optionalString (!isDarwin) ''$env.PATH = prepath "${config.security.wrapperDir}" # has to be at the top of PATH''}
        ${getExe' pkgs.coreutils "dircolors"} --c-shell | parse "setenv {key} {val}" | transpose -rd | load-env
        $env.NH_FLAKE = "${env.NH_FLAKE}"
        $env.NIXPKGS_REV = "${env.NIXPKGS_REV}"
        if (not ($"($zhukcfg)/autoload" | path exists)) { mkdir $"($zhukcfg)/autoload" }
        # carapace
        $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
        if (not ($"($zhukcfg)/autoload/carapace.nu" | path exists)) {
          ${getExe pkgs.carapace} _carapace nushell | save --force $"($zhukcfg)/autoload/carapace.nu"
        }
        # source $"($zhukcfg)/just.nu"
        source $"($zhukcfg)/zoxide.nu"
        # https://github.com/bydmiller/nixos-configs/blob/6a7053f1e081c21cf4362724b57d3d70e63198ed/machines/nebula/homes/zsh/aliases.nix#L63-L64
        alias canihazip = ${dig} @resolver4.opendns.com myip.opendns.com +short
        alias canihazip4 = ${dig} @resolver4.opendns.com myip.opendns.com +short -4
        ${lib.optionalString isDarwin ''
          alias emg = ^open -a EmacsClient
        ''}
        $env.SHELL = "${getExe pkgs.nushell}"
        use std/config *
        # Initialize the PWD hook as an empty list if it doesn't exist
        $env.config.hooks.env_change.PWD = $env.config.hooks.env_change.PWD? | default []
        $env.config.hooks.env_change.PWD ++= [{||
          if (which direnv | is-empty) {
            # If direnv isn't installed, do nothing
            return
          }
          direnv export json | from json | default {} | load-env
          # If direnv changes the PATH, it will become a string and we need to re-convert it to a list
          $env.PATH = do (env-conversions).path.from_string $env.PATH
        }]
      '';
      "ghostty/config".source = "${config.zhuk.configRoot}/configs/ghostty";
      "sway/config".source = "${config.zhuk.configRoot}/configs/sway";
      "emacs/init.el".source = "${config.zhuk.configRoot}/configs/emacs/init.el";
      "emacs/early-init.el".source = "${config.zhuk.configRoot}/configs/emacs/early-init.el";
      "git/ignore".text = ''
        .DS_Store
      '';
      "git/config" = let
        delta = lib.getExe pkgs.delta;
      in {
        generator = (pkgs.formats.toml {}).generate "config";
        value =
          {
            alias = {
              log-pretty = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
              root = "rev-parse --show-toplevel";
            };
            http.postBuffer = 157286400;
            # branch.autosetuprebase = "always";
            color.ui = true;
            core.askPass = ""; # [INFO]: needs to be empty to use terminal for ask pass
            core.pager = delta;
            credential.helper = "store"; # [TODO]: make this more secure
            github.user = currentSystemUser;
            # push.default = "upstream";
            init.defaultBranch = "main";
            interactive.diffFilter = "${delta} --color-only";
            pull.rebase = true;
            rebase.autoStash = true;
            delta = {
              navigate = true;
              features = "decorations";
              line-numbers = true;
              side-by-side = true;
              # syntax-theme = "ansi";
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
          }
          // lib.optionalAttrs config.zhuk.git.secrets {
            include.path = config.sops.secrets.gitsecrets.path;
          };
      };
    };
    files =
      {
        ".bashrc".text = ''
          if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
            builtin source "''${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
          fi
        '';
        ".ssh/config".text =
          lib.optionalString
          isDarwin ''
            Host *
                IdentityAgent "${env.HOME}/Library/Group Containers/group.strongbox.mac.mcguill/agent.sock"
          ''
          + ''
            Host *
              IPQoS=cs1
              ForwardAgent no
              AddKeysToAgent no
              Compression no
              ServerAliveInterval 0
              ServerAliveCountMax 3
              HashKnownHosts yes
              UserKnownHostsFile ${env.HOME}/.ssh/known_hosts
              ControlMaster auto
              ControlPath ${env.HOME}/.ssh/master-%r@%n:%p
              ControlPersist no
              IdentitiesOnly yes
              HashKnownHosts yes
              IdentityFile ${env.HOME}/.ssh/gh.pub
              IdentityFile ${env.HOME}/.ssh/pers.pub
              IdentityFile ${env.HOME}/.ssh/misc.pub
              IdentityFile ${env.HOME}/.ssh/work.pub
            Include ${env.HOME}/.ssh/hosts
            Include ${env.HOME}/.ssh/mutable-config'';
      }
      // lib.optionalAttrs isDarwin {
        "LAPS".source = "${env.HOME}/${LAPS}";
        "${LAPS}/com.mitchellh.ghostty".source = "${env.HOME}/.config/ghostty";
        "${LAPS}/nushell".source = "${env.HOME}/.config/nushell";
      };
  };
}
