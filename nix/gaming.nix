{
  pkgs,
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
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
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
  ];

  environment.systemPackages = [
    pkgs.gamescope-wsi
  ];
}
