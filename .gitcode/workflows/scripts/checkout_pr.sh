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
#
# A PR targeting a branch other than the gate's own (derived from
# ATOMGIT_WORKFLOW_REF, defaulting to master) is rejected before
# anything is touched: the platform runs this default-branch
# workflow for every PR, and such a base branch carries no gate
# scripts to build with.

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

# 1. this gate covers exactly one branch: the one it lives on. The
# runner executes the default-branch workflow for every
# pull_request_target event, so a PR targeting a release branch that
# never carried the gate (e.g. openEuler-24.03-LTS-Next) still lands
# here - and resetting this checkout to that base would delete the
# gate scripts the workflow references by relative path (observed
# live as "build_docs.sh: No such file or directory"). Fail fast
# with a clear reason instead; the build jobs then skip cleanly.
# GATE_BRANCH overrides the derivation (which branch this workflow
# came from), e.g. while testing a gate deployed on another branch.
GATE_BRANCH="${GATE_BRANCH:-}"
if [ -z "${GATE_BRANCH}" ]; then
    case "${ATOMGIT_WORKFLOW_REF:-}" in
        *@refs/heads/*) GATE_BRANCH="${ATOMGIT_WORKFLOW_REF##*@refs/heads/}" ;;
        *) GATE_BRANCH="master" ;;
    esac
fi
if [ "${BASE_REF}" != "${GATE_BRANCH}" ]; then
    echo "::error::this gate lives on ${GATE_BRANCH} and only covers PRs targeting ${GATE_BRANCH}."
    echo "::error::this PR targets ${BASE_REF}, which has no GitCode gate of its own -"
    echo "::error::failing instead of building a branch the gate was never written for."
    exit 1
fi

# 2. keep this checkout (the gate scripts) on the trusted base branch
if git fetch --depth=1 origin "${BASE_REF}" 2>/dev/null \
        && git checkout --force -B "${BASE_REF}" \
               "refs/remotes/origin/${BASE_REF}" 2>/dev/null; then
    echo "gate scripts: ${BASE_REF} @ $(git rev-parse HEAD)"
else
    echo "::warning::could not reset this checkout to ${BASE_REF};" \
         "gate scripts stay at $(git rev-parse HEAD 2>/dev/null || echo unknown)"
fi

# 3. materialize the PR code into a git worktree
# the tip commit's tree already contains every commit's changes
# (commits are snapshots), but fetch some history as well so the
# git log diagnostics show the PR's commit chain; depth is
# configurable for large PRs. Failures here are fatal: with the PR
# context confirmed, silently falling back to the base checkout
# would let the gate pass without testing the PR.
GATE_PR_FETCH_DEPTH="${GATE_PR_FETCH_DEPTH:-10}"

if ! git fetch --depth="${GATE_PR_FETCH_DEPTH}" origin "${HEAD_REF}" 2>/dev/null; then
    # fork PR: the head branch lives in the author's fork, not in
    # this repository. Resolve the PR through the platform API (match
    # head branch + target branch + source repo id), then fetch from
    # the fork, with the merge-request refs on origin as fallbacks.
    echo "head branch ${HEAD_REF} not in origin - resolving the PR via the platform API (fork PR)"
    PR_RESOLVED=$(python3 - "${HEAD_REF}" "${BASE_REF}" \
        "${ATOMGIT_SOURCE_REPOSITORY_ID:-}" << 'PYEOF'
import json
import os
import sys
import urllib.request

head_ref, base_ref, source_id = sys.argv[1], sys.argv[2], sys.argv[3].strip()
repo = os.environ.get("ATOMGIT_REPOSITORY", "")
token = os.environ.get("ATOMGIT_TOKEN", "")

# api base candidates: derived from the repository url first (that
# host definitely serves this repo), then the runner-declared api
bases = []
repo_url = os.environ.get("ATOMGIT_REPOSITORYURL", "")
if repo_url.startswith("http"):
    bases.append("/".join(repo_url.split("/")[:3]) + "/api/v5")
api = os.environ.get("ATOMGIT_API_URL", "")
if api.startswith("http"):
    bases.append(api.rstrip("/") + "/api/v5")


def list_pulls(base, tok):
    prs_all = []
    page = 1
    while page <= 10:
        url = (f"{base}/repos/{repo}/pulls"
               f"?state=open&per_page=100&page={page}")
        req = urllib.request.Request(url)
        if tok:
            req.add_header("Authorization", f"Bearer {tok}")
        with urllib.request.urlopen(req, timeout=30) as resp:
            prs = json.load(resp)
        prs_all.extend(prs or [])
        if not prs or len(prs) < 100:
            break
        page += 1
    return prs_all


matches = []
errors = []
listed = False
# anonymous first: the runner's workflow token is rejected by the
# pulls API on public repos unless the workflow declares pr
# permission, while anonymous read works there; the token then
# covers private repositories
for base in bases:
    for tok in (None, token or None):
        try:
            prs = list_pulls(base, tok)
        except Exception as exc:
            errors.append(f"{base} "
                          f"({'token' if tok else 'anonymous'}): {exc}")
            continue
        listed = True
        for pr in prs:
            head = pr.get("head") or {}
            if head.get("ref") != head_ref:
                continue
            if (pr.get("base") or {}).get("ref") != base_ref:
                continue
            head_repo = head.get("repo") or {}
            if source_id and str(head_repo.get("id", "")) != source_id:
                continue
            matches.append((pr.get("number"),
                            head_repo.get("html_url", "")))
        break
    if listed:
        break

if len(matches) == 1:
    number, fork = matches[0]
    print(f"{number}\t{fork}")
elif len(matches) > 1:
    print(f"ambiguous: {len(matches)} open PRs match head {head_ref} "
          f"base {base_ref} - cannot pick one safely", file=sys.stderr)
    sys.exit(1)
elif not listed:
    print("api resolution failed - " + " | ".join(errors or ["no api"]),
          file=sys.stderr)
    sys.exit(1)
else:
    print(f"no open PR matches head {head_ref} base {base_ref} "
          f"(source repo {source_id or 'any'})", file=sys.stderr)
    sys.exit(1)
PYEOF
    )
    if [ -z "${PR_RESOLVED}" ]; then
        echo "::error::could not resolve the PR for head branch ${HEAD_REF}" \
             "via the platform API; failing instead of building the base branch"
        exit 1
    fi
    PR_NUM="${PR_RESOLVED%%	*}"
    FORK_URL="${PR_RESOLVED#*	}"
    echo "resolved PR !${PR_NUM} (head repo: ${FORK_URL:-unknown})"

    fetched=0
    if [ -n "${FORK_URL}" ] \
        && git fetch --depth="${GATE_PR_FETCH_DEPTH}" "${FORK_URL}" "${HEAD_REF}"; then
        echo "fetched the PR head branch from the fork"
        fetched=1
    fi
    if [ "${fetched}" = "0" ] && [ -n "${PR_NUM}" ]; then
        if git fetch --depth="${GATE_PR_FETCH_DEPTH}" origin \
                "refs/merge-requests/${PR_NUM}/head" \
            || git fetch --depth="${GATE_PR_FETCH_DEPTH}" origin \
                "refs/merge-requests/${PR_NUM}/merge"; then
            echo "fetched the PR via refs/merge-requests/${PR_NUM}"
            fetched=1
        fi
    fi
    if [ "${fetched}" = "0" ]; then
        echo "::error::could not fetch the PR head (${HEAD_REF}, PR !${PR_NUM});" \
             "failing instead of building the base branch"
        exit 1
    fi
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
