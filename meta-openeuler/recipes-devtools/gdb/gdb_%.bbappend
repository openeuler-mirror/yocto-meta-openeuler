# main bbfile: yocto-poky/meta/recipes-devtools/gdb/gdb_11.2.bb
# ref: http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-devtools/gdb/gdb_12.1.bb?id=8d42315c074a97

require gdb-src.inc

# keep same with upstream
DEPENDS += "mpfr"
