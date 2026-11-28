#!/bin/bash
# Summarize one daily build run and open one issue per day when
# something failed. All green runs post nothing.
#
# The expected target list comes from daily_targets.yaml (same filter
# as the build jobs), so the report does not depend on job outputs:
# the platform rejects strategy.matrix and job outputs are not proven.
# A selected target without a status file counts as failed.
#
# Stub: the issue endpoint and the runner token's permissions are
# still being verified on the test repository. A failed POST only
# warns; it never turns the report job red - the build jobs already
# carry the failure. TODOs mark the dedupe/auto-close work.
#
# Inputs (env):
#   GATE_SHARE_DIR      shared cache root; status files live under
#                       ${GATE_SHARE_DIR}/daily/<run_id>/
#   GATE_RUN_ID         run id, used for the status dir and issue body
#   GATE_BUILD_RESULTS  comma-separated needs.<build job>.result values
#                       (used as the aggregate hint; any failure or
#                       cancellation marks the run failed)
#   GATE_DAILY_TARGETS  dispatch input narrowing the target list
#   GATE_DAILY_ISSUE    "0" disables issue creation (default 1)
#   GATE_DAILY_ISSUE_REPO  repo to open the issue in, defaults to the
#                       repository the run belongs to
#   ATOMGIT_REPOSITORY, ATOMGIT_REPOSITORYURL, ATOMGIT_API_URL,
#   ATOMGIT_TOKEN       set by the runner

set -u

RUN_REPO="${ATOMGIT_REPOSITORY:-}"
REPO="${GATE_DAILY_ISSUE_REPO:-${RUN_REPO}}"
# the runner exports ATOMGIT_RUN_ID; the workflow env mapping of
# atomgit.run_id does not resolve, which left the run link empty
RUN_ID="${ATOMGIT_RUN_ID:-${GATE_RUN_ID:-unknown}}"
echo "daily report: repo=${REPO:-<none>} run=${RUN_ID}"
BUILD_RESULT="${GATE_BUILD_RESULT:-unknown}"
if [ "${BUILD_RESULT}" = "unknown" ] && [ -n "${GATE_BUILD_RESULTS:-}" ]; then
    case ",${GATE_BUILD_RESULTS}," in
        *",failure"*|*",cancelled"*) BUILD_RESULT=failure ;;
        *) BUILD_RESULT=success ;;
    esac
fi
DATE="$(TZ=Asia/Shanghai date +%F)"
STATUS_DIR="${GATE_SHARE_DIR:-}/daily/${RUN_ID}"
SUMMARY="$(mktemp)"

python3 -c 'import yaml' >/dev/null 2>&1 \
    || pip3 install -q pyyaml -i https://pypi.tuna.tsinghua.edu.cn/simple \
       >/dev/null 2>&1 || true

EXPECTED=""
EXPECTED_ERR="$(mktemp)"
if python3 .gitcode/workflows/scripts/daily_targets.py list \
        >"${EXPECTED_ERR}" 2>&1; then
    EXPECTED="$(tr '\n' ',' <"${EXPECTED_ERR}")"
else
    echo "::warning::cannot resolve the expected targets: $(cat "${EXPECTED_ERR}")"
    EXPECTED=""
fi
rm -f "${EXPECTED_ERR}"

python3 - "${STATUS_DIR}" "${RUN_ID}" "${RUN_REPO}" "${DATE}" \
    "${BUILD_RESULT}" "${EXPECTED}" >"${SUMMARY}" << 'PYEOF'
import glob
import json
import os
import sys

status_dir, run_id, run_repo, date, build_result, expected_arg = sys.argv[1:7]

rows = []
for path in sorted(glob.glob(os.path.join(status_dir, "*.json"))):
    try:
        with open(path) as f:
            rows.append(json.load(f))
    except (OSError, ValueError) as exc:
        print("::warning::ignoring unreadable status file {}: {}".format(path, exc))

expected = [n for n in expected_arg.split(",") if n]
by_name = {row.get("name"): row for row in rows}

if expected:
    # a selected target whose pod died before writing its status file
    # is a failure: without this a timed-out job would vanish from the
    # report
    report_rows = []
    for name in expected:
        row = by_name.get(name)
        if row is None or row.get("result") == "skip":
            report_rows.append({"name": name, "arch": "?", "result": "fail",
                                "seconds": "?"})
        else:
            report_rows.append(row)
