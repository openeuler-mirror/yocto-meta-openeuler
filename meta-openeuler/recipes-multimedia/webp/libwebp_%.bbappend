# the main bb file: yocto-poky/meta/recipes-multimedia/webp/libwebp_1.2.4.bb

PV = "1.3.2"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://libwebp-freeglut.patch \
    file://backport-0001-CVE-2023-4863.patch \
"

SRC_URI[sha256sum] = "2a499607df669e40258e53d0ade8035ba4ec0175244869d1025d460562aa09b4"

# sync from 1.3.2 openembedded-core/meta/recipes-multimedia/webp/libwebp_1.3.2.bb
BBCLASSEXTEND += "native nativesdk"   
