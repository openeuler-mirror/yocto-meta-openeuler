# main bbfile: yocto-poky/meta/recipes-extended/less/less_563.bb

# less version in openEuler
PV = "633"

LIC_FILES_CHKSUM = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464 \
                    file://LICENSE;md5=1b2446f5c8632bf63a97d7a49750e1c6 \
                    "

# Use the source packages and patches from openEuler
# less-475-fsync.patch can't apply: cannot run test program while cross compiling
SRC_URI = "file://${BP}.tar.gz \
          file://less-394-time.patch \
          file://backport-Some-constifying.patch \
          file://backport-Implement-osc8_open.patch \
          file://backport-CVE-2024-32487.patch \
          file://backport-Don-t-return-READ_AGAIN-from-iread-if-no-data-has-ye.patch \
          file://backport-Fix-for-previous-fix.patch \
          file://backport-Avoid-stealing-data-from-an-input-program-that-uses-.patch \
          file://backport-Do-not-assume-PATH_MAX-is-defined.patch \
	  file://backport-Fix-bug-related-to-ctrl-X-when-output-is-not-a-termi.patch \
"
CAUSE_CONFIGURE_ERR = " \
          file://less-475-fsync.patch \
"

SRC_URI[md5sum] = "1cdec714569d830a68f4cff11203cdba"
SRC_URI[sha256sum] = "a69abe2e0a126777e021d3b73aa3222e1b261f10e64624d41ec079685a6ac209"

ASSUME_PROVIDE_PKGS = "less"
