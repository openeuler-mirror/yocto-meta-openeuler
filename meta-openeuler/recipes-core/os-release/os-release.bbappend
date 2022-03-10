BUILDTIME = "${DATETIME}"
BUILDTIME[vardepsexclude] = "DATETIME"
do_install_append () {
    if [ "${BUILDTIME}" ]; then
        echo ${BUILDTIME} > ${D}${sysconfdir}/os-revision
    fi
}
