DEPENDS += "c-utils"

OPENEULER_MULTI_REPOS += "commonlibrary_c_utils"

SRC_URI += " \
            file://commonlibrary_c_utils/c_utils.bundle.json \
            file://commonlibrary_c_utils/c_utils.BUILD.gn \
            "

do_patch:append() {
    bb.build.exec_func('do_prepare_c_utils_gn_directory', d)
}

do_prepare_c_utils_gn_directory() {
    mkdir -p ${S}/commonlibrary/c_utils/base/

    # copy bundle
    cp -rfp ${WORKDIR}/commonlibrary_c_utils/c_utils.bundle.json ${S}/commonlibrary/c_utils/bundle.json
    cp -rfp ${WORKDIR}/commonlibrary_c_utils/c_utils.BUILD.gn ${S}/commonlibrary/c_utils/base/BUILD.gn
}
