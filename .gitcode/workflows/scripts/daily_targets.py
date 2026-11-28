#!/usr/bin/env python3
"""Query daily_targets.yaml for the daily build workflow and scripts.

The platform rejects strategy.matrix at workflow compile time, so the
workflow carries one static job per target and the selection happens
here instead:

  selected <name>  exit 0 when the target builds in this run, 10 when
                   it is disabled or filtered out by the dispatch
                   input, 2 on a configuration error
  list             print the targets this run builds, one per line
  check-workflow   fail when the config and the workflow's static build
                   jobs disagree (missing job, extra job, arch/sample
                   mismatch); run before every build

Selection = entries with enabled != false, optionally narrowed by the
GATE_DAILY_TARGETS comma-separated list (the workflow_dispatch
targets input).
"""

import os
import re
import sys

import yaml

# outside .gitcode/workflows/: the platform compiles every yaml in
# that directory as a workflow, which turns a plain config file into a
# failed PUSH run
CONFIG = ".gitcode/ci/daily_targets.yaml"
WORKFLOW = ".gitcode/workflows/daily_build.yml"
INVOKE = re.compile(r"daily_build\.sh\s+(\S+)\s+(\S+)\s+(\S+)")
SAMPLES = ".oebuild/samples"
NAME_CHARS = set("abcdefghijklmnopqrstuvwxyz"
                 "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.@")

EXIT_SKIP = 10
EXIT_ERROR = 2


def fail(message):
    print("::error::{}".format(message))
    sys.exit(EXIT_ERROR)


def load_targets():
    try:
        with open(CONFIG) as f:
            data = yaml.safe_load(f) or {}
    except OSError as exc:
        fail("cannot read {}: {}".format(CONFIG, exc))
    builds = data.get("builds")
    if not isinstance(builds, list) or not builds:
        fail("{} defines no builds".format(CONFIG))

    known = {}
    for entry in builds:
        if not isinstance(entry, dict):
            fail("target entry is not a mapping: {!r}".format(entry))
        name = str(entry.get("name", "")).strip()
        arch = str(entry.get("arch", "")).strip()
        sample = str(entry.get("sample", name)).strip()
        if not name or not arch or not sample:
            fail("target entry needs name, arch and sample: {!r}".format(entry))
        for field in (name, arch, sample):
            if not set(field) <= NAME_CHARS:
                fail("target entry has unexpected characters: {!r}".format(entry))
        if name in known:
            fail("duplicate target name: {}".format(name))
        known[name] = {
            "name": name,
            "arch": arch,
            "sample": sample,
            "enabled": entry.get("enabled", True) is not False,
        }
    return known


def wanted_names(known):
    wanted = [t.strip() for t in
              os.environ.get("GATE_DAILY_TARGETS", "").split(",") if t.strip()]
    unknown = [t for t in wanted if t not in known]
    if unknown:
        fail("unknown daily targets: {}".format(", ".join(unknown)))
    return wanted


def is_selected(entry, wanted):
    return entry["enabled"] and (not wanted or entry["name"] in wanted)


def sample_path(entry):
    return os.path.join(SAMPLES, entry["arch"], entry["sample"] + ".yaml")


def cmd_selected(known, name):
    if name not in known:
        fail("unknown daily target: {}".format(name))
    wanted = wanted_names(known)
    entry = known[name]

    if wanted and name not in wanted:
        print("{}: not selected by GATE_DAILY_TARGETS".format(name))
        sys.exit(EXIT_SKIP)
    if name in wanted and not entry["enabled"]:
        fail("daily target {} is disabled in {}".format(name, CONFIG))
    if not is_selected(entry, wanted):
        print("{}: disabled in {}".format(name, CONFIG))
        sys.exit(EXIT_SKIP)
    if not os.path.isfile(sample_path(entry)):
        fail("sample not found for {}: {}".format(name, sample_path(entry)))

    print("{}: selected (arch={}, sample={})".format(
        name, entry["arch"], entry["sample"]))


def cmd_list(known):
    wanted = wanted_names(known)
    selected = [e["name"] for e in known.values() if is_selected(e, wanted)]
    for name in selected:
        print(name)


def workflow_invocations():
    try:
        with open(WORKFLOW) as f:
            data = yaml.safe_load(f) or {}
    except OSError as exc:
        fail("cannot read {}: {}".format(WORKFLOW, exc))
    calls = {}
    for job in (data.get("jobs") or {}).values():
        for step in job.get("steps") or []:
            for line in (step.get("run") or "").splitlines():
                match = INVOKE.search(line)
                if match:
                    calls[match.group(1)] = {"arch": match.group(2),
                                             "sample": match.group(3)}
    return calls


def cmd_check_workflow(known):
    calls = workflow_invocations()
    problems = []
    for name, entry in known.items():
        call = calls.get(name)
        if call is None:
            problems.append(
                "{}: configured in {} but no job calls daily_build.sh"
                .format(name, CONFIG))
        elif (call["arch"], call["sample"]) != (entry["arch"], entry["sample"]):
            problems.append(
                "{}: config {}/{} but the job passes {}/{}".format(
                    name, entry["arch"], entry["sample"],
                    call["arch"], call["sample"]))
    for name in calls:
        if name not in known:
            problems.append(
                "{}: build job has no entry in {}".format(name, CONFIG))
    if problems:
        for problem in problems:
            print("::error::{}".format(problem))
        sys.exit(EXIT_ERROR)
    print("workflow matches {}: {} target(s)".format(CONFIG, len(known)))


def main():
    commands = ("selected", "list", "check-workflow")
    if len(sys.argv) < 2 or sys.argv[1] not in commands:
        fail("usage: daily_targets.py selected <name> | list | check-workflow")
    known = load_targets()
    if sys.argv[1] == "list":
        cmd_list(known)
    elif sys.argv[1] == "check-workflow":
        cmd_check_workflow(known)
    else:
        if len(sys.argv) != 3:
            fail("usage: daily_targets.py selected <name>")
        cmd_selected(known, sys.argv[2])


if __name__ == "__main__":
    main()