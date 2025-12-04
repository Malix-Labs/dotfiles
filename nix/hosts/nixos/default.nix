# Host configuration for nixos (Lenovo Legion laptop)
{ ... }:
{
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  system.stateVersion = "24.11"; # NEVER MUTATE
}
