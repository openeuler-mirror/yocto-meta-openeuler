PV = "3.0.3"
SRC_URI[sha256sum] = "611bb273cd68f3b993fabdc4064fc858c5b47a973cb5aa7999ec1ba405c87cd7"

# apply patch from openEuler
SRC_URI += " \
        file://backport-CVE-2024-22195.patch;patchdir=.. \
        file://backport-CVE-2024-34064.patch;patchdir=.. \
"

require pypi-src-openeuler.inc
OPENEULER_REPO_NAME = "python-jinja2"
