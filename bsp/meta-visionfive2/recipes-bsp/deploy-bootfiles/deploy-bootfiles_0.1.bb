SUMMARY = "Deploy Boot files recipe"
DESCRIPTION = "Recipe to deploy uEnv.txt to the deploy directory"
LICENSE = "CLOSED"

SRC_URI = "file://vf2_uEnv.txt \
           file://visionfive-v2-extlinux.conf \
          "

S = "${WORKDIR}"

inherit deploy

do_deploy(){
        # uboot environment configuration
        install -m 755 ${WORKDIR}/vf2_uEnv.txt     ${DEPLOYDIR}/
        # default extlinux configuration
        install -m 755 ${WORKDIR}/visionfive-v2-extlinux.conf     ${DEPLOYDIR}/
}

addtask deploy before do_build after do_install
