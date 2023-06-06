# main bb yocto-poky/meta/recipes-support/libical/libical_3.0.9.bb

# todo: The new version has some bbclass introductions and cmake changes, not clear the usefulness, and
# improve the BB file later

# apply openeuler source package
PV = "3.0.11"

SRC_URI = "\
    file://${BP}.tar.gz \
    file://libical-bugfix-timeout-found-by-fuzzer.patch \
"
