{
  pkgs,
  lib,
  nix-gaming-edge,
  ...
}:

let
  mkSteamCompatRule =
    tool:
    "L+ /usr/share/steam/compatibilitytools.d/${lib.getName tool} - - - - ${tool.steamcompattool}";
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
      enable = true; # implicitely enabled by `steam.gamescopeSession.enable`, but required to set other options
      capSysNice = true;
    };

    gamemode.enable = true;
  };

  # So that Proton can be discovered by other tools
  systemd.tmpfiles.rules = map mkSteamCompatRule steamCompatTools;

  environment.systemPackages = with pkgs; [
    gamescope-wsi
  ];
}
