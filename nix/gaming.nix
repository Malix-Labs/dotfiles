{
  pkgs,
  ...
}:

{
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      protontricks.enable = true;
      extest.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    gamescope = {
      enable = true; # implicitely enabled by `steam.gamescopeSession.enable`, but required to set other options
      capSysNice = true;
    };

    gamemode.enable = true;
  };
}
