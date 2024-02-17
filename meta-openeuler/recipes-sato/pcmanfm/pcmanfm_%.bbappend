# main bb: yocto-poky/meta/recipes-sato/pcmanfm/pcmanfm_1.3.2.bb

PV = "1.3.2"

SRC_URI += " \
        file://${BP}.tar.xz \
        file://pcmanfm-0101-split-out-per-monitor-initialization-part-from-fm_de.patch \
        file://pcmanfm-0102-use-GList-for-FmDesktop-entries-instead-of-static-ar.patch \
        file://pcmanfm-0103-Fix-the-bug-that-desktop-configuration-is-not-proper.patch \
        file://pcmanfm-0104-Finish-implementation-of-inserting-new-monitor.patch \
        file://pcmanfm-0202-connect_model-connect-to-signal-before-setting-folde.patch \
"

S = "${WORKDIR}/${BP}"
