#main bbfile: yocto-poky/meta/recipes-core/packagegroups/packagegroup-core-tools-debug.bb

# remove mtrace which openeuler not support current.
RDEPENDS:${PN}:remove =  " \
    ${MTRACE} \
"
