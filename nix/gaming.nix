{
  pkgs,
  nix-gaming-edge,
  ...
}:

let
  steamCompatDirectory = "/usr/share/steam/compatibilitytools.d";
in
{
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      protontricks.enable = true;
      extest.enable = true;
      extraCompatPackages = with pkgs; [
        nix-gaming-edge.packages.${pkgs.stdenv.hostPlatform.system}.proton-cachyos-x86_64-v3
        proton-ge-bin
      ];
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
  systemd.tmpfiles.rules = [
    "L+ ${steamCompatDirectory}/GE-Proton - - - - ${pkgs.proton-ge-bin.steamcompattool}"
    "L+ ${steamCompatDirectory}/Proton-CachyOS-SLR - - - - ${
      nix-gaming-edge.packages.${pkgs.stdenv.hostPlatform.system}.proton-cachyos-x86_64-v3.steamcompattool
    }"
  ];

  environment.systemPackages = with pkgs; [
    gamescope-wsi
  ];
}
