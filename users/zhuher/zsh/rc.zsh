# shellcheck=zsh
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
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
n() {
  pushd $NH_FLAKE >/dev/null
  just $1
  popd >/dev/null
}
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
