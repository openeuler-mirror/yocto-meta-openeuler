SUMMARY = "Tools to manipulate UEFI variables"
DESCRIPTION = "efivar provides a simple command line interface to the UEFI variable facility"
HOMEPAGE = "https://github.com/rhboot/efivar"

LICENSE = "LGPL-2.1-or-later"
LIC_FILES_CHKSUM = "file://COPYING;md5=6626bb1e20189cfa95f2c508ba286393"

COMPATIBLE_HOST = "(i.86|x86_64|arm|aarch64).*-linux"

SRC_URI = "git://github.com/rhinstaller/efivar.git;branch=main;protocol=https \
           file://0001-docs-do-not-build-efisecdb-manpage.patch \
           "
SRCREV = "c47820c37ac26286559ec004de07d48d05f3308c"

S = "${WORKDIR}/git"

inherit pkgconfig

export CCLD_FOR_BUILD = "${BUILD_CCLD}"

do_compile() {
    oe_runmake ERRORS= HOST_CFLAGS="${BUILD_CFLAGS}" HOST_LDFLAGS="${BUILD_LDFLAGS}"
}

do_install() {
    oe_runmake install DESTDIR=${D}
}

BBCLASSEXTEND = "native"

RRECOMMENDS:${PN}:class-target = "kernel-module-efivarfs"

CLEANBROKEN = "1"

# With the clang toolchain + ld-is-lld, libefisec.so fails to link because:
#   ld.lld: error: unknown argument '--add-needed'
# efivar's defaults.mk hardcodes -Wl,--add-needed (a legacy GNU ld no-op flag)
# in its "override LDFLAGS = ..." (the override keyword blocks Yocto's
# LDFLAGS from removing it). lld rejects this flag, so strip the line from
# defaults.mk before compiling when lld is the linker.
do_compile:prepend() {
    if echo "${LDFLAGS}" | grep -q "fuse-ld=lld"; then
        # efivar's defaults.mk hardcodes -Wl,--add-needed (a legacy GNU ld
        # no-op) in its "override LDFLAGS = ..."; lld rejects it with
        # "unknown argument '--add-needed'". Strip the line.
        sed -i '/--add-needed/d' "${S}/src/include/defaults.mk"
        # efivar's makeguids generates guids.lds with "INSERT AFTER .data"
        # (a GNU ld extension); lld doesn't support it and fails with
        # "unable to insert .data after .data" when linking libefivar.so.
        # Patch makeguids.c to output just the symbol assignments (no
        # SECTIONS/.data/INSERT AFTER) — top-level assignments work with
        # both lld and GNU ld. (void)dash_t suppresses -Werror=unused-but-
        # set-variable after removing dash_t's only use (the INSERT AFTER).
        S="${S}" python3 <<'PYEOF'
import os
f = os.environ["S"] + "/src/makeguids.c"
s = open(f).read()
old = (
    '\t\t"SECTIONS\\n"\n'
    '\t\t"{\\n"\n'
    '\t\t"  .data :\\n"\n'
    '\t\t"  {\\n"\n'
    '\t\t"    efi_well_known_guids = efi_well_known_guids_;\\n"\n'
    '\t\t"    efi_well_known_guids_end = efi_well_known_guids_ + %zd;\\n"\n'
    '\t\t"    efi_well_known_names = efi_well_known_names_;\\n"\n'
    '\t\t"    efi_well_known_names_end = efi_well_known_names_ + %zd;\\n"\n'
    '\t\t"  }\\n"\n'
    '\t\t"}%s;\\n",\n'
    '\t\t(line - 1) * sizeof(struct efivar_guidname),\n'
    '\t\t(line - 1) * sizeof(struct efivar_guidname),\n'
    '\t\tdash_t ? " INSERT AFTER .data" : "");'
)
new = (
    '\t\t"    efi_well_known_guids = efi_well_known_guids_;\\n"\n'
    '\t\t"    efi_well_known_guids_end = efi_well_known_guids_ + %zd;\\n"\n'
    '\t\t"    efi_well_known_names = efi_well_known_names_;\\n"\n'
    '\t\t"    efi_well_known_names_end = efi_well_known_names_ + %zd;\\n",\n'
    '\t\t(line - 1) * sizeof(struct efivar_guidname),\n'
    '\t\t(line - 1) * sizeof(struct efivar_guidname));\n'
    '\t(void)dash_t;'
)
if old in s:
    s = s.replace(old, new)
    open(f, "w").write(s)
PYEOF
    fi
}
