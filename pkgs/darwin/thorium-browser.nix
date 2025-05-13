{
  lib,
  fetchurl,
  stdenv,
  undmg,
}:
let
  pname = "thorium-browser";
  version = "130.0.6723.174";
in
stdenv.mkDerivation {

  inherit pname version;

  src = fetchurl {
    url = "https://github.com/Alex313031/Thorium-MacOS/releases/download/M${version}/Thorium_MacOS_ARM.dmg";
    sha256 = "sha256-uhxFpSlixffZspN1exynRWFx4kCSfDDc2vf9SNLcjAQ=";
  };

  nativeBuildInputs = [ undmg ];

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
    maintainers = with lib.maintainers; [ zhuher ];
    mainProgram = "Thorium";
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
