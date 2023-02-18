# apply openeuler source package
PV = "3.0.11"

SRC_URI = "\
    file://${BP}.tar.gz \
    file://libical-bugfix-timeout-found-by-fuzzer.patch \
"
