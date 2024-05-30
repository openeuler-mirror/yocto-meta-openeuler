SUMMARY = "packagegroup of dsoftbus"
PR = "r1"
inherit packagegroup

RDEPENDS:packagegroup-dsoftbus = " \
"

RDEPENDS:packagegroup-dsoftbus:append:aarch64 = " \
hilog \
c-utils \
distributed-beget \
eventhandler \
binder \
ipc \
samgr \
safwk \
huks \
device-auth \
communication-dsoftbus \
"
