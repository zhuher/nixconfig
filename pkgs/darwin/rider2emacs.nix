{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "rider2emacs";
  version = "0.1.1";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-7HvdrzSeoIhWy2y7UPwJfZ9/ckxXrHCPW/3J+FjQPAI=";
  };

  cargoHash = "sha256-5FG7rhcqY27YO2F858/DsfVGQuwNI8hdRDvHh6NmqQE=";
  cargoDepsName = pname;
  useFetchCargoVendor = true;
  meta = {
    description = "Translates JetBrains Rider invocations to emacsclient invocations (for Unity)";
    homepage = "https://github.com/elizagamedev/rider2emacs";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
