INSTALLMODULES = " \
${@bb.utils.contains('DISTRO_FEATURES', 'isulad', 'kernel-module-overlay', '', d)} \
kernel-module-8021q \
kernel-module-ext2 \
kernel-module-inet-diag \
kernel-module-ip-tunnel \
kernel-module-ip6-udp-tunnel \
kernel-module-ipip \
kernel-module-ipt-reject \
kernel-module-ipv6 \
kernel-module-nf-defrag-ipv6 \
kernel-module-nf-nat \
kernel-module-nf-reject-ipv4 \
kernel-module-nf-reject-ipv6 \
kernel-module-xt-tcpudp \
kernel-module-tunnel4 \
kernel-module-af-packet \
${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '', 'kernel-module-nfs-ssc', d)} \
kernel-module-fscache \
kernel-module-grace \
kernel-module-sunrpc \
kernel-module-auth-rpcgss \
kernel-module-lockd \
kernel-module-nfs-acl \
kernel-module-nfs \
kernel-module-nfsv3 \
kernel-module-nfsd \
kernel-module-crc-ccitt \
kernel-module-ip6table-nat \
kernel-module-ip6t-reject \
kernel-module-xt-nat \
"
