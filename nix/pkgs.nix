{
  lib,

  pkgs,
  nixpkgs-chosen,

  nixpkgs-unstable,
  nixpkgs-stable,

  ...
}:
{
  _module.args =
    {
      unstable = nixpkgs-unstable;
      stable = nixpkgs-stable;
    }
    |> lib.concatMapAttrs (
      name: channel: {
        "pkgs-${name}" =
          if nixpkgs-chosen == channel then
            pkgs
          else
            import channel {
              inherit (pkgs) config;
              inherit (pkgs.stdenv.hostPlatform) system;
            };
      }
    );
}
