#!/bin/bash
# Build a yocto image for the GitCode Actions PR gate.
#
# Usage: build_image.sh <arch> <image_name>
#   arch:       aarch64 / arm32 / x86-64 / riscv64
#   image_name: qemu-aarch64 / qemu-arm32 / x86-64 / hieulerpi1 /
#               qemu-riscv64 / phytium
#
# Mirrors the Jenkins gate's buildTask/dynamicBuild: the oebuild
# workspace under the shareDir is used in place - it already holds the
# repos, downloads and sstate-cache on the runner disk - and every
# build only re-points src/yocto-meta-openeuler at the PR checkout and
# uses its own build directory, which is removed afterwards. oebuild
# init is a no-op on an already initialized workspace. No copying or
# rsyncing is involved.

set -euo pipefail

# make the user the runner launched this step with visible in the log
echo "image gate started as $(id -un)"

# oebuild lives in the jenkins user site directory which is not on
# PATH for non-login shells
export PATH="/home/jenkins/.local/bin:$PATH"

# switch to the jenkins user the CI image is built for, whatever user
# the step was launched with; root needs no sudo to switch users
if [ "$(id -un)" != "jenkins" ]; then
    exec runuser -u jenkins -- \
        env GATE_RUN_ID="${GATE_RUN_ID:-}" \
            GATE_SHARE_DIR="${GATE_SHARE_DIR:-}" \
            GATE_TARGET_BRANCH="${GATE_TARGET_BRANCH:-}" \
            ATOMGIT_BASE_REF="${ATOMGIT_BASE_REF:-}" \
            "PATH=${PATH}" \
        bash "$0" "$@"
fi

ARCH="$1"
IMAGE_NAME="$2"

# the checkout is owned by the root user that ran the runner step,
# while the build now runs as jenkins; without this git rejects the
# repository as dubious ownership
git config --global --add safe.directory '*' 2>/dev/null || true
# cache key branch: the PR target branch the runner reports
# (verified set on PR and comment events); GATE_TARGET_BRANCH can
# override it, and master is the last resort for manual runs
TARGET_BRANCH="${GATE_TARGET_BRANCH:-${ATOMGIT_BASE_REF:-master}}"
# the code under test: the PR worktree prepared by checkout_pr.sh
# (created when the run carries PR context); fall back to this
# checkout for manual runs without PR context
REPO_DIR="${GATE_PR_CODE_DIR:-/tmp/gate-pr-code}"
if [ ! -e "${REPO_DIR}/.git" ]; then
    REPO_DIR="$(git rev-parse --show-toplevel)"
fi
SAMPLE_YAML="${REPO_DIR}/.oebuild/samples/${ARCH}/${IMAGE_NAME}.yaml"
RUN_ID="${GATE_RUN_ID:-$$}"
BUILD_YAML="/tmp/oebuild-gate-${IMAGE_NAME}-${RUN_ID}.yaml"
BUILD_LOG="/tmp/oebuild-gate-${IMAGE_NAME}-${RUN_ID}.log"
BUILD_NAME="oebuild-gate-${IMAGE_NAME}-${RUN_ID}"

# shared per-branch source cache, exactly the Jenkins gate's
# cacheSrcDir; the compile yaml carries it so oebuild rsyncs the layer
# repos from the cache instead of cloning them. Warn loudly when the
# cache is not present (runner without the provisioning): the build
# still works, oebuild falls back to network clones, just slower.
CACHE_SRC_DIR="${GATE_SHARE_DIR:+${GATE_SHARE_DIR}/${TARGET_BRANCH}/oebuild_workspace/src}"
if [ -n "${CACHE_SRC_DIR}" ] && [ ! -d "${CACHE_SRC_DIR}" ]; then
    echo "::warning::shared cache ${CACHE_SRC_DIR} not present;" \
         "building without the cache (network clones, slower)"
fi

# the workspace itself is ephemeral for this run
WORK_DIR="/tmp/${BUILD_NAME}"
BUILD_OUT="${WORK_DIR}/build/${BUILD_NAME}"

if [ ! -f "${SAMPLE_YAML}" ]; then
    echo "::error::Sample YAML not found: ${SAMPLE_YAML}"
    exit 1
fi

echo "Building ${IMAGE_NAME} (arch=${ARCH}) as $(id -un)"
echo "Sample: ${SAMPLE_YAML}"
echo "Repo: ${REPO_DIR}"
echo "Workspace: ${WORK_DIR}"

