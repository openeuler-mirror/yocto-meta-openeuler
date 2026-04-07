DESCRIPTION = "Some pre-compiled ko and initscripts for hieulerpi1"
SECTION = "base"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "update-rc.d-native"
DEPENDS += " ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'hieulerpi1-sdk-pkg', '', d)} "
do_fetch[depends] += "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'hieulerpi1-sdk-pkg:do_deploy', '', d)}"

OPENEULER_LOCAL_NAME = "HiEuler-driver"

RT_SUFFIX = "${@bb.utils.contains('DISTRO_FEATURES', 'preempt-rt', '-rt', '', d)}"

SRC_URI = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://${DEPLOY_DIR}/third_party_sdk/ko.tar.gz \
    ', ' \
        file://HiEuler-driver/drivers/ko${RT_SUFFIX}.tar.gz \ 
        file://HiEuler-driver/drivers/ko-extra.tar.gz \
        file://HiEuler-driver/drivers/ws73.tar.gz \
    ', d)} \
        file://HiEuler-driver/drivers/btools \
        file://HiEuler-driver/drivers/S90AutoRun \
        file://HiEuler-driver/drivers/pinmux.sh \
        file://HiEuler-driver/drivers/env.tar.gz \
        file://HiEuler-driver/drivers/can-tools.tar.gz \
        file://HiEuler-driver/drivers/sparklink-tools.tar.gz \
        file://HiEuler-driver/mcu \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', ' file://hieulerpi1-bsp.service file://hieulerpi1-fb.service ', '', d)} \
"

S = "${WORKDIR}/HiEuler-driver/drivers"

INSANE_SKIP:${PN} += "already-stripped"
FILES:${PN} = "${sysconfdir} ${systemd_system_unitdir} /usr/bin /ko /opt /vendor /firmware"

