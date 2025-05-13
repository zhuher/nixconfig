{
  lib,
  fetchurl,
  stdenv,
  _7zz,
}:
let
  pname = "ghostty-darwin";
  version = "1.1.3";
in
stdenv.mkDerivation {
  inherit pname version;
  src = fetchurl {
    url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
    sha256 = "sha256-ZOUUGI9UlZjxZtbctvjfKfMz6VTigXKikB6piKFPJkc=";
  };

  outputs = [
    "out"
    "terminfo"
  ];

  nativeBuildInputs = [ _7zz ];

  sourceRoot = "Ghostty.app";

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
      builtins.replaceStrings [ "." ] [ "-" ] version
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
}
