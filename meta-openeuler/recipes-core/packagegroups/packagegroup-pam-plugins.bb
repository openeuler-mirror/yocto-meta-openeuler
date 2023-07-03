SUMMARY = "libpam plugins collector"
PR = "r1"

inherit packagegroup

RDEPENDS:${PN} = "\
pam-plugin-access \
pam-plugin-debug \
pam-plugin-deny \
pam-plugin-echo \
pam-plugin-env \
pam-plugin-exec \
pam-plugin-faildelay \
pam-plugin-faillock \
pam-plugin-filter \
pam-plugin-ftp \
pam-plugin-group \
pam-plugin-issue \
pam-plugin-keyinit \
pam-plugin-lastlog \
pam-plugin-limits \
pam-plugin-listfile \
pam-plugin-localuser \
pam-plugin-loginuid \
pam-plugin-mail \
pam-plugin-mkhomedir \
pam-plugin-motd \
pam-plugin-namespace \
pam-plugin-nologin \
pam-plugin-permit \
pam-plugin-pwhistory \
pam-plugin-rhosts \
pam-plugin-rootok \
pam-plugin-securetty \
pam-plugin-setquota \
pam-plugin-shells \
pam-plugin-stress \
pam-plugin-succeed-if \
pam-plugin-time \
pam-plugin-timestamp \
pam-plugin-umask \
pam-plugin-unix \
pam-plugin-usertype \
pam-plugin-warn \
pam-plugin-wheel \
pam-plugin-xauth \
"
