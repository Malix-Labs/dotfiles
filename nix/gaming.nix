{
  pkgs,

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
      enableWsi = true;
      capSysNice = true;
    };

    gamemode.enable = true;
  };

  # Make steamCompatTools usable elsewhere
  home-manager.users.${username} = {
    imports = [ nix-gaming-edge.homeModules.steam-compat-tools ];
    programs.steam-compat-tools = {
      enable = true;
      packages = steamCompatTools;
    };
  };
}
