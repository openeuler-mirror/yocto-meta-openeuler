# main bbfile: yocto-poky/meta/recipes-core/update-rc.d/update-rc.d_0.8.bb

# source from from yocto-embedded-tools
SRC_URI = "file://yocto-embedded-tools/build_tools/update-rc.d"

S = "${WORKDIR}/yocto-embedded-tools/build_tools/update-rc.d"

python do_fetch() {
    repoList = [{
        "repo_name": "yocto-embedded-tools",
        "git_space": "openeuler",
        "branch": "master"
    }]

    d.setVar("PKG_REPO_LIST", repoList)

    bb.build.exec_func("do_openeuler_fetchs", d)
}
