PV = "2022g"

DL_DIR = "${OPENEULER_SP_DIR}/tzdata"

OPENEULER_REPO_NAME = "tzdata"

LIC_FILES_CHKSUM = "file://LICENSE;md5=c679c9d6b02bc2757b3eaf8f53c43fba"

S = "${WORKDIR}"

# files, patches that come from openeuler
SRC_URI = " \
        file://tzcode${PV}.tar.gz;name=tzcode \
        file://tzdata${PV}.tar.gz;name=tzdata \
        file://backport-Much-of-Greenland-still-uses-DST-from-2024-on.patch \
        file://bugfix-0001-add-Beijing-timezone.patch \
        file://remove-ROC-timezone.patch \
        file://rename-Macau-to-Macao.patch \
        file://remove-El_Aaiun-timezone.patch \
        file://remove-Israel-timezone.patch \
        file://skip-check_web-testcase.patch \
        "

SRC_URI[tzcode.sha256sum] = "9610bb0b9656ff404c361a41f3286da53064b5469d84f00c9cb2314c8614da74"
SRC_URI[tzdata.sha256sum] = "4491db8281ae94a84d939e427bdd83dc389f26764d27d9a5c52d782c16764478"
