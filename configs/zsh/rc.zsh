# shellcheck=zsh
eval "$($DIRCOLORS_EXE)"
HELPLDIR="$ZSH_DIR/share/zsh/$ZSH_VERSION/help"
path+="$ZSH_FZF_TAB_DIR/share/fzf-tab"
fpath+="$ZSH_FZF_TAB_DIR/share/fzf-tab"
fpath+="$NH_FLAKE/configs/zsh/comp"

autoload -Uz compinit
mkdir -p $XDG_CACHE_HOME/zsh
source "$NH_FLAKE/configs/zsh/comp.zsh"

if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  autoload -Uz -- "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
  ghostty-integration
  unfunction ghostty-integration
fi
fpath+="$ZIG_SHELL_COMPLETIONS_DIR/share/zsh/site-functions"

if [[ -n $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION(#qN.mh+24) ]]; then
  compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
else
  compinit -C
fi

eval "$($ZOXIDE_EXE init zsh)"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,underline"
ZSH_AUTOSUGGEST_STRATEGY=(history)

source $ZSH_FZF_TAB_DIR/share/fzf-tab/fzf-tab.plugin.zsh

source $ZSH_AUTOSUGGESTIONS_DIR/share/zsh-autosuggestions/zsh-autosuggestions.zsh

source $ZSH_FAST_SYNTAX_HIGHLIGHTING_DIR/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

setopt nullglob
e() { $EDITOR $@ }
HISTORY_SUBSTRING_SEARCH_FUZZY=1
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=10,underline,bg=8"
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="fg=9,underline,bg=8"
[ -n "$EAT_SHELL_INTEGRATION_DIR" ] && source "$EAT_SHELL_INTEGRATION_DIR/zsh"
alias latesthash='curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | jq -r ".data.result[] | select(.metric.channel==\"nixpkgs-unstable\") | .metric.revision"' # gets the latest cached revision of nixpkgs (https://github.com/dmadisetti/.dots/blob/7ddf08934d45da00a471f42cb2d13cf3a8f5ed9c/dot/config/fish/functions/update.fish#L4)
unescape() { echo $1 | sed -E "s/[ ]*[+,][ ]*/+/g;s/[ -]+/-/g;s/[][)(]//g" }
torsend() {
    local newname="$(unescape $1)";
    mv $1 $newname;
    echo ${newname:t}
    ((rsync -aLPuv $newname ZHUKOMPUTER-WSL:/mnt/d/torrents/.torrents && ssh ZHUKOMPUTER-WSL "qbt torrent add file /mnt/d/torrents/.torrents/${newname:t} --folder=D:/torrents/") && ssh ZHUKOMPUTER-WIN "sys disks") && rm $newname;
}
offfocusloss() { printf "\e[?1004l" }
deluks() { if [[ "$1" = "l" ]]; then ssh INITRDL; else ssh INITRD; fi }
autoload -z edit-command-line
zle -N edit-command-line
bindkey -e
bindkey "^X^E" edit-command-line
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
n() {
  pushd $NH_FLAKE >/dev/null
  just $@
  popd >/dev/null
}
docerts() {
  pushd "$HOME" >/dev/null
  security export -t certs -f pemseq -k /Library/Keychains/System.keychain -o /tmp/certs-system.pem
  security export -t certs -f pemseq -k /System/Library/Keychains/SystemRootCertificates.keychain -o /tmp/certs-root.pem
  cat /tmp/certs-root.pem "$HOME"/tinkoff-root.crt /tmp/certs-system.pem > "$1"
  popd >/dev/null
}
bytes-me-to-uuid() {
  print "$@" | awk '{ print $4$3$2$1 "-" $6$5 "-" $8$7 "-" $9$10 "-" $11$12$13$14$15$16 }'
}
uuid-to-bytes-me() {
  printf "$@" | sed 's/-//g;s/../& /g' | awk '{ print toupper($4" "$3" "$2" "$1" "$6" "$5" "$8" "$7" "$9" "$10" "$11" "$12" "$13" "$14" "$15" "$16) }'
}
win2lin() {
  ssh WINDOWSL 'bcdedit /set {fwbootmgr} bootsequence {fbdc8c86-3b1e-11f1-b08e-806e6f6e6963}; shutdown /r /t 0'
}
lin2win() {
  ssh CELEBRIMBORL -t 'sudo efibootmgr -n 0000; sudo reboot now'
}
# sudo NIX_CONFIG="extra-experimental-features = nix-command flakes" nix run github:nix-community/disko -- --mode mount nixconfig/nix/machine/celebrimbor/disko.nix
# NIX_CONFIG="extra-experimental-features = nix-command flakes" nix run develop nixconfig/shells/.nix
# NIX_CONFIG="extra-experimental-features = nix-command flakes" nix shell nixpkgs#chntpw nixpkgs#hivex nixpkgs#delta nixpkgs#ripgrep nixpkgs#fd nixpkgs#bat
# printf "/home/zhuher/nixconfig" > le; sudo nixos-install --no-bootloader --no-root-password --flake ./nixconfig#celebrimbor --override-input flake-path file+file:///home/nixos/le
# nixos-install --no-bootloader --no-root-password --flake nixconfig#celebrimbor
colortest() {
    local color escapes intensity style
    echo "NORMAL bold  dim   itali under rever strik  BRIGHT bold  dim   itali under rever strik"
    for color in $(seq 0 7); do
	for intensity in 3 9; do  # normal, bright
	    escapes="${intensity}${color}"
	    printf '\e[%sm\\e[%sm\e[0m ' "$escapes" "$escapes" # normal
	    for style in 1 2 3 4 7 9; do  # bold, dim, italic, underline, reverse, strikethrough
		escapes="${intensity}${color};${style}"
		printf '\e[%sm\\e[%sm\e[0m ' "$escapes" "$style"
	    done
	    echo -n " "
	done
	echo
    done;
    printf "%s\n%s\n" "$(for c in {0..7}; do
      print -P -n - "%F{$c}%f%K{$c}${(r(2)( ))c}%k%F{$c}%f"
    done)" "$(for c in {8..15}; do
      print -P -n - "%F{$c}%f%K{$c}${(r(2)( ))c}%k%F{$c}%f"
    done)"
    echo -n "TRUECOLOR "
    awk 'BEGIN{
	columns = 78;
	step = columns / 6;
	for (hue = 0; hue<columns; hue++) {
	  x = (hue % step) * 255 / step;
          if (hue < step) {
	    r = 255; g = x; b = 0;
	  } else if (hue < step*2) {
	    r = 255-x; g = 255; b = 0;
	  } else if (hue < step*3) {
	    r = 0; g = 255; b = x;
	  } else if (hue < step*4) {
	    r = 0; g = 255-x; b = 255;
	  } else if (hue < step*5) {
	    r = x; g = 0; b = 255;
	  } else {
	    r = 255; g = 0; b = 255-x;
	  }
	  printf "\033[48;2;%d;%d;%dm", r, g, b;
	  printf "\033[38;2;%d;%d;%dm", 255-r, 255-g, 255-b;
	  printf " \033[0m";
        }
	printf "\n";
      }'
}
HISTSIZE=9999999999
HISTFILE="$ZDOTDIR/hist"
SAVEHIST=9999999999
mkdir -p "$(dirname "$HISTFILE")"
chmod 600 "$HISTFILE"
setopt HIST_FCNTL_LOCK APPEND_HISTORY HIST_IGNORE_DUPS
unsetopt HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE HIST_EXPIRE_DUPS_FIRST SHARE_HISTORY EXTENDED_HISTORY
if [[ $options[zle] = on ]]; then
  source <($FZF_EXE --zsh)
fi
source $ZSH_HISTORY_SUBSTRING_SEARCH_DIR/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down
ed() { pushd "$($ZOXIDE_EXE query $1)"; $EDITOR; popd }
if (( ! ${+NONU} )); then
  export NONU=1
  exec nu -il
else
  return  # or exit 0
fi
