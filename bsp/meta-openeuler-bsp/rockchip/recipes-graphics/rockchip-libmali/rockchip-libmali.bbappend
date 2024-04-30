OPENEULER_REPO_NAME = "mali-common"
OPENEULER_MULTI_REPOS = "mali-${MALI_GPU}-${MALI_VERSION} mali-common"

python do_fetch() {
    bb.build.exec_func("do_openeuler_fetch_multi", d)
}

SRC_URI = " \
    file://mali-common \
    file://mali-${MALI_GPU}-${MALI_VERSION} \
"
S = "${WORKDIR}/mali-common"

do_unpack:append() {
    bb.build.exec_func('do_copy_elglib_source', d)
}

do_copy_elglib_source() {
    cp -r mali-${MALI_GPU}-${MALI_VERSION}/* mali-common/
}
