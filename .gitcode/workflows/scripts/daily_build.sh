#!/bin/bash
# Build one daily target, gated by daily_targets.yaml and the dispatch
# input, and record the outcome for the report job.
#
# Usage: daily_build.sh <name> <arch> <sample>
#
# Selection lives in daily_targets.py because the platform rejects
# strategy.matrix: the workflow carries a static job per target and
# every job runs this script, which exits 0 without building when the
# target is disabled or filtered out by inputs.targets.
#
# build_image.sh does the actual build (host mode, shared cache, thread
# cap, pinned DATETIME, rm_work, no SDK). This wrapper only times it
# and drops a status file into the shared cache, which every runner
# node mounts, so the report job can summarize the run without
# artifacts or job outputs.

set -u

NAME="$1"
ARCH="$2"
SAMPLE="$3"

# the runner exports ATOMGIT_RUN_ID; GATE_RUN_ID from the workflow env
# does not resolve atomgit.run_id on this platform
RUN_ID="${ATOMGIT_RUN_ID:-${GATE_RUN_ID:-unknown}}"
STATUS_DIR="${GATE_SHARE_DIR:-}/daily/${RUN_ID}"
if [ -n "${GATE_SHARE_DIR:-}" ]; then
    mkdir -p "${STATUS_DIR}" 2>/dev/null || true
fi

write_status() {
    if [ -n "${GATE_SHARE_DIR:-}" ] && [ -d "${STATUS_DIR}" ]; then
        printf '{"name":"%s","arch":"%s","sample":"%s","result":"%s","seconds":%s}\n' \
            "${NAME}" "${ARCH}" "${SAMPLE}" "$1" "${2:-0}" \
            >"${STATUS_DIR}/${NAME}.json"
    fi
}

set +e
python3 .gitcode/workflows/scripts/daily_targets.py selected "${NAME}"
selected_rc=$?

# no set -e here: a failing build must still reach write_status below,
# otherwise the report cannot tell a failed target from a killed pod
case "${selected_rc}" in
    0) ;;
    10)
        echo "daily build ${NAME}: skipped by target selection"
        write_status skip 0
        exit 0
        ;;
    *)
        echo "::error::daily build ${NAME}: target selection failed"
        write_status fail 0
        exit "${selected_rc}"
        ;;
esac

echo "daily build ${NAME} (arch=${ARCH}, sample=${SAMPLE}) starting at $(date -u +%FT%TZ)"
start=$(date +%s)
bash .gitcode/workflows/scripts/build_image.sh "${ARCH}" "${SAMPLE}"
rc=$?
end=$(date +%s)

if [ "${rc}" -eq 0 ]; then
    result=pass
else
    result=fail
fi
write_status "${result}" "$((end - start))"

echo "daily build ${NAME} finished with rc=${rc} after $((end - start))s"
exit "${rc}"