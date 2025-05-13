#!/usr/bin/env zsh
local saved="$(cat ~/latest_date)"
local now="$(curl -s "https://steamdb.info/api/PatchnotesRSS/?appid=1086940" | grep -o '<pubDate>[^<]*</pubDate>' | sed -n '1s/.*<pubDate>\([^<]*\)<\/pubDate>.*/\1/p')" # returns Wed, 16 Oct 2024 11:34:43 +0000 as of 01-04-2025
tmux new-session -d -s bg3
local result
if [[ -n "$now" && "$now" != " " && "$saved" != "$now" ]]; then
  echo "$now" > ~/latest_date
  result="\033[32mNew patch found: $now\033[0m"
  tmux send-keys -t bg3 "/etc/profiles/per-user/zhuher/bin/steamcmd +force_install_dir /mnt/d/BG +@sSteamCmdForcePlatformType macos +login mrtoster007 +app_update 1086940 +quit" ENTER
else
  result="\033[33mNo new patch\033[0m"
fi
tmux send-keys -t bg3 "echo -e '$(date): $result'" ENTER
