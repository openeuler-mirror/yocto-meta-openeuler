PV = "1.6.1"

SRC_URI += " \
    file://${BP}.tar.gz \
    file://bugfix-cronie-systemd-alias.patch \
"

ASSUME_PROVIDE_PKGS ="crontabs cronie"
