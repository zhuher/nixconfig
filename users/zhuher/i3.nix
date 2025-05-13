{ pkgs, ... }:
{
  services = {
    openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
      };
    };
    displayManager = {
      defaultSession = "none+i3";
      autoLogin = {
        enable = true;
        user = "zhuher";
      };
    };
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
      };
      desktopManager = {
        xterm.enable = true;
      };
      windowManager = {
        i3 = {
          enable = true;
          extraPackages = with pkgs; [
            rofi
            i3status
            i3lock
            i3blocks
          ];
        };
      };
      videoDrivers = [ "nvidia" ];
    };
  };
}
