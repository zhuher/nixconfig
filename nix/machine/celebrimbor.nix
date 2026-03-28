{
  pkgs,
  lib,
  config,
  ...
}: {
  # 💿 Disko Configuration
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          efiGptPartitionFirst = false;
          partitions = {
            # 1. Microsoft Reserved (p1)
            msr = {
              priority = 1;
              start = "103424K";
              size = "16384K";
              type = "0C01";
            };

            # 2. Windows Basic Data (p2)
            windows = {
              priority = 2;
              device = "/dev/nvme0n1p2";
              start = "119808K";
              size = "208965632K";
              type = "0700"; #gdisk
              content = {
                type = "filesystem";
                format = "ntfs"; # Mounts Windows C: drive
                mountpoint = "/windows";
                mountOptions = ["ro" "nofail"]; # Read-only for safety
              };
            };

            # 3. Windows Recovery (p3)
            recovery = {
              priority = 3;
              device = "/dev/nvme0n1p3";
              start = "209085440K";
              size = "748544K";
              type = "2700"; #gdisk
              content = {
                type = "filesystem";
                format = "ntfs";
                mountpoint = "/winre";
                mountOptions = ["ro" "nofail"];
              };
            };

            # 4. EFI System Partition (p4)
            ESP = {
              priority = 4;
              device = "/dev/nvme0n1p4";
              start = "209833984K";
              size = "1024000K";
              type = "EF00"; #gdisk
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            # 5. NixOS LUKS + Btrfs
            nixos = {
              priority = 5;
              start = "210857984K";
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true; # Optimized for Samsung NVMe
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "8G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  # 🚀 Bootloader Configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.configurationLimit = 10;

  # Samsung 970 EVO Plus & Kernel Optimizations
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod"];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # 🛠️ System Maintenance
  services.fstrim.enable = true; # SSD Trim for Samsung 970
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = ["/"];
  };
  programs.xstarbound.enable = false;
}
