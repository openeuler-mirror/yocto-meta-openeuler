# main bb file: yocto-meta-openembedded/meta-oe/recipes-extended/libpwquality/libpwquality_1.4.4.bb

DEPENDS:append ="\
  gcompat \
"
LDFLAGS:append = " -lgcompat"
