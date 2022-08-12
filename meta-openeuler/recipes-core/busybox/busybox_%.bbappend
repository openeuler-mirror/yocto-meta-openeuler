PV = "1.34.1"

DL_DIR = "${OPENEULER_SP_DIR}/${BPN}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
            file://busybox-udhcpc-no_deconfig.patch \
            file://0001-testsuite-check-uudecode-before-using-it.patch \
            file://0001-gen_build_files-Use-C-locale-when-calling-sed-on-glo.patch \
            file://0001-awk-fix-CVEs.patch \
            file://0002-man-fix-segfault-in-man-1.patch \
            "

#we always want busybox with mdev\init packages to support multi init manager
SRC_URI_append = " \
        file://init.cfg \
        file://rcS.default \
        file://mdev.cfg \
        "
do_install_append () {
    if grep -q "CONFIG_INIT=y" ${B}/.config ; then
        install -D -m 0755 ${WORKDIR}/rcS ${D}${sysconfdir}/init.d/rcS
        install -D -m 0755 ${WORKDIR}/rcK ${D}${sysconfdir}/init.d/rcK
        install -D -m 0755 ${WORKDIR}/rcS.default ${D}${sysconfdir}/default/rcS
    fi
}

# files, patches that come from openeuler
SRC_URI += ""

SRC_URI[tarball.sha256sum] = "415fbd89e5344c96acf449d94a6f956dbed62e18e835fc83e064db33a34bd549"

