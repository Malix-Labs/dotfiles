{
  pkgs,
  lib,
  nix-gaming-edge,
  ...
}:

let
  mkSteamCompatRule =
    tool:
    "L+ %h/.local/share/Steam/compatibilitytools.d/${lib.getName tool} - - - - ${tool.steamcompattool}";
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
      enable = true; # already implicitly enabled by `steam.gamescopeSession.enable`
      capSysNice = true;
    };

    gamemode.enable = true;
  };

  # So that Proton can be discovered by other tools
  systemd.user.tmpfiles.rules = map mkSteamCompatRule steamCompatTools;

  environment.systemPackages = with pkgs; [
    gamescope-wsi
  ];
}
