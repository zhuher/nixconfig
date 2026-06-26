{currentSystemUser, ...}: {
  users.groups.media = {};
  users.users.${currentSystemUser}.extraGroups = ["media"];
  users.users.navidrome.extraGroups = ["media"];
  # users.users.lidarr.extraGroups = ["media"];

  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      MusicFolder = "/var/lib/shared-music";
      Port = 4533;
      Address = "0.0.0.0";
      ScanSchedule = "@every 10m";
      LastFM.Enabled = true;
      EnableUve = true;
      ImageCacheSize = "100MB";
    };
  };
  # services.lidarr = { # a worse UX than lidarr sadly...!
  #   enable = true;
  #   openFirewall = true;
  # };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d /home/${currentSystemUser}/Music 0775 ${currentSystemUser} media -"
    "d /home/${currentSystemUser}/Music/.torrents 0775 ${currentSystemUser} media -"
    "d /var/lib/shared-music 0775 ${currentSystemUser} media -"
  ];
  fileSystems."/var/lib/shared-music" = {
    device = "/home/${currentSystemUser}/Music";
    fsType = "none";
    options = ["bind" "rw"];
  };
}
