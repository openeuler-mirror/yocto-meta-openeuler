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
do_install:append () {
    echo "export LC_ALL=C" >> ${D}${sysconfdir}/profile
}

