{
  pkgs,
  lib,
  config,
  ...
}:
{
  boot = {
    kernel.sysctl = {
      # "net.ipv4.tcp_congestion_control" = "bbr";
      # "kernel.sysrq" = 1;
      "kernel.pty.max" = 24000;
      "net.ipv4.tcp_congestion_control" = "westwood"; # sets the TCP congestion control algorithm to Westwood for IPv4 in the Linux kernel.
    };
    supportedFilesystems = {
      btrfs = true;
    };
    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      systemd-boot = {
        enable = true;
      };
    };
    initrd.availableKernelModules = [
      "ahci" # Enables the Advanced Host Controller Interface (AHCI) driver, typically used for SATA (Serial ATA) controllers.
      "ehci_pci" # Enables the Enhanced Host Controller Interface (EHCI) driver for PCI-based USB controllers, providing support for USB 2.0.
      "nvme"
      "nvme" # module in your initrd configuration can be useful if you plan to use an NVMe drive in the future
      "sd_mod" # Enables the SCSI disk module (sd_mod), which allows the system to recognize and interact with SCSI-based storage devices.
      "sr_mod" # Loads the SCSI (Small Computer System Interface) CD/DVD-ROM driver, allowing the system to recognize and use optical drives.
      "uas" # Enables the USB Attached SCSI (UAS) driver, which provides a faster and more efficient way to access USB storage devices.
      "usb_storage" # Enables the USB Mass Storage driver, allowing the system to recognize and use USB storage devices like USB flash drives and external hard drives.
      "usbhid" # Enables the USB Human Interface Device (HID) driver, which provides support for USB input devices such as keyboards and mice.
      "xhci_pci" # Enables the eXtensible Host Controller Interface (xHCI) driver for PCI-based USB controllers, providing support for USB 3.0 and later standards.
    ];
    initrd.kernelModules = [ ];
    blacklistedKernelModules = lib.mkDefault [ "nouveau" ];
    kernelModules = [
      "kvm-amd"
      "uinput"
      "tcp_cubic" # Cubic: A traditional and widely used congestion control algorithm
      "tcp_reno" # Reno: Another widely used and stable algorithm
      "tcp_newreno" # New Reno: An extension of the Reno algorithm with some improvements
      "tcp_bbr" # BBR: Dynamically optimize how data is sent over a network, aiming for higher throughput and reduced latency
      "tcp_westwood" # Westwood: Particularly effective in wireless networks
    ];
    kernelParams = [
      "nvidia_drm.fbdev=1" # Enables the use of a framebuffer device for NVIDIA graphics. This can be useful for certain configurations.
      "nvidia_drm.modeset=1" # Enables kernel modesetting for NVIDIA graphics. This is essential for proper graphics support on NVIDIA GPUs.
      "quiet" # suppresses most boot messages during the system startup
    ];
    extraModulePackages = [ ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/50f8025d-a90a-4fcd-ae9a-82295a46ef2d";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E2AC-DB0F";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/t7-shield" = {
    device = "/dev/disk/by-uuid/4A88-AC1F";
    fsType = "exfat";
    options = [
      "users"
      "nofail"
    ];
  };

  fileSystems."/hdd2tb" = {
    device = "/dev/disk/by-uuid/30D6EF78D6EF3CAA";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=${builtins.toString config.users.users.zhuher.uid}"
    ];
  };

  # Avahi is used by Sunshine
  services.avahi.enable = true;
  services.avahi.publish.userServices = true;

  swapDevices = [ ];

  environment.systemPackages = with pkgs; [
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
  ];
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.variables = {
    WLR_BACKEND = "vulkan";
    WLR_RENDERER = "vulkan";
    XDG_SESSION_TYPE = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    WLR_DRM_DEVICES = "/dev/dri/card1";
    NIXOS_OZONE_WL = "1";
    GBM_BACKEND = "nvidia-drm";
    # WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # WLR_DRM_NO_ATOMIC = 1;
    # XCURSOR_SIZE = 24;
    # QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORM = "wayland-egl";
    GDK_BACKEND = "wayland";
    TERM = "wezterm";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    uinput.enable = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    nvidia = {

      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = true;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # Currently "beta quality", so false is currently the recommended setting.
      open = false;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.production;
      # vulkan_beta;
      # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      #   version = "555.58";
      #   sha256_64bit = "sha256-bXvcXkg2kQZuCNKRZM5QoTaTjF4l2TtrsKUvyicj5ew=";
      #   sha256_aarch64 = "sha256-7XswQwW1iFP4ji5mbRQ6PVEhD4SGWpjUJe1o8zoXYRE=";
      #   openSha256 = "sha256-hEAmFISMuXm8tbsrB+WiUcEFuSGRNZ37aKWvf0WJ2/c=";
      #   settingsSha256 = "sha256-vWnrXlBCb3K5uVkDFmJDVq51wrCoqgPF03lSjZOuU8M=";
      #   persistencedSha256 = "sha256-lyYxDuGDTMdGxX3CaiWUh1IQuQlkI2hPEs5LI20vEVw=";
      # };
      forceFullCompositionPipeline = true;
    };
  };
}
