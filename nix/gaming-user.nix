{
  pkgs,
  osConfig,
  nix-gaming-edge,
  ...
}:
{
  imports = [
    nix-gaming-edge.homeModules.steam-compat-tools
  ];

  programs = {
    prismlauncher.enable = true;

    steam-compat-tools = {
      enable = true;
      packages = osConfig.programs.steam.extraCompatPackages;
    };
  };

  home.packages = with pkgs; [
    (heroic.override {
      extraPkgs =
        pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
    })
  ];
}
