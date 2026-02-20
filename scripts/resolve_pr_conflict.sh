#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <base-branch> <feature-branch> [remote]"
  echo "Example: $0 main work origin"
  exit 1
fi

BASE_BRANCH="$1"
FEATURE_BRANCH="$2"
REMOTE="${3:-origin}"

echo "[1/7] Fetching latest branches from ${REMOTE}..."
git fetch "${REMOTE}" "${BASE_BRANCH}" "${FEATURE_BRANCH}"

echo "[2/7] Switching to feature branch ${FEATURE_BRANCH}..."
git checkout "${FEATURE_BRANCH}"

echo "[3/7] Ensuring clean working tree..."
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is not clean. Commit/stash changes before running this script."
  exit 2
fi

echo "[4/7] Merging ${REMOTE}/${BASE_BRANCH} into ${FEATURE_BRANCH}..."
set +e
git merge --no-ff "${REMOTE}/${BASE_BRANCH}"
MERGE_EXIT=$?
set -e

if [[ ${MERGE_EXIT} -ne 0 ]]; then
  echo ""
  echo "Merge conflict detected."
  echo "Resolve conflicts (likely index.html), then run:"
  echo "  git add <resolved-files>"
  echo "  git commit"
  echo ""
  echo "After commit, continue with:"
  echo "  git push ${REMOTE} ${FEATURE_BRANCH}"
  exit 3
fi

echo "[5/7] Merge completed without conflicts."

echo "[6/7] Running quick status check..."
git status --short

echo "[7/7] Push your branch:"
echo "  git push ${REMOTE} ${FEATURE_BRANCH}"
