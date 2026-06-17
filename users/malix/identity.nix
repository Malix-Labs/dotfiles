{
  lib,
  ...
}:

let
  fullname_deduce =
    first: middle: last:
    "${first} ${middle} ${last}";
  from_api = id: { inherit id; };
in
{
  users.malix = rec {
    email = "alixbrunetcontact@gmail.com";
    login = lib.toLower username;
    username = "Malix";
    name = rec {
      first = "Alix";
      last = "Brunet";
      full = fullname_deduce first last;
    };
    description = "${username} - ${name.full}";
    providers = {
      github = from_api "76160668"; # https://api.github.com/user/76160668
      x = from_api "882328150298030083"; # https://api.x.com/2/users/882328150298030083
    };
  };
}
