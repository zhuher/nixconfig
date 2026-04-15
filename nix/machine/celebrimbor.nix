{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.default
    inputs.apollo.nixosModules.default
    ./celebrimbor/disko.nix
    ../module/steam.nix
  ];
  environment.systemPackages = with pkgs; [efibootmgr ghostty];
  system = {
    stateVersion = "26.05";
  };
  networking = {
    interfaces = {
      enp34s0 = {
        wakeOnLan = {
          enable = true;
          policy = ["magic"];
        };
      };
    };
    firewall = {
      allowedUDPPorts = [9];
    };
  };
  boot = {
    loader = {
      grub = {
        enable = false;
      };
      systemd-boot.enable = false;
      timeout = 5;
      # 🚀 Bootloader Configuration
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      limine = {
        enable = true;
        efiSupport = true;
        resolution = "1920x1080x32";
        maxGenerations = 10;
        enableEditor = false;
        extraConfig = ''
          timeout: 0
        '';
        extraEntries = ''
          /Windows
              protocol: efi
              path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
        '';
      };
    };

    kernelModules = [
      "ahci" # Advanced Host Controller Interface for SATA devices
      "xhci_pci" # USB 3.0
      "failover" # Base failover functionality
      "net_failover" # Network failover capability
      "nvme"
      "usb_storage"
      "xhci_pci"
    ];
    kernelParams = [
      "ahci.mobile_lpm_policy=1" # no power management for SATA: LPM support broken, forcing max_power
    ];

    # kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelPackages = pkgs.linuxPackages_latest;
    initrd = {
      enable = true;
      availableKernelModules = ["r8169"];
      network = {
        enable = true;
        flushBeforeStage2 = true;
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
          hostKeys = ["/boot/initrd_ssh_host_ed25519_key"];
        };
      };
      # NEW: use systemd-networkd in initrd (instead of udhcpc)
      # The exact option names can vary a bit by nixpkgs revision, but the idea is:
      # - enable networkd in initrd
      # - add a .network that enables DHCP on your NIC
      systemd.network = {
        enable = true;
        networks."10-wan" = {
          matchConfig.Name = "en* eth*"; # or set the exact name, e.g. "enp3s0"
          networkConfig.DHCP = "yes";
          # optionally:
          # networkConfig.IPv6AcceptRA = true;
          # dhcpV4Config.UseDomains = true;
        };
      };
    };
  };
  systemd.services.initrd-luks-profile = {
    description = "Initrd helper to add cryptsetup-askpass to root profile";
    wantedBy = ["initrd.target"];
    before = ["initrd.target"];
    after = ["systemd-tmpfiles-setup.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      echo 'cryptsetup-askpass' >> /root/.profile
      echo 'exit' >> /root/.profile
    '';
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  specialisation.sway.configuration = {
    environment.etc."specialisation".text = config.zhuk.__spec; # for nh
    imports = [
      ../module/sway.nix
    ];
  };
  services = {
    fstrim.enable = true;
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = ["/"];
    };
  };
  programs.xstarbound.enable = false;
  zhuk.git.secrets = false;
  zhuk.jj.secrets = false;
}
