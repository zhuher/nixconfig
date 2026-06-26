{
  # 💿 Disko Configuration
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_500GB_S4EVNJ0N332554R";
        content = {
          type = "gpt";
          partitions = {
            # 1. EFI System Partition
            ESP = {
              priority = 1;
              size = "1024000K";
              type = "EF00"; #gdisk
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            # 2. NixOS LUKS + Btrfs
            nixos = {
              priority = 2;
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
                      mountOptions = ["compress=zstd:3" "noatime"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd:3" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd:3" "noatime"];
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
}
