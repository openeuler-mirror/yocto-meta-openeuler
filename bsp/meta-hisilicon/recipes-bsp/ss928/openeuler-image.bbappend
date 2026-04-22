do_custom_install_complete:append() {
	if ${@bb.utils.contains('MACHINE', 'hieulerpi1', 'true', 'false', d)}; then
		if ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'true', 'false', d)}; then
			if ${@bb.utils.contains('DISTRO_FEATURES', 'oebridge', 'true', 'false', d)}; then
				mv ${IMAGE_ROOTFS}${sysconfdir}/rcS.d/S02initfs ${IMAGE_ROOTFS}${sysconfdir}/rc.d/init.d
				rm -rf ${IMAGE_ROOTFS}${sysconfdir}/rcS.d/S80network
				sed -i 's/Address=192.168.7.2\/24/Address=192.168.1.168\/24/' ${IMAGE_ROOTFS}${sysconfdir}/systemd/network/10-eth-static.network
				sed -i 's/Gateway=192.168.7.1/Gateway=192.168.1.1/' ${IMAGE_ROOTFS}${sysconfdir}/systemd/network/10-eth-static.network
				echo 'user-session=xfce' >> ${IMAGE_ROOTFS}${sysconfdir}/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf
				echo 'session-wrapper=/usr/bin/startxfce4' >> ${IMAGE_ROOTFS}${sysconfdir}/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf
				echo 'background=/usr/share/backgrounds/xfce/xfce-blue.jpg' >> ${IMAGE_ROOTFS}${sysconfdir}/lightdm/lightdm-gtk-greeter.conf
				sed -i 's/Requires=dbus.service/Requires=dbus.service hieulerpi1-fb.service/g' ${IMAGE_ROOTFS}/usr/lib/systemd/system/lightdm.service
				sed -i '/Type=dbus/a ExecStartPre=\/bin\/sleep 1' ${IMAGE_ROOTFS}/usr/lib/systemd/system/lightdm.service
				sed -i '/ExecStart=\/etc\/init.d\/pinmux.sh/a ExecStart=/etc/init.d/S02initfs' ${IMAGE_ROOTFS}${systemd_system_unitdir}/hieulerpi1-bsp.service
				mkdir -p ${IMAGE_ROOTFS}/root/Desktop
				cp -a ${IMAGE_ROOTFS}/usr/share/applications/pluma.desktop ${IMAGE_ROOTFS}/root/Desktop/

				cat > "${IMAGE_ROOTFS}${sysconfdir}/pam.d/lightdm" <<-'EOF'
				#%PAM-1.0
				auth    sufficient      pam_succeed_if.so user = root
				auth    required        pam_unix.so nullok

				account required        pam_unix.so
				account required        pam_permit.so

				session required        pam_unix.so
				session required        pam_loginuid.so
				EOF

				cat > "${IMAGE_ROOTFS}${sysconfdir}/lightdm/lightdm.conf.d/20-autologin.conf" <<-'EOF'
				[Seat:*]
				autologin-user=root
				autologin-user-timeout=0
				greeter-hide-users=true
				greeter-show-manual-login=false
				EOF

				cat > "${IMAGE_ROOTFS}${sysconfdir}/systemd/system/kill-xfce4-screensaver.service" <<-'EOF'
				[Unit]
				Description=Periodically check and kill xfce4-screensaver process
				After=network.target

				[Service]
				Type=simple
				# Execute script every 10 seconds (adjust sleep time as needed)
				ExecStart=/bin/bash -c "while true; do killall xfce4-screensaver -q; sleep 10; done"
				StandardOutput=journal+console
				StandardError=journal+console
				Restart=always
				RestartSec=5

				[Install]
				WantedBy=multi-user.target
				EOF

				ln -sf /lib/systemd/system/graphical.target ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/default.target
				ln -sf ${systemd_system_unitdir}/lightdm.service ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/display-manager.service
				ln -sf ${systemd_system_unitdir}/NetworkManager.service ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/multi-user.target.wants/NetworkManager.service
				ln -sf ${sysconfdir}/systemd/system/kill-xfce4-screensaver.service ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/multi-user.target.wants/kill-xfce4-screensaver.service
			fi
		fi
	fi
}
