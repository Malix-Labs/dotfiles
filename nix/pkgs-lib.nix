{
  config,
  nixpkgs-unstable,
  ...
}:
{
  _module.args.pkgs-unstable = import nixpkgs-unstable {
    hostPlatform = config.nixpkgs.hostPlatform;
  };
}
