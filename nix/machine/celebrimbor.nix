{
  pkgs,
  lib,
  config,
  inputs,
  currentSystemUser,
  ...
}: let
  env = config.environment.variables;
in {
  imports = [
    inputs.disko.nixosModules.default
    inputs.apollo.nixosModules.default
    ./celebrimbor/disko.nix
    ../module/steam.nix
    ../module/specialisation.nix
    ../module/minecraft.nix
    ../module/navidrome.nix
  ];
  sops.defaultSopsFile = ../../secrets/cbbor.yaml;
  environment.systemPackages = with pkgs; [
    efibootmgr
    ghostty
    keepassxc
    qbittorrent
  ];
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
      limine = {
        enable = true;
        efiSupport = true;
        resolution = "1920x1080x32";
        maxGenerations = 10;
        enableEditor = false;
        extraConfig = ''
          timeout: 5
        '';
        extraEntries = ''
          /Windows
              protocol: efi
              path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
        '';
      };
      grub = {
        enable = false;
      };
      systemd-boot.enable = false;
      timeout = 0;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
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
      systemd = {
        users.root.shell = "/bin/systemd-tty-ask-password-agent";
        network = {
          enable = true;
          networks."10-wan" = {
            matchConfig.Name = "en* eth*"; # or set the exact name, e.g. "enp3s0"
            networkConfig.DHCP = "yes";
          };
        };
      };
    };
  };
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  services = {
    syncthing = {
      dataDir = "${env.HOME}/Sync";
      user = currentSystemUser;
      enable = true;
      openDefaultPorts = true;
    };
    fstrim.enable = true;
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = ["/"];
    };
  };
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  zhuk.git.secrets = false;
  zhuk.jj.secrets = false;
  networking.nameservers = [
    "9.9.9.11"
    "149.112.112.11"
    "2620:fe::11"
    "2620:fe::fe:11"
  ];

  sops.secrets = {
    "sunshine-cakey" = {
      sopsFile = ../../secrets/cbbor/sunchine.cakey.pem;
      key = "data";
      path = "${env.HOME}/.config/sunshine/credentials/cakey.pem";
      mode = "0400";
      owner = currentSystemUser;
    };
    "sunshine-cacert" = {
      sopsFile = ../../secrets/cbbor/sunchine.cacert.pem;
      key = "data";
      path = "${env.HOME}/.config/sunshine/credentials/cacert.pem";
      mode = "0444";
      owner = currentSystemUser;
    };
  };
}
