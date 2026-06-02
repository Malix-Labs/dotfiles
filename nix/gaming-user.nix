{
  pkgs,

  ...
}:

{
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
