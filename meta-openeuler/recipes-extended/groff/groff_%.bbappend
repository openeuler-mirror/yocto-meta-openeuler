# source bb file: yocto-poky/meta/recipes-extended/groff/groff_1.22.4.bb
PV = "1.22.4"

# the OPENEULER_SRC_URI_REMOVE will remove the original URL of the tarball
#  which is from upstream community if the software package exists in manifest.yaml.
# Thus, it is necessary to add the new file path of the tarball to SRC_URI
SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    "