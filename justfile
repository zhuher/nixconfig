# NIXPORT := env('NIXPORT', "22")
NIXUSER := env('NIXUSER', "zhuher")
CONFIG_DIR := justfile_directory()
UNAME := `uname -a`
HOST := env('NIXHOST', if UNAME =~ ".*Darwin.*" {
             if shell("sysctl -na machdep.cpu.brand_string") =~ ".*M1.*" { "gandalf" }
             else { error("Unsupported Darwin!") }
         } else {
             if UNAME =~ "(?i).*wsl.*" { "wsl" }
             else { error("Unsupported system type!") }
         })
SYS := if UNAME =~ ".*Darwin.*" { "darwin" } else { "os" }
CONFIG := if UNAME =~ ".*Darwin.*" { "darwin" } else { "nixos" }
# shows this message
info:
    @echo "nh command       : {{SYS}}"
    @echo "uname            : {{UNAME}}"
    @echo "config directory : {{CONFIG_DIR}}"
    @echo "user             : {{NIXUSER}}"
    just --list
# applies current config onto the system
switch:
    nh "{{SYS}}" switch --impure --diff=always --cores="$(nproc)" "{{CONFIG_DIR}}#{{CONFIG}}Configurations.{{HOST}}" -- --override-input flake-path file+file://<(printf "{{CONFIG_DIR}}")
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
