{
  currentSystemUser,
  config,
  pkgs,
  lib,
  ...
}: {
  # sway's WLR_RENDERER=vulkan crashes on wlr capture method so far
  programs.zsh.loginShellInit = lib.mkBefore ''
    [[ "$(${lib.getExe' pkgs.coreutils "tty"})" == /dev/tty1 ]] && ${lib.getExe pkgs.sway} --unsupported-gpu -d > ~/sway.log 2> ~/sway.err.log
  '';
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-wlr];
  };
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];
  services = {
    getty = {
      autologinOnce = true;
      autologinUser = currentSystemUser;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    apollo = {
      enable = true;
      package =
        if config.zhuk.nvidia
        then pkgs.apollo-cuda
        else pkgs.apollo;
      openFirewall = true;
      capSysAdmin = true;
      autoStart = true;
      settings = {
        min_log_level = 2;
        # capture = "kms"; # [Error]: Unknown Monitor connector type [HEADLESS]: Please report this to the GitHub issue tracker (stinker!!!)
        capture = "wlr";
      };
      applications = {
        env = {
          PATH = "${lib.makeBinPath (with pkgs; [sway bash])}";
        };
        apps = [
          {
            name = "Headless x2";
            prep-cmd = [
              {
                do = ''
                  bash -c "
                    swaymsg output HEADLESS-1 enable;
                    swaymsg output HEADLESS-1 mode ''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}Hz;
                    swaymsg output HEADLESS-1 scale 2;
                    swaymsg output DP-1 disable;
                    if [ \"$SUNSHINE_CLIENT_HDR\" = \"1\" ]; then
                      swaymsg output HEADLESS-1 render_bit_depth 10;
                    else
                      swaymsg output HEADLESS-1 render_bit_depth 8;
                    fi"'';
                undo = ''bash -c "swaymsg output HEADLESS-1 disable; swaymsg output DP-1 enable"'';
              }
            ];
          }
          {
            name = "Headless";
            prep-cmd = [
              {
                do = ''
                  bash -c "
                    swaymsg output HEADLESS-1 enable;
                    swaymsg output HEADLESS-1 mode ''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}Hz;
                    swaymsg output HEADLESS-1 scale 1;
                    swaymsg output DP-1 disable;
                    if [ \"$SUNSHINE_CLIENT_HDR\" = \"1\" ]; then
                      swaymsg output HEADLESS-1 render_bit_depth 10;
                    else
                      swaymsg output HEADLESS-1 render_bit_depth 8;
                    fi"'';
                undo = ''bash -c "swaymsg output HEADLESS-1 disable; swaymsg output DP-1 enable"'';
              }
            ];
          }
        ];
      };
    };

    seatd = {
      enable = true;
      user = currentSystemUser;
    };
  };
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      tofi
      rofi-power-menu
      ironbar
    ];
  };
  hardware = {
    uinput.enable = true;
  };
  users.users.${currentSystemUser}.extraGroups = [
    "uinput"
    "input"
    "video"
    "sway"
  ];
}
