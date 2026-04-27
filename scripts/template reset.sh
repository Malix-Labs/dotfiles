#!/bin/sh
set -euC -o pipefail

git fetch --depth=1 --no-tags "${1:-"https://github.com/Malix-Labs/Template"}" "${2:-}" # a git fetch call with its second argument being empty strings (`""`) fetch the default branch instead of void (``) which silently crashes
ROOT=$(git rev-list --max-parents=0 --first-parent HEAD)
git rebase --rebase-merges --no-verify --onto $(git commit-tree FETCH_HEAD^{tree} -m "$(git log --format=%B $ROOT)") $ROOT
