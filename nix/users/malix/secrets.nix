{
  config,
  lib,
  username,
  ...
}:
let
  owner = username;

  secretsDir = ./secrets;

  secretNames =
    secretsDir
    |> lib.readDir
    |> lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".age" name)
    |> lib.attrNames
    |> map (lib.removeSuffix ".age");
in
{
  vaultix = {
    secrets = lib.genAttrs secretNames (name: {
      inherit owner;
      file = "${secretsDir}/${name}.age";
    });

    templates."secrets.env" = {
      inherit owner;
      content =
        let
          inherit (config.vaultix.placeholder)
            github_token
            gitlab_token
            context7_api_key
            ;
        in
        {
          GITHUB_TOKEN = github_token;
          GITHUB_PERSONAL_ACCESS_TOKEN = github_token;
          GITLAB_TOKEN = gitlab_token;
          GITLAB_PERSONAL_ACCESS_TOKEN = gitlab_token;
          CONTEXT7_API_KEY = context7_api_key;
        }
        |> lib.generators.toKeyValue { };
    };
  };
}
