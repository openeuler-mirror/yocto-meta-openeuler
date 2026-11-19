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

# Write the docs decision as a step output (only meaningful when the
# invoking step declares an id). Callers default to building docs when
# the output is absent, so a platform that drops outputs fails open.
write_docs_output() {
    if [ -n "${ATOMGIT_OUTPUT:-}" ]; then
        echo "docs_changed=$1" >>"${ATOMGIT_OUTPUT}"
    fi
}

echo "== runner context =="
env | grep '^ATOMGIT' | grep -v '^ATOMGIT_TOKEN=' | sort || true
echo "plugin checkout HEAD: $(git rev-parse HEAD 2>/dev/null || echo none)"

HEAD_REF="${ATOMGIT_HEAD_REF:-}"
BASE_REF="${ATOMGIT_BASE_REF:-master}"

if [ -z "${HEAD_REF}" ] || [ "${HEAD_REF}" = "${BASE_REF}" ]; then
    echo "no PR context (head=${HEAD_REF:-<unset>}) - building this checkout"
    write_docs_output true
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

# Resolve the PR this run belongs to. Preferred source is the run
# record (v8 API), which carries pull_request_id for MR and comment
# events alike; the PR detail (v5 API) then yields the exact head SHA
# and the head repository URL. Listing open PRs and matching the head
# branch is kept as a fallback for older platform versions - unlike
# the run record it cannot see PRs merged or closed after the
# trigger, and it is ambiguous when several forks reuse a branch name.
PR_RESOLVED=$(python3 - "${HEAD_REF}" "${BASE_REF}" \
    "${ATOMGIT_SOURCE_REPOSITORY_ID:-}" << 'PYEOF'
import json
import os
import sys
import time
import urllib.request

head_ref, base_ref, source_id = sys.argv[1], sys.argv[2], sys.argv[3].strip()
repo = os.environ.get("ATOMGIT_REPOSITORY", "")
run_id = os.environ.get("ATOMGIT_RUN_ID", "").strip()
token = os.environ.get("ATOMGIT_TOKEN", "")

# api hosts: the one serving the repository url first (that host
# definitely serves this repo), then the runner-declared api host
hosts = []
api = os.environ.get("ATOMGIT_API_URL", "")
if api.startswith("http"):
    hosts.append(api.rstrip("/"))
repo_url = os.environ.get("ATOMGIT_REPOSITORYURL", "")
if repo_url.startswith("http"):
    host = "/".join(repo_url.split("/")[:3])
    if host not in hosts:
        hosts.append(host)


def fetch_json(host, path, tok):
    req = urllib.request.Request(host + path)
    if tok:
        req.add_header("Authorization", f"Bearer {tok}")
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.load(resp)


def call(path):
    # anonymous first: the runner token is rejected by the pulls API
    # on public repos unless the workflow declares pr permission,
    # while anonymous read works there; the token then covers
    # private repositories. A few retries absorb API jitter: every
    # job depends on this call.
    last = None
    for attempt in range(2):
        for tok in (None, token or None):
            for host in hosts:
                try:
                    return fetch_json(host, path, tok)
                except Exception as exc:
                    last = exc
        if attempt < 1:
            time.sleep(1)
    raise last or RuntimeError("no api host")


def emit(number, sha="", head_repo=""):
    print("{}\t{}\t{}".format(number, sha or "", head_repo or ""))


# 1) run record -> pull_request_id -> PR detail (state agnostic)
if run_id:
    number = None
    try:
        rec = call("/api/v8/repos/{}/actions/runs/{}".format(repo, run_id))
        number = rec.get("pull_request_id")
    except Exception as exc:
        print("run record lookup failed: {}".format(exc), file=sys.stderr)
    if number:
        number = str(number)
        try:
            pr = call("/api/v5/repos/{}/pulls/{}".format(repo, number))
            head = pr.get("head") or {}
            base = (pr.get("base") or {}).get("ref")
            if head.get("ref") == head_ref and base == base_ref:
                emit(number, head.get("sha") or "",
                     (head.get("repo") or {}).get("html_url") or "")
                sys.exit(0)
            print("run record PR !{} does not match head {} base {} -"
                  " falling back to the PR list".format(
                      number, head_ref, base_ref), file=sys.stderr)
        except Exception as exc:
            # the number alone still allows merge-request refs
            print("PR detail for !{} unavailable: {}".format(number, exc),
                  file=sys.stderr)
            emit(number)
            sys.exit(0)

# 2) fallback: list open PRs and match head/base/source repo
matches = []
listed = False
try:
    page = 1
    while page <= 10:
        prs = call("/api/v5/repos/{}/pulls?state=open&per_page=100&page={}"
                   .format(repo, page))
        listed = True
        for pr in prs or []:
            head = pr.get("head") or {}
            if head.get("ref") != head_ref:
                continue
            if (pr.get("base") or {}).get("ref") != base_ref:
                continue
            head_repo = head.get("repo") or {}
            if source_id and str(head_repo.get("id", "")) != source_id:
                continue
            matches.append((pr.get("number"), head.get("sha") or "",
                            head_repo.get("html_url") or ""))
        if not prs or len(prs) < 100:
            break
        page += 1
except Exception as exc:
    print("api resolution failed - {}".format(exc), file=sys.stderr)

if len(matches) == 1:
    emit(*matches[0])
elif len(matches) > 1:
    print("ambiguous: {} open PRs match head {} base {}".format(
        len(matches), head_ref, base_ref), file=sys.stderr)
    sys.exit(1)
elif not listed:
    sys.exit(1)
else:
    print("no open PR matches head {} base {} (source repo {})".format(
        head_ref, base_ref, source_id or "any"), file=sys.stderr)
    sys.exit(1)
PYEOF
)
if [ -z "${PR_RESOLVED}" ]; then
    # Same-repository PRs do not need the platform API: the head branch
    # exists in origin. Fall back to it instead of failing all jobs when
    # the API is briefly unavailable. Fork PRs still fail closed - a
    # same-named origin branch would not be the PR.
    if [ -n "${ATOMGIT_SOURCE_REPOSITORY_ID:-}" ] \
        && [ "${ATOMGIT_SOURCE_REPOSITORY_ID}" = "${ATOMGIT_REPOSITORY_ID:-}" ] \
        && git ls-remote --exit-code origin "refs/heads/${HEAD_REF}" >/dev/null 2>&1; then
        echo "::warning::PR resolution unavailable; using the origin head branch" \
             "${HEAD_REF} (same-repo PR, no SHA verification)"
        PR_NUM=""
        PR_SHA=""
        PR_HEAD_REPO=""
    else
        echo "::error::could not resolve the PR for head branch ${HEAD_REF}" \
             "via the platform API; failing instead of building the base branch"
        exit 1
    fi
