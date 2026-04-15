{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf config.zhuk.nvidia {
  boot.blacklistedKernelModules = ["ucsi_ccg" "i2c_nvidia_gpu"]; # my RTX 2060 Super doesn't have Type-C
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [nvidia-vaapi-driver];
    };
    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };
  services = {
    xserver.videoDrivers = ["modesetting" "nvidia"];
  };
}
