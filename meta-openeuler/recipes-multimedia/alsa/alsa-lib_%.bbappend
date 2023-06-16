OPENEULER_REPO_NAME = "alsa-lib"

PV = "1.2.5.1"

SRC_URI_remove = "file://ad8c8e5503980295dd8e5e54a6285d2d7e32eb1e.patch"

SRC_URI += "file://alsa-lib-1.2.5.1-sw.patch \
"

SRC_URI[sha256sum] = "628421d950cecaf234de3f899d520c0a6923313c964ad751ffac081df331438e"
