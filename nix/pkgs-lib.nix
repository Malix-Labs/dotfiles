{
  config,
  nixpkgs-unstable,
  ...
}:
{
  _module.args.pkgs-unstable = import nixpkgs-unstable {
    inherit (config.nixpkgs) hostPlatform config;
  };
}
