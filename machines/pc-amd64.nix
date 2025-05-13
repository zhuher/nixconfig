{ lib, ... }:
{
  imports = [ ./hardware/pc-amd64.nix ];
  networking = {
    useDHCP = lib.mkDefault true;
    hostName = "Zhukomputer";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [
        22
        57766
      ];
      allowedUDPPorts = [
        53
        57766
      ];
      enable = true;
    };
    interfaces = {
      enp34s0.wakeOnLan.enable = true;
    };
  };
}
