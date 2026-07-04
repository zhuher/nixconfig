## LoadCredential example
```nix
{
  age.secrets.ncro-cache-password.file = ./ncro-cache-password.age;

  systemd.services.ncro.serviceConfig.LoadCredential = [
    "ncro-cache-password:${config.age.secrets.ncro-cache-password.path}"
  ];

    services.ncro.settings.upstreams = [
    {
      url = "https://cache.internal.example.com";
      username = "ncro";
      password_file = "/run/credentials/ncro.service/ncro-cache-password";
    }
  ];
}
```
