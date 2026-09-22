PV = "1.36.1"

# use openEuler defconfig
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# The base recipe is poky busybox_1.35.0.bb; PV is overridden to openEuler's
# 1.36.1 above. Most poky patches below are obsolete or unwanted against the
# 1.36.1 source, so they are dropped via SRC_URI:remove. Each entry falls into
# one of three buckets (none is a textual clash with an openEuler patch: openEuler
# only backports 3 CVEs, applied via SRC_URI:append further down):
#   (1) already in the 1.36.1 baseline / upstream -- CVE-2022-30065 and its two
#       follow-ups (sockaddr2str / nslookup printable-char sanitize) plus the
#       uudecode testsuite check; keeping them would fail to apply or double-fix.
#   (2) poky / distro-specific policy Embedded does not want: depmod-debug,
#       devmem-128bit (devmem is instead gated by files/devmem.cfg),
#       udhcpc-no_deconfig, fail_on_no_media, recognize_connmand.
#   (3) config fragment longopts.cfg, superseded by the openEuler defconfig.
SRC_URI:remove = " \
            file://0001-depmod-Ignore-.debug-directories.patch \
            file://longopts.cfg \
            file://0001-libbb-sockaddr2str-ensure-only-printable-characters-.patch \
            file://0002-nslookup-sanitize-all-printed-strings-with-printable.patch \
            file://CVE-2022-30065.patch \
            file://0001-devmem-add-128-bit-width.patch \
            file://busybox-udhcpc-no_deconfig.patch \
            file://0001-testsuite-check-uudecode-before-using-it.patch \
            file://fail_on_no_media.patch \
            file://recognize_connmand.patch \
            "

#we always want busybox with mdev\init packages to support multi init manager
SRC_URI:append = " \
        file://${BP}.tar.bz2 \
        file://backport-CVE-2022-28391.patch \
        file://backport-CVE-2022-48174.patch \
        file://backport-CVE-2023-42363.patch \
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
    if ! ${@bb.utils.contains('DISTRO_FEATURES', 'mini-img', 'true', 'false', d)} && \
       ! ${@bb.utils.contains('TCLIBC', 'musl', 'true', 'false', d)}; then
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
