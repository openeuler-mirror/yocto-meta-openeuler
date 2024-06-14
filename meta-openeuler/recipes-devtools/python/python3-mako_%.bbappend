require pypi-src-openeuler.inc

OPENEULER_REPO_NAME = "python-mako"

PV = "1.1.4"

# openeuler patches
SRC_URI += "file://CVE-2022-40023.patch;patchdir=${S}/mako"

