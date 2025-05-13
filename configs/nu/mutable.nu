alias c = clear
alias cd = z
alias nls = ls -a
$env.EDITOR = "nvim"
alias e = ^$env.EDITOR
$env.config.table.mode = "none"
alias ls = ^eza --all --bytes --smart-group --modified --oneline --long --classify=auto --colour=auto --icons=auto --hyperlink
alias lg = ^eza --all --bytes --smart-group --modified --oneline --long --classify=auto --colour=auto --icons=auto --hyperlink --git
alias lss = ^eza --all --bytes --smart-group --modified --oneline --long --classify=auto --colour=auto --icons=auto --hyperlink --sort=size
alias lsd = ^eza --all --bytes --smart-group --modified --oneline --long --classify=auto --colour=auto --icons=auto --hyperlink --sort=date
alias l = ^eza --all --oneline --classify=auto --colour=auto --icons=auto --hyperlink
# let carapace_completer = {|spans|
#   ^carapace $spans.0 nushell ...$spans | from json
# }
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
$env.config = {
  show_banner: false,
  completions: {
#     case_sensitive: false # case-sensitive completions
    quick: false    # set to false to prevent auto-selecting completions
    partial: true    # set to false to prevent partial filling of the prompt
    algorithm: "fuzzy"    # prefix or fuzzy
    external: {
#       # set to false to prevent nushell looking into $env.PATH to find more suggestions
      # enable: true 
#       # set to lower can improve completion performance at the cost of omitting some options
      max_results: 10000 
#       completer: $carapace_completer # check 'carapace_completer' 
    }
  }
}
source ./deosb.nu
