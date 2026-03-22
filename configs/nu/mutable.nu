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
def "nu-complete zoxide path" [context: string] {
    let parts = $context | str trim --left | split row " " | skip 1 | each { str downcase }
    let completions = (
        ^zoxide query --list --exclude $env.PWD -- ...$parts
            | lines
            | each { |dir|
                if ($parts | length) <= 1 {
                    $dir
                } else {
                    let dir_lower = $dir | str downcase
                    let rem_start = $parts | drop 1 | reduce --fold 0 { |part, rem_start|
                        ($dir_lower | str index-of --range $rem_start.. $part) + ($part | str length)
                    }
                    {
                        value: ($dir | str substring $rem_start..),
                        description: $dir
                    }
                }
            })
    {
        options: {
            sort: false,
            completion_algorithm: substring,
            case_sensitive: false,
        },
        completions: $completions,
    }
}
def --env --wrapped cd [...rest: string@"nu-complete zoxide path"] {
  __zoxide_z ...$rest
}
let fish_completer = {|spans|
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
let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -o 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    match $spans.0 {
        launchctl => $fish_completer
        _ => $carapace_completer
    } | do $in $spans
}
$env.config = {
  show_banner: false,
  completions: {
    case_sensitive: false # case-sensitive completions
    quick: false    # set to false to prevent auto-selecting completions
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
