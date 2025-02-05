PACKAGECONFIG = "libunwind dwarf"

# add some extra PACKAGECONIFG to avoid compiler error
# for linux-kernel 6.6, pls update perf.bb to the one in yocto 5.0
PACKAGECONFIG[perl] = ",NO_LIBPERL=1,perl"
PACKAGECONFIG[bfd] = ",NO_LIBBFD=1"
PACKAGECONFIG[libtraceevent] = ",NO_LIBTRACEEVENT=1,libtraceevent"
# jevents requires host python for generating a .c file, but is
# unrelated to the python item.
PACKAGECONFIG[jevents] = ",NO_JEVENTS=1,python3-native"
PACKAGECONFIG[pfm4] = ",NO_LIBPFM4=1,libpfm4"
PACKAGECONFIG[babeltrace] = ",NO_LIBBABELTRACE=1,babeltrace"
PACKAGECONFIG[zstd] = ",NO_LIBZSTD=1,zstd"
