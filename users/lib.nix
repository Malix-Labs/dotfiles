{
  lib,
  config,
  ...
}:

let
  inherit (lib) mkOption types;

  provider = types.submodule {
    options = {
      id = mkOption {
        type = types.str;
      };
    };
  };

  user =
    {
      name,
      config,
      ...
    }:
    {
      options = {
        login = mkOption {
          type = types.str;
          default = name;
        };

        username = mkOption {
          type = types.str;
          default = lib.toLower config.login;
        };

        email = mkOption {
          type = types.str;
          description = "Primary contact email.";
        };

        name = {
          first = mkOption {
            type = types.str;
          };
          middle = mkOption {
            type = types.str;
          };
          last = mkOption {
            type = types.str;
          };
          full = "${config.name.first} ${config.name.middle} ${config.name.last}";
        };

        description = mkOption {
          type = types.str;
          # Logic: "${username} - ${name.full}"
          default = "${config.username} - ${config.name.full}";
          description = "GECOS or profile description.";
        };

        providers = {
          github = mkOption {
            type = types.nullOr provider;
            default = null;
          };
          x = mkOption {
            type = types.nullOr provider;
            default = null;
          };
        };
      };
    };

in
{
  options.identity.users = mkOption {
    type = types.attrsOf (types.submodule user);
    default = { };
    description = "Map of user identities.";
  };
}
