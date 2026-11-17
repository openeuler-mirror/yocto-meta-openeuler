#!/bin/bash
# Put the PR code under test at /tmp/gate-pr-code, keeping this
# checkout (the gate scripts) on the trusted base branch.
#
# Why two checkouts: the runner's checkout plugin fetches whatever
# ATOMGIT_REF points at - on comment-triggered runs that is the base
# branch (observed: ATOMGIT_REF=refs/heads/master on a /retest run),
# so the gate would otherwise build the base branch instead of the
# PR. Conversely, naively switching this checkout to the PR would let
# the PR supply its own gate scripts (the player rewriting the
# referee's rules). So:
#   - this checkout stays on the base branch: trusted gate scripts
#   - the PR head branch (ATOMGIT_HEAD_REF, set even on comment
#     events) is fetched into a git worktree at GATE_PR_CODE_DIR so
#     it keeps its git history (oebuild's os-release revision reads
#     repo.head.object.hexsha from it)
#   - the build scripts link the worktree into the oebuild workspace
#     as the code under test
# Without PR context (e.g. workflow_dispatch) nothing is changed and
# the build falls back to this checkout.

set -u

GATE_PR_CODE_DIR="${GATE_PR_CODE_DIR:-/tmp/gate-pr-code}"

echo "== runner context =="
env | grep '^ATOMGIT' | grep -v '^ATOMGIT_TOKEN=' | sort || true
echo "plugin checkout HEAD: $(git rev-parse HEAD 2>/dev/null || echo none)"

HEAD_REF="${ATOMGIT_HEAD_REF:-}"
BASE_REF="${ATOMGIT_BASE_REF:-master}"

if [ -z "${HEAD_REF}" ] || [ "${HEAD_REF}" = "${BASE_REF}" ]; then
    echo "no PR context (head=${HEAD_REF:-<unset>}) - building this checkout"
    echo "== build HEAD =="
    git rev-parse HEAD
    git log --oneline -3
    exit 0
fi

echo "== PR detected: head branch ${HEAD_REF}, base ${BASE_REF} =="

# 1. keep this checkout (the gate scripts) on the trusted base branch
if git fetch --depth=1 origin "${BASE_REF}" 2>/dev/null \
        && git checkout --force -B "${BASE_REF}" \
               "refs/remotes/origin/${BASE_REF}" 2>/dev/null; then
    echo "gate scripts: ${BASE_REF} @ $(git rev-parse HEAD)"
else
    echo "::warning::could not reset this checkout to ${BASE_REF};" \
         "gate scripts stay at $(git rev-parse HEAD 2>/dev/null || echo unknown)"
fi

# 2. materialize the PR code into a git worktree
# the tip commit's tree already contains every commit's changes
# (commits are snapshots), but fetch some history as well so the
# git log diagnostics show the PR's commit chain; depth is
# configurable for large PRs. Failures here are fatal: with the PR
# context confirmed, silently falling back to the base checkout
# would let the gate pass without testing the PR.
if ! git fetch --depth="${GATE_PR_FETCH_DEPTH:-10}" origin "${HEAD_REF}"; then
    echo "::error::could not fetch the PR head branch ${HEAD_REF};" \
         "failing instead of building the base branch"
    exit 1
fi

rm -rf "${GATE_PR_CODE_DIR}"
git worktree prune
if git worktree add --detach "${GATE_PR_CODE_DIR}" FETCH_HEAD; then
    echo "PR code worktree: ${GATE_PR_CODE_DIR}"
    echo "== code under test (PR head) =="
    git -C "${GATE_PR_CODE_DIR}" rev-parse HEAD
    git -C "${GATE_PR_CODE_DIR}" log --oneline -3
else
    echo "::error::could not create the worktree at ${GATE_PR_CODE_DIR};" \
         "failing instead of building the base branch"
    exit 1
fi

echo "== gate scripts HEAD (this checkout) =="
git rev-parse HEAD
