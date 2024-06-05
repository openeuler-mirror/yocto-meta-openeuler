RDEPENDS:${PN} += " \
    ${@oe.utils.conditional("AUTO-EXPAND-FS", "1", "auto-expand-fs", "", d)} \
"

RDEPENDS:${PN}:remove = " \
    kernel-vmlinux \
"
