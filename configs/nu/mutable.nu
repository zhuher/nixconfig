ulimit -n 65535
alias c = clear
$env.EDITOR = "nvim"
alias e = ^$env.EDITOR
$env.config.table.mode = "none"
alias ls = ls -a
alias eza = ^eza --all --bytes --smart-group --modified --oneline --long --classify=auto --colour=auto --icons=auto --hyperlink
alias ezag = ^eza --all --bytes --smart-group --modified --oneline --long --classify=auto --colour=auto --icons=auto --hyperlink --git
alias ezas = ^eza --all --bytes --smart-group --modified --oneline --long --classify=auto --colour=auto --icons=auto --hyperlink --sort=size
alias ezad = ^eza --all --bytes --smart-group --modified --oneline --long --classify=auto --colour=auto --icons=auto --hyperlink --sort=date
alias ez = ^eza --all --oneline --classify=auto --colour=auto --icons=auto --hyperlink
alias jjl = jj log --limit=10 --no-pager
alias jjgf = jj git fetch --all-remotes
module "awg-quick extern" {
  def complete_tunnel [] {
    nls /var/run/amneziawg/*.name
                            | get name
                            | path parse
                            | get stem
  }
  def complete_config [] {
    nls /usr/local/etc/amnezia/amneziawg/*.conf
                                         | get name
                                         | path parse
                                         | get stem
  }
  export extern "awg-quick down" [
    tunnel: string@complete_tunnel # Config name to set up a tunnel with
  ]
  export extern "awg-quick up" [
    conf: string@complete_config # Config name to set up a tunnel with
  ]
}
use "awg-quick extern" "awg-quick up"
use "awg-quick extern" "awg-quick down"
alias "aa up" = awg-quick up
alias "aa down" = awg-quick down
def "nu-complete nixconfig" [context: string] {
    do $env.config.completions.external.completer ($context | str trim --left | split row " " | skip 1 | prepend $"--justfile=($env.NH_FLAKE)/justfile" | prepend just)
}
def n [...rest: string@"nu-complete nixconfig"] {
  ^just $"--justfile=($env.NH_FLAKE)/justfile" ...$rest
}
def "nu-complete cd" [context: string] {
    do $env.config.completions.external.completer ($context | str trim --left | split row " " | skip 1 | prepend cd)
}
def --env --wrapped cd [...rest: string@"nu-complete cd"] {
  z ...$rest
}
let fish_completer = {|spans: list<string>|
    fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
    | from tsv --flexible --noheaders
    | rename value description
    | update value {|row|
      let value = $row.value
      let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
      if ($need_quote and ($value | path exists)) {
        let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
        $'"($expanded_path | str replace --all "\"" "\\\"")"'
      } else {$value}
    }
}
let carapace_completer = {|spans: list<string>|
    CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
}
let external_completer = {|spans: list<string>|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -o 0.expansion

    let spans = (if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }) | match $in.0 {
      ',' => ($spans | skip)
      _ => $spans
    }

    match $spans.0 {
        launchctl
        | sops
        | jj
        => $fish_completer
        _ => $carapace_completer
    } | do $in $spans
}
def latesthash [] {
  curl -sL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" | from json | get data.result.metric | where {|m| $m.channel == "nixpkgs-unstable"} | get revision.0
}
def update-nixpkgs [] {
  use std/dirs
  dirs add $env.NH_FLAKE
  sed -i $"s/($env.NIXPKGS_REV)/(latesthash)/g" ...(glob -D ./**/*.nix)
  dirs drop
}
$env.PROMPT_COMMAND_RIGHT = { $'(if (($env.CMD_DURATION_MS | into int) > 10) { $"\(⌛️(($env.CMD_DURATION_MS | into float) / 1000)) " } else "")(date now | format date "%H:%M:%S@%Y-%m-%d")' }
$env.config = {
  show_banner: false,
  completions: {
    case_sensitive: false # case-sensitive completions
    quick: true    # set to false to prevent auto-selecting completions
    partial: true    # set to false to prevent partial filling of the prompt
    algorithm: "fuzzy"    # prefix or fuzzy
    external: {
      # set to false to prevent nushell looking into $env.PATH to find more suggestions
      enable: true
      # set to lower can improve completion performance at the cost of omitting some options
      # max_results: 10000
      completer: $external_completer
    }
  }
}
source ./deosb.nu
