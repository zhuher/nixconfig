final: _prev: {
  # zig = final.zigpkgs."0_15_2";
  # zls = final.zigpkgs."0_15_2".zls;
  # wrappers {{{
  # bat {{{
  bat-wrapped = with final;
    symlinkJoin {
      name = "bat-wrapped";
      paths = [bat];
      nativeBuildInputs = [makeBinaryWrapper];
      postBuild = ''
        wrapProgram $out/bin/bat --set-default \
        BAT_CONFIG_PATH ${../configs/bat}
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
        ${../configs/tmux.conf}
      '';
    };
  # tmux }}}
  # nvim {{{
  nvim-wrapped = with final;
    symlinkJoin {
      name = "nvim";
      paths = [neovim-unwrapped];
      nativeBuildInputs = [makeBinaryWrapper];
      postBuild = ''
        wrapProgram $out/bin/nvim \
        --add-flags '-u' \
        --add-flags '${../configs/nvim.lua}' \
        --prefix PATH : ${final.lib.makeBinPath (with final; [git emmylua-ls])}
      '';
    };
  # nvim }}}
  # wrappers }}}
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
  syncthing =
    final.callPackage (
      {
        lib,
        fetchurl,
        stdenvNoCC,
        # clangStdenv,
        go,
        apple-sdk_15,
        darwin,
        zig,
        writeShellScriptBin,
      }: let
        pname = "syncthing";
        version = "2.0.14";
        sysroot = "${apple-sdk_15}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk";
        zigbin = lib.getExe' zig "zig";
        zigargs =
          if stdenv.isDarwin
          then "${zigbin} cc -O3 -march=native -I${sysroot}/usr/include -L${sysroot}/usr/lib -L${darwin.libresolv}/lib -F${sysroot}/System/Library/Frameworks -Wno-typedef-redefinition -Wno-newline-eof -Wno-nullability-extension -Wno-strict-prototypes -Wno-macro-redefined -Wno-deprecated-declarations -Wno-undef -Wno-tautological-compare -Wno-documentation -Wno-documentation-unknown-command -Wno-nullability-completeness -Wno-date-time -Wno-unknown-warning-option -Wno-availability -Wno-overriding-deployment-version -Xclang -Ofast"
          else "${zigbin} cc";
        zigc = writeShellScriptBin "clang" ''
          exec -a ${zigbin} ${zigargs} $@
        '';
        stdenv = stdenvNoCC;
        # stdenv = clangStdenv;
      in
        stdenv.mkDerivation {
          inherit pname version;

          strictDeps = true;

          nativeBuildInputs = [
            zigc
            go
          ];

          src = fetchurl {
            url = "https://github.com/syncthing/syncthing/releases/download/v${version}/syncthing-source-v${version}.tar.gz";
            sha256 = "sha256-/sNs4gu81ubRy3DPsK96RcYiFYE2HZu5KAc4myRwOgI=";
          };
          env = {
            CGO_ENABLED = 1;
          };

          buildPhase = ''
            runHook preBuild
            # We change HOME to a writable location to avoid this error during the build: failed to initialize build cache at /homeless-shelter/Library/Caches/go-build: mkdir /homeless-shelter: operation not permitted
            HOME=$TMPDIR
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
    ) {
      #inherit (final) zig;
    };
  # syncthing }}}
  writeZig = zig: name: text: args: let
    src = final.writeText "${name}.zig" text;
  in
    final.runCommand name {
      nativeBuildInputs = [zig];
    } ''
      mkdir -p $out/bin
      zig build-exe ${src} --global-cache-dir "$TMPDIR" --cache-dir "$TMPDIR" --name ${name} ${args}
      mv ${name} $out/bin/${name}
    '';
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
          sha256 = "sha256-nfp+j/cmDcAyqtVnYpmo0uQp5A6lQlvsUXB+r4HukT8=";
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
    emacs = let
      # compilation opts {{{
      epkg = final.emacs-git.override {
        # # Boolean flags
        # withNativeCompilation ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
        # noGui ? false,
        # srcRepo ? false,
        # withAcl ? false,
        # withAlsaLib ? false,
        # withAthena ? false,
        # withCairo ? withX,
        # withCsrc ? true,
        # withDbus ? stdenv.hostPlatform.isLinux,
        # # https://github.com/emacs-mirror/emacs/blob/emacs-30.2/etc/NEWS#L52-L56
        # withGcMarkTrace ? false,
        # withGTK3 ? withPgtk && !noGui,
        # withGlibNetworking ? withPgtk || withGTK3 || (withX && withXwidgets),
        # withGpm ? stdenv.hostPlatform.isLinux,
        # # https://github.com/emacs-mirror/emacs/blob/emacs-27.2/etc/NEWS#L118-L120
        # withImageMagick ? false,
        # # Emacs 30+ has native JSON support
        # withJansson ? lib.versionOlder version "30",
        # withMailutils ? true,
        # withMotif ? false,
        # withNS ? stdenv.hostPlatform.isDarwin && !(variant == "macport" || noGui),
        # withPgtk ? false,
        # withSelinux ? stdenv.hostPlatform.isLinux,
        # withSQLite3 ? true,
        # withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
        # withToolkitScrollBars ? true,
        # withTreeSitter ? true,
        # withWebP ? true,
        # withX ? !(stdenv.hostPlatform.isDarwin || noGui || withPgtk),
        # withXinput2 ? withX,
        # withXwidgets ?
        #   !noGui
        #   && (withGTK3 || withPgtk || withNS || variant == "macport")
        #   && (stdenv.hostPlatform.isDarwin || lib.versionOlder version "30"),
        # # XXX: - upstream bug 66068 precludes newer versions of webkit2gtk (https://lists.gnu.org/archive/html/bug-gnu-emacs/2024-09/msg00695.html)
        # # XXX: - Apple_SDK WebKit is compatible with Emacs.
        # withSmallJaDic ? false,
        withSmallJaDic = true;
        # withCompressInstall ? true,
      }; # compilation opts }}} # final.callPackage "${final.helix}/grammars.nix" {};
    in
      {
        "aarch64-darwin" =
          # emacs on darwin {{{
          # (final.emacsPackagesFor (
          epkg.overrideAttrs (old: {
            __noChroot = true; # [INFO]: cannot access /etc/ssl/certs otherwise (Operation not permitted)
            nativeBuildInputs = (old.nativeBuildInputs or []) ++ [_prev.makeBinaryWrapper];
            postInstall =
              (old.postInstall or "")
              + ''
                emacs_version=$(ls "$out/share/emacs" | grep -E '^[0-9]' | sort -V | tail -1)
                old_pdmp=$(find "$out/libexec/emacs/$emacs_version" -name 'emacs-*.pdmp' 2>/dev/null | head -1)
                if [ -n "$old_pdmp" ]; then
                  tmp_pdmp="$old_pdmp.tmp"
                  eln_dir="$out/lib/emacs/$emacs_version/native-lisp"
                  elisp_file=$(mktemp "$TMPDIR/emacs-redump-XXXXXX.el")
                  cat > "$elisp_file" << ELISP
                ; Fix pdmp-frozen variables that point to the build sandbox.
                (when (boundp 'native-comp-eln-load-path)
                  (setq native-comp-eln-load-path (list "$eln_dir/")))
                (setq temporary-file-directory "/tmp/")
                ; source-directory captures the unpacked build tree path. Emacs source
                ; is not installed to the store, but $out is a better fallback than a
                ; stale sandbox path — prevents "Listing directory failed" errors from
                ; xref/find-function trying to scan the missing build dir.
                (setq source-directory "$out/share/emacs/$emacs_version/src/")
                ; package-directory-list is frozen in the pdmp at emacs-git build time
                ; when no user packages are present. When this emacs is later used to
                ; build elisp packages, EMACSLOADPATH adds deps to load-path but
                ; package-directory-list (already bound → defcustom is a no-op) does
                ; not include their elpa dirs, so package-activate-all cannot find deps.
                ;
                ; Fix: use with-eval-after-load so that AFTER package.el loads (triggered
                ; by the -f package-activate-all autoload), we reset package-directory-list
                ; from the current load-path (which includes EMACSLOADPATH additions) and
                ; call package-initialize to populate package-alist.
                ;
                ; NOTE: advice-add before package.el loads is wiped when defun redefines
                ; the symbol; with-eval-after-load ensures the hook runs after defun.
                ; Gate on noninteractive: in interactive Emacs, package-activate-all is
                ; called at startup which triggers this hook and resets package-alist,
                ; breaking package activation (org-mode not rendering, treesit nil, etc.).
                ; Only batch/build-time invocations need this fix.
                (with-eval-after-load 'package
                  (when noninteractive
                    (setq package-directory-list
                      (let (result)
                        (dolist (f load-path)
                          (and (stringp f)
                               (equal (file-name-nondirectory f) "site-lisp")
                               (push (expand-file-name "elpa" f) result)))
                        (nreverse result)))
                    (unless (bound-and-true-p package--initialized)
                      (package-initialize t))))
                ; Re-enable global minor modes that batch mode leaves disabled but
                ; the original pdmp (built by loadup.el) had enabled. Without this,
                ; interactive Emacs inherits the batch-mode nil state.
                (global-font-lock-mode 1)
                (transient-mark-mode 1)
                (dump-emacs-portable "$tmp_pdmp")
                ELISP
                  EMACSDATA="$out/share/emacs/$emacs_version/etc" \
                  EMACSLOADPATH="$out/share/emacs/$emacs_version/lisp:" \
                    "$out/bin/emacs" \
                      --dump-file "$old_pdmp" \
                      --batch \
                      --no-site-file \
                      --load "$elisp_file" \
                    && mv "$tmp_pdmp" "$old_pdmp" \
                    || echo "Warning: emacs re-dump failed, continuing with original pdmp"
                  rm -f "$elisp_file"
                fi
                wrapProgram "$out/bin/emacs" \
                  --set-default EMACSDATA "$out/share/emacs/$emacs_version/etc"
              '';
            patches =
              old.patches
              ++ [
                # order taken from https://github.com/bbenchen/homebrew-emacs-plus/blob/9976d930dd3296a12474c08dc215ad6ac49ca5d8/Formula/emacs-plus%4031.rb#L107-L116
                # and mixed with https://github.com/d12frosted/homebrew-emacs-plus/blob/df393ba5a3f10183fe77a3cf792d15cded73595d/Formula/emacs-plus%4031.rb#L75-L77
                # (final.fetchpatch {
                #   url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/df393ba5a3f10183fe77a3cf792d15cded73595d/patches/emacs-31/fix-ns-x-colors.patch";
                #   sha256 = "sha256-oe3DFgEXwp0cZJl+ufWqTonaeWSliikTRsVDNbcy4Yw=";
                # })
                (final.fetchpatch {
                  url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/3e95d573d5f13aba7808193b66312b38a7c66851/patches/emacs-31/system-appearance.patch";
                  sha256 = "sha256-4+2U+4+2tpuaThNJfZOjy1JPnneGcsoge9r+WpgNDko=";
                })
                (final.fetchpatch {
                  url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/3e95d573d5f13aba7808193b66312b38a7c66851/patches/emacs-31/round-undecorated-frame.patch";
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
                # (final.writeText "interactive-ns_init_colors.patch" ''
                #   Skip NS color initialization in batch mode (bug#80377 workaround)
                #
                #   Commit b7aca342e6 moved ns_init_colors() to main() in emacs.c before
                #   init_lread().  At that point data-directory still holds the stale value
                #   from the pdump (the build sandbox path) because init_lread() has not
                #   recalculated it yet.  In Nix builds the sandbox path no longer exists,
                #   so reading rgb.txt fails and kills the process.
                #
                #   Guard the call with !noninteractive so batch-mode byte-compilation
                #   (used by Nix elisp package builds) skips color init entirely.
                #
                #   Trade-off: elisp running in --batch that queries X11 color names will
                #   not have the full color list.  This is acceptable because batch mode
                #   has no display and color queries are meaningless there.
                #
                #   diff --git a/src/emacs.c b/src/emacs.c
                #   index 8e3d528dcea..01a971095bd 100644
                #   --- a/src/emacs.c
                #   +++ b/src/emacs.c
                #   @@ -2066,7 +2066,7 @@ Using an Emacs configured with --with-x-toolkit=lucid does not have this problem
                #
                #    #ifdef HAVE_NS
                #      /* For early calls to ns_lisp_to_color or Fns_list_colors.  */
                #   -  if (!dump_mode)
                #   +  if (!dump_mode && !noninteractive)
                #        ns_init_colors ();
                #
                #      if (!noninteractive)
                # '')
              ];
          })
          # )).emacsWithPackages
          # (epkgs: with epkgs; [treesit-grammars.with-all-grammars])
          ; # emacs on darwin }}}
        "x86_64-linux" = (final.emacsPackagesFor epkg).emacsWithPackages (epkgs:
          with epkgs; [
            treesit-grammars.with-all-grammars
          ]);
      }."${final.stdenv.hostPlatform.system}";
  };
}
