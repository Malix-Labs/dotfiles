{
  pkgs,
  lib,

  username,

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
      enable = true; # already implicitly enabled by `steam.gamescopeSession.enable`
      capSysNice = true;
    };

    gamemode.enable = true;
  };

  home-manager.users.${username}.xdg.dataFile = lib.listToAttrs (
    map (tool: {
      name = "Steam/compatibilitytools.d/${lib.getName tool}";
      value.source = tool.steamcompattool;
    }) steamCompatTools
  );

  environment.systemPackages = with pkgs; [
    gamescope-wsi
  ];
}
