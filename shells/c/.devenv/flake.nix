{
  description = "A Nix-flake-based C/C++/Zig development environment";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/76eec3925eb9bbe193934987d3285473dbcfad50";
  outputs = {nixpkgs, ...} @ inputs: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (
        system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = with inputs; [
              ];
            };
          }
      );
  in {
    packages = forEachSupportedSystem (
      {pkgs}: {
        default = pkgs.mkShellNoCC {
          shellHook = ''
            export ZIG_GLOBAL_CACHE_DIR="$(pwd)/.direnv/zig-cache"
            export SHELL_PKGS_REV=76eec3925eb9bbe193934987d3285473dbcfad50
          '';
          packages = with pkgs; let
            sdk = "${apple-sdk_15}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk";
            warningOpts = "-Wno-typedef-redefinition -Wno-newline-eof -Wno-nullability-extension -Wno-strict-prototypes -Wno-macro-redefined -Wno-deprecated-declarations -Wno-undef -Wno-tautological-compare -Wno-documentation -Wno-documentation-unknown-command -Wno-nullability-completeness -Wno-date-time -Wno-unknown-warning-option -Wno-availability"; # cleans up the system header inclusion warnings
            includeOpts = "-I${sdk}/usr/include -L${sdk}/usr/lib -F${sdk}/System/Library/Frameworks";
            cOpts = "-O3 -march=native -Xclang -Ofast ${warningOpts} ${includeOpts}";
            mkCZigWrapper = name: tool: opts:
              writeShellScriptBin "${name}" ''exec -a zig zig ${tool} $@ ${opts}'';
          in
            [
              zig
              zls
              subunit
              lcov
              check
              git
              (writeShellScriptBin "testarg" ''exec printf "$0"'')
            ]
            ++ builtins.map (name: mkCZigWrapper name "cc" "${cOpts}") [
              "cc"
              "clang"
              "gcc"
            ]
            ++ builtins.map (name: mkCZigWrapper name "c++" "${cOpts}") [
              "clang"
              "c++"
              "g++"
            ];
        };
      }
    );
  };
}
