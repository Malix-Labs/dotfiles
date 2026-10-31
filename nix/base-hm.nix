{
  specialArgs,
  pkgs-unstable,
  pkgs-stable,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    extraSpecialArgs = specialArgs // {
      inherit pkgs-unstable pkgs-stable;
    };
  };
}
