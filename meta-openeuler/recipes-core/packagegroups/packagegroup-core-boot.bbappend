# we add kernel-img and kernel-vmlinux
RDEPENDS_${PN} += " \
    kernel \
    kernel-img \
    kernel-vmlinux \
    os-base \
"

# * netbase's configuration files are included in os-base
#   to avoid extra download
RDEPENDS_${PN}_remove =  " \
    netbase \
"
