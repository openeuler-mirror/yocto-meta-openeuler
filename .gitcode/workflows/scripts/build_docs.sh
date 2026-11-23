#!/bin/bash
# Build the documentation for the GitCode Actions PR gate.
#
# The gate job containers' 'options: --user jenkins' setting has no
# effect on step execution - the runner always launches steps as
# root - so the script switches to the jenkins user at the very
# start; the docs toolchain from scripts/requirements-doc.txt is
# installed for that user.

set -euo pipefail

# make the user the runner launched this step with visible in the log
echo "docs gate started as $(id -un)"

# sphinx lives in the jenkins user site directory which is not on
# PATH for non-login shells
export PATH="/home/jenkins/.local/bin:$PATH"

# switch to the jenkins user the CI image is built for, whatever user
# the step was launched with; root needs no sudo to switch users
if [ "$(id -un)" != "jenkins" ]; then
    exec runuser -u jenkins -- \
        env GATE_PR_CODE_DIR="${GATE_PR_CODE_DIR:-}" \
            ATOMGIT_HEAD_REF="${ATOMGIT_HEAD_REF:-}" "PATH=${PATH}" \
        bash "$0" "$@"
fi

# the checkout is owned by the root user that ran the runner step,
# while the build now runs as jenkins; without this git rejects the
# repository as dubious ownership
git config --global --add safe.directory '*' 2>/dev/null || true

# the code under test: the PR worktree prepared by checkout_pr.sh
# (created when the run carries PR context); fall back to this
# checkout for manual runs without PR context
REPO_DIR="${GATE_PR_CODE_DIR:-/tmp/gate-pr-code}"
if [ ! -e "${REPO_DIR}/.git" ]; then
    # a PR run must never silently fall back to the base checkout:
    # checkout_pr.sh creates the head worktree for every PR shape
    # (including head == base), so its absence here means something
    # upstream of the build broke
    if [ -n "${ATOMGIT_HEAD_REF:-}" ]; then
        echo "::error::PR context (head ${ATOMGIT_HEAD_REF}) but no PR worktree at ${REPO_DIR} -"
        echo "::error::refusing to build the base branch"
        exit 1
    fi
    REPO_DIR="$(git rev-parse --show-toplevel)"
fi

# build from a writable copy under /tmp to keep build output out of
# the checkout
DOCS_TMP="$(mktemp -d /tmp/docs-gate-XXXXXX)"
cp -r "${REPO_DIR}/docs" "${DOCS_TMP}/docs"

echo "Building documentation as $(id -un) ..."

# install the docs toolchain only when the image does not already
# carry it (the CI image pre-installs the pinned versions)
python3 -c 'import sphinx, sphinxcontrib.mermaid, myst_parser, \
sphinx_tabs, sphinx_multiversion' >/dev/null 2>&1 || \
    pip3 install -q -r "${REPO_DIR}/scripts/requirements-doc.txt" \
        -i https://pypi.tuna.tsinghua.edu.cn/simple

cd "${DOCS_TMP}/docs"
make html SPHINXOPTS="-W"
echo "Documentation build passed"

rm -rf "${DOCS_TMP}"
