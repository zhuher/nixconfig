set shell := ["zsh", "-cu"]
NIXUSER := env('NIXUSER', `whoami`)
export NIX_CONFIG := "extra-experimental-features = nix-command flakes
extra-sandbox-paths = /usr/bin"
CONFIG_DIR := justfile_directory()
UNAME := `uname -a`
HOST := env('NIXHOST', `hostname`)
SYS := if UNAME =~ ".*Darwin.*" { "darwin" } else { "os" }
CONFIG := if UNAME =~ ".*Darwin.*" { "darwin" } else { "nixos" }
# shows this message
help:
    @echo "nh command       : {{SYS}}"
    @echo "uname            : {{UNAME}}"
    @echo "host             : {{HOST}}"
    @echo "config directory : {{CONFIG_DIR}}"
    @echo "user             : {{NIXUSER}}"
    @echo "config           : {{NIX_CONFIG}}"
    just --list
# updates inputs
upgrade *extra-args:
    nh "{{SYS}}" switch --impure -u --diff=always --cores="$(nproc)" "{{CONFIG_DIR}}#{{CONFIG}}Configurations.{{HOST}}" -- --override-input flake-path file+file://<(printf "{{CONFIG_DIR}}") {{extra-args}}
# applies current config onto the system
switch *extra-args:
    nh "{{SYS}}" switch --impure --diff=always --cores="$(nproc)" "{{CONFIG_DIR}}#{{CONFIG}}Configurations.{{HOST}}" -- --override-input flake-path file+file://<(printf "{{CONFIG_DIR}}") {{extra-args}}
# creates a .wsl builder
wsl:
    nix build "{{CONFIG_DIR}}#nixosConfigurations.{{HOST}}.config.system.build.tarballBuilder" --show-trace --override-input flake-path file+file://<(printf "{{CONFIG_DIR}}")
# opens $EDITOR in config dir
edit:
  $EDITOR ./
# updates devshells
update-shells:
    for shell in ./shells/*; do { pushd "$shell"; nix flake update --flake ./.devenv --override-input nixpkgs nixpkgs --override-input zig-overlay zig-overlay; popd; } done
# garbage collection
clean:
    nh clean all
