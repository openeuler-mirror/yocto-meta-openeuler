
PV = "1.1.13"

# since all software packages exist in manifest.yaml will be automatically
# removed by OPENEULER_SRC_URI_REMOVE
# we need to manually add src uri from openEuler
SRC_URI:prepend = "file://${BP}.tar.gz "

# patches from openEuler
# The following patch cannot be applied:
# file://001-Fix-Invalid-Suffix_pbzip2.patch
