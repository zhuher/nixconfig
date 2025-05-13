{...}: {
  home.file.".docker/config.json".text = ''
  {
    "auths": {},
    "credHelpers": {
      "docker-hosted.artifactory.tcsbank.ru": "artifactory",
      "docker-proxy.artifactory.tcsbank.ru": "artifactory"
    },
    "currentContext": "colima",
    "features": {
      "buildkit": ""
    }
  }'';
}
