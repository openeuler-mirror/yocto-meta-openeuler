OPENEULER_REPO_NAME = "gstreamer1-plugins-base"

PV = "1.18.4"

LIC_FILES_CHKSUM = "file://COPYING;md5=6762ed442b3822387a51c92d928ead0d"

# remove outdated patch
SRC_URI_remove = "file://0004-glimagesink-Downrank-to-marginal.patch \
"

SRC_URI += " \
    file://0001-missing-plugins-Remove-the-mpegaudioversion-field.patch \
    file://gst-plugins-base-1.18.4-sw.patch \
    file://backport-xclaesse-fix-meson-0-58.patch \
    file://CVE-2023-37328.patch \
"

SRC_URI[sha256sum] = "29e53229a84d01d722f6f6db13087231cdf6113dd85c25746b9b58c3d68e8323"

PACKAGECONFIG[viv-fb] = ",,virtual/libgles2 virtual/libg2d"
