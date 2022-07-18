#main bbfile: yocto-poky/meta/recipes-extended/procps/procps_3.3.17.bb

#version in openEuler
PV = "3.3.17"

S = "${WORKDIR}/${BPN}-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
            git://gitlab.com/procps-ng/procps.git;protocol=https \
            "
# files, patches that come from openeuler
SRC_URI += " \
        file://procps-ng/procps-ng-${PV}.tar.xz \
        file://procps-ng/0001-top-fix-two-potential-alternate-display-mode-abends.patch \
        file://procps-ng/0002-top-In-the-bye_bye-function-replace-fputs-with-the-w.patch \
        file://procps-ng/0003-add-options-M-and-N-for-top.patch \
        file://procps-ng/0004-top-exit-with-error-when-pid-overflow.patch \
        file://procps-ng/0005-fix-a-fix-for-the-bye_bye-function.patch \
        "

do_configure_prepend() {
    # cannot run po/update-potfiles in new version
    if [ ! -f ${S}/po/update-potfiles ]; then
        touch ${S}/po/update-potfiles
        chmod +x ${S}/po/update-potfiles
    fi
}

SRC_URI[tarball.md5sum] = "d60613e88c2f442ebd462b5a75313d56"
SRC_URI[tarball.sha256sum] = "4518b3e7aafd34ec07d0063d250fd474999b20b200218c3ae56f5d2113f141b4"

