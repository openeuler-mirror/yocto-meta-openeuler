# main bbfile: yocto-poky/meta/recipes-devtools/perl/libxml-parser-perl_2.46.bb
PV = "6.5.3"

OPENEULER_SRC_URI_REMOVE = "http https git"
OPENEULER_REPO_NAME = "btrfs-progs"

# remove poky attr
SRC_URI:remove = "\
           file://0001-Add-a-possibility-to-specify-where-python-modules-ar.patch \
           "

# openeuler source
SRC_URI:prepend = "file://btrfs-progs-v${PV}.tar.xz \
                  "

S = "${WORKDIR}/btrfs-progs-v${PV}"

# attr from 6.5.3.bb
DEPENDS = "lzo util-linux zlib"
PACKAGECONFIG[manpages] = "--enable-documentation, --disable-documentation, python3-sphinx-native"
PACKAGECONFIG[lzo] = "--enable-lzo,--disable-lzo,lzo"

