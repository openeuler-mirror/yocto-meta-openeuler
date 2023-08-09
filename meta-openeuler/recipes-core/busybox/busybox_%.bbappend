PV = "1.34.1"

# use openEuler defconfig
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
            file://0001-depmod-Ignore-.debug-directories.patch \
            file://longopts.cfg \
            file://0001-libbb-sockaddr2str-ensure-only-printable-characters-.patch \
            file://0002-nslookup-sanitize-all-printed-strings-with-printable.patch \
            file://CVE-2022-30065.patch \
            file://0001-devmem-add-128-bit-width.patch \
            file://busybox-udhcpc-no_deconfig.patch \
            file://0001-testsuite-check-uudecode-before-using-it.patch \
            file://0001-gen_build_files-Use-C-locale-when-calling-sed-on-glo.patch \
            file://0001-awk-fix-CVEs.patch \
            file://0002-man-fix-segfault-in-man-1.patch \
            file://fail_on_no_media.patch \
            "

#we always want busybox with mdev\init packages to support multi init manager
SRC_URI:append = " \
        file://backport-CVE-2022-28391.patch \
        file://backport-CVE-2022-30065.patch \
        file://backport-fix-use-after-free-in-bc-module.patch \
        file://backport-generalize-const-trick.patch \
        file://init.cfg \
        file://rcS.default \
        file://mdev.cfg \
        "

# support NFS, which depends on libtirpc
DEPENDS += "libtirpc"
CFLAGS += "${@bb.utils.contains('DEPENDS', 'libtirpc', '-I${STAGING_INCDIR}/tirpc', '', d)}"

do_prepare_config:append () {
    set +e
    grep -E '^CONFIG_FEATURE_MOUNT_NFS=y|^CONFIG_FEATURE_INETD_RPC=y' ${S}/.config
    ret=$?
    if [ $ret -eq 0 ]; then
        grep -E '^CONFIG_EXTRA_CFLAGS=".*-I/usr/include/tirpc|^CONFIG_EXTRA_LDLIBS=".*tirpc' ${S}/.config
        ret=$?
        if [ $ret -ne 0 ]; then
            sed -i 's/^CONFIG_EXTRA_LDLIBS="/CONFIG_EXTRA_LDLIBS="tirpc /g' ${S}/.config
        fi
    fi
    set -e
}

do_install:append () {
    if grep -q "CONFIG_INIT=y" ${B}/.config ; then
        install -D -m 0755 ${WORKDIR}/rcS ${D}${sysconfdir}/init.d/rcS
        install -D -m 0755 ${WORKDIR}/rcK ${D}${sysconfdir}/init.d/rcK
        install -D -m 0755 ${WORKDIR}/rcS.default ${D}${sysconfdir}/default/rcS
    fi
}

SRC_URI[tarball.sha256sum] = "415fbd89e5344c96acf449d94a6f956dbed62e18e835fc83e064db33a34bd549"
