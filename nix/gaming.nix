{
  pkgs,
  lib,
  nix-gaming-edge,
  ...
}:

let
  steamCompatTools = with pkgs; [
    proton-ge-bin
    nix-gaming-edge.packages.${pkgs.stdenv.hostPlatform.system}.proton-cachyos-x86_64-v3
  ];
in
{
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      protontricks.enable = true;
      extest.enable = true;
      extraCompatPackages = steamCompatTools;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    gamescope = {
      enable = true; # implicitly enabled by `steam.gamescopeSession.enable`, but required to set other options
      capSysNice = true;
    };

    gamemode.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gamescope-wsi
  ];
}
