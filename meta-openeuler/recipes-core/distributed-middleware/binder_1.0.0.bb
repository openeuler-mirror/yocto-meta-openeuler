SUMMARY = "Inter-process communication (IPC) and Remote Procedure Call (RPC)"
DESCRIPTION = "The inter-process communication (IPC) and remote procedure call (RPC) mechanisms are used to implement cross-process communication"
PR = "r1"
LICENSE = "CLOSED"

inherit module

pkg-binder = "binder-openEuler-22.03-LTS-SP2"

OPENEULER_REPO_NAME = "communication_ipc_kernel510"

SRC_URI = " \
            file://${pkg-binder}.tar.gz \
            file://0003-adapt-binder-as-a-kernel-module.patch \
            file://communication_ipc_kernel510/binder.pp \
          "

SRC_URI:append = " \
        file://0004-feat-for-embedded-fix-binder-kallsyms-init-error.patch \
"

RPROVIDES:${PN} += "kernel-module-binder-linux"

FILES:${PN} = "/usr/share/"

S = "${WORKDIR}/binder"

do_install() {
    install -d ${D}/lib/modules/5.10.0-openeuler/binder/
    install -m 644 ${S}/binder_linux.ko ${D}/lib/modules/5.10.0-openeuler/binder/

    install -d ${D}/usr/share/pp/
    install -m 755 ${WORKDIR}/communication_ipc_kernel510/binder.pp ${D}/usr/share/pp/

    if [ ! -e "${B}/${MODULES_MODULE_SYMVERS_LOCATION}/Module.symvers" ] ; then
        bbwarn "Module.symvers not found in ${B}/${MODULES_MODULE_SYMVERS_LOCATION}"
        bbwarn "Please consider setting MODULES_MODULE_SYMVERS_LOCATION to a"
        bbwarn "directory below B to get correct inter-module dependencies"
    else
        install -Dm0644 "${B}/${MODULES_MODULE_SYMVERS_LOCATION}"/Module.symvers ${D}${includedir}/${BPN}/Module.symvers
        # Module.symvers contains absolute path to the build directory.
        # While it doesn't actually seem to matter which path is specified,
        # clear them out to avoid confusion
        sed -e 's:${B}/::g' -i ${D}${includedir}/${BPN}/Module.symvers
    fi
}