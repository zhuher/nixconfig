{
  description = "LMAO TOP TEXT";
  # inputs {{{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/76eec3925eb9bbe193934987d3285473dbcfad50";
    nixos-wsl = {
      # {{{
      # Build a custom WSL installer
      url = "github:nix-community/NixOS-WSL"; # "/bc827c2924c46f2344d3168fd82c6711aaceb610"; # next commit broke mount root regex check
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    sops-nix = {
      # {{{
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    # darwinoids {{{
    nix-darwin = {
      # {{{
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle = {
      # {{{
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    }; # }}}
    homebrew-core = {
      # {{{
      url = "github:homebrew/homebrew-core";
      flake = false;
    }; # }}}
    homebrew-cask = {
      # {{{
      url = "github:homebrew/homebrew-cask";
      flake = false;
    }; # }}} # darwinoids }}}
    nfp = {
      # {{{
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nix-index-database = {
      # {{{
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    zig-overlay = {
      # {{{
      url = "github:bandithedoge/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # }}}
    lix = {
      # {{{
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    }; # }}}
    lix-module = {
      # {{{
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    }; # }}}
    gwfox = {
      # {{{
      url = "github:akkva/gwfox";
      flake = false;
    }; # }}}
    flake-path = {
      # {{{
      url = "file+file:///dev/null"; # needs to be overriden
      flake = false;
    }; # }}}
    xsb = {
      url = "github:zhuher/xStarbound/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  # inputs }}}
  outputs = {nixpkgs, ...} @ inputs: let
    # overlays {{{
    overlays = [
      inputs.emacs-overlay.overlays.default
      inputs.neovim-nightly-overlay.overlays.default
      inputs.sops-nix.overlays.default
      inputs.zig-overlay.overlays.default
      inputs.lix-module.overlays.default
      # custom overlays {{{
      (
        final: _prev: {
          # wrappers {{{
          # bat {{{
          bat-wrapped = with final;
            symlinkJoin {
              name = "bat-wrapped";
              paths = [bat];
              nativeBuildInputs = [makeBinaryWrapper];
              postBuild = ''
                wrapProgram $out/bin/bat --set-default \
                BAT_CONFIG_PATH ${pkgs/bat/config}
              '';
            };
          # bat }}}
          # tmux {{{
          tmux-wrapped = with final;
            symlinkJoin {
              name = "tmux";
              paths = [tmux];
              nativeBuildInputs = [makeBinaryWrapper];
              postBuild = ''
                wrapProgram $out/bin/tmux \
                --add-flags '-f' \
                --add-flags \
                ${pkgs/tmux/tmux.conf}
              '';
            };
          # tmux }}}
          # nvim {{{
          nvim-wrapped = with final;
            symlinkJoin {
              name = "nvim";
              paths = [neovim-unwrapped];
              nativeBuildInputs = [makeBinaryWrapper];
              buildInputs = [git lua-language-server];
              postBuild = ''
                wrapProgram $out/bin/nvim \
                --add-flags '-u' \
                --add-flags '${pkgs/nvim/init.lua}'
              '';
            };
          # nvim }}}
          # wrappers }}}
          # ccache configuration {{{
          ccacheWrapper = _prev.ccacheWrapper.override {
            extraConfig = ''
              export CCACHE_COMPRESS=1
              export CCACHE_SLOPPINESS=random_seed
              export CCACHE_DIR="/nix/var/cache/ccache"
              export CCACHE_UMASK=007
              if [ ! -d "$CCACHE_DIR" ]; then
                echo "====="
                echo "Directory '$CCACHE_DIR' does not exist"
                echo "Please create it with:"
                echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
                echo "  sudo chown root:nixbld '$CCACHE_DIR'"
                echo "====="
                exit 1
              fi
              if [ ! -w "$CCACHE_DIR" ]; then
                echo "====="
                echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
                echo "Please verify its access permissions"
                echo "====="
                exit 1
              fi
            '';
          };
          # ccache configuration }}}
          # linkFiles {{{
          # turns a list of [ [ "srcPath1" "dstPath1" ] [ "srcPath2" "dstPath2" ] ] into a mkdir and ln of dst to src script
          linkFiles = fileList:
            builtins.concatStringsSep "" (builtins.map (lk: let
              src = builtins.elemAt lk 0;
              dst = builtins.elemAt lk 1;
              ln = final.lib.getExe' final.coreutils "ln";
              mkdir = final.lib.getExe' final.coreutils "mkdir";
              dirname = final.lib.getExe' final.coreutils "dirname";
            in
              final.zhuk.notify "Populating ${dst}" ''${mkdir} -pv "$(${dirname} -- "${dst}")" && ${ln} -fsv "${src}" "${dst}"'')
            fileList);
          # }}}
          # syncthing {{{
          syncthing = final.callPackage (
            {
              lib,
              fetchurl,
              stdenvNoCC,
              go,
              apple-sdk_15,
              darwin,
              zig,
              writeShellScriptBin,
            }: let
              pname = "syncthing";
              version = "2.0.12";
              sysroot = "${apple-sdk_15}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk";
              zigbin = lib.getExe' zig "zig";
              zigargs =
                if stdenvNoCC.isDarwin
                then "${zigbin} cc -O3 -march=native -I${sysroot}/usr/include -L${sysroot}/usr/lib -L${darwin.libresolv}/lib -F${sysroot}/System/Library/Frameworks -Wno-typedef-redefinition -Wno-newline-eof -Wno-nullability-extension -Wno-strict-prototypes -Wno-macro-redefined -Wno-deprecated-declarations -Wno-undef -Wno-tautological-compare -Wno-documentation -Wno-documentation-unknown-command -Wno-nullability-completeness -Wno-date-time -Wno-unknown-warning-option -Wno-availability -Wno-overriding-deployment-version -Xclang -Ofast"
                else "${zigbin} cc";
              zigc = writeShellScriptBin "clang" ''
                exec -a ${zigbin} ${zigargs} $@
              '';
            in
              stdenvNoCC.mkDerivation {
                inherit pname version;

                strictDeps = true;

                nativeBuildInputs = [
                  zigc
                  go
                ];

                src = fetchurl {
                  url = "https://github.com/syncthing/syncthing/releases/download/v${version}/syncthing-source-v${version}.tar.gz";
                  sha256 = "sha256-VgBK5tl0qjh8PGpzTrmKr9XWFZ/GV6H0xhjgsYFPra4=";
                };

                buildPhase = ''
                  runHook preBuild
                  # We change HOME to a writable location to avoid this error during the build: failed to initialize build cache at /homeless-shelter/Library/Caches/go-build: mkdir /homeless-shelter: operation not permitted
                  HOME=$TMPDIR
                  CGO_ENABLED=1
                  go run build.go build
                  go run build.go install
                  runHook postBuild
                '';

                installPhase = ''
                  runHook preInstall

                  mkdir -p $out/bin
                  cp ./bin/${pname} $out/bin/

                  runHook postInstall
                '';

                meta = {
                  description = "Open Source Continuous File Synchronization";
                  homepage = "https://github.com/syncthing/syncthing";
                  license = lib.licenses.gpl3;
                  maintainers = with lib.maintainers; [zhuher];
                  mainProgram = "syncthing";
                  platforms = lib.platforms.darwin;
                  sourceProvenance = with lib.sourceTypes; [fromSource];
                };
              }
          ) {inherit (final) zig;};
          # syncthing }}}
          zig = final.zigpkgs."0_15_2";
          inherit (final.zigpkgs."0_15_2") zls;
          zhuk = {
            # notify {{{
            # Simple notification function for shell scripts
            notify = msg: body: ''
              echo -e "\033[34m${msg}...\033[0m"
              ${body}
              echo -e "\033[32m${msg}... Done.\033[0m"
            '';
            # notify }}}
            # alex313031-codium {{{
            alex313031-codium = final.callPackage ({
              lib,
              fetchurl,
              stdenv,
              _7zz,
            }: let
              pname = "codium";
              version = "1.93.1.24277";
            in
              stdenv.mkDerivation ({
                }
                // {
                  inherit pname version;

                  src =
                    fetchurl
                    {
                      "aarch64-darwin" = {
                        url = "https://github.com/Alex313031/codium/releases/download/${version}/Codium_macos_${version}_arm64.dmg";
                        sha256 = "sha256-aA1tDJVwEI8tvOJXm7jBf6rbVoWX9RFWUAw2jmpbm+I=";
                      };
                    }."${stdenv.hostPlatform.system}";

                  nativeBuildInputs = {"aarch64-darwin" = [_7zz];}."${stdenv.hostPlatform.system}";

                  sourceRoot = {"aarch64-darwin" = "Codium.app";}."${stdenv.hostPlatform.system}";
                  unpackPhase =
                    {
                      "aarch64-darwin" = ''
                        runHook preUnpack
                        ${lib.getExe _7zz} e -spf2 -snld -i!Codium.app "$src"
                        runHook postUnpack
                      '';
                    }."${stdenv.hostPlatform.system}";

                  installPhase =
                    {
                      "aarch64-darwin" = ''
                        runHook preInstall

                        mkdir -p "$out/Applications/Codium.app" $out/bin
                        cp -R . "$out/Applications/Codium.app"
                        ln -s {../Applications/Codium.app/Contents/Resources/app/bin,$out/bin}/codium

                        runHook postInstall
                      '';
                    }."${stdenv.hostPlatform.system}";

                  meta = {
                    description = "VSCodium Fork with Compiler Optimizations, better Logo, and Windows 7/8/8.1 Support!";
                    homepage = "https://thorium.rocks/codium/";
                    license = lib.licenses.bsd3;
                    maintainers = with lib.maintainers; [zhuher];
                    mainProgram = "codium";
                    platforms = lib.platforms.darwin;
                    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
                  };
                })) {};
            # alex313031-codium }}}
            # ghostty {{{
            ghostty = final.callPackage ({
              lib,
              fetchurl,
              stdenv,
              _7zz,
            }: let
              pname = "ghostty-darwin";
              version = "tip";
            in
              stdenv.mkDerivation {
                inherit pname version;
                src = fetchurl {
                  url = "https://github.com/ghostty-org/ghostty/releases/download/${version}/Ghostty.dmg";
                  sha256 = "sha256-AXGwsOdJNywZShycjv8PY2QTZUNHn0lxFpKQN4Y7nwc=";
                };

                outputs = [
                  "out"
                  "terminfo"
                ];

                nativeBuildInputs = [_7zz];

                sourceRoot = "Ghostty.app";

                unpackPhase = ''
                  runHook preUnpack
                  ${lib.getExe _7zz} e -spf2 -snld -i!Ghostty.app "$src"
                  runHook postUnpack
                '';

                installPhase = ''
                  runHook preInstall

                  mkdir -p $out/Applications/Ghostty.app $out/bin
                  cp -R . $out/Applications/Ghostty.app
                  ln -s $out/Applications/Ghostty.app/Contents/MacOS/ghostty $out/bin

                  runHook postInstall
                '';
                postInstall = ''
                  mkdir -p $out/nix-support $terminfo/share
                  cp -R $out/Applications/Ghostty.app/Contents/Resources/terminfo $terminfo/share/
                  echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
                '';

                meta = {
                  mainProgram = "Ghostty.app";
                  homepage = "https://ghostty.org/";
                  description = "Ghostty is a fast, feature-rich, and cross-platform terminal emulator that uses platform-native UI and GPU acceleration.";
                  longDescription = ''
                    Ghostty is a terminal emulator that differentiates
                    itself by being fast, feature-rich, and native. While
                    there are many excellent terminal emulators available,
                    they all force you to choose between speed, features,
                    or native UIs. Ghostty provides all three.
                  '';
                  platforms = with lib.platforms; darwin;
                  changelog = "https://ghostty.org/docs/install/release-notes/${
                    builtins.replaceStrings ["."] ["-"] version
                  }";
                  license = lib.licenses.gpl3Only;
                  maintainers = with lib.maintainers; [
                    zhuher
                  ];
                  outputsToInstall = [
                    "out"
                    "terminfo"
                  ];
                };
              }) {};
            # ghostty }}}
            # thorium-browser {{{
            thorium-browser = final.callPackage ({
              lib,
              fetchurl,
              stdenv,
              undmg,
            }: let
              pname = "thorium-browser";
              version = "130.0.6723.174";
            in
              stdenv.mkDerivation {
                inherit pname version;

                src = fetchurl {
                  url = "https://github.com/Alex313031/Thorium-MacOS/releases/download/M${version}/Thorium_MacOS_ARM.dmg";
                  sha256 = "sha256-uhxFpSlixffZspN1exynRWFx4kCSfDDc2vf9SNLcjAQ=";
                };

                nativeBuildInputs = [undmg];

                sourceRoot = "Thorium.app";

                installPhase = ''
                  runHook preInstall

                  mkdir -p "$out/Applications/Thorium.app" $out/bin
                  cp -R . "$out/Applications/Thorium.app"
                  ln -s ../Applications/Thorium.app/Contents/MacOS/Thorium $out/bin

                  runHook postInstall
                '';

                meta = {
                  description = "Thorium, the best Chromium fork, by Alex313031";
                  homepage = "https://thorium.rocks";
                  license = lib.licenses.bsd3;
                  maintainers = with lib.maintainers; [zhuher];
                  mainProgram = "Thorium";
                  platforms = lib.platforms.darwin;
                  sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
                };
              }) {};
            # thorium-browser }}}
            # monero-cli {{{
            monero-cli = final.callPackage ({
              lib,
              fetchurl,
              stdenv,
              gnutar,
            }: let
              pname = "monero-cli";
              version = "0.18.4.2";
            in
              stdenv.mkDerivation {
                inherit pname version;

                src = fetchurl {
                  url = "https://downloads.getmonero.org/cli/monero-mac-armv8-v${version}.tar.bz2";
                  sha256 = "sha256-m5jaaRG0dpq+8inCDiHynZGbEdsVaWXW8TnS4a1mJcI=";
                };

                nativeBuildInputs = [gnutar];

                unpackPhase = ''
                  runHook preUnpack
                  tar -xjvf ''${src}
                  runHook postUnpack
                '';

                sourceRoot = "monero-aarch64-apple-darwin11-v${version}";

                installPhase = ''
                  runHook preInstall

                  mkdir -p $out/bin
                  cp -R monero* $out/bin

                  runHook postInstall
                '';

                meta = {
                  description = "A monero cli suite";
                  homepage = "https://www.getmonero.org/resources/user-guides/vps_run_node.html";
                  license = lib.licenses.gpl2;
                  maintainers = with lib.maintainers; [zhuher];
                  # mainProgram = "monerod";
                  platforms = lib.platforms.darwin;
                  sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
                };
              }) {};
            # monero-cli }}}
            # mullvad-upgrade-tunnel {{{
            mullvad-upgrade-tunnel = final.callPackage ({
              lib,
              fetchFromGitHub,
              gnumake,
              stdenvNoCC,
              go,
            }: let
              pname = "mullvad-upgrade-tunnel";
              version = "1.0.6";
            in
              stdenvNoCC.mkDerivation {
                inherit pname version;

                strictDeps = true;

                nativeBuildInputs = [
                  gnumake
                  go
                ];

                src = fetchFromGitHub {
                  owner = "mullvad";
                  repo = "wgephemeralpeer";
                  rev = "v${version}";
                  sha256 = "sha256-Dut6XnWWjtrmuuCxqwdLN4rnicXp1+MgZLkmmnCaZUc=";
                };

                patchPhase = ''
                  runHook prePatch
                  # Sed's here because otherwise Makefile gets metadata via git, which does not work without fetchFromGitHub { ..., deepClone = true }, and that uses pkgs.fetchgit, which pulls the "fatal: unable to access 'https://github.com/mullvad/wgephemeralpeer.git/': SSL certificate problem: unable to get local issuer certificate" error. Compilation succeeds regardless of this substitution, but the resultant binary would display a blank space in lieu of v${version} when invoked with the '-version' flag.
                  sed -i 's/export VERSION[ ]*=.*/export VERSION = "v${version}"/g' Makefile
                  # The following substitution is not critical, as omitting it results in a non-fatal "sh: line 1: git: command not found" warning, relevant only for the build-container recipe.
                  # sed -i 's/export SOURCE_DATE_ISO[ ]*=.*/export SOURCE_DATE_ISO = "2025-02-03 10:50:03 +0000"/g' Makefile # date for v1.0.6
                  runHook postPatch
                '';

                preBuild = ''
                  # We set HOME to avoid this error: failed to initialize build cache at /homeless-shelter/Library/Caches/go-build: mkdir /homeless-shelter: operation not permitted
                  HOME=$TMPDIR
                '';

                installPhase = ''
                  runHook preInstall

                  mkdir -p $out/bin
                  cp ./mullvad-upgrade-tunnel $out/bin/

                  runHook postInstall
                '';

                meta = {
                  description = "Mullvad Post-Quantum-secure WireGuard tunnels for vanilla WireGuard and custom integrations.";
                  homepage = "https://github.com/mullvad/wgephemeralpeer";
                  license = lib.licenses.gpl3;
                  maintainers = with lib.maintainers; [zhuher];
                  mainProgram = "mullvad-upgrade-tunnel";
                  platforms = lib.platforms.darwin;
                  sourceProvenance = with lib.sourceTypes; [fromSource];
                };
              }) {};
            # mullvad-upgrade-tunnel }}}
            # tile-thumbnails {{{
            tile-thumbnails = final.callPackage ({
              writeTextFile,
              ffmpeg,
              gawk,
              bc,
            }:
              writeTextFile {
                name = "tile-thumbnails";
                # script content {{{
                text = ''
                  #!/bin/sh
                  #===============================================================================
                  # tile-thumbnails
                  # create an image with thumbnails from a video
                  # https://raw.githubusercontent.com/NapoleonWils0n/ffmpeg-scripts/5b1f61bc07cdf3128afde003f36b832afcacd0d1/tile-thumbnails
                  #===============================================================================
                  # dependencies:
                  # ffmpeg ffprobe awk bc
                  #===============================================================================
                  # script usage
                  #===============================================================================
                  usage()
                  {
                  echo "\
                  # create an image with thumbnails from a video
                  $(basename "$0") -i input -s 00:00:00.000 -w 000 -t 0x0 -p 00 -m 00 -c color -f fontcolor -b boxcolor -x on -o output.png
                  -i input.(mp4|mkv|mov|m4v|webm)
                  -s seek into the video file                : default 00:00:05
                  -w thumbnail width                         : 160
                  -t tile layout format width x height : 4x3 : default 4x3
                  -p padding between images                  : default 7
                  -m margin                                  : default 2
                  -c color = https://ffmpeg.org/ffmpeg-utils.html#color-syntax : default black
                  -f fontcolor                               : default white
                  -b boxcolor                                : default black
                  -x on                                      : default off, display timestamps
                  -o output.png                              : optional argument
                  # if option not provided defaults to input-name-tile-date-time.png"
                  exit 2
                  }
                  #===============================================================================
                  # error messages
                  #===============================================================================
                  INVALID_OPT_ERR='Invalid option:'
                  REQ_ARG_ERR='requires an argument'
                  WRONG_ARGS_ERR='wrong number of arguments passed to script'
                  #===============================================================================
                  # check the number of arguments passed to the script
                  #===============================================================================
                  [ $# -gt 0 ] || usage "''${WRONG_ARGS_ERR}"
                  #===============================================================================
                  # getopts check the options passed to the script
                  #===============================================================================
                  while getopts ':i:s:w:t:p:m:c:b:f:x:o:h' opt
                  do
                    case ''${opt} in
                       i) infile="''${OPTARG}";;
                       s) seek="''${OPTARG}";;
                       w) scale="''${OPTARG}";;
                       t) tile="''${OPTARG}";;
                       p) padding="''${OPTARG}";;
                       m) margin="''${OPTARG}";;
                       c) color="''${OPTARG}";;
                       f) fontcolor="''${OPTARG}";;
                       b) boxcolor="''${OPTARG}";;
                       x) timestamp="''${OPTARG}";;
                       o) outfile="''${OPTARG}";;
                       h) usage;;
                       \?) usage "''${INVALID_OPT_ERR} ''${OPTARG}" 1>&2;;
                       :) usage "''${INVALID_OPT_ERR} ''${OPTARG} ''${REQ_ARG_ERR}" 1>&2;;
                    esac
                  done
                  shift $((OPTIND-1))
                  #===============================================================================
                  # variables
                  #===============================================================================
                  # input, input name
                  infile_nopath="''${infile##*/}"
                  infile_name="''${infile_nopath%.*}"
                  # ffprobe get fps and duration
                  videostats=$(${ffmpeg}/bin/ffprobe \
                  -v error \
                  -select_streams v:0 \
                  -show_entries stream=r_frame_rate:format=duration \
                  -of default=noprint_wrappers=1 \
                  "''${infile}")
                  # fps
                  fps=$(echo "''${videostats}" | ${gawk}/bin/awk -F'[=//]' '/r_frame_rate/{print $2/$3}')
                  # duration
                  duration=$(echo "''${videostats}" | ${gawk}/bin/awk -F'[=/.]' '/duration/{print $2}')
                  # check if tile is null
                  if [ -z "''${tile}" ]; then
                     : # tile variable not set : = pass
                  else
                     # tile variable set
                     # tile layout
                     tile_w=$(echo "''${tile}" | ${gawk}/bin/awk -F'x' '{print $1}')
                     tile_h=$(echo "''${tile}" | ${gawk}/bin/awk -F'x' '{print $2}')
                     # title sum
                     tile_sum=$(echo "''${tile_w} * ''${tile_h}" | ${bc}/bin/bc)
                  fi
                  # defaults
                  seek_default='00:00:05'
                  scale_default='160'
                  tile_layout_default='4x3'
                  tile_default='12'
                  padding_default='7'
                  margin_default='2'
                  color_default='black'
                  fontcolor_default='white'
                  boxcolor_default='black'
                  timestamp_default='off'
                  pts_default='5'
                  pts=$(printf "%s %s\n" "''${seek}" | ${gawk}/bin/awk '{
                            start = $1
                            if (start ~ /:/) {
                              split(start, t, ":")
                              seconds = (t[1] * 3600) + (t[2] * 60) + t[3]
                            }
                            printf("%s\n"), seconds
                  }')
                  outfile_default="''${infile_name}-tile-$(date +"%Y-%m-%d-%H-%M-%S").png"
                  # duration * fps / number of tiles
                  frames=$(echo "''${duration} * ''${fps} / ''${tile_sum:=''${tile_default}}" | ${bc}/bin/bc)
                  #===============================================================================
                  # functions
                  #===============================================================================
                  # contact sheet - no timestamps
                  tilevideo () {
                  ${ffmpeg}/bin/ffmpeg \
                  -hide_banner \
                  -stats -v panic \
                  -ss "''${seek:=''${seek_default}}" \
                  -i "''${infile}" \
                  -frames 1 -vf "select=not(mod(n\,''${frames})),scale=''${scale:=''${scale_default}}:-1,tile=''${tile:=''${tile_layout_default}}:padding=''${padding:=''${padding_default}}:margin=''${margin:=''${margin_default}}:color=''${color:=''${color_default}}" \
                  "''${outfile:=''${outfile_default}}"
                  }
                  # contact sheet - timestamps
                  timestamp () {
                  ${ffmpeg}/bin/ffmpeg \
                  -hide_banner \
                  -stats -v panic \
                  -ss "''${seek:=''${seek_default}}" \
                  -i "''${infile}" \
                  -frames 1 -vf "drawtext=text='%{pts\:hms\:''${pts:=''${pts_default}}}':x='(main_w-text_w)/2':y='(main_h-text_h)':fontcolor=''${fontcolor:=''${fontcolor_default}}:fontsize='(main_h/8)':boxcolor=''${boxcolor:=''${boxcolor_default}}:box=1,select=not(mod(n\,''${frames})),scale=''${scale:=''${scale_default}}:-1,tile=''${tile:=''${tile_layout_default}}:padding=''${padding:=''${padding_default}}:margin=''${margin:=''${margin_default}}:color=''${color:=''${color_default}}" \
                  "''${outfile:=''${outfile_default}}"
                  }
                  #===============================================================================
                  # check option passed to script
                  #===============================================================================
                  if [ "''${timestamp}" == on ]; then
                      timestamp "''${infile}" # -x on
                  elif [ ! -z "''${fontcolor}" ]; then
                      timestamp "''${infile}" # -f
                  elif [ ! -z "''${boxcolor}" ]; then
                      timestamp "''${infile}" # -b
                  elif [ -z "''${timestamp}" ]; then
                      tilevideo "''${infile}" # no timestamp
                  else
                      tilevideo "''${infile}" # no timestamp
                  fi
                '';
                # script content }}}
                executable = true;
                destination = "/bin/tile-thumbnails";
              }) {};
            # tile-thumbnails }}}
            emacsen = let
              # compilation opts {{{
              epkg = final.emacs-git.override {
                withNativeCompilation = true;
                withCsrc = true;
                withImageMagick = true;
                withMailutils = true;
                withSQLite3 = true;
                withToolkitScrollBars = true;
                withTreeSitter = true;
                withWebP = true;
                withCompressInstall = true;
                # use ccache
                # or not lolol # stdenv = final.ccacheStdenv;
              }; # compilation opts }}} # final.callPackage "${final.helix}/grammars.nix" {};
            in {
              darwin =
                # emacs on darwin {{{
                (final.emacsPackagesFor (
                  epkg.overrideAttrs (old: {
                    __noChroot = false; # [INFO]: cannot access /etc/ssl/certs otherwise (Operation not permitted)
                    patches =
                      old.patches
                      ++ [
                        # order taken from https://github.com/bbenchen/homebrew-emacs-plus/blob/9976d930dd3296a12474c08dc215ad6ac49ca5d8/Formula/emacs-plus%4031.rb#L107-L116
                        (final.fetchpatch {
                          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/3e95d573d5f13aba7808193b66312b38a7c66851/patches/emacs-31/system-appearance.patch";
                          sha256 = "sha256-4+2U+4+2tpuaThNJfZOjy1JPnneGcsoge9r+WpgNDko=";
                        })
                        (final.fetchpatch {
                          url = "https://raw.githubusercontent.com/bbenchen/homebrew-emacs-plus/8dbc7c832322091349b4c55884b4e9ffef655cb7/patches/emacs-31/round-undecorated-frame.patch";
                          sha256 = "sha256-WWLg7xUqSa656JnzyUJTfxqyYB/4MCAiiiZUjMOqjuY=";
                        })
                        (final.fetchpatch {
                          url = "https://raw.githubusercontent.com/bbenchen/homebrew-emacs-plus/9976d930dd3296a12474c08dc215ad6ac49ca5d8/patches/emacs-31/alpha-background.patch";
                          sha256 = "sha256-qfZhWue2RgwEbiz64nKL0Nq5/loMGhg5oDK+gCNyHOg=";
                        })
                        (final.fetchpatch {
                          url = "https://raw.githubusercontent.com/bbenchen/homebrew-emacs-plus/ac5d6b64dc2b3567f12145c687ee3febf9597ec8/patches/emacs-30/blur.patch";
                          sha256 = "sha256-X6ml5Gr5vUaQSb38H92lhK8X9D6oDL4bzmO1ujS74ws=";
                        })
                      ];
                  })
                )).emacsWithPackages
                (epkgs: with epkgs; [treesit-grammars.with-all-grammars]); # emacs on darwin }}}
              linux = (final.emacsPackagesFor epkg).emacsWithPackages (epkgs:
                with epkgs; [
                  treesit-grammars.with-all-grammars
                ]);
            };
          };
        }
      )
      # custom overlays }}}
    ];
    # overlays }}}
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    forEachSupportedSystem = overlays: f:
      nixpkgs.lib.genAttrs supportedSystems (
        system:
          f {
            pkgs = import nixpkgs {
              inherit overlays system;
            };
            inherit system;
          }
      );
    bts = nixpkgs.lib.boolToString;
    # mkSystem {{{
    mkSystem = name: {
      system,
      user,
      shell,
      isDarwin ? false,
      isWSL ? false,
    }: let
      systemFunc =
        if isDarwin
        then inputs.nix-darwin.lib.darwinSystem
        else nixpkgs.lib.nixosSystem;
    in
      systemFunc rec {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          # zsh configuration {{{
          (
            {
              pkgs,
              lib,
              config,
              currentSystemUser,
              isWSL,
              isDarwin,
              ...
            }: let
              inherit (lib) getExe getExe';
              inherit (pkgs) zoxide fzf steamcmd coreutils;
              env = config.environment.variables;
            in {
              environment = {
                shells = with pkgs; [
                  zsh
                ];
                systemPackages = with pkgs; [
                  zsh
                  zsh-fzf-tab
                ];
              };
              programs.zsh = {
                enable = true;
                enableBashCompletion = true;
                enableCompletion = true;
                enableGlobalCompInit = false;
                promptInit = ''
                  setopt PROMPT_SUBST
                  PROMPT='%B%F{green}%*%f@%F{blue}%U%m%u%f %F{yellow}%~%f %(?.%F{green}>.%F{red}[%?]>)%f%b '
                ''; # ''''; # ''[[ $TERM != "dumb" ]] && eval "$(''${getExe' starship "starship"} init zsh)"'';
                shellInit =
                  ''''
                  + lib.optionalString isWSL ''
                    getip() { ip r | grep 'link src' | awk '{ print $9 }' }
                  '';
                interactiveShellInit = ''
                  eval "$(${getExe' coreutils "dircolors"})"
                  HELPLDIR="${pkgs.zsh}/share/zsh/$ZSH_VERSION/help"
                  path+="${pkgs.zsh-fzf-tab}/share/fzf-tab"
                  fpath+="${pkgs.zsh-fzf-tab}/share/fzf-tab"
                  fpath+="${env.NH_FLAKE}/users/${currentSystemUser}/zsh/comp"

                  autoload -Uz compinit
                  mkdir -p ${env.XDG_CACHE_HOME}/zsh
                  source "${env.NH_FLAKE}/users/${currentSystemUser}/zsh/comp.zsh"

                  if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
                    autoload -Uz -- "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
                    ghostty-integration
                    unfunction ghostty-integration
                  fi
                  fpath+="${pkgs.zig-shell-completions}/share/zsh/site-functions"

                  if [[ -n ${env.XDG_CACHE_HOME}/zsh/zcompdump-$ZSH_VERSION(#qN.mh+24) ]]; then
                    compinit -d "${env.XDG_CACHE_HOME}/zsh/zcompdump-$ZSH_VERSION"
                  else
                    compinit -C
                  fi

                  eval "$(${getExe zoxide} init zsh)"
                  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,underline"
                  ZSH_AUTOSUGGEST_STRATEGY=(history)

                  source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

                  source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

                  source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

                  setopt nullglob
                  source "${env.NH_FLAKE}/users/${currentSystemUser}/zsh/rc.zsh"

                  HISTSIZE=9999999999
                  HISTFILE="${env.ZDOTDIR}/hist"
                  SAVEHIST=9999999999
                  mkdir -p "$(dirname "$HISTFILE")"
                  chmod 600 "$HISTFILE"

                  setopt HIST_FCNTL_LOCK APPEND_HISTORY HIST_IGNORE_DUPS
                  unsetopt HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS
                  setopt HIST_IGNORE_SPACE HIST_EXPIRE_DUPS_FIRST SHARE_HISTORY EXTENDED_HISTORY

                  if [[ $options[zle] = on ]]; then
                    source <(${getExe fzf} --zsh)
                  fi

                  source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
                  bindkey "^[[A" history-substring-search-up
                  bindkey "^[[B" history-substring-search-down
                  ${lib.optionalString false ''[[ $TERM != "dumb" ]] && exec ${getExe pkgs.nushell}''}
                  ed() { pushd "$(${getExe zoxide} query $1)"; $EDITOR; popd }
                  ${lib.optionalString isDarwin ''
                    alias -- emg='open -a EmacsClient'
                    source ${config.sops.secrets.secret-script-1.path}
                  ''}
                  ${lib.optionalString isWSL ''
                    macgame2dir() { ${getExe steamcmd} +force_install_dir "$2" +@sSteamCmdForcePlatformType macos +login mrtoster007 +app_update "$1" +quit }
                    bg2dir() { macgame2dir 1086940 "$1" }
                  ''}
                  [[ -s "${pkgs.grc}/etc/grc.zsh" ]] && source ${pkgs.grc}/etc/grc.zsh
                '';
              };
            }
          )
          # zsh configuration }}}
          # nushell configuration {{{
          (
            {
              pkgs,
              currentSystemUser,
              isDarwin,
              lib,
              config,
              ...
            }: {
              environment = with pkgs; {
                systemPackages = [
                  carapace
                  nushell
                ];
                shells = [nushell];
              };
              system.activationScripts.extraActivation.text = let
                inherit (lib) getExe getExe';
                dig = getExe' pkgs.dnsutils "dig";
                su =
                  if isDarwin
                  then "/usr/bin/su"
                  else getExe' pkgs.su "su";
                zsh = getExe pkgs.zsh;
                env = config.environment.variables;
                configDir = "${
                  # if isDarwin
                  # then "Library/Application Support"
                  # else
                  ".config"
                }/nushell";
                nuenv = pkgs.writeText "env-${currentSystemUser}.nu" ''
                  $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
                  mkdir ${env.XDG_CACHE_HOME}/carapace
                  let carpath = "${env.XDG_CACHE_HOME}/carapace/init.nu"
                  if (not ($carpath | path exists)) { ${getExe pkgs.carapace} _carapace nushell | save --force $carpath }
                  if (not ("~/${configDir}/zoxide.nu" | path exists)) { ${getExe pkgs.zoxide} init nushell | save -f "~/${configDir}/zoxide.nu" }
                '';
                nuconf = pkgs.writeText "config-${currentSystemUser}.nu" ''
                  # use std/util "path add"
                  # for $pathdir in [ '/etc/profiles/per-user/${currentSystemUser}/bin',
                  #   '/opt/homebrew/bin',
                  #   '/opt/homebrew/sbin',
                  #   '/run/current-system/sw/bin',
                  #   '/nix/var/nix/profiles/default/bin',
                  #   ] { if ($pathdir | path exists) { path add $pathdir } }
                  use std/dirs
                  def n [action?: string] {
                    dirs add ${env.NH_FLAKE}
                    match $action {
                      null => { ${getExe pkgs.just} }
                      _ => { ${getExe pkgs.just} $action }
                    }
                    dirs drop
                  }
                  # https://github.com/bydmiller/nixos-configs/blob/6a7053f1e081c21cf4362724b57d3d70e63198ed/machines/nebula/homes/zsh/aliases.nix#L63-L64
                  alias canihazip = ${dig} @resolver4.opendns.com myip.opendns.com +short
                  alias canihazip4 = ${dig} @resolver4.opendns.com myip.opendns.com +short -4
                  source "~/${configDir}/zoxide.nu"
                  alias cd = z
                  source "${env.NH_FLAKE}/users/zhuher/nu/mutable.nu"
                  source "${env.XDG_CACHE_HOME}/carapace/init.nu"
                  $env.config.hooks.env_change.PWD = (
                    $env.config.hooks.env_change.PWD | append (source ${pkgs.nu_scripts}/share/nu_scripts/nu-hooks/nu-hooks/direnv/direnv.nu)
                  )
                '';
                subody = pkgs.writeText "link-nu-config.zsh" ''
                  ${pkgs.linkFiles [
                    ["${nuenv}" "${env.HOME}/${configDir}/env.nu"]
                    ["${nuconf}" "${env.HOME}/${configDir}/config.nu"]
                  ]}
                '';
              in ''
                ${su} ${currentSystemUser} -c '${zsh} ${subody}'
              '';
            }
          )
          # nushell configuration }}}
          # activation scripts {{{
          (
            {
              pkgs,
              config,
              lib,
              isWSL,
              isDarwin,
              currentSystemUser,
              ...
            }: {
              system.activationScripts = let
                inherit (pkgs) coreutils mkalias;
                inherit (pkgs.zhuk) notify;
                inherit (lib) getExe' getExe;
                zsh = getExe pkgs.zsh;
                delta = getExe pkgs.delta;
                realpath = getExe' coreutils "realpath";
                rm = getExe' coreutils "rm";
                su =
                  if isDarwin
                  then "/usr/bin/su"
                  else "${getExe' pkgs.su "su"}";
                userConfigDir = users/${currentSystemUser};
                env = config.environment.variables;
                xdgConfig = env.XDG_CONFIG_HOME;
                sshconfig = pkgs.writeTextFile {
                  name = "sshconfig-${currentSystemUser}";
                  text =
                    lib.optionalString isDarwin ''
                      Host *
                          IdentityAgent "${env.HOME}/Library/Group Containers/group.strongbox.mac.mcguill/agent.sock"
                    ''
                    + ''
                      Host *
                        IPQoS=throughput
                        ForwardAgent no
                        AddKeysToAgent no
                        Compression no
                        ServerAliveInterval 0
                        ServerAliveCountMax 3
                        HashKnownHosts yes
                        UserKnownHostsFile ${env.HOME}/.ssh/known_hosts
                        ControlMaster auto
                        ControlPath ${env.HOME}/.ssh/master-%r@%n:%p
                        ControlPersist no
                        IdentitiesOnly yes
                        HashKnownHosts yes
                        IdentityFile ${config.sops.secrets.ssh-keys-gh.path}
                        IdentityFile ${config.sops.secrets.ssh-keys-pers.path}
                        IdentityFile ${config.sops.secrets.ssh-keys-misc.path}
                      Include ${config.sops.secrets.ssh-hosts.path}
                      Include ${env.HOME}/.ssh/mutable-config'';
                };
                # git config {{{
                gitconfig = (pkgs.formats.toml {}).generate "gitconfig" {
                  alias = {
                    log-pretty = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
                    root = "rev-parse --show-toplevel";
                  };
                  include.path = config.sops.secrets.gitsecrets.path;
                  http.postBuffer = 157286400;
                  branch.autosetuprebase = "always";
                  color.ui = true;
                  core.askPass = ""; # [INFO]: needs to be empty to use terminal for ask pass
                  core.pager = delta;
                  credential.helper = "store"; # [TODO]: make this more secure
                  github.user = currentSystemUser;
                  push.default = "tracking";
                  init.defaultBranch = "main";
                  interactive.diffFilter = "${delta} --color-only";
                  pull.rebase = true;
                  rebase.autoStash = true;
                  delta = {
                    navigate = true;
                    features = "decorations";
                    line-numbers = true;
                    side-by-side = true;
                    syntax-theme = "base16";
                    keep-plus-minus-markers = true;
                    decorations = {
                      commit-decoration-style = "blue ol";
                      commit-style = "raw";
                      file-style = "omit";
                      hunk-header-decoration-style = "blue box";
                      hunk-header-file-style = "yellow";
                      hunk-header-style = "file line-number syntax";
                      hyperlinks = true;
                    };
                  };
                }; # git config }}}
                gitignore = pkgs.writeText "gitignore" ''
                  .DS_Store
                '';
                bashrc = pkgs.writeText "bashrc-${currentSystemUser}" ''
                  echo 'hi'
                  if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
                    builtin source "''${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
                  fi
                '';
              in {
                # preActivation {{{
                preActivation = {
                  text =
                    ''
                    ''
                    + (lib.optionalString isWSL (notify "wsl::preActivation" ''
                      # systemctl stop dbus.socket
                      # systemctl stop dbus.service
                    ''))
                    + lib.optionalString isDarwin (notify "darwin::preActivation"
                      ''
                        ${pkgs.linkFiles [
                          ["${env.HOME}/Library/Application Support" "${env.HOME}/LAPS"]
                          ["${env.NH_FLAKE}/users/${currentSystemUser}/ghostty" "${env.HOME}/LAPS/com.mitchellh.ghostty/config"]
                        ]}
                      '');
                };
                # preActivation }}}
                # extraActivation {{{
                extraActivation = {
                  text = let
                    body = pkgs.writeText "extraActivation.zsh" ''
                      ${pkgs.linkFiles (
                        [
                          ["${sshconfig}" "${env.HOME}/.ssh/config"]
                          ["${gitignore}" "${xdgConfig}/git/ignore"]
                          ["${gitconfig}" "${xdgConfig}/git/config"]
                          ["${bashrc}" "${env.HOME}/.bashrc"]
                          ["${env.NH_FLAKE}/users/${currentSystemUser}/ghostty" "${xdgConfig}/ghostty/config"]
                          ["${userConfigDir}/emacs/early-init.el" "${xdgConfig}/emacs/early-init.el"]
                          ["${userConfigDir}/emacs/init.el" "${xdgConfig}/emacs/init.el"]
                        ]
                        # # all .pub files(ssh pubkeys) from users/${currentSystemUser}
                        # ++ (lib.mapAttrsToList (name: _value: ["${userConfigDir}/${name}" "${env.HOME}/.ssh/${name}"]) (lib.filterAttrs (file: _: lib.hasSuffix ".pub" file) (builtins.readDir userConfigDir)))
                      )}
                    '';
                  in
                    notify "common::extraActivation" ''
                      ${su} ${currentSystemUser} -c '${zsh} ${body}'
                    '';
                };
                # extraActivation }}}
                # postActivation {{{
                postActivation = {
                  text = let
                    body = pkgs.writeText "postActivation.zsh" ''
                      setopt nullglob
                      for app in {{/Applications/Nix\ Apps/,/Volumes/t7-shield/SteamLibrary/steamapps/common/},${env.HOME}/{Library/Application\ Support/Steam/steamapps/common/*/,Documents/Games/**/,Applications/Crossover/**/}}*.app
                      do
                        ${rm} "/Applications/''${''${app:t}%.*}"
                        ${lib.getExe mkalias} "$(${realpath} "$app")" "/Applications/''${''${app:t}%.*}"
                      done
                    '';
                  in
                    ''
                    ''
                    + (lib.optionalString isDarwin (notify "darwin::postActivation" ''
                      ${su} ${currentSystemUser} -c '${zsh} ${body}'
                    ''));
                };
                # postActivation }}}
              };
            }
          )
          # activation scripts }}}
          # packages {{{
          (
            {
              lib,
              inputs,
              pkgs,
              config,
              isDarwin,
              isWSL,
              currentSystemUser,
              ...
            }: let
              env = config.environment.variables;
            in {
              imports = [
                inputs.xsb.nixosModules.default
              ];
              # xSB {{{
              programs.xstarbound = {
                enable = true;
                package = let
                  curSys = pkgs.stdenv.hostPlatform.system;
                in
                  inputs.xsb.packages.${curSys}.default.override {
                    xstarbound-unwrapped =
                      inputs.xsb.packages.${curSys}.xstarbound-unwrapped.override
                      {clangStdenv = pkgs.ccacheStdenv;};
                  };
                localMods = {
                  enable = false;
                  dir =
                    {
                      "${bts true}" = "${env.HOME}/Library/Application Support/Steam/steamapps/workshop/content/211820";
                      "${bts false}" =
                        {
                          "${bts true}" = "/mnt/c/Program Files (x86)/Steam/steamapps/workshop/content/211820";
                        }."${bts isWSL}";
                    }."${bts isDarwin}";
                };
                bootconfig.settings = {
                  assetDirectories = [
                    # Starbound assets
                    # "./xsb-assets/"
                    # "./Resources/xsb-assets/"
                    # "./xSB Client.app/Contents/Resources/xsb-assets/"
                    # Steam-installed Starbound directory on Darwin:
                    "${env.HOME}/Library/Application Support/Steam/steamapps/common/Starbound/assets/"
                  ];
                  storageDirectory = "${env.XDG_DATA_HOME}/xStarbound";
                };
              }; # xSB }}}
              environment.systemPackages = with pkgs; # All systems {{{
              
                let
                  # gnupg-wrapped {{{
                  mapArgs = args: let
                    lines = builtins.filter (el: !(builtins.isList el || el == "")) (builtins.split "\n" args);
                    words = builtins.filter (el: !builtins.isList el) (builtins.concatLists (builtins.map (line: builtins.split " " line) lines));
                    flags = map (w: "--add-flags " + w) words;
                    result = builtins.concatStringsSep " " flags;
                  in
                    result;
                  mappedArgs = mapArgs ''
                    --list-options show-photos,show-usage,show-ownertrust,show-policy-urls,show-std-notations,show-keyserver-urls,show-uid-validity,show-unusable-uids,show-unusable-subkeys,show-unusable-sigs,show-keyring,show-sig-expire,show-sig-subpackets,sort-sigs
                    --display-charset utf-8
                    --compress-level 9
                    --bzip2-compress-level 9
                    --no-random-seed-file
                    --no-greeting
                    --require-secmem
                    --require-cross-certification
                    --expert
                    --armor
                    --with-fingerprint
                    --with-fingerprint
                    --with-subkey-fingerprint
                    --with-keygrip
                    --with-key-origin
                    --with-wkd-hash
                    --with-secret
                    --pinentry-mode loopback
                    --full-timestrings
                    --passphrase-repeat 4
                    --no-symkey-cache
                    --with-sig-list
                    --keyid-format 0xlong
                  '';
                  gnupg-wrapped = symlinkJoin {
                    name = "gnupg-wrapped";
                    paths = [gnupg];
                    nativeBuildInputs = [makeBinaryWrapper];
                    postBuild = ''
                      wrapProgram $out/bin/gpg \
                      ${mappedArgs}
                    '';
                  };
                  # gnupg-wrapped }}}
                  # jujutsu-wrapped {{{
                  jujutsu-wrapped = let
                    # config {{{
                    jjconf = (formats.toml {}).generate "jj.toml" {
                      colors."commit_id prefix".bold = true;
                      revsets.log = ''@ | ancestors(immutable_heads()..) | trunk()'';
                      template-aliases = {
                        "format_short_id(id)" = "id.shortest()";
                        "format_timestamp(timestamp)" = ''timestamp ++ "(" ++ timestamp.ago() ++ ")"'';
                      };
                      ui = {
                        default_command = ["log" "--no-pager" "--limit=6"];
                        diff-editor = ["${lib.getExe' nvim-wrapped "nvim"}" "-c" "DiffEditor $left $right $output"];
                        pager = "${lib.getExe delta}";
                        diff-formatter = ":git";
                      };
                      signing = {
                        behavior = "own";
                        backend = "gpg";
                      };
                      templates = {
                        log_node = ''
                          coalesce(
                            if(!self, "🮀"),
                            if(current_working_copy, "@"),
                            if(root, "┴"),
                            if(immutable, "●", "○"),
                          )'';
                      };
                      op_log_node = ''if(current_operation, "@", "○")'';
                      snapshot.max-new-file-size = 16777216;
                      aliases = {
                        my-inline-script = [
                          "util"
                          "exec"
                          "--"
                          "bash"
                          "-c"
                          ''
                            #!/usr/bin/env bash
                            set -euo pipefail
                            echo "Look Ma, everything in one file!"
                            echo "args: $@"
                          ''
                          ""
                        ];
                        yolo = [
                          "util"
                          "exec"
                          "--"
                          "bash"
                          "-c"
                          ''
                            jj desc -m "$(curl -s "https://whatthecommit.com/index.txt")"
                          ''
                          ""
                        ];
                      };
                    };
                    # config }}}
                  in
                    symlinkJoin {
                      name = "jujutsu-wrapped";
                      paths = [jujutsu];
                      nativeBuildInputs = [makeBinaryWrapper];
                      buildInputs = [delta nvim-wrapped];
                      postBuild = ''
                        wrapProgram $out/bin/jj \
                        --set JJ_CONFIG "${"${jjconf}:${config.sops.secrets.jjsecrets.path}"}"
                      '';
                    };
                  # jujutsu-wrapped }}}
                in
                  [
                    hyperfine
                    gnugrep
                    age
                    alejandra
                    bat-wrapped
                    btop
                    coreutils
                    delta
                    (writeShellScriptBin "devinit" ''nix flake init -t ${env.NH_FLAKE}#$1 && cp ${env.NH_FLAKE}/shells/$1/.envrc{,.local} ./'')
                    eza
                    fastfetch
                    fd
                    fzf
                    gh
                    git
                    gnutar
                    jq
                    jujutsu-wrapped
                    just
                    nh
                    nil
                    nodejs-slim
                    nushell
                    nvim-wrapped
                    ripgrep
                    rsync
                    sops
                    ssh-to-age
                    tmux-wrapped
                    wget
                    yazi
                    zig
                    zls
                    zoxide
                    grc
                    gnupg-wrapped
                    # (amneziawg-tools.overrideAttrs (prev: {
                    #   postFixup =
                    #     prev.postFixup
                    #     + ''
                    #       sed -i 's/\bwg\b/awg/g;s#/wireguard#/amneziawg#g' $out/bin/.awg-quick-wrapped
                    #     '';
                    # }))
                  ] # All systems }}}
                  ++ {
                    # Darwin {{{
                    "${bts true}" = with pkgs; [
                      localsend
                      anki-bin
                      apparency # [ERROR]: QuickLook extension does not work when installed via nix.
                      mas
                      appcleaner
                      # cataclysm-dda-git
                      crawl
                      dockutil
                      ffmpeg
                      ice-bar # [ERROR] Crashes when using the floating ice bar.
                      iina
                      libjxl
                      # moonlight-qt # [ERROR]: Crashes on launch (brew version works fine).
                      prismlauncher
                      # raycast # [ERROR] Needs VPN
                      rtorrent
                      syncthing
                      # utm # [ERROR] le errare abobuous
                      zhuk.emacsen.darwin
                      zhuk.ghostty
                      zhuk.monero-cli
                      zhuk.mullvad-upgrade-tunnel
                      zhuk.thorium-browser
                      zhuk.tile-thumbnails
                      zhuk.alex313031-codium
                      qbittorrent
                    ]; # Darwin }}}
                    # Linux {{{
                    "${bts false}" = with pkgs;
                      [
                        su
                        cron
                        keepassxc
                        qbittorrent-cli
                        steamcmd
                        valgrind
                      ]
                      ++ {
                        # Non-WSL {{{
                        "${bts false}" = with pkgs; [
                          ladybird
                          lutris
                        ]; # Non-WSL }}}
                        # WSL {{{
                        "${bts true}" = []; # WSL }}}
                      }
        ."${bts isWSL}"; # Linux }}}
                  }
    ."${bts isDarwin}";
            }
          )
          # packages }}}
          # environment {{{
          ({
            pkgs,
            lib,
            inputs,
            config,
            isDarwin,
            currentSystemUser,
            currentSystemName,
            currentUserShell,
            ...
          }: let
            inherit (lib) getExe' getExe;
            inherit (pkgs) nvim-wrapped eza;
          in {
            programs = {
              direnv = {
                enable = true;
                nix-direnv.enable = true;
                settings = {
                  global = {
                    warn_timeout = "30s";
                  };
                  whitelist = {
                    exact = ["${config.environment.variables.HOME}/.envrc"];
                  };
                };
              };
            };
            users.users."${currentSystemUser}".shell = pkgs."${currentUserShell}";
            environment = {
              pathsToLink = ["/share/zsh"];
              shellAliases =
                # {{{
                rec {
                  l = "${getExe eza} --all --oneline --classify=auto --colour=auto --icons=auto --hyperlink";
                  ls = "${getExe eza} --all --bytes --smart-group --modified --oneline --long --classify=auto --colour=auto --icons=auto --hyperlink";
                  lstr = "${ls} --tree --ignore-glob '.git|.jj|.direnv' --group-directories-first";
                  aa = "awg-quick";
                  c = "clear";
                  cd = "z";
                  cp = "cp -irv";
                  jjgf = "jj git fetch";
                  jjl = "jj log -r '@ | ancestors(immutable_heads()..) | trunk()' --no-pager --limit=6";
                  mv = "mv -iv";
                  nv = "nvim";
                  rm = "rm -irv";
                  tmux = "TERM=xterm-256color tmux";
                  # make sudo use aliases (https://github.com/sukhmancs/nixos-configs/blob/c4dbf10fb95f3237130a0b1a899a688ca9c77d32/machines/nebula/homes/zsh/aliases.nix#L12)
                  sudo = "sudo ";
                }
                // (
                  if isDarwin
                  then {uv = "diskutil ap unlockVolume";}
                  else {}
                ); # shellAliases }}}
              variables =
                # {{{
                let
                  manpager = pkgs.writeShellScriptBin "manpager" (
                    if isDarwin
                    then ''
                      sh -c 'sed -u -e "s/\\x1B\[[0-9;]*m//g; s/.\\x08//g" | bat -p -lman'
                    ''
                    else ''
                      cat "$1" | col -bx | bat --language man --style plain
                    ''
                  );
                  flake-path = builtins.readFile inputs.flake-path.outPath;
                in rec {
                  NIXPKGS_REV = "76eec3925eb9bbe193934987d3285473dbcfad50";
                  PAGER = "${pkgs.delta}/bin/delta";
                  MANPAGER = "${manpager}/bin/manpager";
                  EDITOR = getExe' nvim-wrapped "nvim";
                  LANG = "C.UTF-8";
                  HOME = config.users.users."${currentSystemUser}".home;
                  XDG_CACHE_HOME = "${HOME}/.cache";
                  XDG_CONFIG_HOME = "${HOME}/.config";
                  XDG_DATA_HOME = "${HOME}/.local/share";
                  XDG_STATE_HOME = "${HOME}/.local/state";
                  NH_FLAKE = builtins.trace "Flake path is ${flake-path}" flake-path;
                  ZDOTDIR = "${XDG_CONFIG_HOME}/zsh";
                  FZF_CTRL_R_OPTS = "--sort --exact";
                  FZF_CTRL_T_COMMAND = "fd --type f";
                  FZF_CTRL_T_OPTS = "--ansi --preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'";
                }
                # // (if !isDarwin then { MANROFFOPT = "-c"; } else { })
                ; # vvariables }}}
            };
            documentation.enable = true;
            documentation.doc.enable = true;
            documentation.info.enable = true;
            documentation.man.enable = true;
            time.timeZone = "Europe/Moscow";
            nix = {
              registry = pkgs.lib.mapAttrs (_: value: {flake = value;}) inputs;
              nixPath = pkgs.lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
              enable = true;
              package = pkgs.lix; # use lix instead of nixCpp
              checkConfig = true;
              optimise = {
                automatic = false;
              };
              settings = {
                auto-optimise-store = false;
                cores = 0;
                sandbox = "relaxed"; # [INFO]: "relaxed" or bool;
                extra-substituters = [
                  "https://cache.garnix.io"
                  "https://cache.nixos.org?priority=10"
                  "https://nix-community.cachix.org"
                ];
                extra-trusted-public-keys = [
                  "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
                  "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                  "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                ];
                trusted-users = [
                  "@admin"
                  "${currentSystemUser}"
                ];
              };
              channel.enable = false;
            };
            networking.hostName = currentSystemName;
          })
          # environment }}}
          # machine-specific {{{
          {
            "gandalf" = {
              pkgs,
              lib,
              currentSystemUser,
              currentSystemName,
              config,
              ...
            }: let
              inherit (pkgs) coreutils syncthing gnutar;
              inherit (pkgs.zhuk) notify;
              inherit (lib) getExe getExe';
              emacs = getExe' pkgs.zhuk.emacsen.darwin "emacs";
              zsh = lib.getExe pkgs.zsh;
            in {
              fonts = {
                packages = with pkgs.nerd-fonts;
                  [
                    fantasque-sans-mono
                    fira-code
                    fira-mono
                    hack
                    im-writing
                    jetbrains-mono
                    liberation
                    meslo-lg
                    monaspace
                    symbols-only
                  ]
                  ++ [pkgs.maple-mono.variable];
              };
              nix = {
                gc = {
                  interval = {
                    Weekday = 0;
                    Hour = 23;
                    Minute = 0;
                  };
                  automatic = true;
                };
                optimise.interval = {
                  Weekday = 0;
                  Hour = 23;
                  Minute = 0;
                };
                extraOptions = ''
                  experimental-features = nix-command flakes
                  keep-outputs = true
                  keep-derivations = true
                  allowed-impure-host-deps = /bin/sh /usr/lib/libSystem.B.dylib /usr/lib/system/libunc.dylib /dev/zero /dev/random /dev/urandom
                  extra-sandbox-paths = /nix/var/cache/ccache
                  !include ${config.sops.secrets.access-tokens.path}
                '';
              };
              services.openssh.enable = true;
              security.pam.services.sudo_local.touchIdAuth = true;
              launchd.user.agents.zhukmacs.serviceConfig = {
                AbandonProcessGroup = true;
                Disabled = false;
                KeepAlive = true;
                Label = "zhuk.gnu.emacs.daemon";
                ProcessType = "Interactive";
                RunAtLoad = true;
                StandardOutPath = "/Users/${currentSystemUser}/Library/Logs/Zhukmacs.log";
                StandardErrorPath = "/Users/${currentSystemUser}/Library/Logs/Zhukmacs-Errors.log";
                ProgramArguments = [
                  "${zsh}"
                  "-ilc"
                  "${emacs} --fg-daemon"
                ];
              };
              launchd.user.agents.syncthing = {
                environment = {
                  HOME = "/Users/${currentSystemUser}";
                  STNORESTART = "1";
                  STNOUPGRADE = "1";
                };
                serviceConfig = {
                  KeepAlive = true;
                  Label = "net.syncthing.syncthing";
                  LowPriorityIO = true;
                  ProcessType = "Background";
                  ProgramArguments = [
                    "${getExe syncthing}"
                  ];
                  StandardOutPath = "/Users/${currentSystemUser}/Library/Logs/Syncthing.log";
                  StandardErrorPath = "/Users/${currentSystemUser}/Library/Logs/Syncthing-Errors.log";
                };
              };
              networking = {
                applicationFirewall.enableStealthMode = true;
                computerName = "Gandalf";
                dns = [
                  "9.9.9.11"
                  "149.112.112.11"
                  "2620:fe::11"
                  "2620:fe::fe:11"
                ];
                knownNetworkServices = [
                  "Thunderbolt Bridge"
                  "Wi-Fi"
                ];
              };
              sops = {
                defaultSopsFile = users/${currentSystemUser}/secrets.yaml;
                defaultSopsFormat = "yaml";
                age.sshKeyPaths = [
                  /Users/${currentSystemUser}/.ssh/age
                ];
                secrets = {
                  secret-script-1 = {
                    mode = "0500";
                    owner = currentSystemUser;
                  };
                  ssh-keys-gh = {
                    mode = "0400";
                    owner = currentSystemUser;
                  };
                  ssh-keys-pers = {
                    mode = "0400";
                    owner = currentSystemUser;
                  };
                  ssh-keys-misc = {
                    mode = "0400";
                    owner = currentSystemUser;
                  };
                  jjsecrets = {
                    mode = "0400";
                    owner = currentSystemUser;
                  };
                  gitsecrets = {
                    mode = "0400";
                    owner = currentSystemUser;
                  };
                  lmao.owner = currentSystemUser;
                  copilot-hosts = {
                    path = "/Users/${currentSystemUser}/.config/github-copilot/hosts.json";
                    owner = currentSystemUser;
                    mode = "0400";
                  };
                  exercism-user = {
                    path = "/Users/${currentSystemUser}/.config/exercism/user.json";
                    owner = currentSystemUser;
                    mode = "0400";
                  };
                  gck = {
                    mode = "0400";
                    owner = currentSystemUser;
                  };
                  contact-info.mode = "0400";
                  ssh-hosts = {
                    mode = "0400";
                    path = "/Users/${currentSystemUser}/.ssh/hosts";
                    owner = currentSystemUser;
                  };
                  access-tokens = {
                    mode = "0440";
                    group = config.users.groups.keys.name;
                  };
                };
                # secrets.tunnels = {
                #   format = "binary";
                #   sopsFile = ./gandalf/secrets/tunnels;
                #   mode = "0400";
                # };
              };
              # names of scripts that would be run can be found at https://github.com/nix-darwin/nix-darwin/blob/eaff8219d629bb86e71e3274e1b7915014e7fb22/modules/system/activation-scripts.nix#L148-L155
              system.activationScripts.postActivation.text = let
                mkdir = getExe' coreutils "mkdir";
                tar = getExe' gnutar "tar";
                subody = pkgs.writeText "postActivation-${currentSystemName}.zsh" ''
                  # Following line should allow us to avoid a logout/login cycle
                  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
                '';
              in
                notify "${currentSystemName}::postActivation" ''
                  # # we restore the launchpad to one before Tahoe
                  # ${notify "Restoring launchpad" ''
                    #   ${mkdir} -p /Library/Preferences/FeatureFlags/Domain
                    #   defaults write /Library/Preferences/FeatureFlags/Domain/SpotlightUI.plist SpotlightPlus -dict Enabled -bool false
                    #   find /private/var/folders/ -type d -name com.apple.dock.launchpad -exec rm -rf {} + 2>/dev/null || true
                    # ''}
                  ${notify "Setting login screen message" ''
                    defaults write /Library/Preferences/com.apple.loginwindow.plist LoginwindowText -string "$(cat ${config.sops.secrets.contact-info.path})"
                  ''}
                  # sops-nix links secrets at activation, so reading from them is to be done post-activation
                  # ${notify "Setting up wireguard tunnels" ''
                    #   ${mkdir} -p /var/run/amneziawg
                    #   ${tar} --no-same-owner --skip-old-files -xzf ''$\{config.sops.secrets.tunnels.path} -C /usr/local/etc/amnezia/amneziawg/
                    #   chmod 400 /usr/local/etc/amnezia/amneziawg/*
                    # ''}
                  ${notify "Activating settings" ''
                    su ${currentSystemUser} -c '${zsh} ${subody}'
                  ''}
                '';
            };
            "wsl" = {currentSystemUser, ...}: {
              imports = [];
              wsl = {
                enable = true;
                wslConf.automount.root = "/mnt";
                defaultUser = currentSystemUser;
                startMenuLaunchers = true;
                wslConf.interop.appendWindowsPath = true;
                wslConf.network.generateHosts = true;
                wslConf.user.default = currentSystemUser;
              };
              nix = {
                extraOptions = ''
                  experimental-features = nix-command flakes
                  keep-outputs = true
                  keep-derivations = true
                '';
              };
              environment.enableAllTerminfo = true;
              services = {
                dbus = {
                  packages = [];
                  implementation = "dbus";
                };
                openssh.ports = [2022];
              };
              users.users."${currentSystemUser}".home = "/home/${currentSystemUser}";
              # systemd.services = {
              #   dbus-broker.serviceConfig = {
              #     Disagled = true;
              #   };
              # };
              system.stateVersion = "25.05";
            };
          }."${name}"
          # machine-specific }}}
          # system-specific {{{
          {
            "${bts true}" = {
              pkgs,
              config,
              currentSystemUser,
              ...
            }: {
              imports = [
                (
                  {
                    config,
                    pkgs,
                    lib,
                    ...
                  }:
                  # Original source: https://gist.github.com/antifuchs/10138c4d838a63c0a05e725ccd7bccdd
                    with lib; let
                      cfg = config.local.dock;
                      inherit (pkgs) stdenv;
                      zsh = getExe pkgs.zsh;
                      dockutil = getExe pkgs.dockutil;
                    in {
                      options = {
                        local.dock.enable = mkOption {
                          description = "Enable dock";
                          default = stdenv.isDarwin;
                          example = false;
                        };

                        local.dock.entries = mkOption {
                          description = "Entries on the Dock";
                          type = with types;
                            listOf (submodule {
                              options = {
                                path = mkOption {type = str;};
                                section = mkOption {
                                  type = str;
                                  default = "apps";
                                };
                                options = mkOption {
                                  type = str;
                                  default = "";
                                };
                              };
                            });
                          readOnly = true;
                        };
                        local.dock.username = mkOption {
                          description = "Username to apply the dock settings to";
                          default = config.system.primaryUser;
                          type = types.str;
                        };
                      };

                      config = mkIf cfg.enable (
                        let
                          normalize = path:
                            if hasSuffix ".app" path
                            then path + "/"
                            else path;
                          entryURI = path:
                            "file://"
                            + (
                              builtins.replaceStrings
                              [
                                " "
                                "!"
                                "\""
                                "#"
                                "$"
                                "%"
                                "&"
                                "'"
                                "("
                                ")"
                              ]
                              [
                                "%20"
                                "%21"
                                "%22"
                                "%23"
                                "%24"
                                "%25"
                                "%26"
                                "%27"
                                "%28"
                                "%29"
                              ]
                              (normalize path)
                            );
                          wantURIs = concatMapStrings (entry: "${entryURI entry.path}\n") cfg.entries;
                          createEntries =
                            concatMapStrings
                            (
                              entry: "${dockutil} --no-restart --add '${entry.path}' --section ${entry.section} ${entry.options}\n"
                            )
                            cfg.entries;
                          subody = pkgs.writeText "dock.zsh" ''
                            haveURIs="$(${dockutil} --list | ${getExe' pkgs.coreutils "cut"} -f2)"
                            if ! diff -wu <(echo -n "$haveURIs") <(echo -n '${wantURIs}') >&2 ; then
                              echo >&2 -e "\033[33mResetting Dock.\033[0m"
                              ${dockutil} --no-restart --remove all
                              ${createEntries}
                              killall Dock
                            fi
                            echo >&2 -e "\033[32mDock setup complete.\033[0m"
                          '';
                        in {
                          system.activationScripts.postActivation.text = ''
                            echo >&2 -e "\033[34mSetting up the Dock for ${cfg.username}...\033[0m"
                            su ${cfg.username} -c '${zsh} ${subody}'
                          '';
                        }
                      );
                    }
                )
              ];

              # brew & app store {{{
              homebrew = {
                taps = builtins.attrNames config.nix-homebrew.taps;
                enable = true;
                onActivation = {
                  cleanup = "zap";
                  autoUpdate = true;
                  upgrade = true;
                };

                whalebrews = [
                ];
                brews = [
                  "virtualenv"
                ];

                casks = [
                  "orion"
                  "qlmarkdown"
                  "syntax-highlight"
                  "moonlight"
                  "keka"
                  # "parsec" # VPN
                  # "tor-browser" VPN
                ];

                # These app IDs are from using the mas CLI app
                # mas = mac app store
                # https://github.com/mas-cli/mas
                # ```sh
                # nix shell nixpkgs#mas
                # mas search <app name>
                # ```
                masApps = {
                  "Velja" = 1607635845;
                  # "GarageBand" = 682658836;
                  # "Warframe" = 1520001008; # only mobile devices (why???)
                  "Pages" = 409201541;
                  "Numbers" = 409203825;
                  # "DaisyDisk" = 411643860; # using a version from their website as it's more powerful
                  "StrongBox" = 1481853033;
                  # "Customize Search Engine" = 6445840140; # [TODO]: Return to this maybe
                  "Telegram" = 747648890;
                  # "Xcode" = 497799835;
                };
              }; # brew & app store }}}

              system = {
                primaryUser = "${currentSystemUser}";
                activationScripts.postActivation.text = '''';
                stateVersion = 5;
                # defaults {{{
                defaults = {
                  # Reduce window resize animation duration.
                  NSGlobalDomain.NSWindowResizeTime = 0.001;
                  # Motion reduction NEEDS to be off, no speed gain
                  CustomSystemPreferences."com.apple.Accessibility".ReduceMotionEnabled = 0;
                  # universalaccess.reduceMotion = false;
                  ".GlobalPreferences" = {
                    "com.apple.mouse.scaling" = 1.0; # max is 8.0
                    "com.apple.sound.beep.sound" = /System/Library/Sounds/Hero.aiff;
                  };
                  ActivityMonitor.IconType = 0;
                  CustomSystemPreferences = {};
                  CustomUserPreferences = {
                    # "com.apple.universalaccess" = {
                    #   mouseDriverCursorSize = 1;
                    #   cursorOutline = {
                    #     alpha = 1;
                    #     blue = "0.389";
                    #     green = "0.547";
                    #     red = "0.938";
                    #   };
                    #   cursorIsCustomized = 1;
                    #   cursorFill = {
                    #     alpha = 1;
                    #     blue = 0;
                    #     green = 0;
                    #     red = 0;
                    #   };
                    # };
                    NSGlobalDomain = {
                      ApplePressAndHoldEnabled = false;
                      AppleMenuBarVisibleInFullscreen = 0;
                      _HIHideMenuBar = 0;
                    };
                    "com.moonlight-stream.Moonlight" = {
                      width = 1512;
                      height = 945;
                    };
                    "org.gpgtools.common" = {
                      DisableKeychain = false;
                    };
                    "com.apple.GameController" = {
                      homeButtonLongPressAction = "com.apple.launchpad.launcher";
                    };
                  };
                  NSGlobalDomain = {
                    "com.apple.mouse.tapBehavior" = 1;
                    "com.apple.sound.beep.feedback" = 1;
                    "com.apple.springing.enabled" = true;
                    "com.apple.swipescrolldirection" = true;
                    AppleICUForce24HourTime = true;
                    AppleInterfaceStyleSwitchesAutomatically = true;
                    AppleKeyboardUIMode = 3;
                    AppleMeasurementUnits = "Centimeters";
                    AppleMetricUnits = 1;
                    AppleScrollerPagingBehavior = true; # jump to clicked scrollbar position
                    AppleShowAllExtensions = true;
                    AppleShowAllFiles = true;
                    AppleShowScrollBars = "Always";
                    AppleTemperatureUnit = "Celsius";
                    InitialKeyRepeat = 15;
                    KeyRepeat = 2;
                    NSDisableAutomaticTermination = true;
                    NSDocumentSaveNewDocumentsToCloud = false;
                    NSNavPanelExpandedStateForSaveMode = true;
                    NSNavPanelExpandedStateForSaveMode2 = true;
                    NSScrollAnimationEnabled = true; # smooth scrolling
                    NSTableViewDefaultSizeMode = 1; # 2, 3
                    NSTextShowsControlCharacters = true;
                    NSWindowShouldDragOnGesture = true; # drag holding anywhere like on linux
                    _HIHideMenuBar = false;
                  };
                  SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
                  controlcenter.Bluetooth = false;
                  dock = {
                    appswitcher-all-displays = true;
                    autohide = true;
                    autohide-delay = 0.0;
                    autohide-time-modifier = 0.0;
                    dashboard-in-overlay = true;
                    enable-spring-load-actions-on-all-items = true;
                    launchanim = true;
                    minimize-to-application = true;
                    mouse-over-hilite-stack = true;
                    mru-spaces = true;
                    orientation = "bottom";
                    show-process-indicators = true;
                    show-recents = false;
                    showhidden = false;
                    tilesize = 64;
                    # 10: Put Display to Sleep
                    # 11: Launchpad
                    # 12: Notification Center
                    # 13: Lock Screen
                    # 14: Quick Note
                    # 1: Disabled
                    # 2: Mission Control
                    # 3: Application Windows
                    # 4: Desktop
                    # 5: Start Screen Saver
                    # 6: Disable Screen Saver
                    # 7: Dashboard
                    wvous-bl-corner = 1;
                    wvous-br-corner = 1;
                    wvous-tl-corner = 1;
                    wvous-tr-corner = 1;
                  };
                  finder = {
                    # NewWindowTargetPath # url-escaped file:/// uri
                    # NewWindowTarget # “Computer”, “OS volume”, “Home”, “Desktop”, “Documents”, “Recents”, “iCloud Drive”, “Other”
                    AppleShowAllExtensions = true;
                    AppleShowAllFiles = true;
                    FXDefaultSearchScope = "SCcf";
                    FXPreferredViewStyle = "icnv"; # = Icon view, “Nlsv” = List view, “clmv” = Column View, “Flwv” = Gallery View
                    QuitMenuItem = true;
                    ShowExternalHardDrivesOnDesktop = true;
                    ShowHardDrivesOnDesktop = true;
                    ShowMountedServersOnDesktop = true;
                    ShowPathbar = true;
                    ShowRemovableMediaOnDesktop = true;
                    ShowStatusBar = true;
                    _FXShowPosixPathInTitle = false;
                    _FXSortFoldersFirst = true;
                    _FXSortFoldersFirstOnDesktop = true;
                  };
                  # “Change Input Source”, “Show Emoji & Symbols”, “Start Dictation”
                  hitoolbox.AppleFnUsageType = "Do Nothing";
                  loginwindow = {
                    DisableConsoleAccess = true;
                    GuestEnabled = true;
                    SHOWFULLNAME = true;
                  };
                  menuExtraClock = {
                    FlashDateSeparators = true;
                    ShowDayOfMonth = true;
                    ShowDayOfWeek = true;
                    ShowSeconds = true;
                  };
                  screensaver = {
                    askForPassword = true;
                    askForPasswordDelay = 0;
                  };
                  screencapture = {
                    location = "~/Desktop/Screenshots";
                    type = "png";
                    disable-shadow = false;
                  };
                  trackpad = {
                    Clicking = true;
                    Dragging = true;
                    FirstClickThreshold = 0;
                    SecondClickThreshold = 1;
                    TrackpadThreeFingerDrag = false;
                    TrackpadThreeFingerTapGesture = 2;
                  };
                }; # defaults }}}
                keyboard = {
                  enableKeyMapping = true;
                };
              };

              # The user should already exist, but we need to set this up so Nix knows
              # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
              users.users."${currentSystemUser}" = {
                home = "/Users/${currentSystemUser}";
              };
              users.knownGroups = [config.users.groups.keys.name];
              users.groups.keys = {
                gid = 69420;
                members = ["${currentSystemUser}"];
              };
              # dock {{{
              local.dock = {
                enable = true;
                entries = [
                  {path = "/Applications/Safari.app";}
                  {
                    path = "${
                      # pkgs.moonlight-qt
                      ""
                    }/Applications/Moonlight.app";
                  }
                  {path = "/Applications/Telegram.app";}
                  {path = "${pkgs.zhuk.thorium-browser}/Applications/Thorium.app";}
                  {path = "${pkgs.zhuk.ghostty}/Applications/Ghostty.app";}
                  # {path = "${users.users."${currentSystemUser}".home}/Applications/Home Manager Apps/Librewolf.app";}
                  {
                    path = "/Applications";
                    section = "others";
                    options = "--sort name --view grid --display stack";
                  }
                  {
                    path = "/Users/${currentSystemUser}/Downloads";
                    section = "others";
                    options = "--sort dateadded --view grid --display folder";
                  }
                ];
              };
              # dock }}}
            };
            "${bts false}" = {
              currentSystemUser,
              pkgs,
              ...
            }: let
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmqp+RfNqw0LXFBRe0WNL+0+YzlMlfztMMzJmnGtMmw"
              ];
            in {
              programs.nh = {
                enable = true;
                package = pkgs.nh;
              };
              environment = {
                localBinInPath = true;
              };
              documentation = {
                dev.enable = true;
                nixos.enable = true;
              };
              services = {
                openssh = {
                  enable = true;
                  settings = {
                    PermitRootLogin = "yes";
                    PasswordAuthentication = false;
                  };
                  openFirewall = true;
                };
              };
              users.users = {
                "${currentSystemUser}" = {
                  uid = 1000;
                  isNormalUser = true;
                  home = "/home/${currentSystemUser}";
                  extraGroups = [
                    "wheel"
                  ];
                  initialHashedPassword = "$6$rounds=6901337$dkuHV9Y6YarEavnp$nfsXc1d3F5T/RbzUPtHSvYKw8NSr1lQpLVyxfx6PgCgdlbSEvpPy9D4utNZ6Khf1VU8b0UrpdqM4sBECJsU8q1";
                  openssh.authorizedKeys.keys = keys;
                  linger = true; # run user's units independent of login
                };
                root = {
                  extraGroups = [
                  ];
                  initialHashedPassword = "$6$rounds=6901337$YAbU3RUwNYFvWBXh$vqAhp0Y8Heiuwwdf0EbYMa.l61WwhNveASUIPf2KBwE8/k/PSUGxxMM9Xd7kYDkM/m0446w8Cts8iN0Kst81D0";
                  openssh.authorizedKeys.keys = keys;
                };
              };
              nix = {
                checkAllErrors = true;
                gc = {
                  automatic = false;
                  dates = "daily";
                  persistent = true;
                };
                optimise = {
                  persistent = true;
                  dates = ["daily"];
                };
                extraOptions = ''
                  experimental-features = nix-command flakes
                  keep-outputs = true
                  keep-derivations = true
                '';
              };
              i18n = {
                defaultLocale = "C.UTF-8";
                extraLocaleSettings = {
                  LC_ALL = "C.UTF-8";
                };
              };
              security.audit.enable = true;
            };
          }."${bts isDarwin}"
          # system-specific }}}
          # module arguments {{{
          {
            config._module.args = {
              currentSystem = system;
              currentSystemUser = user;
              currentSystemName = name;
              currentUserShell = builtins.trace "Current shell: ${shell}" shell;
              inherit isWSL;
              inherit isDarwin;
              inherit inputs;
            };
          }
          # module arguments }}}
          # nixpkgs settings & overlays {{{
          (
            _: {
              nixpkgs = {
                config.allowUnfree = true;
                inherit overlays;
                flake.setFlakeRegistry = false; # set manually along with all other inputs
                flake.setNixPath = false; # ditto
              };
            }
          )
          # nixpkgs settings & overlays }}}
          # nix-index-database {{{
          inputs.nix-index-database."${
            if isDarwin
            then "darwin"
            else "nixos"
          }Modules".nix-index
          # nix-index-database }}}
          # nix-homebrew {{{
          (
            if isDarwin
            then inputs.nix-homebrew.darwinModules.nix-homebrew
            else {}
          )
          (
            if isDarwin
            then {
              nix-homebrew = {
                enable = true;
                user = "${user}";
                taps = {
                  "homebrew/homebrew-core" = inputs.homebrew-core;
                  "homebrew/homebrew-cask" = inputs.homebrew-cask;
                  "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            else {}
          )
          # nix-homebrew }}}
          # nixos-wsl {{{
          (
            if isWSL
            then inputs.nixos-wsl.nixosModules.wsl
            else {}
          )
          # nixos-wsl }}}
          # sops-nix {{{
          inputs.sops-nix."${
            if isDarwin
            then "darwin"
            else "nixos"
          }Modules".sops
          # sops-nix }}}
        ];
      };
    # mkSystem }}}
  in {
    # packages {{{
    packages =
      forEachSupportedSystem
      overlays (
        {pkgs, ...}: {
          nvim = pkgs.nvim-wrapped;
          tmux = pkgs.tmux-wrapped;
        }
      );
    # packages }}}
    # formatter {{{
    formatter = forEachSupportedSystem [] (
      {system, ...}:
        inputs.nfp.lib.mkFormatter {
          inherit system;
          inherit (inputs) nixpkgs;
          config = {
            tools = {
              deadnix.enable = true;
              alejandra.enable = true;
              statix.enable = true;
            };
          };
        }
    );
    # formatter }}}
    # checks {{{
    checks = forEachSupportedSystem [] (
      {system, ...}: {
        nfp = inputs.nfp.lib.mkCheck {
          inherit system;
          inherit (inputs) nixpkgs;
          config = {
            tools = {
              deadnix.enable = true;
              alejandra.enable = true;
              statix.enable = true;
            };
          };
          checkFiles = ["./."];
        };
      }
    );
    # checks }}}
    nixosConfigurations = {
      wsl = mkSystem "wsl" {
        system = "x86_64-linux";
        user = "zhuher";
        shell = "zsh";
        isWSL = true;
      };
    };
    darwinConfigurations = {
      macbook-KY7WHGYV1Y = mkSystem "macbook-KY7WHGYV1Y" {
        system = "aarch64-darwin";
        user = "ge.zhukov";
        shell = "zsh";
        isDarwin = true;
      };
      gandalf = mkSystem "gandalf" {
        system = "aarch64-darwin";
        user = "zhuher";
        shell = "zsh";
        isDarwin = true;
      };
    };
    templates = builtins.mapAttrs (name: _type: {
      path = ./shells/${name};
    }) (builtins.readDir ./shells);
  };
}
