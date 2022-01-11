SUMMARY = "SELinux library and simple utilities"
DESCRIPTION = "libselinux provides an API for SELinux applications to get and set \
process and file security contexts and to obtain security policy \
decisions.  Required for any applications that use the SELinux API."
SECTION = "base"
LICENSE = "PD"

inherit lib_package

DEPENDS += "libsepol libpcre"

def get_policyconfigarch(d):
    import re
    target = d.getVar('TARGET_ARCH', True)
    p = re.compile('i.86')
    target = p.sub('i386',target)
    return "ARCH=%s" % (target)
EXTRA_OEMAKE += "${@get_policyconfigarch(d)}"

EXTRA_OEMAKE += "LDFLAGS='${LDFLAGS} -lpcre ' CFLAGS=' ${CFLAGS} -DNO_ANDROID_BACKEND'"

BBCLASSEXTEND = "native"
