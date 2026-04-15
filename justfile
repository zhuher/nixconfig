set shell := ["zsh", "-cu"]

NIXUSER := env('NIXUSER', `whoami`)

CONFIG_DIR := env('NH_FLAKE', justfile_directory())

UNAME := `uname -a`
HOST := env('NIXHOST', `hostname`)

DARWIN := if UNAME =~ ".*Darwin.*" { "1" } else { "0" }

SYS := if DARWIN == "1" { "darwin" } else { "os" }

CONFIG := if DARWIN == "1" { "darwin" } else { "nixos" }

NIX_SPEC := env('NIX_SPEC', "nahhh")
SPEC := if NIX_SPEC != "nahhh" { "-s " + NIX_SPEC } else { "" }

export NIX_CONFIG := "extra-experimental-features = nix-command flakes"\
  + if DARWIN == "1" { "
extra-sandbox-paths = /usr/bin/codesign" } else { "
" }

# shows this message
help:
    @echo "nh command       : {{SYS}}"
    @echo "uname            : {{UNAME}}"
    @echo "host             : {{HOST}}"
    @echo "config directory : {{CONFIG_DIR}}"
    @echo "user             : {{NIXUSER}}"
    @echo "config           : {{NIX_CONFIG}}"
    @echo "{{ if DARWIN == "1" { "we be darwin" } else { "we be linux" } }}"
    just --list
# updates inputs
update *inputs:
    nix flake update {{inputs}}
# updates inputs and switches
upgrade *extra-args:
    nh "{{SYS}}" switch --impure -u --diff=always --cores="$(nproc)" "{{CONFIG_DIR}}#{{CONFIG}}Configurations.{{HOST}}" -- --override-input flake-path file+file://<(printf "{{CONFIG_DIR}}") {{extra-args}}
# builds current
build *extra-args:
    nh "{{SYS}}" build --impure --diff=always --cores="$(nproc)" "{{CONFIG_DIR}}#{{CONFIG}}Configurations.{{HOST}}" -- --override-input flake-path file+file://<(printf "{{CONFIG_DIR}}") {{extra-args}}
# applies current config onto the system(extra args for nh)
nswitch *extra-args:
    nh "{{SYS}}" switch {{extra-args}} --impure --diff=always --cores="$(nproc)" "{{CONFIG_DIR}}#{{CONFIG}}Configurations.{{HOST}}" -- --override-input flake-path file+file://<(printf "{{CONFIG_DIR}}")
# applies current config onto the system
switch *extra-args:
    nh "{{SYS}}" switch {{ if DARWIN != "1" { SPEC } else { "" } }} --impure --diff=always --cores="$(nproc)" "{{CONFIG_DIR}}#{{CONFIG}}Configurations.{{HOST}}" -- --override-input flake-path file+file://<(printf "{{CONFIG_DIR}}") {{extra-args}}
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
