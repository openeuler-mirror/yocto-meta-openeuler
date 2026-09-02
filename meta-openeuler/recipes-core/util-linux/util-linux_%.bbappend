require util-linux-common.inc

# diff from upstream 2.37.4 to 2.39.1
PACKAGECONFIG[selinux] = "--with-selinux,--without-selinux,libselinux"
RRECOMMENDS:${PN}-ptest += " kernel-module-algif-hash "
ALTERNATIVE_LINK_NAME[ipcrm] = "${bindir}/ipcrm"
ALTERNATIVE_LINK_NAME[ipcs] = "${bindir}/ipcs"

# When busybox is the init manager (mdev-busybox) or no init manager is used
# (none), the commands provided by both busybox and util-linux (mount, umount,
# dmesg, getopt, more, hwclock, ...) should resolve to the busybox applets, so
# that init scripts written for busybox applet behaviour keep working. Poky gives
# util-linux a higher default ALTERNATIVE_PRIORITY (80) than busybox (50), so
# those symlinks would otherwise point to util-linux.
# Lower util-linux below busybox here instead of raising busybox above util-linux:
# this keeps coreutils (priority 100) winning over busybox for the shared
# coreutils applets (ls, cp, date, ...), and leaves untouched both the util-linux
# tools busybox does not provide (su, lsblk, findmnt, uuidgen, ...) and the
# util-linux libraries. In the default systemd mode the priority stays 80.
ALTERNATIVE_PRIORITY = "${@bb.utils.contains_any('INIT_MANAGER', ['mdev-busybox', 'none'], '40', '80', d)}"

ASSUME_PROVIDE_PKGS = "libsmartcols libmount libblkid libfdisk util-linux"