else
    # split explicitly: tab is IFS whitespace, so `read` would collapse
    # the empty sha field and shift the repository URL into PR_SHA
    case "${PR_RESOLVED}" in
        *$'\t'*$'\t'*) ;;
        *)
            echo "::error::unexpected PR resolution output: ${PR_RESOLVED}"
            exit 1
            ;;
    esac
    PR_NUM="${PR_RESOLVED%%$'\t'*}"
    PR_REST="${PR_RESOLVED#*$'\t'}"
    PR_SHA="${PR_REST%%$'\t'*}"
    PR_HEAD_REPO="${PR_REST#*$'\t'}"
    echo "resolved PR !${PR_NUM}" \
         "(head repo: ${PR_HEAD_REPO:-unknown}, sha: ${PR_SHA:-unknown})"
fi

# Decide whether the docs job needs to build: only PRs that touch docs
# sources or the docs toolchain do. The platform's changed-file list is
# merge-base semantics (unlike a base..head diff), so unrelated commits
# landing on the target branch do not rebuild docs. Any failure to
# obtain the list keeps docs enabled (fail open).
DOCS_CHANGED=true
if [ -n "${PR_NUM}" ]; then
DOCS_CHANGED=$(python3 - "${PR_NUM}" << 'PYEOF'
import json
import os
import sys
import time
import urllib.request

number = sys.argv[1]
repo = os.environ.get("ATOMGIT_REPOSITORY", "")
token = os.environ.get("ATOMGIT_TOKEN", "")

hosts = []
api = os.environ.get("ATOMGIT_API_URL", "")
if api.startswith("http"):
    hosts.append(api.rstrip("/"))
repo_url = os.environ.get("ATOMGIT_REPOSITORYURL", "")
if repo_url.startswith("http"):
    host = "/".join(repo_url.split("/")[:3])
    if host not in hosts:
        hosts.append(host)

DOCS_PREFIXES = ("docs/",)
DOCS_FILES = {
    "scripts/requirements-doc.txt",
    ".gitcode/workflows/scripts/build_docs.sh",
    ".gitcode/workflows/openeuler_embedded_PR_gate.yml",
}


def fetch_json(host, path, tok):
    req = urllib.request.Request(host + path)
    if tok:
        req.add_header("Authorization", f"Bearer {tok}")
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.load(resp)


def call(path):
    last = None
    for attempt in range(2):
        for tok in (None, token or None):
            for host in hosts:
                try:
                    return fetch_json(host, path, tok)
                except Exception as exc:
                    last = exc
        if attempt < 1:
            time.sleep(1)
    raise last or RuntimeError("no api host")


def is_docs(path):
    if not path:
        return False
    if path.startswith(DOCS_PREFIXES):
        return True
    return path in DOCS_FILES


try:
    page = 1
    while page <= 30:
        files = call("/api/v5/repos/{}/pulls/{}/files?per_page=100&page={}"
                     .format(repo, number, page))
        for changed in files or []:
            paths = [changed.get("filename"), changed.get("new_path"),
                     changed.get("old_path")]
            for path in paths:
                if is_docs(path):
                    print("true")
                    print("docs path changed: {}".format(path),
                          file=sys.stderr)
                    sys.exit(0)
        if not files or len(files) < 100:
            break
        page += 1
    else:
        print("true")
        print("more than 30 pages of changed files; building docs",
              file=sys.stderr)
        sys.exit(0)
    print("false")
except Exception as exc:
    print("true")
    print("could not list PR files ({}); building docs".format(exc),
          file=sys.stderr)
PYEOF
)
fi
case "${DOCS_CHANGED}" in
    true|false) ;;
    *) DOCS_CHANGED=true ;;
