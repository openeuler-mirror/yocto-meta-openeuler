# main bbfile: yocto-poky/meta/recipes-extended/xz/xz_5.2.5.bb

LIC_FILES_CHKSUM = "file://COPYING;md5=c8ea84ebe7b93cce676b54355dc6b2c0 \
                    file://COPYING.GPLv2;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://COPYING.GPLv3;md5=1ebbd3e34237af26da5dc08a4e440464 \
                    file://COPYING.LGPLv2.1;md5=4fbd65380cdd255951079008b364516c \
                    file://lib/getopt.c;endline=23;md5=2069b0ee710572c03bb3114e4532cd84 \
                    "

PV = "5.4.7"

SRC_URI += " \
    file://${BP}.tar.xz \
    file://xz-5213-547-562-libtool.patch \
    file://0001-fix-CVE-2024-47611.patch \
    file://add-sw_64-support.patch \
    file://xz-cve-2025-31115.patch \
    file://backport-Autodetect-unaligned-access-support-on-LoongArch.patch \
    file://backport-CVE-2026-34743.patch \
    file://backport-GHSA-5qpq-xqfv-j9pg.patch \
"

ASSUME_PROVIDE_PKGS = "xz-libs xz"
