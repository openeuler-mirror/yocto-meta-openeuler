# main bbfile: yocto-poky/meta/recipes-extended/screen/screen_4.9.0.bb

PV = "5.0.2"

LIC_FILES_CHKSUM = "file://COPYING;md5=c678957b0c8e964aa6c70fd77641a71e \
                    file://screen.h;endline=26;md5=b8dc717c9a3dba842ae6c44ca0f73f52 \
"

# 5.0 renamed the option and needs an in-source build (autotools-brokensep)
# so the generated kmapdef.h is found (as OE-Core master screen_5.0.2.bb)
EXTRA_OECONF:remove = "--with-sys-screenrc=${sysconfdir}/screenrc"
EXTRA_OECONF:append = " --with-system_screenrc=${sysconfdir}/screenrc"
inherit autotools-brokensep

# all four 4.9.0-era patches fail on 5.0.2
SRC_URI:remove = "file://CVE-2023-24626.patch \
           file://0002-comm.h-now-depends-on-term.h.patch \
           file://0001-fix-for-multijob-build.patch \
           file://0001-Remove-more-compatibility-stuff.patch \
"

# files, patches that come from openeuler (the 4.3.1-era patches were
# dropped or renamed to 5.0.0 versions in the src repo)
SRC_URI:prepend = "file://${BP}.tar.gz \
           file://screen-5.0.0-screenrc.patch \
           file://screen-5.0.0-suppress_remap.patch \
"

SRC_URI[sha256sum] = "a7d615ee46f5361489fc423c4436b02d5b622aeefadeb4cd1a60b46d5d161dde"
