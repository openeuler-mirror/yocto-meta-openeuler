PV = "3.0.8"
require pypi-src-openeuler.inc
OPENEULER_REPO_NAME = "Cython"

LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=61c3ee8961575861fa86c7e62bc9f69c"

# From python3-cython_3.0.8.bb
do_install:append() {
        # remove build paths from generated sources
        sed -i -e 's|${WORKDIR}||' ${S}/Cython/*.c ${S}/Cython/Compiler/*.c ${S}/Cython/Plex/*.c
}
