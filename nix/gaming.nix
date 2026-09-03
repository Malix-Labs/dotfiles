{
  pkgs,

  nix-gaming-edge,

  ...
}:
{
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      protontricks.enable = true;
      extest.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
        nix-gaming-edge.packages.${pkgs.stdenv.hostPlatform.system}.proton-cachyos-x86_64-v3
      ];
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    gamescope = {
      enable = true; # already implicitly enabled by `steam.gamescopeSession.enable`
      enableWsi = true;
      capSysNice = true;
    };

    gamemode.enable = true;
  };
}
