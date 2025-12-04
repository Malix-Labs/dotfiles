# User definition for host nixos
{ ... }:
{
  users.users.malix = {
    isNormalUser = true;
    description = "Malix";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
    ];
  };
}
