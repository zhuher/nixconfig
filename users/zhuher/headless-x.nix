{ pkgs, ... }:
{
  services.xserver = {
    # Dummy screen
    monitorSection = ''
      VendorName     "Unknown"
      HorizSync      30-85
      VertRefresh    48-120

      ModelName      "Unknown"
      Option         "DPMS"
    '';

    deviceSection = ''
      VendorName  "NVIDIA Corporation"
      Option      "AllowEmptyInitialConfiguration"
      Option      "ConnectedMonitor" "DFP"
      Option      "CustomEDID" "DFP-0"
    '';

    screenSection = ''
      DefaultDepth    24
      Option         "ModeValidation" "AllowNonEdidModes, NoVesaModes"
      Option         "MetaModes" "1920x1080"
      SubSection     "Display"
          Depth       24
      EndSubSection
    '';
  };
}
