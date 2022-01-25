SUMMARY = "Timezone data"
DESCRIPTION = "The Time Zone Database contains code and data that represent \
the history of local time for many representative locations around the globe."
HOMEPAGE = "http://www.iana.org/time-zones"
SECTION = "base"
LICENSE = "PD & BSD & BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=c679c9d6b02bc2757b3eaf8f53c43fba"

SRC_URI = "file://tzdata/tzcode${PV}.tar.gz;name=tzcode \
           file://tzdata/tzdata${PV}.tar.gz;name=tzdata \
	   file://tzdata/bugfix-0001-add-Beijing-timezone.patch \
           file://tzdata/remove-country-selection-from-tzselect-steps.patch \
           file://tzdata/remove-ROC-timezone.patch \
           file://tzdata/rename-Macau-to-Macao.patch \
           file://tzdata/remove-El_Aaiun-timezone.patch \
           file://tzdata/remove-Israel-timezone.patch \
           file://tzdata/skip-check_web-testcase.patch \
           "

UPSTREAM_CHECK_URI = "http://www.iana.org/time-zones"

SRC_URI[tzcode.sha256sum] = "584666393a5424d13d27ec01183da17703273664742e049d4f62f62dab631775"
SRC_URI[tzdata.sha256sum] = "07ec42b737d0d3c6be9c337f8abb5f00554a0f9cc4fcf01a703d69403b6bb2b1"
