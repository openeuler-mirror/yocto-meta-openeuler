# baseline: yocto-meta-openeuler/meta-openeuler/recipes-connectivity/wpa-supplicant/wpa-supplicant_%.bbappend 

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# apply source package in openeuler
SRC_URI:prepend = " \
	file://patch-wpa_supplicant-for-wifi.patch \
"

# patch for wifi
do_configure:append() {
    pushd ${S}/wpa_supplicant
    cp defconfig .config
    sed -i "s/CONFIG_CTRL_IFACE_DBUS_NEW=y/#CONFIG_CTRL_IFACE_DBUS_NEW=y/g" .config
    sed -i "s/CONFIG_CTRL_IFACE_DBUS_INTRO=y/#CONFIG_CTRL_IFACE_DBUS_INTRO=y/g" .config
    sed -i "s/#CONFIG_IEEE80211AX=y/CONFIG_IEEE80211AX=y/g" .config
    sed -i "s/#CONNECTIVITY_SET_P2P_IE_PATCH=y/CONNECTIVITY_SET_P2P_IE_PATCH=y/g" .config
    sed -i "s/#CONNECTIVITY_SINGLE_VAP_PATCH=y/CONNECTIVITY_SINGLE_VAP_PATCH=y/g" .config
    sed -i "s/#CONNECTIVITY_LOG_PATCH=y/CONNECTIVITY_LOG_PATCH=y/g" .config
    sed -i "s/#CONFIG_WEP=y/CONFIG_WEP=y/g" .config
    sed -i "s/#CONFIG_OWE=y/CONFIG_OWE=y/g" .config
    sed -i "s/#CONFIG_ROAM_EXTRA_SUPPORT=y/CONFIG_ROAM_EXTRA_SUPPORT=y/g" .config
    popd
}

