PV = "5.3"

S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:prepend = " \
        file://${BP}.tar.xz \
"

# checksum of debugedit-5.3.tar.xz (src-openeuler)
SRC_URI[sha256sum] = "3b8c6396fe235e0270c9b9c0d244cfd0e86c284fc27e820acc58360e7cfa08c2"

# debugedit 5.3 configure hard-checks host tools used by find-debuginfo
# (the rpm packaging path, not used by yocto's own -dbg splitting).
# gdb-native is unavailable in the external-toolchain layout; the rest
# (dwz, eu-elflint, help2man, cpio, xz) come from the build container
# and elfutils-native provides eu-strip.
DEPENDS:append = " elfutils-native xxhash"

do_configure:prepend() {
    mkdir -p ${B}/host-stubs
    printf '#!/bin/sh\n# stub: gdb-native is not available; find-debuginfo is an rpm-path tool\nexit 0\n' \
        > ${B}/host-stubs/gdb-add-index
    chmod +x ${B}/host-stubs/gdb-add-index
    # the build container provides dwz/eu-elflint/help2man/cpio/xz in /usr/bin,
    # which is not on the sanitised task PATH by default; keep sysroot tools
    # (autoconf-native etc.) ahead of it
    export PATH="${B}/host-stubs:$PATH:/usr/bin"
}
