{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # 1. Microsoft Reserved (p1)
            msr = {
              start = "103424K";
              size = "16384K";
              type = "0C01";
            };

            # 2. Windows Basic Data (p2)
            windows = {
              device = "/dev/nvme0n1p2";
              # start = "119808K";
              # size = "208965632K";
              type = "0700"; #gdisk
              content = {
                type = "filesystem";
                format = "ntfs"; # Mounts Windows C: drive
                mountpoint = "/windows";
              };
            };

            # 3. Windows Recovery (p3)
            recovery = {
              device = "/dev/nvme0n1p3";
              # start = "209085440K";
              # size = "748544K";
              type = "2700"; #gdisk
              content = {
                type = "filesystem";
                format = "ntfs";
                mountpoint = "/winre";
              };
            };

            # 4. EFI System Partition (p4)
            ESP = {
              device = "/dev/nvme0n1p4";
              # start = "209833984K";
              # size = "1024000K";
              type = "EF00"; #gdisk
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
          };
        };
      };
    };
  };
}
