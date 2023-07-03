# main bb file: yocto-poky/meta/recipes-support/libevdev/libevent_2.1.12.bb

SRC_URI:append = "\
    file://libevent-nonettests.patch \
    file://http-add-callback-to-allow-server-to-decline-and-the.patch \
    file://add-testcases-for-event.c-apis.patch \
    file://0001-Revert-Fix-checking-return-value-of-the-evdns_base_r.patch \
"
