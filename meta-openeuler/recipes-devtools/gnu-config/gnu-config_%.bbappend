
inherit oee-archive

PV = "20211108"

SRC_URI:prepend = "file://${BP}.tar.gz \
"

# Override LIC_FILES_CHKSUM to match local 20211108 tarball
LIC_FILES_CHKSUM = "file://config.guess;beginline=9;endline=29;md5=b75d42f59f706ea56d6a8e00216fca6a"
