{
  currentSystemUser,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./sound.nix
  ];
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];
  services = {
    apollo = {
      enable = true;
      package =
        if config.zhuk.nvidia
        then pkgs.apollo-cuda
        else pkgs.apollo;
      openFirewall = true;
      capSysAdmin = true;
      autoStart = false;
      settings = {
        min_log_level = 2;
        # capture = "kms"; # [Error]: Unknown Monitor connector type [HEADLESS]: Please report this to the GitHub issue tracker (stinker!!!)
        capture = "wlr";
        audio_sink = "sink-sunshine-surround71";
        fec_percentage = 20;
      };
      applications = {
        env = {
          PATH = "${lib.makeBinPath (with pkgs; [sway bash])}";
          # PULSE_SINK = "Sunshine-only";
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

  system.activationScripts = {
    "refresh-tofi-cache" = {
      text = ''
        rm ${config.environment.variables.XDG_CACHE_HOME}/tofi-drun || true
      '';
    };
  };
  systemd.user.services.apollo = {
    bindsTo = ["sway.service"];
    partOf = ["sway.service"];
  };
  systemd.user.services.sway = {
    description = "Primary Sway Session";
    wantedBy = ["default.target"];
    environment = {
      "NONU" = "1";
      "LIBSEAT_BACKEND" = "seatd";
      "XDG_SESSION_TYPE" = "wayland";
    };
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${lib.getExe' pkgs.coreutils "timeout"} 10 ${lib.getExe pkgs.bash} -c 'until [ -e /dev/dri/renderD128 ]; do sleep 0.1; done'";
      ExecStart = "${lib.getExe pkgs.zsh} -ilc 'unset NONU; exec ${lib.getExe config.programs.sway.package} --unsupported-gpu'";
      ExecStopPost = "${lib.getExe' pkgs.systemd "systemctl"} --user unset-environment WAYLAND_DISPLAY DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP";
      Restart = "on-failure";
      RestartSec = 5;
      StandardOutput = "file:%h/sway.log";
      StandardError = "file:%h/sway.err.log";
    };
  };
  hardware = {
    uinput.enable = true;
  };
  users.users.${currentSystemUser} = {
    linger = true;
    extraGroups = [
      "uinput"
      "input"
      "video"
      "sway"
    ];
  };
}
