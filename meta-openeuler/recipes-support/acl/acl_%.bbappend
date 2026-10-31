# main bbfile: yocto-poky/meta/recipes-support/attr/acl_2.3.1.bb

SRC_URI = "file://${BP}.tar.gz \
           file://backport-acl_copy_entry-Prevent-accidental-NULL-pointer-deref.patch \
           file://backport-libobj-declare-s_str-directory-in-string_obj_tag.patch \
           file://backport-setfacl-preserve-the-failed-status-when-processing-m.patch \
           file://backport-0001-CVE-2026-54369.patch \
           file://backport-0002-CVE-2026-54369.patch \
           file://backport-0003-CVE-2026-54369.patch \
           file://backport-0004-CVE-2026-54369.patch \
           file://backport-0005-CVE-2026-54369.patch \
           file://backport-0006-CVE-2026-54369.patch \
           file://backport-0007-CVE-2026-54369.patch \
           file://backport-0008-CVE-2026-54369.patch \
           file://backport-0001-CVE-2026-54370.patch \
           file://backport-0002-CVE-2026-54370.patch \
           file://backport-0003-CVE-2026-54370.patch \
           file://backport-0004-CVE-2026-54370.patch \
           file://backport-0005-CVE-2026-54370.patch \
           file://backport-0006-CVE-2026-54370.patch \
           file://backport-0007-CVE-2026-54370.patch \
           file://backport-0008-CVE-2026-54370.patch \
           file://backport-0009-CVE-2026-54370.patch \
           file://backport-0010-CVE-2026-54370.patch \
           file://backport-0011-CVE-2026-54370.patch \
           file://backport-0012-CVE-2026-54370.patch \
           file://backport-0013-CVE-2026-54370.patch \
           file://backport-0014-CVE-2026-54370.patch \
           file://backport-Fix-some-compiler-warnings-for-CVE-2026-54369-CVE-2026-54370.patch \
"

# checksums of acl-2.3.1.tar.gz (from src-openeuler repo)
SRC_URI[md5sum] = "3cecb80cb0a52a0b273e6698ba642263"
SRC_URI[sha256sum] = "760c61c68901b37fdd5eefeeaf4c0c7a26bdfdd8ac747a1edff1ce0e243c11af"

ASSUME_PROVIDE_PKGS = "libacl"
