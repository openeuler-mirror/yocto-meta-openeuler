
PV = "0.25.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

SRC_URI:prepend = "file://${BP}.tar.xz \
           file://backport-Fix-probing-of-C_GetInterface.patch \
           "

# patches from upstream, fix meson.build error
SRC_URI:append = " \
           file://strerror-1.patch \
           file://strerror-2.patch"

S = "${WORKDIR}/${BP}"

# keep same as upstream
BBCLASSEXTEND += " native"


### openeuler configuration
# from the document of unix, https://www.unix.com/man-page/centos/8/UPDATE-CA-TRUST/
# we can know that the update-ca-trust script
# of ca-certificates package will search for the trusted certificates
# from /etc/pki/ca-trust/source and /usr/share/pki/ca-trust-source by default.
# Also, the ca-certificates package will install the trusted certificates
# to /usr/share/pki/ca-trust-source.
# User may change the p11-kit trust paths configuration to add more paths,
# but if we do not include the path /usr/share/pki/ca-trust-source,
# the trusted certificates installed by ca-certificates package will not be found.
EXTRA_OEMESON += "-Dtrust_paths=/etc/pki/ca-trust/source:/usr/share/pki/ca-trust-source"
