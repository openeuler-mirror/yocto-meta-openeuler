PV = "1.36.1"

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
            file://recognize_connmand.patch \
            "

# The following SP4 patches duplicate CVEs already applied by poky's busybox_1.36.1.bb:
#   backport-CVE-2022-48174.patch    -> poky: CVE-2022-48174.patch
#   backport-CVE-2023-42363.patch    -> poky: CVE-2023-42363.patch
#   backport-CVE-2023-42364-CVE-2023-42365.patch -> poky: CVE-2023-42363 area
#   backport-CVE-2023-42366.patch    -> poky: 0001-awk.c-fix-CVE-2023-42366-bug-15874.patch
#   backport-CVE-2023-39810.patch    -> poky: CVE-2023-39810.patch
#   backport-CVE-2025-46394.patch    -> poky: CVE-2025-46394-01.patch + CVE-2025-46394-02.patch
#   backport-CVE-2025-60876.patch    -> poky: CVE-2025-60876.patch
# Only add SP4-specific patches not already covered by poky
#we always want busybox with mdev\init packages to support multi init manager
SRC_URI:append = " \
        file://${BP}.tar.bz2 \
        file://busybox-1.36.1-kernel-6.8.patch \
        file://backport-CVE-2022-28391.patch \
        file://backport-CVE-2024-58251.patch \
        file://backport-CVE-2026-26157-CVE-2026-26158.patch \
        file://backport-tar-only-strip-unsafe-components-from-hardlinks-not-.patch \
        file://backport-0001-CVE-2026-29004.patch \
        file://backport-0002-CVE-2026-29004.patch \
        file://init.cfg \
        file://rcS.default \
        file://mdev.cfg \
        ${@bb.utils.contains('IMAGE_FEATURES', 'debug-tweaks', 'file://devmem.cfg', '', d)} \
        "
# support NFS, which depends on libtirpc
DEPENDS += "libtirpc"
DEPENDS:remove = "${@bb.utils.contains('TCLIBC', 'musl', 'libtirpc', '', d)}"
CFLAGS += "${@bb.utils.contains('DEPENDS', 'libtirpc', '-I${STAGING_INCDIR}/tirpc', '', d)}"
do_prepare_config:append () {
    set +e
    if ! ${@bb.utils.contains('DISTRO_FEATURES', 'mini-img', 'true', 'false', d)}; then
        grep -E '^CONFIG_FEATURE_MOUNT_NFS=y|^CONFIG_FEATURE_INETD_RPC=y' ${S}/.config
        ret=$?
        if [ $ret -eq 0 ]; then
            grep -E '^CONFIG_EXTRA_CFLAGS=".*-I/usr/include/tirpc|^CONFIG_EXTRA_LDLIBS=".*tirpc' ${S}/.config
            ret=$?
            if [ $ret -ne 0 ]; then
                sed -i 's/^CONFIG_EXTRA_LDLIBS="/CONFIG_EXTRA_LDLIBS="tirpc /g' ${S}/.config
            fi
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

SRC_URI[tarball.sha256sum] = "b8cc24c9574d809e7279c3be349795c5d5ceb6fdf19ca709f80cde50e47de314"

ASSUME_PROVIDE_PKGS = "which cpio vim-minimal diffutils systemd systemd-libs systemd-udev"
