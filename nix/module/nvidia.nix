{
  inputs,
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
  nixpkgs.overlays = [
    (final: prev: {
      nvidia_cachyos_custom = prev.callPackage "${inputs.chaotic}/pkgs/nvidia-cachyos" {
        inherit final;
        linuxPackages_cachyos = config.boot.kernelPackages;
      };
    })
  ];
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [nvidia-vaapi-driver];
    };
    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = pkgs.nvidia_cachyos_custom;
    };
  };
  services = {
    xserver.videoDrivers = ["modesetting" "nvidia"];
  };
  environment.systemPackages = with pkgs; [
    low-latency-layer
  ];
}
