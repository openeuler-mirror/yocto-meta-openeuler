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

DESCRIPTION = "Rust compiler and standard libraries (pre-compiled binary version)"
HOMEPAGE = "https://rust-lang.org"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
SECTION = "devel"

inherit cross cargo

# prevent loop dependency
DEPENDS:remove = "cargo-bin-cross-${TARGET_ARCH}"

# Required to link binaries
DEPENDS += "gcc-cross-${TARGET_ARCH}"

PN = "rustc-bin-cross-${TARGET_ARCH}"

# Extra architectures to install standard library for. Must match one of the
# standard rust targets. The standard library for the default host and target
# will be installed automatically.
EXTRA_RUST_TARGETS ?= ""

RUST_BUILD_TARGET = "${@rust_target(d, 'BUILD')}"
RUST_TARGET_TARGET = "${@rust_target(d, 'TARGET')}"
RUST_ALL_TARGETS = "${RUST_BUILD_TARGET} ${RUST_TARGET_TARGET} ${EXTRA_RUST_TARGETS}"

S = "${WORKDIR}/rustc-${PV}-${RUST_BUILD_TARGET}"

# Relocating WORKDIR doesn't matter to installer
S[vardepsexclude] += "WORKDIR"

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
    # Install rustc
    ${S}/install.sh --verbose --destdir="${D}" --prefix="${prefix}"

    # Install rust standard libraries
    cd ${WORKDIR}/rust-std
    for subdir in *; do
        $subdir/install.sh --destdir="${D}" --prefix="${prefix}"
    done

    # Remove components that will conflict with other installables
    rm -f ${D}${prefix}/lib/rustlib/uninstall.sh
    rm -f ${D}${prefix}/lib/rustlib/install.log
    rm -f ${D}${prefix}/lib/rustlib/components
    rm -f ${D}${prefix}/lib/rustlib/rust-installer-version
}
do_install[depends] += "virtual/fakeroot-native:do_populate_sysroot"

python () {
    pv = d.getVar("PV", True)
    base_uri = d.getVar("RUST_BASE_URI", True)
    targets = d.getVar("RUST_ALL_TARGETS", True).split()
    build_target = d.getVar("RUST_BUILD_TARGET", True)
    rustc_src_uri = ("%s/dist/rustc-%s-%s.tar.gz;md5sum=%s;sha256sum=%s" %
                     (base_uri, pv, build_target, rustc_md5(build_target), rustc_sha256(build_target)))
    std_src_uris = ["%s/dist/rust-std-${PV}-%s.tar.gz;md5sum=%s;sha256sum=%s;subdir=rust-std" %
                    (base_uri, target, rust_std_md5(target), rust_std_sha256(target)) for target in targets]
    src_uri = d.getVar("SRC_URI", True).split()
    d.setVar("SRC_URI", ' '.join(src_uri + [rustc_src_uri] + std_src_uris))
}
