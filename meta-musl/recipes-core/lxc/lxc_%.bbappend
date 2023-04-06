FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

DEPENDS_append ="\
  gcompat \
"

SRC_URI_append = " \
          file://lxc-for-musl.patch \
"
CFLAGS_append = " -Wno-error=address   -Wno-error=array-bounds -Wno-array-bounds "
CFLAGS_append_toolchain-clang = " -Wno-error=cast-align " 
LDFLAGS_append = " -lgcompat"
do_compile_prepend() {
       sed -i "s/init_lxc_static_LDFLAGS = -all-static -pthread/init_lxc_static_LDFLAGS = -pthread/" ${S}/src/lxc/Makefile.am
}

