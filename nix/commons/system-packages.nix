# Common system packages
{
  pkgs,
  fh,
  mcp-nixos,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ghostty
    helix
    wget
    git
    fastfetch
    wl-clipboard-rs
    # clipboard-jh # broken for Wayland, see https://github.com/Slackadays/Clipboard/issues/171

    nixd
    nixfmt-rfc-style
    fh.packages.${pkgs.system}.default
    mcp-nixos.packages.${pkgs.system}.default

    cloudflare-warp
    protonvpn-gui
  ];
}
