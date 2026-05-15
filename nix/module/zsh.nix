{
  lib,
  pkgs,
  currentSystemUser,
  isWSL,
  ...
}: {
  programs.zsh = let
    inherit (lib) getExe getExe';
    inherit (pkgs) steamcmd coreutils;
  in {
    loginShellInit = lib.mkOrder 69420 /*goes after everything nix*/ ''
      return 0
    '';
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
        getip() { ip r | rg 'link src' | awk '{ print $9 }' }
      '';
    interactiveShellInit = with pkgs; ''
      export DIRCOLORS_EXE="${getExe' coreutils "dircolors"}"
      export ZSH_DIR="${zsh}"
      export ZIG_SHELL_COMPLETIONS_DIR="${zig-shell-completions}"
      export ZSH_AUTOSUGGESTIONS_DIR="${zsh-autosuggestions}"
      export ZSH_FAST_SYNTAX_HIGHLIGHTING_DIR="${zsh-fast-syntax-highlighting}"
      export ZSH_HISTORY_SUBSTRING_SEARCH_DIR="${zsh-history-substring-search}"
      [[ "$USER" == "${currentSystemUser}" ]] && { source "$NH_FLAKE/configs/zsh/rc.zsh"; source ${grc + "/etcaboa/grc.zsh"} }
      ${lib.optionalString isWSL ''
        macgame2dir() { ${getExe steamcmd} +force_install_dir "$2" +@sSteamCmdForcePlatformType macos +login mrtoster007 +app_update "$1" +quit }
        bg2dir() { macgame2dir 1086940 "$1" }
      ''}
    '';
  };
}
