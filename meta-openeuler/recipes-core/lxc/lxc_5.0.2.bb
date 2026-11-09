SUMMARY = "lxc aims to use these new functionalities to provide an userspace container object"
DESCRIPTION = "lxc is a well-known Linux container runtime that consists of tools, templates, \
            and library and language bindings. It's pretty low level, very flexible and covers \
            just about every containment feature supported by the upstream kernel"
SECTION = "console/utils"
LICENSE = "LGPL-2.1-only & GPL-2.0-only"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = " \
        file://${BP}.tar.gz \
        file://0001-iSulad-add-json-files-and-adapt-to-meson.patch \
        file://0002-iSulad-adapt-security-conf-attach-cgroup-and-start.patch \
        file://0003-iSulad-adapt-conf-network-storage-and-termianl.patch \
        file://0004-iSulad-adapt-confile-lxccontainer-and-start.patch \
        file://0005-fix-compile-error.patch \
        file://0006-remove-isulad_cgfsng.patch \
        file://0007-fix-run-container-failed-when-enable-isulad.patch \
        file://0008-bugfix-for-system-container-and-stream.patch \
        file://0009-bugfix-about-cgroup-mount-propagation-and-capabiliti.patch \
        file://0010-add-storage-block-code-for-embedded-image.patch \
        file://0011-skip-setup-console-if-disable-pty-and-fix-syscontain.patch \
        file://0012-fix-dev-mount-failed-and-skip-send-recv-devpts_fd-if.patch \
        file://0013-ensure-cpuset-cgroup-built-while-writing-cgroup.proc.patch \
        file://0014-fix-cpuset-cgroup-error.patch \
        file://0015-append-mntopt-to-mntdata-if-not-found-in-mount_opt.patch \
        file://0016-unfreeze-freezing-container-and-bugfix-for-files.lim.patch \
        file://0017-fix-error-of-cc.compiles-on-aarch.patch \
        file://0018-add-fPIC-compile-option.patch \
        file://0019-Ensure-do_lxcapi_unfreeze-returns-false-when-getstat.patch \
        file://0020-CVE-2026-39402-lxc-user-nic-clarify-and-fix.patch \
"

DEPENDS = " \
        yajl libseccomp libcap \
        libselinux \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)} \
"

# meson build options (mirroring the src repo spec %build)
EXTRA_OEMESON = " \
        -Disulad=true \
        -Dman=false \
"

FILES:${PN} += " \
        /usr/share \
        /lib/systemd/system \
"

RDEPENDS:${PN} += "bash"

inherit meson pkgconfig

BBCLASSEXTEND = "native nativesdk"

CFLAGS:append = " -Wno-error=stringop-overflow -Wno-error=strict-prototypes -Wno-error=old-style-definition -Wno-error=address  -Wno-error=uninitialized "