esac
echo "docs gate: docs_changed=${DOCS_CHANGED}"
write_docs_output "${DOCS_CHANGED}"

# Fetch the PR head, most precise source first. When the API gave us
# the run's head SHA, every fetched tip is validated against it, so a
# force-pushed branch or a same-named branch elsewhere cannot make
# the gate build a commit other than the one this run was created
# for.
fetched=0

fetch_and_check() {
    local url="$1" ref="$2" got
    echo "fetch: ${url} ${ref}"
    git fetch --depth="${GATE_PR_FETCH_DEPTH}" "${url}" "${ref}" || return 1
    got=$(git rev-parse FETCH_HEAD)
    if [ -n "${PR_SHA}" ] && [ "${got}" != "${PR_SHA}" ]; then
        echo "  fetched ${got}, expected ${PR_SHA} - trying the next source"
        return 1
    fi
    fetched=1
    return 0
}

if [ -n "${PR_HEAD_REPO}" ] && [ -n "${PR_SHA}" ]; then
    fetch_and_check "${PR_HEAD_REPO}" "${PR_SHA}"
fi
if [ "${fetched}" = "0" ] && [ -n "${PR_HEAD_REPO}" ]; then
    fetch_and_check "${PR_HEAD_REPO}" "${HEAD_REF}"
fi
if [ "${fetched}" = "0" ] && [ -n "${PR_SHA}" ]; then
    fetch_and_check origin "${PR_SHA}"
fi
# authoritative MR refs before any unverified branch fetch
if [ "${fetched}" = "0" ] && [ -n "${PR_NUM}" ]; then
    fetch_and_check origin "refs/merge-requests/${PR_NUM}/head" \
        || fetch_and_check origin "refs/merge-requests/${PR_NUM}/merge"
fi
if [ "${fetched}" = "0" ] && [ -z "${PR_SHA}" ]; then
    echo "::warning::no head SHA available; fetching origin branch" \
         "${HEAD_REF} without verification"
    fetch_and_check origin "${HEAD_REF}"
fi
if [ "${fetched}" = "0" ]; then
    echo "::error::could not fetch the PR head (${HEAD_REF}, PR !${PR_NUM:-unknown});" \
         "failing instead of building the base branch"
    exit 1
fi
if [ -n "${PR_SHA}" ]; then
    echo "fetched the run's PR head ${PR_SHA}"
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
