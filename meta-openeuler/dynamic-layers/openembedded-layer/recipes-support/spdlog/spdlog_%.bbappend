# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/spdlog/spdlog_1.9.2.bb

PV = "1.11.0"

SRC_URI:prepend = " file://v${PV}.tar.gz;subdir=git;striplevel=1 \
        file://CVE-2025-6140.patch "

# can't not apply the following patch, because of different version
SRC_URI:remove = " \
        file://0001-Enable-use-of-external-fmt-library.patch \
"
