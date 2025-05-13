devenv() { echo use flake "/Users/zhuher/nixconfig#templates.$1" >> .envrc && direnv allow; }
devinit() { nix flake init -t "/Users/zhuher/nixconfig#templates.$1" && (printf 'export NIXPKGS_ALLOW_UNFREE=1\nuse flake .\n' >> .envrc && (e .envrc && (e flake.nix && direnv allow))); }
nixsh() {
    local ARRAY=($@)
    ARRAY=('nixpkgs#'$^ARRAY)
    [[ ! -z $NIXSHELLS ]] && local TEMPNIXSTR="$NIXSHELLS: $@" || local TEMPNIXSTR="$@"
    NIXSHELLS=$TEMPNIXSTR nix shell $ARRAY
}
torsend() {
    local newname="$(echo "$1" | sed -E "s/] /-/g;s/ \+/+/g;s/\+ /+/g;s/) | +/-/g;s/[[(,']//g;s/]//g;")";
    mv "$1" "$newname";
    (rsync --remove-source-files -aLPuv "$newname" ZHUKOMPUTER-WSL:/mnt/d/torrents/.torrents && ssh ZHUKOMPUTER-WSL "qbt torrent add file /mnt/d/torrents/.torrents/$newname --folder=D:/torrents/") && ssh ZHUKOMPUTER-WIN "sys disks";
}
list-torrents() {
    ssh ZHUKOMPUTER-WSL "nu -c 'qbt torrent list --format=json | from json | select added_on name ratio total_size size state uploaded uploaded_session | into filesize total_size size uploaded uploaded_session | format filesize GB total_size size uploaded uploaded_session | insert added_on_hr { |row| \$row.added_on * 1000000000 } | into datetime added_on_hr | reject added_on | rename --column { added_on_hr: added_on } | sort-by added_on | table -w $COLUMNS'"
}
gitignore() {
    curl -sL https://www.gitignore.io/api/"$1"
}
dotors() {
    dir="$(pwd)"
    cd "/Users/zhuher/Downloads/"
    for filename in ./*.torrent; do
	  torsend "$(basename "$filename")"
    done
    cd "$dir"
}
latesthash() { curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | jq -r ".data.result[] | select(.metric.channel==\"nixpkgs-unstable\") | .metric.revision" }
update() { nixfmt ./**/*.nix && git diff -- . ':!*.lock' ':!**/hist' && make switch && jj desc && jjb "$1" && jjp "$1" }
jjb() { jj bookmark set "$1" }
jjp() { jj git push --bookmark="$1" --remote=origin }
jjn() { jj new }
jjnb() { jj new "$1" }
bricklaptop() {
      sudo nvram auto-boot=%00 #A great trick to facilitate keyboard cleaning :^)
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
e() { $EDITOR "$@" }
