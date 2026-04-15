{...}: {
  programs.steam = {
    enable = true;
  };
  # Optional: If you encounter amdgpu issues with newer kernels (e.g., 6.10+ reported issues),
  # you might consider using the LTS kernel or a known stable version.
  # boot.kernelPackages = pkgs.linuxPackages_lts; # Example for LTS
}
