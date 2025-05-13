{
  lib,
  fetchFromGitHub,
  gnumake,
  stdenvNoCC,
  go,
}:
let
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
    # We change HOME to a writable location to avoid this error: failed to initialize build cache at /homeless-shelter/Library/Caches/go-build: mkdir /homeless-shelter: operation not permitted
    HOME="$(pwd)"
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
    maintainers = with lib.maintainers; [ zhuher ];
    mainProgram = "mullvad-upgrade-tunnel";
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
