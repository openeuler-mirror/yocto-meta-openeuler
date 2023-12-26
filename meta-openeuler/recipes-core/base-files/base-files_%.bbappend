# main bbfile yocto-poky/meta/recipes-core/base-files/base-files_3.0.14.bb
# we create this file as a layer to use openeuler's configs files
# config files use openeuler's, see base-files under this dir

FILESEXTRAPATHS_prepend := "${THISDIR}/base-files/:"

# add secure option for banner use
do_install_basefilesissue_append () {
    BANNERSTR="Authorized uses only. All activity may be monitored and reported."
    echo "${BANNERSTR}"  >> ${D}${sysconfdir}/issue.net
    echo >> ${D}${sysconfdir}/issue.net
    echo "${BANNERSTR}"  >> ${D}${sysconfdir}/issue
    echo >> ${D}${sysconfdir}/issue
}

do_install_append () {
    BANNERSTR="Authorized uses only. All activity may be monitored and reported."
    echo "${BANNERSTR}"  >> ${D}${sysconfdir}/motd
    echo >> ${D}${sysconfdir}/motd
}

# Since we have added glibc-locale support,
# which is en_US.utf8, some software will search the
# system path and use it as default locale.
# However, using this locale will have a worse performance
# than using the default POSIX locale (also known as ASCII),
# so by default we use POSIX locale.
# ******
# USERS MAY CHANGE THIS ENVIRONMENT VARIABLE TO
# ADAPT TO YOUR OWN APPLICATIONS, AS THIS VARIABLE
# IS IN THE HIGHEST PRIORITY AND WILL INFLUENCE
# THOSE APPLICATIONS WHICH USE "LANG" AS THE
# ENVIRONMENT VARIABLE TO DETERMINE WHICH
# LOCALE TO USE.
# ******
do_install_append_raspberrypi4-64 () {
    echo "export LC_ALL=C" >> ${D}${sysconfdir}/profile
}
