OPENEULER_REPO_NAME = "wpa_supplicant"

# version in openEuler
PV = "2.10"

# apply source package in openeuler
SRC_URI:remove = "http://w1.fi/releases/wpa_supplicant-${PV}.tar.gz  \
file://0001-replace-systemd-install-Alias-with-WantedBy.patch \
file://0001-AP-Silently-ignore-management-frame-from-unexpected-.patch \
file://0001-WPS-UPnP-Do-not-allow-event-subscriptions-with-URLs-.patch \
file://0002-WPS-UPnP-Fix-event-message-generation-using-a-long-U.patch \
file://0003-WPS-UPnP-Handle-HTTP-initiation-failures-for-events-.patch \
file://CVE-2021-0326.patch \
file://CVE-2021-27803.patch \
file://CVE-2021-30004.patch \
"

SRC_URI:prepend = "file://wpa_supplicant-${PV}.tar.gz \
"

# checksum changed
LIC_FILES_CHKSUM = "file://COPYING;md5=5ebcb90236d1ad640558c3d3cd3035df \
                    file://README;beginline=1;endline=56;md5=e3d2f6c2948991e37c1ca4960de84747 \
                    file://wpa_supplicant/wpa_supplicant.c;beginline=1;endline=12;md5=76306a95306fee9a976b0ac1be70f705"
