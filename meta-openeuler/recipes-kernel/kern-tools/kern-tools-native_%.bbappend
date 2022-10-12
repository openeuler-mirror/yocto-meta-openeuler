# main bbfile: yocto-poky/meta/recipes-kernel/kern-tools/kern-tools-native_git.bb

# source from from yocto-embedded-tools
SRC_URI = "file://yocto-embedded-tools/build_tools/yocto-kernel-tools"
PV = "0.2"

S = "${WORKDIR}/yocto-embedded-tools/build_tools/yocto-kernel-tools"

python do_fetch() {
    repoList = [{
        "repo_name": "yocto-embedded-tools",
        "git_space": "openeuler",
        "branch": "master"
    }]

    d.setVar("PKG_REPO_LIST", repoList)

    bb.build.exec_func("do_openeuler_fetchs", d)
}
