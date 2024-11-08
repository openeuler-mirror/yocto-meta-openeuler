# python3-pbr Dependencies
PV = "0.42.0"

require pypi-src-openeuler.inc
OPENEULER_LOCAL_NAME = "python-wheel"

# from version 0.40.0, compare the differences in upstream recipe
SRC_URI[sha256sum] = "000b0bb617ff3914f7a352687a7087ededd5b96a95e70e743c484904115a1021"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=7ffb0db04527cfe380e4f2726bd05ebf"

# remove 0.37.1 patch
SRC_URI:remove = "file://0001-Backport-pyproject.toml-from-flit-backend-branch.patch \
            file://0001-Fixed-potential-DoS-attack-via-WHEEL_INFO_RE.patch \
           "
