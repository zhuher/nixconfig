{
  lib,
  fetchurl,
  stdenv,
  _7zz,
  darwin,
}:
let
  pname = "ayugram";
  version = "5.8.3";
in
stdenv.mkDerivation {

  inherit pname version;

  src = fetchurl {
    url = "https://github.com/AyuGram/AyuGramDesktop/releases/download/v${version}/AyuGram.dmg";
    sha256 = "sha256-d2kEgTkyRwBln3P1K3A6Zav7ceZ2jtw9MphHNWWjGEk=";
  };

  nativeBuildInputs = [
    _7zz
    darwin.autoSignDarwinBinariesHook
  ];

  sourceRoot = "AyuGram.app";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications/AyuGram.app" $out/bin
    cp -R . "$out/Applications/AyuGram.app"
    ln -s "../Applications/AyuGram.app/Contents/MacOS/AyuGram" $out/bin

    runHook postInstall
  '';

  meta = {
    description = "AyuGram, a Telegram client with le ebic features : - DDDD";
    homepage = "https://example.org/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ zhuher ];
    mainProgram = "AyuGram";
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
