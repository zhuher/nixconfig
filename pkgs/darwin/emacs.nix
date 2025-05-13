{
  pkgs,
  withCustomPackages ? false,
}:
let
  epkgFromGitHub =
    {
      pname,
      version,
      owner,
      repo,
      rev,
      hash,
      deps ? [ ],
    }:
    pkgs.callPackage
      (
        { trivialBuild }:
        trivialBuild {
          inherit pname version;
          src = pkgs.fetchFromGitHub {
            inherit
              owner
              repo
              rev
              hash
              ;
          };
          buildInputs = deps;
        }
      )
      {
        trivialBuild = pkgs.emacs.pkgs.trivialBuild;
      };
  emacsPkg = pkgs.emacs-git;
in
if withCustomPackages then
  ((pkgs.emacsPackagesFor emacsPkg).emacsWithPackages (
    epkgs:
    (with epkgs.melpaPackages; [
      folding
      apheleia
      anzu
      base16-theme
      corfu
      envrc
      doom-modeline
      doom-themes
      flycheck
      helpful
      lsp-mode
      lsp-ui
      marginalia
      meow
      nerd-icons
      nerd-icons-completion
      nerd-icons-corfu
      nerd-icons-dired
      nerd-icons-ibuffer
      nix-ts-mode
      orderless
      rust-mode
      rustic
      vertico
      whitespace-cleanup-mode
      yaml-pro
      exec-path-from-shell
    ])
    ++ (with epkgs.nongnuPackages; [
      corfu-terminal
    ])
    ++ [
      epkgs.tree-sitter
      epkgs.tree-sitter-langs
      epkgs.treesit-grammars.with-all-grammars
      (epkgFromGitHub {
        pname = "copilot";
        version = "0.0.1";
        owner = "copilot-emacs";
        repo = "copilot.el";
        rev = "88b10203705a9cdcbc232e7d2914f6b12217a885";
        hash = "sha256-oTAxayxrEiIu0GUtsqaL/pCY0ElU1RjZp7OXgqqJqnA=";
        deps = with epkgs; [
          f
          dash
          editorconfig
          s
        ];
      })
      (epkgFromGitHub {
        pname = "treesit-fold";
        version = "0.1.0";
        owner = "emacs-tree-sitter";
        repo = "treesit-fold";
        rev = "0e21e12560f0977d390e3d4af45020f0f6db1c15";
        hash = "sha256-ZuL9k7jTUqU+/MbvzOBkJN82REbFQHRx1CpyaZKxLRQ=";
      })
      (epkgFromGitHub {
        pname = "zig-ts-mode";
        version = "0.1.0";
        owner = "Ziqi-Yang";
        repo = "zig-ts-mode";
        rev = "020500ac3c9ac2cadedccb5cd6c506eb38327443";
        hash = "sha256-vstl13IWwAxaQTsy/bn/uCet4Oxm2edKjmwREfhNAk8=";
      })
    ]
  ))
else
  emacsPkg
