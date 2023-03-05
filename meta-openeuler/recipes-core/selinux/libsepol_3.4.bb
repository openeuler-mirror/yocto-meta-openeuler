SUMMARY = "SELinux binary policy manipulation library"
DESCRIPTION = "libsepol provides an API for the manipulation of SELinux binary policies. \
It is used by checkpolicy (the policy compiler) and similar tools, as well \
as by programs like load_policy that need to perform specific transformations \
on binary policies such as customizing policy boolean settings."
SECTION = "base"
LICENSE = "LGPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://${S}/COPYING;md5=a6f89e2100d9b6cdffcea4f398e37343"

require selinux_common.inc

inherit lib_package

SRC_URI += "file://0001-libsepol-fix-validation-of-user-declarations-in-modu.patch"

S = "${WORKDIR}/git/libsepol"

DEPENDS = "flex-native"

BBCLASSEXTEND = "native"
