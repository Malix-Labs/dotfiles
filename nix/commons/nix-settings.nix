# Common Nix settings shared across all configurations
{
  config,
  lib,
  pkgs,
  ...
}:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "ca-derivations"
      "cgroups"
      "git-hashing"
      "no-url-literals"
      "local-overlay-store"
      "pipe-operators"
      "verified-fetches"
    ];
    substituters = [
      "https://cache.nixos.org/" # don't know if this one is included by default already
      "https://nix-community.cachix.org/"
      "https://hyprland.cachix.org/"
      "https://install.determinate.systems"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" # don't know if this one is included by default already
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
