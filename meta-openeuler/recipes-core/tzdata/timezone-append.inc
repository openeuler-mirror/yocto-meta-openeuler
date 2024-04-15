PV = "2024a"

DL_DIR = "${OPENEULER_SP_DIR}/tzdata"

OPENEULER_REPO_NAME = "tzdata"

LIC_FILES_CHKSUM = "file://LICENSE;md5=c679c9d6b02bc2757b3eaf8f53c43fba"

S = "${WORKDIR}"

# files, patches that come from openeuler
SRC_URI = " \
        file://tzcode${PV}.tar.gz;name=tzcode \
        file://tzdata${PV}.tar.gz;name=tzdata \
        file://bugfix-0001-add-Beijing-timezone.patch \
        file://remove-ROC-timezone.patch \
        file://rename-Macau-to-Macao.patch \
        file://remove-El_Aaiun-timezone.patch \
        file://remove-Israel-timezone.patch \
        file://skip-check_web-testcase.patch \
        "

SRC_URI[tzcode.sha256sum] = "80072894adff5a458f1d143e16e4ca1d8b2a122c9c5399da482cb68cba6a1ff8"
SRC_URI[tzdata.sha256sum] = "0d0434459acbd2059a7a8da1f3304a84a86591f6ed69c6248fffa502b6edffe3"
