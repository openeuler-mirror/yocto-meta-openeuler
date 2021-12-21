SUMMARY = "Text file viewer similar to more"
DESCRIPTION = "Less is a program similar to more, i.e. a terminal \
based program for viewing text files and the output from other \
programs. Less offers many features beyond those that more does."
HOMEPAGE = "http://www.greenwoodsoftware.com/"
SECTION = "console/utils"

# (GPLv2+ (<< 418), GPLv3+ (>= 418)) | less
# Including email author giving permissing to use BSD
#
# From: Mark Nudelman <markn@greenwoodsoftware.com>
# To: Elizabeth Flanagan <elizabeth.flanagan@intel.com
# Date: 12/19/11
#
# Hi Elizabeth,
# Using a generic BSD license for less is fine with me.
# Thanks,
#
# --Mark
#

LICENSE = "GPLv3+ | BSD-2-Clause"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504 \
                    file://LICENSE;md5=ba01d0cab7f62f7f2204c7780ff6a87d \
                    "
DEPENDS = "ncurses"

SRC_URI = "file://${BPN}/${BPN}-${PV}.tar.gz \
           file://${BPN}/backport-Create-only-one-ifile-when-a-file-is-opened-under-di.patch \
           file://${BPN}/backport-Fix-crash-when-call-set_ifilename-with-a-pointer-to-.patch \
           file://${BPN}/backport-Fix-minor-memory-leak-with-input-preprocessor.-150.patch  \
           file://${BPN}/backport-Fix-Tag-not-found-error-while-looking-for-a-tag-s-lo.patch \
           file://${BPN}/backport-Ignore-SIGTSTP-in-secure-mode.patch  \
           file://${BPN}/backport-Lesskey-don-t-translate-ctrl-K-in-an-EXTRA-string.patch \
           file://${BPN}/backport-Make-histpattern-return-negative-value-to-indicate-e.patch \
           file://${BPN}/backport-Protect-from-buffer-overrun.patch \
           file://${BPN}/backport-Remove-extraneous-frees-associated-with-removed-call.patch \
           file://${BPN}/backport-Remove-unnecessary-call-to-pshift-in-pappend.patch \
           file://${BPN}/backport-Reset-horizontal-shift-when-opening-a-new-file.patch \
           file://${BPN}/less-394-time.patch \ 
	  "
#file://${BPN}/less-418-fsync.patch

SRC_URI[sha256sum] = "ce5b6d2b9fc4442d7a07c93ab128d2dff2ce09a1d4f2d055b95cf28dd0dc9a9a"

UPSTREAM_CHECK_URI = "http://www.greenwoodsoftware.com/less/download.html"

#inherit autotools update-alternatives
inherit autotools

do_install () {
        oe_runmake 'bindir=${D}${bindir}' 'mandir=${D}${mandir}' install
}

ALTERNATIVE_${PN} = "less"
ALTERNATIVE_PRIORITY = "100"
