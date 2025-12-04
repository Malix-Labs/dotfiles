# NixOS-specific localization settings
{ ... }:
{
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocales = [
    "en_US.UTF-8"
    "fr_CH.UTF-8"
    "fr_FR.UTF-8"
  ];

  console.keyMap = "fr";
}
