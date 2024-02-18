# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

SRC_URI = " \
    file://kernel-5.10-tag3093 \
    file://config/hi3093/defconfig \
"

python do_fetch() {
    # download src-openeuler/kernel repo for patches
    d.setVar("OPENEULER_REPO_NAME", "kernel")
    d.setVar("OPENEULER_LOCAL_NAME", 'src-kernel-5.10-tag3093')
    bb.build.exec_func("do_openeuler_fetch", d)

    # download openeuler/kernel-5.10 repo for linux kernel src files
    d.setVar("OPENEULER_REPO_NAME", "kernel-5.10")
    d.setVar("OPENEULER_LOCAL_NAME", 'kernel-5.10-tag3093')
    bb.build.exec_func("do_openeuler_fetch", d)
}

S = "${WORKDIR}/kernel-5.10-tag3093"
