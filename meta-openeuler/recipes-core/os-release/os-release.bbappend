do_install_append () {
    if [ "${DATETIME}" ]; then
        echo ${DATETIME} > ${D}${sysconfdir}/os-revision
    fi
}
