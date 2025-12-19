{
  lib,

  pkgs,
  pkgs-unstable,

  declarative-flatpak,

  ...
}:
let
  nu = lib.getExe pkgs.nushell;
in
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
      gitkraken
      github-copilot-cli
      simplex-chat-desktop

      sequoia-sq
      sequoia-chameleon-gnupg
    ];
  };

  programs = {
    home-manager.enable = true;

    nushell = {
      enable = true;
      settings = {
        show_banner = false;
      };
    };

    bash = {
      enable = true;
      initExtra = ''
        if [[ $- == *i* ]] && \
          [ -z "$BASH_EXECUTION_STRING" ] && \
          [ "$TERM" != "dumb" ] && \
          [[ ! "$(< /proc/$PPID/comm)" =~ ^nu(shell)?$ ]];
        then
          if shopt -q login_shell; then
            exec ${nu} --login
          else
            exec ${nu}
          fi
        fi
      '';
    };

    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };

    starship = {
      enable = true;
      enableNushellIntegration = true;
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Malix - Alix Brunet";
          email = "alixbrunetcontact@gmail.com";
        };
      };
      signing = {
        signByDefault = true;
        format = "openpgp";
        signer = lib.getExe pkgs.sequoia-chameleon-gnupg;
        key = "369E2AB995539B6F30AAC24C600394C79ED874E5";
      };
    };

    gh = {
      enable = true;
    };

    gh-dash = {
      enable = true;
    };

    helix = {
      enable = true;
    };

    ghostty = {
      enable = true;
      settings.command = nu;
    };

    zed-editor = {
      enable = true;
    };

    vscode = {
      enable = true;
    };

    vesktop = {
      enable = true;
    };
  };

  services = {
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
