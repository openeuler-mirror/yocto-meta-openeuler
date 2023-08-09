# main bbfile yocto-poky/meta/recipes-core/base-files/base-files_3.0.14.bb
# we create this file as a layer to use openeuler's configs files
# config files use openeuler's, see base-files under this dir

FILESEXTRAPATHS:prepend := "${THISDIR}/base-files/:"

# add secure option for banner use
do_install_basefilesissue:append () {
    BANNERSTR="Authorized uses only. All activity may be monitored and reported."
    echo "${BANNERSTR}"  >> ${D}${sysconfdir}/issue.net
    echo >> ${D}${sysconfdir}/issue.net
    echo "${BANNERSTR}"  >> ${D}${sysconfdir}/issue
    echo >> ${D}${sysconfdir}/issue
}

do_install:append () {
    BANNERSTR="Authorized uses only. All activity may be monitored and reported."
    echo "${BANNERSTR}"  >> ${D}${sysconfdir}/motd
    echo >> ${D}${sysconfdir}/motd
}
