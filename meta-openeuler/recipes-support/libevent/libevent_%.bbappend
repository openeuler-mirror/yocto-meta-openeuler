# main bb file: yocto-poky/meta/recipes-support/libevdev/libevent_2.1.12.bb

PV = "2.1.12"

SRC_URI:prepend = " \
        file://${BP}-stable.tar.gz \
        file://libevent-nonettests.patch \
        file://http-add-callback-to-allow-server-to-decline-and-the.patch \
        file://add-testcases-for-event.c-apis.patch \
        file://0001-Revert-Fix-checking-return-value-of-the-evdns_base_r.patch \
        file://backport-ssl-do-not-trigger-EOF-if-some-data-had-been-successf.patch \
        "
