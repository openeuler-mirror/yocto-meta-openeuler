PV = "0.185"

# add patches from openeuler
SRC_URI += " \
    file://eu-elfclassify-no-stdin-should-use-classify_flag_no_stdin.patch \
"

SRC_URI[sha256sum] = "dc8d3e74ab209465e7f568e1b3bb9a5a142f8656e2b57d10049a73da2ae6b5a6"

# delete conflict patches from poky
SRC_URI_remove += " \
           file://0001-add-support-for-ipkg-to-debuginfod.cxx.patch \
"
