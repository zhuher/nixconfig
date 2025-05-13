#!/usr/bin/env zsh
local saved="$(cat ~/latest_date 2>/dev/null)"
local now="$(curl -s "https://steamdb.info/api/PatchnotesRSS/?appid=1086940" | grep -o '<pubDate>[^<]*</pubDate>' | sed -n '1s/.*<pubDate>\([^<]*\)<\/pubDate>.*/\1/p')" # returns Wed, 16 Oct 2024 11:34:43 +0000 as of 01-04-2025
tmux new-session -d -s bg3 2>/dev/null || true
local result
if [[ -n "$now" && "$now" != " " && "$saved" != "$now" ]]; then
  echo "$now" > ~/latest_date
  result="\033[32mNew patch found: $now\033[0m"
  osascript -e 'display alert "Новый патч!" message "Патч для Baldurs Gate 3 вышел!" as critical buttons { "OK" } default button "OK"' -e 'set response to button returned of the result' -e 'if response is "OK" then open location "https://steamdb.info/app/1086940/patchnotes/"' 2>/dev/null &
else
  result="\033[33mNo new patch\033[0m"
fi
tmux send-keys -t bg3 "echo -e '$(date): $result'" ENTER
