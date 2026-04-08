PV = "60"
SRC_URI = "file://unzip${PV}.tar.gz \
                file://unzip-6.0-bzip2-configure.patch \
                file://unzip-6.0-exec-shield.patch \
                file://unzip-6.0-close.patch \
                file://unzip-6.0-attribs-overflow.patch \
                file://unzip-6.0-configure.patch \
                file://unzip-6.0-manpage-fix.patch \
                file://unzip-6.0-fix-recmatch.patch \
                file://unzip-6.0-symlink.patch \
                file://unzip-6.0-caseinsensitive.patch \
                file://unzip-6.0-format-secure.patch \
                file://unzip-6.0-valgrind.patch \
                file://unzip-6.0-x-option.patch \
                file://unzip-6.0-overflow.patch \
                file://unzip-6.0-cve-2014-8139.patch \
                file://unzip-6.0-cve-2014-8140.patch \
                file://unzip-6.0-cve-2014-8141.patch \
                file://unzip-6.0-overflow-long-fsize.patch \
                file://unzip-6.0-heap-overflow-infloop.patch \
                file://unzip-6.0-alt-iconv-utf8.patch \
                file://unzip-6.0-alt-iconv-utf8-print.patch \
                file://0001-Fix-CVE-2016-9844-rhbz-1404283.patch \
                file://unzip-6.0-timestamp.patch \
                file://unzip-6.0-cve-2018-1000035-heap-based-overflow.patch \
                file://unzip-6.0-support-clang-build.patch \
                file://CVE-2019-13232-pre.patch \
                file://CVE-2019-13232.patch \
                file://CVE-2019-13232-fur1.patch \
                file://backport-CVE-2021-4217.patch \
                file://CVE-2019-13232-fur2.patch \
                file://CVE-2022-0530.patch \
                file://CVE-2022-0529.patch"

# Fix: File '<file>' in package '<package>' doesn't have GNU_HASH
TARGET_CC_ARCH += "${LDFLAGS}"

# Additional program: zipinfo → not in the automatic strip list
# this is a defect in the official unzip recipe, so manually strip it here
# The specific reason is unknown; handle it this way temporarily
# and modify it specifically after further analysis
python do_zipinfo_manual_strip() {
    import oe.package

    strip_cmd = d.getVar('STRIP')
    file_path = d.expand(d.getVar('PKGD') + d.getVar('bindir') + '/zipinfo')
        
    if os.path.exists(file_path):
        result = oe.package.is_elf(file_path)
        file, elf_file = result 

        if elf_file & 1:
            if not (elf_file & 2):
                oe.package.runstrip((file_path, elf_file, strip_cmd))
            bb.note("Manually stripped: %s" % file_path)
        else:
            bb.note("File already stripped: %s" % file_path)
    else:
        bb.warn("File not found: %s" % file_path)
}

addtask do_zipinfo_manual_strip after do_package before do_package_qa
