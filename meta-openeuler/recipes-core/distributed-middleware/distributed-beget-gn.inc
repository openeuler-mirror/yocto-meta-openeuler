DEPENDS += "distributed-beget"

OPENEULER_MULTI_REPOS += "distributed-beget"

SRC_URI += " \
            file://distributed-beget/startup.bundle.json \
            file://distributed-beget/startup.BUILD.gn \
            "

do_patch:append() {
    bb.build.exec_func('do_prepare_beget_gn_directory', d)
}

do_prepare_beget_gn_directory() {
    mkdir -p ${S}/base/startup/init/interfaces/innerkits/

    # copy bundle
    cp -rfp ${WORKDIR}/distributed-beget/startup.bundle.json ${S}/base/startup/init/bundle.json
    cp -rfp ${WORKDIR}/distributed-beget/startup.BUILD.gn ${S}/base/startup/init/interfaces/innerkits/BUILD.gn
}
