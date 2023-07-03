# This file is developed based on meta-rust-bin(https://github.com/rust-embedded/meta-rust-bin) 
# using MIT License
# 
# Copyright © 2016 meta-rust-bin author
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
# and associated documentation files (the “Software”), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, 
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or 
# substantial portions of the Software.

DESCRIPTION = "Cargo build tool for Rust (pre-compiled binary version)"
HOMEPAGE = "https://rust-lang.org"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
SECTION = "devel"

inherit cross cargo

# prevent loop dependency
DEPENDS:remove = "cargo-bin-cross-${TARGET_ARCH}"

PN = "cargo-bin-cross-${TARGET_ARCH}"

CARGO_HOST_TARGET = "${@rust_target(d, 'HOST')}"

SYSROOT_DIRS_NATIVE += "${prefix}"
SYSROOT_DIRS_IGNORE += "\
    ${prefix}/share \
    ${prefix}/etc \
"

# Stripping fails because of mixed arch types (host and target)
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_build[noexec] = "1"

fakeroot do_install() {
    ${S}/install.sh --destdir="${D}" --prefix="${prefix}"
    rm -f ${D}${prefix}/lib/rustlib/uninstall.sh
    rm -f ${D}${prefix}/lib/rustlib/install.log
    rm -f ${D}${prefix}/lib/rustlib/components
    rm -f ${D}${prefix}/lib/rustlib/rust-installer-version
}
do_install[depends] += "virtual/fakeroot-native:do_populate_sysroot"

python () {
    pv = d.getVar("PV", True)
    pv_uri = pv[0:4] + '-' + pv[4:6] + '-' + pv[6:8]
    target = d.getVar("CARGO_HOST_TARGET", True)
    cargo_uri = ("%s;md5sum=%s;sha256sum=%s;downloadname=%s" %
                 (cargo_url(target), cargo_md5(target), cargo_sha256(target),
                  d.getVar("PN", True) + "-" + pv + "-" + target + ".tar.gz"))
    src_uri = d.getVar("SRC_URI", True).split()
    cargo_extract_path = cargo_url(target).split('/')[-1].replace('.tar.gz', '')
    d.setVar("SRC_URI", ' '.join(src_uri + [cargo_uri]))
    d.setVar("S", "${{WORKDIR}}/{}".format(cargo_extract_path))
    d.appendVarFlag("S", "vardeps", " cargo_url")
    d.appendVarFlag("S", "vardepsexclude", " WORKDIR")
}
