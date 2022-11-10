# main bbfile: yocto-poky/meta/recipes-support/libunistring/libunistring_0.9.10.bb
PV = "1.0"

# solve lic check failed
LIC_FILES_CHKSUM_remove = "file://README;beginline=45;endline=65;md5=08287d16ba8d839faed8d2dc14d7d6a5 \
                           file://doc/libunistring.texi;md5=287fa6075f78a3c85c1a52b0a92547cd \
"

LIC_FILES_CHKSUM += "file://README;beginline=45;endline=65;md5=3a896a943b4da2c551e6be1af27eff8d \
                     file://doc/libunistring.texi;md5=266e4297d7c18f197be3d9622ba99685 \
"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        ${GNU_MIRROR}/libunistring/libunistring-${PV}.tar.gz \
        file://0001-Unset-need_charset_alias-when-building-for-musl.patch \
"

# files, patches that come from openeuler
SRC_URI += " \
        file://${BP}.tar.xz;name=tarball \
"

SRC_URI[tarball.md5sum] = "88752c7859212f9c7a0f6cbf7a273535"
SRC_URI[tarball.sha256sum] = "5bab55b49f75d77ed26b257997e919b693f29fd4a1bc22e0e6e024c246c72741"
