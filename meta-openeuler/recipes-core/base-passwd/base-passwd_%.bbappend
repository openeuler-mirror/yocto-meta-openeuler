# get extra config files from openeuler
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# remove nobash.patch, because we use /bin/bash as default SHELL
SRC_URI:remove = "https://launchpad.net/debian/+archive/primary/+files/${BPN}_${PV}.tar.gz \
"

# as it's small, base-passwd's tar.gz is integrated in openEuler Embedded
# to avoid network download
SRC_URI:prepend = " file://${BPN}_${PV}.tar.gz "

SRC_URI:append = " file://revert_nobash.patch "

SYSROOT_DIRS += "${localstatedir}"

PACKAGES =+ "${PN}-var"

# This is the baseline of openEuler Embedded, modified according to the security configuration. 
# Currently, except for the rollback of the nobash patch configuration, the configuration is 
# consistent with poky 4.
# --------------------------------------------------------------------------------------------
#  root::0:0:root:/root:/bin/bash
#  daemon:*:1:1:daemon:/usr/sbin:/sbin/nologin
#  bin:*:2:2:bin:/bin:/sbin/nologin
#  sys:*:3:3:sys:/dev:/sbin/nologin
#  sync:*:4:65534:sync:/bin:/bin/sync
#  games:*:5:60:games:/usr/games:/sbin/nologin
#  man:*:6:12:man:/var/cache/man:/sbin/nologin
#  lp:*:7:7:lp:/var/spool/lpd:/sbin/nologin
#  mail:*:8:8:mail:/var/mail:/sbin/nologin
#  news:*:9:9:news:/var/spool/news:/sbin/nologin
#  uucp:*:10:10:uucp:/var/spool/uucp:/sbin/nologin
#  proxy:*:13:13:proxy:/bin:/sbin/nologin
#  www-data:*:33:33:www-data:/var/www:/sbin/nologin
#  backup:*:34:34:backup:/var/backups:/sbin/nologin
#  list:*:38:38:Mailing List Manager:/var/list:/sbin/nologin
#  irc:*:39:39:ircd:/var/run/ircd:/sbin/nologin
#  gnats:*:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/sbin/nologin
#  nobody:*:65534:65534:nobody:/nonexistent:/sbin/nologin

