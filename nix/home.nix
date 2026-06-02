{
  lib,
  config,

  pkgs,
  pkgs-unstable,

  username,
  homeDirectory,
  dotfilesDirectory,

  declarative-flatpak,

  ...
}:
let
  symlinksDirectory = "${dotfilesDirectory}/symlinks";

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
    inherit username homeDirectory;
    stateVersion = "25.11"; # NEVER MUTATE
    activation.createSshSocketDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir --parents ${sshDirectory}/sockets
    '';
    packages = with pkgs; [
      audacity
      gitkraken
      simplex-chat-desktop

      devenv
      forgejo-cli
      tea
      antigravity-cli
    ];
  };

  xdg.configFile = {
    "zed".source = config.lib.file.mkOutOfStoreSymlink "${symlinksDirectory}/zed";
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
      flake = "${dotfilesDirectory}/nix";
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

    nix-your-shell.enable = true;

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
        core.fsmonitor = true;
        feature.manyFiles = true;
        checkout = {
          workers = 0;
          thresholdForParallelism = 500;
        };
        pull.rebase = "merges";
        rebase = {
          rebaseMerges = true;
          autoSquash = true;
          autoStash = true;
          missingCommitsCheck = "error";
        };
        merge.autoStash = true;
        rerere = {
          enabled = true;
          autoUpdate = true;
        };
        push = {
          autoSetupRemote = true;
          useForceIfIncludes = true;
        };
        diff = {
          algorithm = "histogram";
          colorMoved = "dimmed-zebra";
          colorMovedWS = "allow-indentation-change";
          renames = "copies";
        };
        commit.verbose = 2;
        fetch = {
          all = true;
          prune = true;
          pruneTags = true;
        };
        column.ui = "auto dense";
        alias = {
          "pf" = "push --force-with-lease";
          "imerge" = ''
            !f() {
              [ $# -eq 1 ] || { echo "usage: git imerge <target>" >&2; return 2; }
              commits=$(git rev-list --reverse --topo-order HEAD.."$1") || return
              for commit in $commits; do
                git merge "$commit" || return
              done;
            }; f'';
          "cmerge" = ''
            !f() {
              [ $# -eq 1 ] || { echo "usage: git cmerge <target>" >&2; return 2; }

              if git merge-tree --write-tree HEAD "$1" >/dev/null; then
                exec git merge "$1" --no-edit
              fi

              last_clean=
              commits=$(git rev-list --reverse --topo-order HEAD.."$1") || return
              for commit in $commits; do
                if ! git merge-tree --write-tree HEAD "$commit" >/dev/null; then
                  if [ -n "$last_clean" ]; then
                    git merge "$last_clean" --no-edit || return
                  fi
                  exec git merge "$commit"
                fi
                last_clean="$commit"
              done
              if [ -n "$last_clean" ]; then
                exec git merge "$last_clean" --no-edit
              fi
            }; f'';
          # "template" = ''
          #
          # '';
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
          "issue view --json 'assignees,author,body,closed,closedAt,closedByPullRequestsReferences,comments,createdAt,id,isPinned,labels,milestone,number,projectItems,reactionGroups,state,stateReason,title,updatedAt,url'";
        "pr export" =
          "pr view --json 'additions,assignees,author,autoMergeRequest,baseRefName,baseRefOid,body,changedFiles,closed,closedAt,closingIssuesReferences,comments,commits,createdAt,deletions,files,fullDatabaseId,headRefName,headRefOid,headRepository,headRepositoryOwner,id,isCrossRepository,isDraft,labels,latestReviews,maintainerCanModify,mergeCommit,mergeStateStatus,mergeable,mergedAt,mergedBy,milestone,number,potentialMergeCommit,projectItems,reactionGroups,reviewDecision,reviewRequests,reviews,state,statusCheckRollup,title,updatedAt,url'";
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

    github-copilot-cli.enable = true;

    google-chrome = {
      enable = true;
      plasmaSupport = true; # not default yet (see https://github.com/nix-community/home-manager/issues/8949)
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
