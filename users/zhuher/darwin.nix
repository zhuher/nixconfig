{ pkgs, config, ... }:
{
  imports = [
    ./dock.nix
  ];
  nixpkgs.overlays = import ../../lib/overlays.nix
  # ++ [ (import ./vim.nix { inherit inputs; }) ]
  ;

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    # whalebrews = [ "scylladb/scylla" ];
    brews = [
      { name = "mas"; }
      { name = "wireguard-tools"; }
      #   { name = "ffmpeg"; }
    ];

    casks = [
      "syncthing"
      "parsec" # VPN:403
      # "orion"
      "tor-browser" # VPN:403
      # "steam" # VPN:403
      "apparency"
      # "qlvideo"
      # "qlstephen"
      # "qlprettypatch"
      # "qlimagesize" # killed by macOS 10.15...
      "qlmarkdown"
      # "qlcolorcode"
      # "qlzipinfo"
      "syntax-highlight"
      "unity" # VPN:403
      "unity-hub" # VPN:unity
      "jdownloader"
    ];

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      "Velja" = 1607635845;
      # "Warframe" = 1520001008; # only mobile devices (why???)
      "Pages" = 409201541;
      "Numbers" = 409203825;
      # "Xcode" = 497799835;
      "DaisyDisk" = 411643860;
      "StrongBox" = 1481853033;
      "Customize Search Engine" = 6445840140;
      # "Consent-O-Matic" = 1606897889;
      # "PiP button for Safari" = 1160374471;
      # "Orion" = 1484498200; # only mobile devices
      "Telegram" = 747648890;
    };
  };
  system = {
    activationScripts.postUserActivation.text = ''
      # Following line should allow us to avoid a logout/login cycle
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
    stateVersion = 5;
    defaults = {
      ".GlobalPreferences" = {
        "com.apple.mouse.scaling" = 1.0; # max is 8.0
        "com.apple.sound.beep.sound" = /System/Library/Sounds/Hero.aiff;
      };
      ActivityMonitor.IconType = 0;
      CustomSystemPreferences = {
      };
      CustomUserPreferences = {
        # "com.apple.universalaccess"."mouseDriverCursorSize" = 1;
        NSGlobalDomain = {
          AppleMenuBarVisibleInFullscreen = 1;
        };
        "com.moonlight-stream.Moonlight" = {
          width = 1512;
          height = 945;
        };
        # defaults write org.gpgtools.common DisableKeychain -bool yes
        "org.gpgtools.common" = {
          DisableKeychain = false;
        };
      };
      NSGlobalDomain = {
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
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
      alf = {
        loggingenabled = 1;
        stealthenabled = 0; # drop ICMP packets
      };
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
        wvous-br-corner = 12;
        wvous-tl-corner = 7;
      };
      finder = {
        # NewWindowTargetPath # url-escaped file:/// uri
        # NewWindowTarget # “Computer”, “OS volume”, “Home”, “Desktop”, “Documents”, “Recents”, “iCloud Drive”, “Other”
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "icnv"; # = Icon view, “Nlsv” = List view, “clmv” = Column View, “Flwv” = Gallery View
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
      hitoolbox.AppleFnUsageType = "Do Nothing";
      loginwindow = {
        # “Change Input Source”, “Show Emoji & Symbols”, “Start Dictation”
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
      universalaccess.mouseDriverCursorSize = 4.0;
    };

    keyboard = {
      enableKeyMapping = true;
    };
  };

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.zhuher = {
    home = "/Users/zhuher";
    shell = pkgs.zsh;
  };
  users.knownGroups = [ config.users.groups.keys.name ];
  users.groups.keys = {
    gid = 69420;
    members = [ "zhuher" ];
  };
  local.dock = {
    enable = true;
    entries = [
      { path = "${pkgs.moonlight-qt}/Applications/Moonlight.app"; }
      {
        path = "${(pkgs.callPackage ../../pkgs/darwin/ayugram-darwin.nix { })}/Applications/AyuGram.app";
      }
      { path = "/Applications/Safari.app"; }
      { path = "${(pkgs.callPackage ../../pkgs/darwin/ghostty.nix { })}/Applications/Ghostty.app"; }
      {
        path = "${(pkgs.callPackage ../../pkgs/darwin/thorium-browser.nix { })}/Applications/Thorium.app";
      }
      {
        path = "/Applications";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
      {
        path = "/Users/zhuher/Downloads";
        section = "others";
        options = "--sort dateadded --view grid --display folder";
      }
    ];
  };
}
