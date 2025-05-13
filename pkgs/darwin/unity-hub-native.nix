{
  lib,
  fetchurl,
  stdenv,
  unzip,
  darwin,
}:
let
  pname = "unity-hub-native";
  version = "1.57";
in
stdenv.mkDerivation rec {

  inherit pname version;

  src = fetchurl {
    url = "https://github.com/Ravbug/UnityHubNative/releases/download/${version}/UnityHubNative-macOS.zip";
    sha256 = "sha256-ypuYjD3Rdt6s57hoUXc/oVuBne6sHYUe5iqq/dvunC0=";
  };

  nativeBuildInputs = [
    unzip
    darwin.autoSignDarwinBinariesHook
  ];

  unpackPhase = ''
    runHook preUnpack
    unzip ${src}
    unzip UnityHubNative.zip
    runHook postInstall
  '';

  sourceRoot = "UnityHubNative.app";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/UnityHubNative.app $out/bin
    cp -R . $out/Applications/UnityHubNative.app
    ln -s ../Applications/UnityHubNative.app/Contents/MacOS/UnityHubNative $out/bin/unityhubnative

    runHook postInstall
  '';

  meta = {
    description = "A native alternative to the heavy Electron Unity Hub, written in C++";
    homepage = "https://github.com/Ravbug/UnityHubNative";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ zhuher ];
    mainProgram = "unityhubnative";
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
