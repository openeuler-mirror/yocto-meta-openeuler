# main bbfile: yocto-poky/meta/recipes-kernel/kexec/kexec-tools_2.0.21.bb
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"
# kexec-tools version in openEuler
PV = "2.0.26"

# Use the source packages from openEuler and remove conflicting patches
SRC_URI:remove = " \
                  file://0001-arm64-kexec-disabled-check-if-kaslr-seed-dtb-propert.patch \
                  "
SRC_URI:prepend = "file://${BP}.tar.xz "

SRC_URI += "file://kexec-Add-quick-kexec-support.patch \
            file://kexec-Quick-kexec-implementation-for-arm64.patch \
            "

SRC_URI[md5sum] = "ce3c79e0f639035ef7ddfc39b286a61a"
SRC_URI[sha256sum] = "7fe36a064101cd5c515e41b2be393dce3ca88adce59d6ee668e0af7c0c4570cd"

RDEPENDS:${PN} += "makedumpfile"

# According to the kdump.sysconfig provided by openeuler, add additional kdump commandline
KDUMP_CMD:aarch64 = "irqpoll nr_cpus=1 reset_devices cgroup_disable=memory udev.children-max=2 panic=10 swiotlb=noforce novmcoredd numa=off"
KDUMP_CMD:x86-64 = "irqpoll nr_cpus=1 reset_devices cgroup_disable=memory mce=off numa=off udev.children-max=2 panic=10 acpi_no_memhotplug transparent_hugepage=never nokaslr hest_disable novmcoredd"

# don't install kexec_test
do_install:append () {
    if [ -e ${D}${libdir} ]; then
        rm -r ${D}${libdir}
    fi

    sed -i -e 's,@KDUMP_COMMANDLINE@,${KDUMP_CMD},g' \
        ${D}${sysconfdir}/sysconfig/kdump.conf
}
