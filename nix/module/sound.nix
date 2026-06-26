{
  pkgs,
  currentSystemUser,
  ...
}: {
  environment.systemPackages = with pkgs; [pwvucontrol_git];
  hardware.firmware = with pkgs; [sof-firmware];
  services = {
    pulseaudio.enable = false; # Realtime scheduling for pipewire and pulseaudio
    pipewire = {
      enable = true;
      # package = pkgs.pkgsx86_64_v3.pipewire; # approx. twelve years to compile
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber = {
        enable = true;
        # package = pkgs.pkgsx86_64_v3.wireplumber; # approx. twelve years to compile
        extraConfig = {
          "51-default-sink" = {
            "monitor.alsa.rules" = [
              {
                matches = [{"node.name" = "~alsa_output.*";}];
                actions = {update-props = {"node.disabled" = true;};};
              }
            ];
            "wireplumber.settings" = {
              "default.configured.audio.sink" = "sink-sunshine-surround71";
            };
          };
        };
      };
      jack.enable = false;
      # extraConfig.pipewire = {
      #   "10-sunshine-only-sink" = {
      #     "context.objects" = [
      #       {
      #         factory = "adapter";
      #         args = {
      #           "factory.name" = "support.null-audio-sink";
      #           "node.name" = "Sunshine-only";
      #           "media.class" = "Audio/Sink";
      #           "node.description" = "Output for Sunshine";
      #           "audio.position" = "FL,FC,FR,RR,RL";
      #         };
      #       }
      #     ];
      #   };
      # };
      # systemWide = true;
    };
  };
  security.rtkit.enable = true;
  users.users.${currentSystemUser}.extraGroups = ["pipewire" "audio"];
}
