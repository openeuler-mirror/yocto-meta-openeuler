# main bbfile: yocto-poky/meta/recipes-kernel/lttng/lttng-modules_2.13.9.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

OPENEULER_SRC_URI_REMOVE = "https git"

OPENEULER_LOCAL_NAME = "oee_archive"

# src package and patches from openEuler
SRC_URI:prepend = " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/${BPN}-${PV}.tar.bz2 \
        file://0001-opneuler-kernel-version-workaround-for-openeuler-lin.patch \
        "

# remove BBCLASSEXTEND = "devupstream:target"
# because an error will be raised in parsing bb files, maybe conflict with OPENEULER_LOCAL_NAME mechanism
# bb.data_smart.ExpansionError: Failure expanding variable SRCPV, expression was ${@bb.fetch2.get_srcrev(d)} which triggered exception FetchError:
# Fetcher failure: There are recursive references in fetcher variables, likely through SRC_URI
# The variable dependency chain for the failure is: SRCPV -> PV -> SRC_URI -> SRCPV -> PV -> SRC_URI
BBCLASSEXTEND = ""
