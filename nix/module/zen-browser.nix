{
  pkgs,
  isDarwin,
  ...
}: {
  environment.systemPackages = with pkgs; [
    (zen-browser.override
      {
        policies = {
          Cookies = {
            Locked = true;
            Behavior = "reject-tracker-and-partition-foreign";
          };
          DisableAppUpdate = true;
          # DisableMasterPasswordCreation = true;
          DisablePocket = true;
          # DisableSetDesktopBackground = true;
          DontCheckDefaultBrowser = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
            EmailTracking = true;
            SuspectedFingerprinting = true;
            Category = "strict";
            # IF BaselineExceptions is true, Firefox will automatically apply exceptions required to avoid major website breakage. (Firefox 145)
            # If ConvenienceExceptionsis true, Firefox will apply exceptions automatically that are only required to fix minor issues and make convenience features available. (Firefox 145)
          };
          UseSystemPrintDialog = true;
          DisableTelemetry = true;
          OfferToSaveLoginsDefault = false;
          PasswordManagerEnabled = false;
          SanitizeOnShutdown = {FormData = true;};
          Extensions = {
            Uninstall = [];
            Install = [];
          };
          PictureInPicture = {
            Enabled = true;
            Locked = true;
          };
          DisableFirefoxStudies = true;
          UserMessaging = {
            ExtensionRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = true;
            MoreFromMozilla = false;
            FirefoxLabs = true;
            FeatureRecommendations = false;
          };
          NetworkPrediction = false;
          SearchEngines = {
            Remove = ["Bing" "Wikipedia"];
            Default = "Google";
            Add = [];
          };
          HttpsOnlyMode = "force_enabled";
          SSLVersionMin = "tls1.2";
          PostQuantumKeyAgreementEnabled = true;
          HttpAllowlist = [
            "http://localhost"
            "http://127.0.0.1"
          ];
          Preferences = let
            lock = Value: {
              inherit Value;
              Status = "locked";
            };
          in {
            "browser.translations.automaticallyPopup" = lock false;
            # "browser.startup.homepage" = lock "https://news.ycombinator.com";
            # "toolkit.legacyUserProfileCustomizations.stylesheets" = lock true;
            # "browser.warnOnQuitShortcut" = lock false;
            # "browser.sessionstore.closedTabsFromClosedWindows" = lock false;
            # "browser.sessionstore.closedTabsFromAllWindows" = lock false;
            # "security.OCSP.require" = lock false;
            # "browser.tabs.closeWindowWithLastTab" = lock false;
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
            listToAttrs (
              [
                (extension (a4 "adnauseam" "adnauseam@rednoise.org" "navbar" true))
                (extension (a3 "libredirect" "7esoorv3@alefvanoon.anonaddy.me" true))
                (extension (a3 "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}" true))
                (extension (a3 "port-authority" "{6c00218c-707a-4977-84cf-36df1cef310f}" true))
                (extension (a2 "search_by_image" "{2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c}"))
                (extension (
                  a4 "terms-of-service-didnt-read" "jid0-3GUEt1r69sQNSrca5p8kx9Ezc3U@jetpack" "navbar" true
                ))
                # (extension (a2 "pstream-extension" "{0c3fcdbd-5e0f-40d5-8f6c-d5eef8ff2b7c}"))
                # (extension (a2 "syncshare" "syncshare@naloaty.me"))
                (extension (a2 "violentmonkey" "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}"))
                (extension (a2 "vknext" "addon@vknext.net"))
                (extension (a2 "vk-music-saver" "vknext-vms@vknext.net"))
                (extension (a4 "xbs" "{019b606a-6f61-4d01-af2a-cea528f606da}" "navbar" false))
                # (extension (a2 "augmented-steam" "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}"))
                (extension (a2 "behind" "{d6005a62-1fdb-4cf2-b5ef-21b865d894f7}"))
                # (extension (a2 "bookmark-dupes" "bookmarkdupes@martin-vaeth.org"))
                (extension (a3 "canvasblocker" "CanvasBlocker@kkapsner.de" true))
                (extension (a3 "chameleon-ext" "{3579f63b-d8ee-424f-bbb6-6d0ce3285e6a}" true))
                # (extension (a4 "cookie-autodelete" "CookieAutoDelete@kennydo.com" "navbar" true))
                # (extension (a2 "cookie-quick-manager" "{60f82f00-9ad5-4de5-b31c-b16a47c51558}"))
                # (extension (a2 "cookies-txt" "{12cf650b-1822-40aa-bff0-996df6948878}"))
                (extension (a3 "fastforwardteam" "addon@fastforward.team" true))
                (extension (a4 "istilldontcareaboutcookies" "idcac-pub@guus.ninja" "navbar" true))
                (extension (a2 "indie-wiki-buddy" "{cb31ec5d-c49a-4e5a-b240-16c767444f62}"))
                (extension (a2 "tridactyl-vim" "tridactyl.vim@cmcaine.co.uk"))
                # (extension (
                #   a4 "localcdn-fork-of-decentraleyes" "{b86e4813-687a-43e6-ab65-0bde4ab75758}" "menupanel" true
                # ))
                (customExt (
                  a4 "{d19a89b9-76c1-4a61-bcd4-49e8de916403}"
                  "https://github.com/mullvad/browser-extension/releases/download/v0.9.7-firefox-beta/mullvad_proxy_extension-0.9.7.xpi"
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
            );
          # To add additional extensions, find it on addons.mozilla.org, find
          # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
          # Then, download the XPI by filling it in to the install_url template, unzip it,
          # run `jq .browser_specific_settings.gecko.id manifest.json` or
          # `jq .applications.gecko.id manifest.json` to get the UUID
        };
      })
  ];
}
