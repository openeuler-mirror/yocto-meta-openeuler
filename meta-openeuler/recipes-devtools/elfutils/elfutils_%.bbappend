PV = "0.185"

# add patches from openeuler
SRC_URI += " \
    file://elfutils-${PV}.tar.bz2 \
    file://backport-elfclassify-Fix-no-stdin-flag.patch \
    file://Fix-segfault-in-eu-ar-m.patch \
    file://backport-libelf-Correctly-decode-ar_mode-as-octal-string.patch \
    file://Fix-issue-of-moving-files-by-ar-or-br.patch \
    file://Get-instance-correctly-for-eu-ar-N-option.patch \
    file://backport-readelf-Handle-DW_LLE_GNU_view_pair.patch \
    file://backport-libdwfl-Fix-overflow-check-in-link_map.c-read_addrs.patch \
"

SRC_URI[sha256sum] = "e70b0dfbe610f90c4d1fe0d71af142a4e25c3c4ef9ebab8d2d72b65159d454c8"

LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504 \
                    file://debuginfod/debuginfod-client.c;endline=27;md5=f8e9d171c401c493ec45a0b2992ea2ed \
                    "

# delete conflict patches from poky
SRC_URI_remove += " \
           file://0001-add-support-for-ipkg-to-debuginfod.cxx.patch \
           https://sourceware.org/elfutils/ftp/${PV}/${BP}.tar.bz2 \
"
