{
  pkgs,
  pkgs-unstable,
  declarative-flatpak,
  ...
}:
{
  imports = [
    declarative-flatpak.homeModules.default
  ];

  home = {
    username = "malix";
    homeDirectory = "/home/malix";
    stateVersion = "25.11";
    packages = with pkgs; [
      google-chrome
      audacity
      gh
      vesktop
      zed-editor
      vscode
      gitkraken
      github-copilot-cli
      simplex-chat-desktop
      sequoia-sq # Sequoia OpenPGP implementation
    ];
  };

  programs = {
    home-manager.enable = true;
    
    gpg = {
      enable = true;
      settings = {
        # Use Sequoia as the default backend when possible
        # Note: Sequoia provides the 'sq' command-line tool for OpenPGP operations
      };
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
    
    flatpak = {
      enable = true;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      };
      packages = [
        "flathub:app/org.vinegarhq.Sober//stable"
      ];
      overrides = {
        "org.vinegarhq.Sober" = {
          Context.filesystems = [
            "xdg-run/pipewire-0"
            "xdg-run/app/com.discordapp.Discord:create"
            "xdg-run/discord-ipc-0"
          ];
          environment = {
            "SDL_AUDIO_DRIVER" = "pipewire";
          };
        };
      };

      # Workaround for unsupported overrides (see https://github.com/in-a-dil-emma/declarative-flatpak/issues/42#issuecomment-3400500573)
      preSwitchCommand = ''
        flatpak override --device=input org.vinegarhq.Sober
      '';
    };
  };
}
