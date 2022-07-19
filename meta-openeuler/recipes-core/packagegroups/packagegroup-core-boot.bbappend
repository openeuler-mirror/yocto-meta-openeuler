# we add kernel-img and kernel-vmlinux
RDEPENDS_${PN} += " \
    kernel \
    kernel-img \
    kernel-vmlinux \
    os-base \
"

# * do not use password and group files from bass-password
# * netbase's configuration files are included in os-base
#   to avoid extra download
RDEPENDS_${PN}_remove =  " \
    base-passwd \
    netbase \
"
