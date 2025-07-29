{
  pkgs,
  isDarwin,
  inputs,
  isWSL,
  currentSystemUser,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${currentSystemUser} = let
      lwHome = "${
        if isDarwin
        then "Library/Application Support/"
        else "."
      }librewolf";
    in {
      # For our MANPAGER env var
      # https://github.com/sharkdp/bat/issues/1145
      manual.manpages.enable = true;
      home = {
        stateVersion = "25.11";
        file = {
          "${lwHome}/Profiles/lirililarilla/chrome" = {
            source = "${inputs.gwfox}/chrome";
            recursive = true;
          };
          "${lwHome}/Profiles/${currentSystemUser}/chrome" = {
            source = "${inputs.gwfox}/chrome";
            recursive = true;
          };
        };
      };
      # firefox {{{
      programs.firefox =
        # https://github.com/llakala/nixos/tree/3ae839c3b3d5fd4db2b78fa2dbb5ea1080a903cd/apps/programs/firefox
        let
          lw = pkgs.librewolf;
        in {
          enable = !isWSL;
          package = lw;
          configPath = lwHome;
          profilesPath = "${lwHome}/Profiles";
          policies = {
            Extensions = {
              Uninstall = [];
              Install = [];
            };
            SearchEngines = {
              Remove = [];
              Default = "Google";
              Add = [];
            };
            Preferences = let
              lock = Value: {
                inherit Value;
                Status = "locked";
              };
            in {
              "browser.startup.homepage" = lock "https://news.ycombinator.com";
              "toolkit.legacyUserProfileCustomizations.stylesheets" = lock true;
              "browser.warnOnQuitShortcut" = lock false;
              "browser.sessionstore.closedTabsFromClosedWindows" = lock false;
              "browser.sessionstore.closedTabsFromAllWindows" = lock false;
              "security.OCSP.require" = lock false;
              "browser.tabs.closeWindowWithLastTab" = lock false;
            };
            ExtensionSettings = with builtins; let
              extension = {
                uuid,
                install_url,
                default_area ? "menupanel",
                private_browsing ? false,
              }: {
                name = install_url;
                value = {
                  install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${uuid}/latest.xpi";
                  installation_mode = "force_installed";
                  inherit default_area private_browsing;
                };
              };
              customExt = {
                uuid,
                install_url,
                default_area ? "menupanel",
                private_browsing ? false,
              }: {
                name = uuid;
                value = {
                  inherit install_url default_area private_browsing;
                  installation_mode = "force_installed";
                };
              };
              a2 = uuid: install_url: {inherit uuid install_url;};
              a3 = uuid: install_url: private_browsing: {
                inherit uuid install_url private_browsing;
                default_area = "menupanel";
              };
              a4 = uuid: install_url: default_area: private_browsing: {
                inherit
                  uuid
                  install_url
                  default_area
                  private_browsing
                  ;
              };
            in
              # extensions {{{
              listToAttrs (
                [
                  (extension (a4 "ublock-origin" "uBlock0@raymondhill.net" "navbar" true))
                  (extension (a3 "libredirect" "7esoorv3@alefvanoon.anonaddy.me" true))
                  (extension (a3 "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}" true))
                  (extension (a3 "port-authority" "{6c00218c-707a-4977-84cf-36df1cef310f}" true))
                  (extension (a2 "search_by_image" "{2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c}"))
                  (extension (
                    a4 "terms-of-service-didnt-read" "jid0-3GUEt1r69sQNSrca5p8kx9Ezc3U@jetpack" "navbar" true
                  ))
                  (extension (a2 "pstream-extension" "{0c3fcdbd-5e0f-40d5-8f6c-d5eef8ff2b7c}"))
                  (extension (a2 "syncshare" "syncshare@naloaty.me"))
                  (extension (a2 "violentmonkey" "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}"))
                  # (extension (a2 "vknext" "addon@vknext.net"))
                  (extension (a4 "xbs" "{019b606a-6f61-4d01-af2a-cea528f606da}" "navbar" false))
                  (extension (a2 "augmented-steam" "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}"))
                  (extension (a2 "behind" "{d6005a62-1fdb-4cf2-b5ef-21b865d894f7}"))
                  (extension (a2 "bookmark-dupes" "bookmarkdupes@martin-vaeth.org"))
                  (extension (a3 "canvasblocker" "CanvasBlocker@kkapsner.de" true))
                  (extension (a3 "chameleon-ext" "{3579f63b-d8ee-424f-bbb6-6d0ce3285e6a}" true))
                  (extension (a4 "cookie-autodelete" "CookieAutoDelete@kennydo.com" "navbar" true))
                  (extension (a2 "cookie-quick-manager" "{60f82f00-9ad5-4de5-b31c-b16a47c51558}"))
                  (extension (a2 "cookies-txt" "{12cf650b-1822-40aa-bff0-996df6948878}"))
                  (extension (a3 "fastforwardteam" "addon@fastforward.team" true))
                  (extension (a4 "istilldontcareaboutcookies" "idcac-pub@guus.ninja" "navbar" true))
                  (extension (a2 "indie-wiki-buddy" "{cb31ec5d-c49a-4e5a-b240-16c767444f62}"))
                  # (extension (
                  #   a4 "localcdn-fork-of-decentraleyes" "{b86e4813-687a-43e6-ab65-0bde4ab75758}" "menupanel" true
                  # ))
                  (customExt (
                    a4 "{d19a89b9-76c1-4a61-bcd4-49e8de916403}"
                    "https://github.com/mullvad/browser-extension/releases/download/v0.9.4-firefox-beta/mullvad-browser-extension-0.9.4.xpi"
                    "navbar"
                    true
                  ))
                  (customExt (
                    a2 "magnolia@12.34" "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-latest.xpi"
                  ))
                ]
                ++ (
                  if isDarwin
                  then [(extension (a4 "strongbox-autofill" "strongbox@phoebecode.com" "navbar" true))]
                  else [(extension (a4 "keepassxc-browser" "keepassxc-browser@keepassxc.org" "navbar" true))]
                )
              ); # extensions }}}
            # To add additional extensions, find it on addons.mozilla.org, find
            # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
            # Then, download the XPI by filling it in to the install_url template, unzip it,
            # run `jq .browser_specific_settings.gecko.id manifest.json` or
            # `jq .applications.gecko.id manifest.json` to get the UUID
          };
          profiles = let
            search = {
              force = true;
              engines = {
                annas-archive = {
                  # https://annas-archive.org/search?desc=1&q=%s
                  name = "Anna's Archive";
                  urls = [{template = "https://annas-archive.org/search?desc=1&q={searchTerms}";}];
                  icon = "https://annas-archive.org/favicon.ico";
                  definedAliases = ["@aa"];
                };
                nix-packages = {
                  name = "Nix Packages";
                  urls = [{template = "https://search.nixos.org/packages?channel=unstable&size=500&sort=relevance&query={searchTerms}";}];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = ["@np"];
                };
                nix-options = {
                  name = "Nix Options";
                  urls = [{template = "https://search.nixos.org/options?channel=unstable&size=500&sort=relevance&query={searchTerms}";}];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = ["@no"];
                };
                sourcegraph-public = {
                  name = "SourceGraph Public Code";
                  urls = [{template = "https://sourcegraph.com/search?q={searchTerms}";}];
                  icon = "https://sourcegraph.com/.assets/img/sourcegraph-mark.svg";
                  definedAliases = ["@sg"];
                };
                nixos-wiki = {
                  name = "NixOS Wiki";
                  urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = ["@nw"];
                };
                mynixos-com = {
                  name = "MyNixOS";
                  urls = [{template = "https://mynixos.com/search?q={searchTerms}";}];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
                  definedAliases = ["@n"];
                };
                home-manager-options = {
                  name = "Home Manager Options";
                  urls = [{template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";}];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = ["@hmo"];
                };
                google = {
                  hidden = false;
                  metaData.alias = "@g"; # builtin engines only support specifying one additional alias
                };
                searx-tiekoetter = {
                  name = "Searx (tiekoetter)";
                  urls = [{template = "https://searx.tiekoetter.com/search?q={searchTerms}&category_general=on&language=en&safesearch=0&theme=simple";}];
                  icon = "https://searx.tiekoetter.com/favicon.ico";
                  definedAliases = ["@sx"];
                };
                bing.metaData.hidden = true;
                "policy-MetaGer".metaData.hidden = true;
                "policy-StartPage".metaData.hidden = true;
                "policy-Mojeek".metaData.hidden = true;
                "policy-SearXNG - searx.be".metaData.hidden = true;
                "policy-DuckDuckGo Lite".metaData.alias = "@ddl";
                wikipedia.metaData.hidden = true;
              };
            };
            # extensions = {
            # };
            settings = {
              "svg.context-properties.content.enabled" = true;
              "sidebar.verticalTabs" = true;
              "sidebar.animation.enabled" = false;
              "security.webauth.webauthn_enable_softtoken" = true;
              "privacy.resistFingerprinting" = false;
              "identity.fxaccounts.enabled" = true;
              "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
              "privacy.clearOnShutdown_v2.cache" = true;
              "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
              "privacy.clearOnShutdown_v2.formdata" = true;
              "privacy.clearOnShutdown_v2.history" = false;
              "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
              "privacy.clearOnShutdown_v2.sessions" = true;
              "privacy.clearOnShutdown_v2.siteSettings" = false;
            };
          in {
            ${currentSystemUser} = {
              id = 0;
              name = currentSystemUser;
              inherit
                settings
                search
                # extensions
                ;
            };
            lirililarilla = {
              inherit settings search;
              name = "lirililarilla";
              id = 1;
            };
          };
        };
      # firefox }}}
    };
    sharedModules = [
      inputs.nix-index-database.homeModules.nix-index
    ];
  };
}
