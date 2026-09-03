{
  pkgs,
  nix-gaming-edge,
  ...
}:
{
  imports = [
    nix-gaming-edge.homeModules.steam-compat-tools
  ];

  programs.prismlauncher.enable = true;

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