do_install () {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'true', 'false', d)}; then
        install -d ${D}/opt
        cp -r ${WORKDIR}/ko ${D}/opt
        sed -i 's|/dev/mmcblk0p2\s*0x00000\s*0x100000|/dev/mmcblk0p2\t\t0x00000\t\t0x40000|' ${WORKDIR}/env/fw_env.config
        install -d ${D}${sysconfdir}/rcS.d
        touch ${D}${sysconfdir}/rcS.d/S02initfs ${D}${sysconfdir}/rcS.d/S80network
        chmod 777 ${D}${sysconfdir}/rcS.d/S02initfs ${D}${sysconfdir}/rcS.d/S80network
		cat > ${D}${sysconfdir}/rcS.d/S02initfs <<-'EOF'
		#!/bin/sh

		RESIZE_DONE_FLAG="/etc/.resize2fs_done"
		if [ ! -f "$RESIZE_DONE_FLAG" ]; then
		    root=$(grep -o 'root=[^ ]*' /proc/cmdline | cut -d= -f2)
		    if /sbin/resize2fs "$root"; then
		        touch "$RESIZE_DONE_FLAG"
		    fi
		fi
		EOF

		cat > "${D}${sysconfdir}/rcS.d/S80network" <<-'EOF'
		#!/bin/sh

		cat > /etc/resolv.conf << 'EORESOLV'
		nameserver 8.8.8.8
		nameserver 114.114.114.114
		nameserver 2001:4860:4860::8888
		nameserver 2001:4860:4860::8844
		EORESOLV

		ipaddr=192.168.1.168
		bootp=
		gateway=192.168.1.1
		netmask=255.255.255.0
		hostname=
		netdev=eth0
		autoconf=

		for ipinfo in `cat /proc/cmdline`
		do
		        case "$ipinfo" in
		        ip=*)
		                for var in ipaddr bootp gateway netmask hostname netdev autoconf
		                do
		                        eval read $var
		                done << EOC
		                $(echo "$ipinfo" | sed "s/:/\n/g" | sed "s/^[    ]*$/-/g" | sed 's/ip=//')
		EOC
		                ipaddr=`echo "$ipaddr" | cut -d = -f 2`
		                [ x$ipaddr == x ] && ipaddr=x
		                ;;
		        esac
		done

		[ -z "$ipaddr" ] && exit 0

		echo "      IP: $ipaddr"
		echo "   BOOTP: $bootp"
		echo " GATEWAY: $gateway"
		echo " NETMASK: $netmask"
		echo "HOSTNAME: $hostname"
		echo "  NETDEV: $netdev"
		echo "AUTOCONF: $autoconf"

		if [ x$ipaddr == x- ] ; then
		        # use DHCP
		        :
		else
		        cmd="ifconfig $netdev $ipaddr"
		        [ x$netmask != x- ] && cmd="$cmd netmask $netmask"
		        eval $cmd
		        [ x$gateway != x- ] && route add default gw $gateway
		fi

		ifconfig lo 127.0.0.1

		EOF

		cat > ${S}/pinmux.sh <<-'EOF'
		#!/bin/sh

		export LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH

		# USRT3_RX
		bspmm 0x0102F012C 0x1201 > /dev/null
		# USRT3_TX
		bspmm 0x0102F0130 0x1201 > /dev/null

		# USRT4_RX
		bspmm 0x0102F0134 0x1201 > /dev/null
		# USRT4_TX
		bspmm 0x0102F0138 0x1201 > /dev/null

		# SPI0_SCLK
		bspmm 0x0102F01D8 0x1201 > /dev/null
		# SPI0_SDO
		bspmm 0x0102F01DC 0x1201 > /dev/null
		# SPI0_SDI
		bspmm 0x0102F01E0 0x1201 > /dev/null
		# SPI0_CSN
		bspmm 0x0102F01E4 0x1201 > /dev/null
		# SYS_RSTN
		bspmm 0x0102F0114 0x1201 > /dev/null
		# CAN_INT
		bspmm 0x0102F0030 0x1200 > /dev/null

		# I2C6_SDA  GPIO1_6
		bspmm 0x010230038 0x1200 > /dev/null
		# I2C6_SCL  GPIO1_7
		bspmm 0x01023003C 0x1200 > /dev/null
		# I2C7_SDA  GPIO2_0
		bspmm 0x010230040 0x1200 > /dev/null
		# I2C7_SCL  GPIO2_2
		bspmm 0x010230048 0x1200 > /dev/null

		# PWM0_OUT1_0_P
		bspmm 0x0102F01EC 0x1201 > /dev/null
		# PWM0_OUT15_0_P
		bspmm 0x0102F00DC 0x1205 > /dev/null

		# LSADC_CH3
		bspmm 0x0102F00FC 0x1200 > /dev/null
		EOF
    else
        cp -r ${WORKDIR}/ko ${D}/
        install -d ${D}${sysconfdir}/ws73
        cp ${WORKDIR}/ws73/firmware/* ${D}${sysconfdir}/ws73/
        cp ${WORKDIR}/ws73/ko/* ${D}/ko/
        cp ${WORKDIR}/ws73/config/* ${D}${sysconfdir}/
    fi

    install -d ${D}/usr/bin
    install -d ${D}/firmware
    install -d ${D}${sysconfdir}/init.d
    install -d ${D}${sysconfdir}/rc5.d

    install -m 0755 ${WORKDIR}/HiEuler-driver/drivers/btools ${D}/usr/bin/
    ln -s /usr/bin/btools ${D}/usr/bin/bspmm
    ln -s /usr/bin/btools ${D}/usr/bin/bspmd.l
    ln -s /usr/bin/btools ${D}/usr/bin/i2c_read
    ln -s /usr/bin/btools ${D}/usr/bin/i2c_write
    if [ -e ${WORKDIR}/ko-extra/pre_vo ];then
        install -m 0755 ${WORKDIR}/ko-extra/pre_vo ${D}/usr/bin/
    fi

    if [ -e ${WORKDIR}/ko-extra/ch343.ko ];then
        cp -f ${WORKDIR}/ko-extra/ch343.ko ${D}/ko
    fi

    #for mipi, use load_ss928v100 from ko-extra
    if [ -e ${WORKDIR}/ko-extra/load_ss928v100 ];then
        cp -f ${WORKDIR}/ko-extra/load_ss928v100 ${D}/ko
        # optimize awk format which may not recognized
        sed -i 's/\$1\/1024\/1024/strtonum(\$1)\/1024\/1024/' ${D}/ko/load_ss928v100*
        chmod 755 ${D}/ko/load_ss928v100
    fi

    # install wifi-1102a firmware
    if [ -e ${WORKDIR}/wifi-1102a-tools ];then
        cp -f ${WORKDIR}/wifi-1102a-tools/plat.ko ${D}/ko
        cp -f ${WORKDIR}/wifi-1102a-tools/wifi.ko ${D}/ko
        install -m 0755 ${WORKDIR}/wifi-1102a-tools/start_wifi ${D}/usr/bin/
        install -d ${D}/vendor
        cp -rf ${WORKDIR}/wifi-1102a-tools/vendor/* ${D}/vendor
    fi

    install -m 0755 ${S}/S90AutoRun ${D}${sysconfdir}/init.d/
    install -m 0755 ${S}/pinmux.sh ${D}${sysconfdir}/init.d/

    # workaround for 6.6 new version, just load sdk ko, other ko need pack later
    if [ -e ${WORKDIR}/ko/load_sdk_driver ];then
        echo "#!/bin/sh" > ${D}${sysconfdir}/init.d/S90AutoRun
        echo "/opt/ko/load_sdk_driver -i" >> ${D}${sysconfdir}/init.d/S90AutoRun
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/hieulerpi1-bsp.service ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/hieulerpi1-fb.service ${D}${systemd_system_unitdir}
        if ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'true', 'false', d)}; then
            # enable auto start
            install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
            ln -sf ${systemd_system_unitdir}/hieulerpi1-bsp.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/hieulerpi1-bsp.service
            ln -sf ${systemd_system_unitdir}/hieulerpi1-fb.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/hieulerpi1-fb.service
        fi
    else
        update-rc.d -r ${D} S90AutoRun start 90 5 .
        update-rc.d -r ${D} pinmux.sh start 90 5 .
    fi

    install -m 0755 ${WORKDIR}/env/fw_env.config ${D}/etc/
    install -m 0755 ${WORKDIR}/env/fw_printenv ${D}/usr/bin/
    install -m 0755 ${WORKDIR}/env/fw_setenv ${D}/usr/bin/

    install -m 0755 ${WORKDIR}/can-tools/ip ${D}/usr/bin
    install -m 0755 ${WORKDIR}/can-tools/candump ${D}/usr/bin
    install -m 0755 ${WORKDIR}/can-tools/cansend ${D}/usr/bin

    install -m 0755 ${WORKDIR}/HiEuler-driver/mcu/load_riscv ${D}/usr/bin
    install -m 0755 ${WORKDIR}/HiEuler-driver/mcu/virt-tty ${D}/usr/bin
    install -m 0755 ${WORKDIR}/HiEuler-driver/mcu/LiteOS.bin ${D}/firmware

    install -m 0755 ${WORKDIR}/sparklink-tools/sparklinkd ${D}/usr/bin
    install -m 0755 ${WORKDIR}/sparklink-tools/sparklinkctrl ${D}/usr/bin
}

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"
