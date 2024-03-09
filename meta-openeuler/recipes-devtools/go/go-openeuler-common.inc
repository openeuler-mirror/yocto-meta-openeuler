# Currently, version 1.21.4 is on src-OpenEuler/master branch. 
# There are conflicts between upstream community Yocto provided cross compilation patches, 
# so we use the latest version from upstream go stored at oee_archive. 
# If there are updates later on src-openEuler, this part can be optimized
OPENEULER_LOCAL_NAME = "oee_archive"
OEE_ARCHIVE_SUBDIR = "go"

PV = "1.22.0"

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/go/go${PV}.src.tar.gz;name=main \
"

do_compile:prepend() {
    pushd ${S}
    # fix using sh for some env bash not support -x cmd
    sed -i 's@^#!\/usr\/bin\/env bash@\#!/usr/bin/env sh@' src/make.bash
    popd
}
