# main bb: yocto-meta-openembedded/meta-oe/recipes-connectivity/hostapd/hostapd_2.10.bb

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "2.10"

S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/hostapd/${BP}.tar.gz \
	file://patch-hostapd-for-wifi.patch \
"

# patch for wifi
do_configure:append() {
	pushd ${S}/hostapd
	sed -i "s/#CONFIG_IEEE80211AX=y/CONFIG_IEEE80211AX=y/g" .config
	sed -i "s/#CONFIG_WEP=y/CONFIG_WEP=y/g" .config
	sed -i "s/#CONFIG_WPS=y/CONFIG_WPS=y/g" .config
	sed -i "s/#CONFIG_ACS=y/CONFIG_ACS=y/g" .config
	sed -i "s/#CONFIG_OWE=y/CONFIG_OWE=y/g" .config
	echo "CONFIG_SAE=y" >> .config
	popd
	echo "DRV_OBJS += ../src/drivers/driver_nl80211_android.o" >> ${S}/src/drivers/drivers.mak
}
