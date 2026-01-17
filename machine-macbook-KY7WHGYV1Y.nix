{
  lib,
  currentSystemUser,
  ...
}: {
  homebrew.enable = lib.mkForce false;
  programs.xstarbound.enable = lib.mkForce false;
  sops.secrets = {
    jjsecrets.sopsFile = ./ws.yaml;
    gitsecrets.sopsFile = ./ws.yaml;
    ssh-hosts = {
      mode = "0400";
      path = "/Users/${currentSystemUser}/.ssh/hosts";
      owner = currentSystemUser;
      sopsFile = ./ws.yaml;
    };
  };
}
