{
  lib,
  fetchurl,
  stdenv,
  gnutar,
}:
let
  pname = "monero-cli";
  version = "0.18.3.4";
in
stdenv.mkDerivation {

  inherit pname version;

  src = fetchurl {
    url = "https://downloads.getmonero.org/cli/macarm8";
    sha256 = "sha256-RFIMs6BcJRjKmurhsuMID+K7oeNZbQFM7/EJDfy6irQ=";
  };

  nativeBuildInputs = [ gnutar ];

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
    maintainers = with lib.maintainers; [ zhuher ];
    # mainProgram = "monerod";
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
