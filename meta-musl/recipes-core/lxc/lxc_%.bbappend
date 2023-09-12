FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

DEPENDS:append ="\
  gcompat \
"
SRC_URI:append = " \
          file://lxc-for-musl.patch \
"
CFLAGS:append = " -Wno-error=address -Wno-error=array-bounds -Wno-array-bounds -D__MUSL__ "
CFLAGS:append:toolchain-clang = " -Wno-error=cast-align " 
LDFLAGS:append = " -lgcompat"
do_compile:prepend() {
       sed -i "s/init_lxc_static_LDFLAGS = -all-static -pthread/init_lxc_static_LDFLAGS = -pthread/" ${S}/src/lxc/Makefile.am
}

