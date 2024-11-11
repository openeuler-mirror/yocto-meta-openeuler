# main bb file: meta/recipes-extended/tcp-wrappers/tcp-wrappers_7.6.bb
# openeuler's tcp-wrapper (https://gitee.com/src-openeuler/tcp_wrappers)
# is the version supporting ipv6, different with poky's one

inherit oee-archive

# upstream src and patches
SRC_URI:prepend = " \
            file://tcp_wrappers_${PV}.tar.gz  \
           "
