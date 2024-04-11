FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI:append: = "\
		   file://systemd-musl.patch \
"			   

CFLAGS:append = " -Wno-error=implicit-function-declaration -Wno-error=int-conversion "
