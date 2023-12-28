# we add bootfile
RDEPENDS_${PN} += " \
    ${@oe.utils.conditional("AUTO-EXPAND-FS", "1", "auto-expand-fs", "", d)} \
"
