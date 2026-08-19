{
  lib,
  username,
  ...
}:
let
  secretsDir = ./secrets;

  secretNames =
    secretsDir
    |> lib.readDir
    |> lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".age" name)
    |> lib.attrNames
    |> map (lib.removeSuffix ".age");
in
{
  vaultix.secrets = lib.genAttrs secretNames (name: {
    file = secretsDir + "/${name}.age";
    owner = username;
  });
}
