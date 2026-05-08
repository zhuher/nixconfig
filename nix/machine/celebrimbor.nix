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
  specialisation = let
    specList = builtins.attrNames config.specialisation;
    mkDefaultEntry = c: let
      specName = c.zhuk._spec;
      specListWD = ["Default"] ++ specList;
      specIdx = lib.lists.findFirstIndex (name: name == specName) 0 specListWD;
    in "default_entry: ${builtins.toString (specIdx + 3)}";
    mkSpec = name: extraAttrs: i:
      {
        zhuk._spec = name;
        environment.etc."specialisation".text = i.config.zhuk._spec; # for nh
        boot.loader.limine.extraConfig = mkDefaultEntry i.config;
      }
      // extraAttrs;
  in {
    sway.configuration = mkSpec "sway" {imports = [../module/sway.nix];};
  };
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
      systemd = {
        users.root.shell = "/bin/systemd-tty-ask-password-agent";
        network = {
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
      openDefaultPorts = true; # Open ports in the firewall for Syncthing. (NOTE: this will not open syncthing gui port)
    };
    navidrome = {
      enable = true;
      settings.MusicFolder = "${env.HOME}/Music";
    };
    fstrim.enable = true;
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = ["/"];
    };
  };
  programs.zsh.interactiveShellInit = lib.mkBefore ''
    ulimit -n 65535
  '';
  zhuk.git.secrets = false;
  zhuk.jj.secrets = false;
}
