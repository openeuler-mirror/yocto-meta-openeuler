# reference: yocto-meta-openembedded/meta-oe/recipes-devtools/suitesparse/suitesparse_5.10.1.bb
OPENEULER_SRC_URI_REMOVE = "https http git"

PV = "5.10.1"

# the local directory name holding suitesparse-${PV}.tar.gz
S = "${WORKDIR}/SuiteSparse-${PV}"

# we do not want to get source code from original upstream
SRC_URI:remove = "git://github.com/DrTimothyAldenDavis/SuiteSparse;protocol=https;branch=master \
            file://0001-Preserve-CXXFLAGS-from-environment-in-Mongoose.patch \
            file://0002-Preserve-links-when-installing-libmetis.patch \
            file://0003-Add-version-information-to-libmetis.patch \
           "
SRC_URI:prepend = "file://SuiteSparse-${PV}.tar.gz \
"