{
  # 💿 Disko Configuration
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_500GB_S4EVNJ0N332554R";
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
              device = "/dev/disk/by-partuuid/a603ac81-3e8c-46e5-8501-a1c0099cc65c";
              start = "119808K";
              size = "208965632K";
              type = "0700"; #gdisk
              content = {
                type = "filesystem";
                format = "ntfs";
                mountpoint = "/windows";
                mountOptions = ["ro" "nofail"]; # Read-only for safety
              };
            };

            # 3. Windows Recovery (p3)
            recovery = {
              priority = 3;
              device = "/dev/disk/by-partuuid/afdf50db-e523-42f7-843c-d0c13a0d5d36";
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
              device = "/dev/disk/by-partuuid/2691484a-66b3-4ad8-90ca-37fdbc18d9cc";
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
              device = "/dev/disk/by-partuuid/30acb5f5-94a8-41c9-8239-f3def0042a6c";
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
  fileSystems."/".neededForBoot = true;
}
