{
  # 💿 Disko Configuration
  disko.devices = {
    disk = {
      main = {
        destroy = false;
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_500GB_S4EVNJ0N332554R";
        content = {
          type = "gpt";
          partitions = {
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
            nixos = {
              priority = 2;
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true;
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
      chungus = {
        destroy = false;
        type = "disk";
        device = "/dev/disk/by-id/ata-ST2000DM008-2FR102_WK301H6Q";
        content = {
          type = "gpt";
          partitions.ntfs = {
            device = "/dev/disk/by-uuid/30D6EF78D6EF3CAA";
            size = "100%";
            type = "8300";
            content = {
              type = "filesystem";
              format = "ntfs";
              mountpoint = "/mnt/chungus";
              mountOptions = ["defaults" "uid=1000" "gid=100" "umask=0022" "nofail"];
            };
          };
        };
      };
    };
  };
}
