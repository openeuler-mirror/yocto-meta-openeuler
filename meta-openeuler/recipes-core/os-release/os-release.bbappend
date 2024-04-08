BUILDTIME = "${DATETIME}"
BUILDTIME[vardepsexclude] = "DATETIME"
do_install:append () {
    if [ "${BUILDTIME}" ]; then
        echo ${BUILDTIME} > ${D}${sysconfdir}/os-revision
        pushd ${OPENEULER_SP_DIR}/yocto-meta-openeuler
            openeuler_revision=$(git rev-parse HEAD)
            echo "yocto-meta-openeuler ${openeuler_revision}" >> ${D}${sysconfdir}/os-revision
        popd
    fi
}

FILES:${PN} += "${sysconfdir}/os-revision"
