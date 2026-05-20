{
  pkgs,

  ...
}:

{
  home.packages = with pkgs; [
    prismlauncher

    (heroic.override {
      extraPkgs =
        pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
    })
  ];
}
