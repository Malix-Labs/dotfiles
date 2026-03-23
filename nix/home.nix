{
  lib,
  config,

  pkgs,
  pkgs-unstable,

  declarative-flatpak,

  ...
}:
let
  dotfilesDir = "${config.home.homeDirectory}/Repositories/Malix-Labs/dotfiles";
  symlinksDir = "${dotfilesDir}/symlinks";

  nu = lib.getExe pkgs.nushell;
  sshDirectory = "${config.home.homeDirectory}/.ssh";
in
{
  imports = [
    ./pkgs-lib.nix
    declarative-flatpak.homeModules.default
    ./gaming-user.nix
  ];

  home = {
    username = "malix";
    homeDirectory = "/home/malix";
    stateVersion = "25.11"; # NEVER MUTATE
    activation.createSshSocketDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir --parents ${sshDirectory}/sockets
    '';
    packages = with pkgs; [
      audacity
      gitkraken
      github-copilot-cli
      simplex-chat-desktop

      devenv
    ];
  };

  xdg.configFile = {
    "zed".source = config.lib.file.mkOutOfStoreSymlink "${symlinksDir}/zed";
  };

  programs = {
    home-manager.enable = true;

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 2w --keep 10 --optimise";
        dates = "daily";
      };
      flake = "${dotfilesDir}/nix";
    };

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

    nix-your-shell = {
      enable = true;
      package = pkgs-unstable.nix-your-shell.overrideAttrs (
        finalAttrs: _: {
          version = "${finalAttrs.src.owner}/${finalAttrs.src.repo}";
          src = pkgs.fetchFromGitHub {
            owner = "Malix-Labs";
            repo = "nix-your-shell";
            rev = "fix-nushell-completions";
            hash = "sha256-YBnfByywQY/oR6GahGnao1TIWLHxTZAsnMAuh8RmCw0=";
          };
        }
      );
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    carapace.enable = true;

    starship.enable = true;

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
        format = "ssh";
        key = "${sshDirectory}/id_ed25519.pub";
      };
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        addKeysToAgent = "yes";
        identityFile = [
          "${sshDirectory}/id_ed25519"
        ];
        identitiesOnly = true;

        controlMaster = "auto";
        controlPath = "${sshDirectory}/sockets/%r@%n:%p";
        controlPersist = "1h";

        serverAliveInterval = 60;

        hashKnownHosts = true;

        setEnv.COLORTERM = "truecolor";
      };
    };

    gh = {
      enable = true;
      settings.aliases = {
        "issue export" =
          "issue view --comments --json 'assignees,author,body,closed,closedAt,closedByPullRequestsReferences,comments,createdAt,id,isPinned,labels,milestone,number,projectItems,reactionGroups,state,stateReason,title,updatedAt,url'";
        "pr export" =
          "pr view --comments --json 'additions,assignees,author,autoMergeRequest,baseRefName,baseRefOid,body,changedFiles,closed,closedAt,closingIssuesReferences,comments,commits,createdAt,deletions,files,fullDatabaseId,headRefName,headRefOid,headRepository,headRepositoryOwner,id,isCrossRepository,isDraft,labels,latestReviews,maintainerCanModify,mergeCommit,mergeStateStatus,mergeable,mergedAt,mergedBy,milestone,number,potentialMergeCommit,projectItems,reactionGroups,reviewDecision,reviewRequests,reviews,state,statusCheckRollup,title,updatedAt,url'";
      };
    };

    gh-dash.enable = true;

    helix = {
      enable = true;
      defaultEditor = true;
    };

    ghostty = {
      enable = true;
      settings.command = nu;
    };

    zed-editor = {
      enable = true;
      package = pkgs-unstable.zed-editor;
    };

    vscode = {
      enable = true;
      package = pkgs-unstable.vscode;
    };

    google-chrome = {
      enable = true;
      plasmaSupport = true; # not default yet (see https://github.com/nix-community/home-manager/issues/8949)
      # nativeMessagingHosts = with pkgs; [ # extensions doesn't work with proprietary chrome (see https://github.com/nix-community/home-manager/issues/1383)
      #   kdePackages.plasma-browser-integration
      # ];
    };

    vesktop.enable = true;
  };

  services = {
    ssh-agent.enable = true;

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
          Context = {
            filesystems = [
              "xdg-run/pipewire-0"
              "xdg-run/app/com.discordapp.Discord:create"
              "xdg-run/discord-ipc-0"
            ];
            devices = [
              "input"
            ];
          };
          Environment = {
            "SDL_AUDIO_DRIVER" = "pipewire";
          };
        };
      };
    };
  };
}
