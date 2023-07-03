# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/spdlog/spdlog_1.9.2.bb
inherit openeuler_source

PV = "1.11.0"

SRC_URI:remove = "git://github.com/gabime/spdlog.git;protocol=https;branch=v1.x; \
        file://0001-Enable-use-of-external-fmt-library.patch \
"

SRC_URI:prepend = "file://v${PV}.tar.gz \
"

S = "${WORKDIR}/git"

