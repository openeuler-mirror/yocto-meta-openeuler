# python3-pbr Dependencies
PV = "0.40.0"

require pypi-src-openeuler.inc
OPENEULER_REPO_NAME = "python-wheel"

# from version 0.40.0, compare the differences in upstream recipe
SRC_URI[sha256sum] = "cd1196f3faee2b31968d626e1731c94f99cbdb67cf5a46e4f5656cbee7738873"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=7ffb0db04527cfe380e4f2726bd05ebf"

# remove 0.37.1 patch
SRC_URI:remove = "file://0001-Backport-pyproject.toml-from-flit-backend-branch.patch \
            file://0001-Fixed-potential-DoS-attack-via-WHEEL_INFO_RE.patch \
           "
