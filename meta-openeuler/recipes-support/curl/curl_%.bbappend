# version in openEuler
PV = "8.4.0"

# files, patches that come from openeuler
# do not apply backport-0101-curl-7.32.0-multilib.patch due to failure "libcurl.pc failed sanity test"
# note that 8.x version doesn't need any patches from poky.
SRC_URI = "         file://${BP}.tar.xz         "
