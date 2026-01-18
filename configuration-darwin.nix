{
  pkgs,
  lib,
  config,
  currentSystemUser,
  inputs,
  ...
}
: {
  imports = [
    # nix-homebrew {{{
    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        user = "${currentSystemUser}";
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
          "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
        };
        mutableTaps = false;
        autoMigrate = true;
      };
    }
    ( # dock {{{
      {
        config,
        pkgs,
        lib,
        ...
      }:
      # Original source: https://gist.github.com/antifuchs/10138c4d838a63c0a05e725ccd7bccdd
        with lib; let
          cfg = config.local.dock;
          inherit (pkgs) stdenv;
          zsh = getExe pkgs.zsh;
          dockutil = getExe pkgs.dockutil;
        in {
          options = {
            local.dock.enable = mkOption {
              description = "Enable dock";
              default = stdenv.isDarwin;
              example = false;
            };
            local.dock.entries = mkOption {
              description = "Entries on the Dock";
              type = with types;
                listOf (submodule {
                  options = {
                    path = mkOption {type = str;};
                    section = mkOption {
                      type = str;
                      default = "apps";
                    };
                    options = mkOption {
                      type = str;
                      default = "";
                    };
                  };
                });
              readOnly = true;
            };
            local.dock.username = mkOption {
              description = "Username to apply the dock settings to";
              default = config.system.primaryUser;
              type = types.str;
            };
          };
          config = mkIf cfg.enable (
            let
              normalize = path:
                if hasSuffix ".app" path
                then path + "/"
                else path;
              entryURI = path:
                "file://"
                + (
                  builtins.replaceStrings
                  [
                    " "
                    "!"
                    "\""
                    "#"
                    "$"
                    "%"
                    "&"
                    "'"
                    "("
                    ")"
                  ]
                  [
                    "%20"
                    "%21"
                    "%22"
                    "%23"
                    "%24"
                    "%25"
                    "%26"
                    "%27"
                    "%28"
                    "%29"
                  ]
                  (normalize path)
                );
              wantURIs = concatMapStrings (entry: "${entryURI entry.path}\n") cfg.entries;
              createEntries =
                concatMapStrings
                (
                  entry: "${dockutil} --no-restart --add '${entry.path}' --section ${entry.section} ${entry.options}\n"
                )
                cfg.entries;
              subody = pkgs.writeText "dock.zsh" ''
                haveURIs="$(${dockutil} --list | ${getExe' pkgs.coreutils "cut"} -f2)"
                if ! diff -wu <(echo -n "$haveURIs") <(echo -n '${wantURIs}') >&2 ; then
                  echo >&2 -e "\033[33mResetting Dock.\033[0m"
                  ${dockutil} --no-restart --remove all
                  ${createEntries}
                  killall Dock
                fi
                echo >&2 -e "\033[32mDock setup complete.\033[0m"
              '';
            in {
              system.activationScripts.postActivation.text = ''
                echo >&2 -e "\033[34mSetting up the Dock for ${cfg.username}...\033[0m"
                su ${cfg.username} -c '${zsh} ${subody}'
              '';
            }
          );
        }
    ) # dock }}}
  ];
  # dock {{{
  local.dock = {
    enable = true;
  };
  # dock }}}
  # brew & app store {{{
  homebrew = {
    taps = builtins.attrNames config.nix-homebrew.taps;
    enable =  true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    whalebrews = [
    ];
    brews = [
      "mas"
      # "virtualenv"
    ];

    casks = [
      "orion"
      "qlmarkdown"
      "syntax-highlight"
      # "moonlight"
      "keka"
      # "parsec" # VPN
      # "tor-browser" VPN
    ];

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    # ```sh
    # nix shell nixpkgs#mas
    # mas search <app name>
    # ```
    masApps = {
      "Velja" = 1607635845;
      # "GarageBand" = 682658836;
      # "Warframe" = 1520001008; # only mobile devices (why???)
      # "Pages" = 409201541;
      # "Numbers" = 409203825;
      # "DaisyDisk" = 411643860; # using a version from their website as it's more powerful
      "StrongBox" = 1481853033;
      # "Customize Search Engine" = 6445840140; # [TODO]: Return to this maybe
      # "Telegram" = 747648890;
      # "Xcode" = 497799835;
    };
  }; # brew & app store }}}
  system = {
    primaryUser = "${currentSystemUser}";
    stateVersion = 5;
    # defaults {{{
    defaults = {
      # Reduce window resize animation duration.
      NSGlobalDomain.NSWindowResizeTime = 0.001;
      CustomSystemPreferences = {
        # Motion reduction NEEDS to be off, no speed gain
        "com.apple.Accessibility".ReduceMotionEnabled = 0;
      };
      ".GlobalPreferences" = {
        "com.apple.sound.beep.sound" = /System/Library/Sounds/Hero.aiff;
      };
      ActivityMonitor.IconType = 0;
      CustomUserPreferences = {
        NSGlobalDomain = {
          AppleMenuBarVisibleInFullscreen = 0;
        };
        "com.moonlight-stream.Moonlight" = {
          width = 1512;
          height = 945;
        };
        "org.gpgtools.common" = {
          DisableKeychain = false;
        };
        "com.apple.GameController" = {
          homeButtonLongPressAction = "com.apple.launchpad.launcher";
        };
      };
      # universalaccess = {
      #   closeViewScrollWheelToggle = true;
      #   mouseDriverCursorSize = 1.5;
      # };
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.feedback" = 1;
        "com.apple.springing.enabled" = true;
        "com.apple.swipescrolldirection" = true;
        AppleICUForce24HourTime = true;
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleKeyboardUIMode = 3;
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleScrollerPagingBehavior = true; # jump to clicked scrollbar position
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleShowScrollBars = "Always";
        AppleTemperatureUnit = "Celsius";
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSDisableAutomaticTermination = true;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSScrollAnimationEnabled = true; # smooth scrolling
        NSTableViewDefaultSizeMode = 1; # 2, 3
        NSTextShowsControlCharacters = true;
        NSWindowShouldDragOnGesture = true; # drag holding anywhere like on linux
        _HIHideMenuBar = false;
        AppleIconAppearanceTheme = "RegularAutomatic";
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
      controlcenter.Bluetooth = false;
      dock = {
        appswitcher-all-displays = true;
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        dashboard-in-overlay = true;
        enable-spring-load-actions-on-all-items = true;
        launchanim = true;
        minimize-to-application = true;
        mouse-over-hilite-stack = true;
        mru-spaces = true;
        orientation = "bottom";
        show-process-indicators = true;
        show-recents = false;
        showhidden = false;
        tilesize = 64;
        # 10: Put Display to Sleep
        # 11: Launchpad
        # 12: Notification Center
        # 13: Lock Screen
        # 14: Quick Note
        # 1: Disabled
        # 2: Mission Control
        # 3: Application Windows
        # 4: Desktop
        # 5: Start Screen Saver
        # 6: Disable Screen Saver
        # 7: Dashboard
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };
      finder = {
        # NewWindowTargetPath # url-escaped file:/// uri
        NewWindowTarget = "Computer"; #, “OS volume”, “Home”, “Desktop”, “Documents”, “Recents”, “iCloud Drive”, “Other”
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "Nlsv"; # "icnv" = Icon view, “Nlsv” = List view, “clmv” = Column View, “Flwv” = Gallery View
        QuitMenuItem = true;
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowPathbar = true;
        ShowRemovableMediaOnDesktop = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = false;
        _FXSortFoldersFirst = true;
        _FXSortFoldersFirstOnDesktop = true;
      };
      hitoolbox.AppleFnUsageType = "Do Nothing"; # “Change Input Source”, “Show Emoji & Symbols”, “Start Dictation”
      loginwindow = {
        DisableConsoleAccess = true;
        GuestEnabled = true;
        SHOWFULLNAME = true;
      };
      menuExtraClock = {
        FlashDateSeparators = true;
        ShowDayOfMonth = true;
        ShowDayOfWeek = true;
        ShowSeconds = true;
      };
      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };
      screencapture = {
        location = "~/Desktop/Screenshots";
        type = "png";
        disable-shadow = true;
      };
      trackpad = {
        Clicking = true;
        Dragging = true;
        FirstClickThreshold = 0;
        SecondClickThreshold = 1;
        TrackpadThreeFingerDrag = false;
        TrackpadThreeFingerTapGesture = 2;
      };
    }; # defaults }}}
    keyboard = {
      enableKeyMapping = true;
    };
    activationScripts = let
      inherit (pkgs.zhuk) notify;
      inherit (pkgs) coreutils mkalias;
      inherit (lib) getExe getExe';
      zsh = getExe pkgs.zsh;
      su = "/usr/bin/su";
      env = config.environment.variables;
      realpath = getExe' coreutils "realpath";
      rm = getExe' coreutils "rm";
    in {
      # names of scripts that would be run can be found at https://github.com/nix-darwin/nix-darwin/blob/eaff8219d629bb86e71e3274e1b7915014e7fb22/modules/system/activation-scripts.nix#L148-L155
      postActivation.text = let
        link-apps = pkgs.writeText "link-apps" ''
          setopt nullglob
          # /Applications/Nix\ Apps/,
          for app in {\
          /Volumes/t7-shield/SteamLibrary/steamapps/common/,\
          ${env.HOME}/Library/Application\ Support/Steam/steamapps/common/*/,\
          ${env.HOME}/Documents/Games/**/,\
          ${env.HOME}/Applications/Crossover/**/}*.app
          do
            ${rm} "/Applications/''${''${app:t}%.*}"
            ${getExe mkalias} "$(${realpath} "$app")" "/Applications/''${''${app:t}%.*}"
          done
        '';
        activate-settings = pkgs.writeText "activate-settings" ''
          # Following line should allow us to avoid a logout/login cycle
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        '';
      in
        notify "darwin::postActivation" ''
          ${su} ${currentSystemUser} -c '${zsh} ${link-apps}'
          # sops-nix links secrets at activation, so reading from them is to be done post-activation
          ${notify "Setting login screen message" ''
            defaults write /Library/Preferences/com.apple.loginwindow.plist LoginwindowText -string "$(cat ${config.sops.secrets.contact-info.path})"
          ''}
          ${notify "Activating settings" ''
            su ${currentSystemUser} -c '${zsh} ${activate-settings}'
          ''}
        '';
    };
  };

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users."${currentSystemUser}" = {
    home = "/Users/${currentSystemUser}";
  };
  environment.systemPackages = with pkgs; [
    localsend
    anki-bin
    apparency # [ERROR]: QuickLook extension does not work when installed via nix.
    dockutil
    # moonlight-qt # [ERROR]: Crashes on launch (brew version works fine).
    # raycast # [ERROR] Needs VPN
    syncthing
    # utm # [ERROR] le errare abobuous
    zhuk.ghostty
  ];
  nix = {
    optimise.automatic = false;
    settings = {
      allowed-impure-host-deps = ["/bin/sh" "/usr/lib/libSystem.B.dylib" "/usr/lib/system/libunc.dylib" "/dev/zero" "/dev/random" "/dev/urandom"];
    };
  };
  services.openssh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;
  launchd.user.agents.syncthing = {
    environment = {
      HOME = "/Users/${currentSystemUser}";
      STNORESTART = "1";
      STNOUPGRADE = "1";
    };
    serviceConfig = {
      KeepAlive = true;
      Label = "net.syncthing.syncthing";
      LowPriorityIO = true;
      ProcessType = "Background";
      ProgramArguments = [
        "${lib.getExe pkgs.syncthing}"
      ];
      StandardOutPath = "/Users/${currentSystemUser}/Library/Logs/Syncthing.log";
      StandardErrorPath = "/Users/${currentSystemUser}/Library/Logs/Syncthing-Errors.log";
    };
  };
  users.knownGroups = [config.users.groups.keys.name];
  users.groups.keys = {
    gid = 69420;
    members = ["${currentSystemUser}"];
  };
  sops = {
    defaultSopsFile = ./darwin.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [
      "/Users/${currentSystemUser}/.ssh/age"
      "/Users/${currentSystemUser}/.ssh/id_ed25519"
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    secrets = {
      jjsecrets = {
        mode = "0400";
        owner = currentSystemUser;
      };
      gitsecrets = {
        mode = "0400";
        owner = currentSystemUser;
      };
      contact-info.mode = "0400";
      access-tokens = {
        mode = "0440";
        group = config.users.groups.keys.name;
      };
    };
  };
}
