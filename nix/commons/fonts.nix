# Common fonts configuration
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    nerd-fonts.noto
    noto-fonts-color-emoji
    nerd-fonts.fira-code
  ];
}
