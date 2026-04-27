#!/bin/sh
set -euC -o pipefail

REPO="${1:-"https://github.com/Malix-Labs/Template"}"
REPO_PREFIX="${REPO#"https://github.com/"}"

git fetch --depth=1 --no-tags "${REPO}" "${2:-}" # a git fetch call with its second argument being empty strings (`""`) fetches the default branch instead of void (``) which silently crashes

TREE="FETCH_HEAD^{tree}"
PARENT="$(git rev-list --max-parents=0 --first-parent HEAD)"
MESSAGE="update(template): ${REPO_PREFIX}@$(git rev-parse FETCH_HEAD)"

make_commit() {
	git commit-tree "${TREE}" -p "${PARENT}" -m "${MESSAGE}" "$@"
}

# Attempt to sign, fallback to unsigned instead of erroring.
MERGE=$(
	make_commit -S 2>/dev/null || \
	make_commit
)

git merge "${MERGE}" --message "merge: ${MERGE}"
