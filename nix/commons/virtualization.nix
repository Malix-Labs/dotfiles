# Common virtualization configuration
{ ... }:
{
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other. See https://wiki.nixos.org/wiki/Podman
    };
    waydroid.enable = true;
  };
}