else:
    # config unavailable: report what the jobs wrote, skip entries
    # neither pass nor fail
    report_rows = [r for r in rows if r.get("result") != "skip"]

total = len(report_rows)
failed = [r for r in report_rows if r.get("result") != "pass"]
unknown = not report_rows and build_result not in ("success", "skipped")

url = ""
if run_repo and run_id not in ("", "unknown"):
    url = "https://atomgit.com/{}/actions/runs/{}".format(run_repo, run_id)

lines = []
lines.append("## Daily build {}".format(date))
lines.append("")
lines.append("| Target | Status | Build |")
lines.append("| --- | --- | --- |")
if report_rows:
    for row in report_rows:
        link = "[run]({})".format(url) if url else "-"
        lines.append("| {} | {} | {} |".format(
            row.get("name", "?"), row.get("result", "?"), link))
else:
    link = "[run]({})".format(url) if url else "-"
    lines.append("| - | unknown ({}) | {} |".format(build_result, link))

print("\n".join(lines))
print("failed={}".format(len(failed)))
print("unknown={}".format(1 if unknown else 0))
print("total={}".format(total))
PYEOF

cat "${SUMMARY}"
echo

failed=$(awk -F= '/^failed=/{print $2}' "${SUMMARY}")
unknown=$(awk -F= '/^unknown=/{print $2}' "${SUMMARY}")
total=$(awk -F= '/^total=/{print $2}' "${SUMMARY}")

if [ -n "${ATOMGIT_STEP_SUMMARY:-}" ]; then
    sed '/^failed=/d;/^unknown=/d;/^total=/d' "${SUMMARY}" >>"${ATOMGIT_STEP_SUMMARY}"
fi

if [ "${failed:-0}" -eq 0 ] && [ "${unknown:-0}" -eq 0 ]; then
    echo "daily report: all ${total:-0} target(s) passed; no issue created"
    rm -f "${SUMMARY}"
    exit 0
fi

# the dispatch input is the string "true"/"false"; unset (scheduled
# runs) keeps issue creation enabled
daily_issue=1
case "${GATE_DAILY_ISSUE:-1}" in
    0|false|False|FALSE|no|No|off|Off) daily_issue=0 ;;
esac
if [ "${daily_issue}" -eq 0 ]; then
    echo "daily report: failure detected but GATE_DAILY_ISSUE=${GATE_DAILY_ISSUE}; not creating an issue"
    rm -f "${SUMMARY}"
    exit 0
fi

if [ -z "${REPO}" ]; then
    echo "::warning::no repository in context; cannot open the daily issue"
    rm -f "${SUMMARY}"
    exit 0
fi

title="每日构建失败：${DATE}（${failed:-?}/${total:-?} 个目标失败）"
if [ "${unknown:-0}" -eq 1 ]; then
    title="每日构建失败：${DATE}（构建结果 ${BUILD_RESULT}）"
fi
echo "daily report: opening issue: ${title}"
body="$(sed '/^failed=/d;/^unknown=/d;/^total=/d' "${SUMMARY}")"

# TODO: search open issues titled "${title}" first and comment instead
# of opening a duplicate when the same day reruns.
python3 - "${REPO}" "${title}" "${body}" << 'PYEOF'
import json
import os
import sys
import urllib.error
import urllib.request

repo, title, body = sys.argv[1:4]
token = os.environ.get("ATOMGIT_TOKEN", "")

base = os.environ.get("ATOMGIT_API_URL", "").rstrip("/")
if not base.startswith("http"):
    repo_url = os.environ.get("ATOMGIT_REPOSITORYURL", "")
    base = "/".join(repo_url.split("/")[:3]) if repo_url.startswith("http") else "https://atomgit.com"

data = json.dumps({"title": title, "body": body}).encode()
req = urllib.request.Request(base + "/api/v5/repos/{}/issues".format(repo),
                             data=data, method="POST")
req.add_header("Content-Type", "application/json")
if token:
    req.add_header("Authorization", "Bearer {}".format(token))
try:
    with urllib.request.urlopen(req, timeout=20) as resp:
        reply = json.load(resp)
    print("daily report: issue created: #{} {}".format(
        reply.get("number", "?"), reply.get("html_url", "")))
except urllib.error.HTTPError as exc:
    print("::warning::issue creation failed: HTTP {} {}".format(
        exc.code, exc.read(200).decode("utf-8", "replace")))
except Exception as exc:
    print("::warning::issue creation failed: {}".format(exc))
PYEOF

rm -f "${SUMMARY}"
exit 0