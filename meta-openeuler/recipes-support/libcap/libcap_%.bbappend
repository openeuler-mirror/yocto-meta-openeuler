PV = "2.69"

LIC_FILES_CHKSUM = "file://License;md5=e2370ba375efe9e1a095c26d37e483b8"
SRC_URI[sha256sum] = "5f65dc5b2e9f63a0748ea1b05be7965a38548db1cbfd53b30271ff02186b3a4a"

# openeuler package and patches
SRC_URI = " \
    file://${BP}.tar.gz \
    file://libcap-buildflags.patch \
    file://backport-libcap-Ensure-the-XATTR_NAME_CAPS-is-define.patch \
    file://support-specify-cc.patch \
    file://backport-getpcaps-fix-program-name-in-help-message.patch \
    file://backport-Stop-using-_pam_overwrite-in-pam_cap.c.patch \
"

S = "${WORKDIR}/${BP}"

# license file is updated
LIC_FILES_CHKSUM:remove = "file://License;md5=e2370ba375efe9e1a095c26d37e483b8"
LIC_FILES_CHKSUM:append = "file://LICENSE;md5=2965a646645b72ecee859b43c592dcaa"

# use cross compile objcopy
# set lib dir, not use ldd to find, maybe fail
EXTRA_OEMAKE:class-target = " \
    OBJCOPY="${OBJCOPY}" \ 
    lib="${base_libdir}" \
"

# The Go application for libcap does not currently support cross-compilation. 
# Turn it off so that it remains consistent with historical features.
export GOLANG="no"

