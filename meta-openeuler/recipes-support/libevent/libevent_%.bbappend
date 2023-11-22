# main bbfile: yocto-poky/meta/recipes-support/libevent/libevent_2.1.12.bb

OPENEULER_SRC_URI_REMOVE = "git https http"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
    https://github.com/libevent/libevent/releases/download/release-${PV}-stable/${BP}-stable.tar.gz \
"
# files, patches that come from openeuler
SRC_URI_prepend = " \
    file://libevent-${PV}-stable.tar.gz \
    file://libevent-nonettests.patch \
    file://http-add-callback-to-allow-server-to-decline-and-the.patch \
    file://backport-ssl-do-not-trigger-EOF-if-some-data-had-been-successf.patch \
    file://backport-http-eliminate-redundant-bev-fd-manipulating-and-cac.patch \
    file://backport-http-fix-fd-leak-on-fd-reset-by-using-bufferevent_re.patch \
    file://backport-bufferevent-introduce-bufferevent_replacefd-like-set.patch \
"
