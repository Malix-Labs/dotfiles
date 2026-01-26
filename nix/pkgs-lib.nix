{
  pkgs,
  nixpkgs-unstable,
  ...
}:
{
  _module.args.pkgs-unstable = import nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (pkgs) config;
  };
}
