# python3-pbr Dependencies
PV = "0.40.0"

require pypi-src-openeuler.inc

# from version 0.40.0, compare the differences in upstream recipe
SRC_URI[sha256sum] = "3ef5fd1a211b34028d72fd3037692db8301dc2bc5e82646fded18cddf5af1ae9"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=7ffb0db04527cfe380e4f2726bd05ebf"

# remove 0.37.1 patch
SRC_URI:remove = "file://0001-Backport-pyproject.toml-from-flit-backend-branch.patch \
            file://0001-Fixed-potential-DoS-attack-via-WHEEL_INFO_RE.patch \
           "
