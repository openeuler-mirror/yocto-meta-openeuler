#main bbfile: yocto-poky/meta/recipes-extended/procps/procps_3.3.17.bb
OPENEULER_SRC_URI_REMOVE = "git"
#version in openEuler
PV = "4.0.2"

S = "${WORKDIR}/procps-ng-${PV}"

FILESEXTRAPATHS_append := "${THISDIR}/procps/:"

OPENEULER_REPO_NAME = "procps-ng"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
            file://0001-w.c-correct-musl-builds.patch \
            file://0002-proc-escape.c-add-missing-include.patch \
            "
# files, patches that come from openeuler
SRC_URI += " \
        file://procps-ng-${PV}.tar.xz \
        file://openeuler-add-M-and-N-options-for-top.patch \
        file://openeuler-top-exit-with-error-when-pid-overflow.patch \
        file://skill-Restore-the-p-flag-functionality.patch \
        file://backport-top-address-the-missing-guest-tics-for-summary-area.patch \
        file://backport-0001-ps-address-missing-or-corrupted-fields-with-m-option.patch \
        file://backport-0002-ps-trade-previous-fix-for-final-solution-to-m-option.patch \
        file://backport-top-lessen-summary-cpu-distortions-with-first-displa.patch \
        file://backport-pmap-Increase-memory-allocation-failure-judgment.patch \
        file://backport-top-added-guest-tics-when-multiple-cpus-were-merged.patch \
        file://backport-library-restore-the-proper-main-thread-tics-valuation.patch \
        file://backport-vmstat-Update-memory-statistics.patch \
        file://backport-vmstat-Print-guest-time.patch \
        file://backport-ps-Fix-possible-buffer-overflow-in-C-option.patch \
        file://backport-ps-Correct-BSD-c-option.patch \
        file://backport-library-address-remaining-cpu-distortions-stat-api.patch \
        file://backport-ps-don-t-lose-tasks-when-sort-used-with-forest-mode.patch \
        file://backport-acknowledge-fix-for-the-lost-tasks-ps-issue.patch \
"

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://COPYING.LIB;md5=4cf66a4984120007c9881cc871cf49db \
                    "

# file://procps-ng/openeuler-add-M-and-N-options-for-top.patch
# file://procps-ng/openeuler-top-exit-with-error-when-pid-overflow.patch
# file://procps-ng/skill-Restore-the-p-flag-functionality.patch
do_configure_prepend() {
    # cannot run po/update-potfiles in new version
    if [ ! -f ${S}/po/update-potfiles ]; then
        touch ${S}/po/update-potfiles
        chmod +x ${S}/po/update-potfiles
    fi
}

SRC_URI[sha256sum] = "ee3fcd2ea6ff94aa43a81ba5cc7912b7c9615acd2911c7a3d3ea081287fdf47a"
