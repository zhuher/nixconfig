{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf config.zhuk.nvidia {
  chaotic.mesa-git = {
    enable = false;
    extraPackages = with pkgs; [
      mesa_git.opencl
      intel-media-driver
      intel-ocl
      intel-vaapi-driver
    ];
  };
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
      # package = pkgs.nvidia_cachyos-lto;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };
  services = {
    xserver.videoDrivers = ["modesetting" "nvidia"];
  };
  environment.systemPackages = with pkgs; [
    # vulkanPackages_latest.vulkan-headers
    # vulkanPackages_latest.vulkan-loader
    low-latency-layer
    # libGL
  ];
}
