require readline.inc

SRC_URI = "file://readline/${BPN}-${PV}.tar.gz \
	   file://readline/readline-8.0-shlib.patch \
	   file://inputrc \
	   file://configure-fix.patch \
"

SRC_URI[archive.md5sum] = "e9557dd5b1409f5d7b37ef717c64518e"
SRC_URI[archive.sha256sum] = "f8ceb4ee131e3232226a17f51b164afc46cd0b9e6cef344be87c65962cb82b02"