# Step 1: generate compile.yaml from the sample, mirroring the Jenkins
# gate's translateCompileToHost: build in host mode, pass the shared
# cache as cache_src_dir, pin DATETIME, inherit rm_work and drop
# do_populate_sdk
pip3 install -q pyyaml || true
python3 - "${SAMPLE_YAML}" "${BUILD_YAML}" "${CACHE_SRC_DIR}" << 'PYEOF'
import sys
import yaml

src, dst, cache = sys.argv[1], sys.argv[2], sys.argv[3]

with open(src, 'r') as f:
    data = yaml.safe_load(f)

data['build_in'] = 'host'
if cache:
    data['cache_src_dir'] = cache
data['local_conf'] = (data.get('local_conf') or '') + \
    '\nDATETIME = "20260101000000"\nINHERIT += "rm_work"\n'

if data.get('bitbake_cmds'):
    data['bitbake_cmds'] = [cmd for cmd in data['bitbake_cmds']
                           if 'do_populate_sdk' not in cmd]

with open(dst, 'w') as f:
    yaml.safe_dump(data, f, default_flow_style=False)

print(f"Generated compile YAML: {dst}")
print(f"  build_in: {data['build_in']}")
print(f"  cache_src_dir: {data.get('cache_src_dir', '(none)')}")
print(f"  bitbake_cmds: {data.get('bitbake_cmds', 'default')}")
PYEOF

# Step 2: initialize the ephemeral workspace
echo "Preparing oebuild workspace: ${WORK_DIR}"
rm -rf "${WORK_DIR}"
oebuild init "${WORK_DIR}"

# oebuild reports some errors without a non-zero exit code (its root
# check just logs and returns), so verify the workspace was really
# created before continuing
if [ ! -d "${WORK_DIR}/src" ]; then
    echo "::error::oebuild init failed: ${WORK_DIR}/src was not created"
    exit 1
fi

# Step 3: re-set src - point the workspace at this PR's checkout and
# make sure the build directory exists; assert the link afterwards:
# oebuild init leaves src/ empty today, but if it (or any future
# step) ever created a real directory at the target, ln would nest
# the link inside it and the build would silently test upstream code
ln -sfn "${REPO_DIR}" "${WORK_DIR}/src/yocto-meta-openeuler"
if [ "$(readlink "${WORK_DIR}/src/yocto-meta-openeuler" 2>/dev/null || true)" != "${REPO_DIR}" ]; then
    echo "::error::src/yocto-meta-openeuler does not point at ${REPO_DIR}; refusing to build"
    exit 1
fi
mkdir -p "${WORK_DIR}/build"
cd "${WORK_DIR}"

# Step 4: run the build, streaming output live
echo "Starting build of ${IMAGE_NAME} ..."
set +e
oebuild "${BUILD_YAML}" 2>&1 | tee "${BUILD_LOG}"
BUILD_RC=${PIPESTATUS[0]}
set -e

# oebuild returns 0 even on some early errors (its root check just
# logs and returns), so the exit code alone cannot be trusted: require
# all three of exit code, clean log and deployed artifacts
fail=0
if [ "${BUILD_RC}" -ne 0 ]; then
    echo "::error::oebuild exited with code ${BUILD_RC}"
    fail=1
fi
if grep -q "ERROR" "${BUILD_LOG}" 2>/dev/null; then
    echo "::error::build log contains ERROR lines"
    fail=1
fi
# -print -quit avoids the find|grep -q SIGPIPE race under pipefail
# (grep exiting early could kill find with 141 and false-fail a build
# that actually produced images)
deployed=$(find "${BUILD_OUT}/tmp/deploy/images" -type f -print -quit 2>/dev/null || true)
if [ -z "${deployed}" ]; then
    echo "::error::no deployed images under ${BUILD_OUT}/tmp/deploy/images"
    fail=1
fi

if [ "${fail}" -ne 0 ]; then
    echo "::error::${IMAGE_NAME} build FAILED"
    echo "===== last 80 lines of the build log ====="
    tail -80 "${BUILD_LOG}" 2>/dev/null || true
    echo "========================================="
    rm -rf "${WORK_DIR}" "${BUILD_YAML}" "${BUILD_LOG}"
    exit 1
fi

# cleanup: drop the ephemeral workspace; the shared cache is untouched
echo "${IMAGE_NAME} build PASSED"
rm -rf "${WORK_DIR}" "${BUILD_YAML}" "${BUILD_LOG}"
echo "${IMAGE_NAME} gate check complete"
