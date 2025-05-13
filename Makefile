# Connectivity info for Linux VM
NIXADDR ?= unset
NIXPORT ?= 22

NIXUSER ?= zhuher

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# Automatic system detection
UNAME := $(shell uname)
MACHINE := $(shell uname -m)
UNAME_A := $(shell uname -a)

ifeq ($(UNAME), Darwin)
    ifeq ($(MACHINE), arm64)
        NIXNAME := macbook-pro-m1
    else
        $(error Unsupported Darwin machine type: $(MACHINE))
    endif
else ifeq ($(UNAME), Linux)
    ifeq ($(MACHINE), x86_64)
        ifneq (,$(findstring WSL2,$(UNAME_A)))
            NIXNAME := wsl
        else
            NIXNAME := pc-amd64
        endif
    else
        $(error Unsupported Linux machine type: $(MACHINE))
    endif
else
    $(error Unsupported operating system: $(UNAME))
endif

print-nixname:
	@echo "Detected NIXNAME: $(NIXNAME)"
switch:
ifeq ($(UNAME), Darwin)
	nix build --impure --extra-experimental-features 'flakes nix-command' ".#darwinConfigurations.${NIXNAME}.system" --show-trace
	./result/sw/bin/darwin-rebuild switch --impure --flake "$$(pwd)#${NIXNAME}" --show-trace
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --impure --flake ".#${NIXNAME}" --show-trace
endif

check:
ifeq ($(UNAME), Darwin)
	nix build ".#darwinConfigurations.${NIXNAME}.system" -vvv
	./result/sw/bin/darwin-rebuild check --flake "$$(pwd)#${NIXNAME}" --verbose --show-trace
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild check --flake ".#$(NIXNAME)" --show-trace
endif

# This builds the given NixOS configuration and pushes the results to the
# cache. This does not alter the current running system. This requires
# cachix authentication to be configured out of band.
# cache:
# 	nix build '.#nixosConfigurations.$(NIXNAME).config.system.build.toplevel' --json \
# 		| jq -r '.[].outputs | to_entries[].value' \
# 		| cachix push mitchellh-nixos-config

# Build a WSL installer
.PHONY: wsl
wsl:
	 nix build ".#nixosConfigurations.wsl.config.system.build.tarballBuilder" --show-trace
