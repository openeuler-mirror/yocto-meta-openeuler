OPENEULER_REPO_NAME = "wpa_supplicant"

# version in openEuler-22.03-LTS-SP2
PV = "2.6"

# apply source package in openeuler
SRC_URI_remove = "http://w1.fi/releases/wpa_supplicant-${PV}.tar.gz  \
"

SRC_URI_prepend = "file://wpa_supplicant-${PV}.tar.gz \
file://macsec-0001-mka-Move-structs-transmit-receive-_-sa-sc-to-a-commo.patch \
file://macsec-0002-mka-Pass-full-structures-down-to-macsec-drivers-pack.patch \
file://macsec-0003-mka-Pass-full-structures-down-to-macsec-drivers-tran.patch \
file://macsec-0004-mka-Pass-full-structures-down-to-macsec-drivers-rece.patch \
file://macsec-0005-mka-Pass-full-structures-down-to-macsec-drivers-tran.patch \
file://macsec-0006-mka-Pass-full-structures-down-to-macsec-drivers-rece.patch \
file://macsec-0007-mka-Add-driver-op-to-get-macsec-capabilities.patch \
file://macsec-0008-mka-Remove-channel-hacks-from-the-stack-and-the-macs.patch \
file://macsec-0009-mka-Sync-structs-definitions-with-IEEE-Std-802.1X-20.patch \
file://macsec-0010-mka-Add-support-for-removing-SAs.patch \
file://macsec-0011-mka-Implement-reference-counting-on-data_key.patch \
file://macsec-0012-mka-Fix-getting-capabilities-from-the-driver.patch \
file://macsec-0013-wpa_supplicant-Allow-pre-shared-CAK-CKN-pair-for-MKA.patch \
file://macsec-0014-mka-Disable-peer-detection-timeout-for-PSK-mode.patch \
file://macsec-0015-wpa_supplicant-Add-macsec_integ_only-setting-for-MKA.patch \
file://macsec-0016-mka-Add-enable_encrypt-op-and-call-it-from-CP-state-.patch \
file://macsec-0017-wpa_supplicant-Allow-configuring-the-MACsec-port-for.patch \
file://macsec-0018-drivers-Move-common-definitions-for-wired-drivers-ou.patch \
file://macsec-0019-drivers-Move-wired_multicast_membership-to-a-common-.patch \
file://macsec-0020-drivers-Move-driver_wired_multi-to-a-common-file.patch \
file://macsec-0021-drivers-Move-driver_wired_get_ifflags-to-a-common-fi.patch \
file://macsec-0022-drivers-Move-driver_wired_set_ifflags-to-a-common-fi.patch \
file://macsec-0023-drivers-Move-driver_wired_get_ifstatus-to-a-common-f.patch \
file://macsec-0024-drivers-Move-driver_wired_init_common-to-a-common-fi.patch \
file://macsec-0025-drivers-Move-driver_wired_deinit_common-to-a-common-.patch \
file://macsec-0026-drivers-Move-driver_wired_get_capa-to-a-common-file.patch \
file://macsec-0027-drivers-Move-driver_wired_get_bssid-to-a-common-file.patch \
file://macsec-0028-drivers-Move-driver_wired_get_ssid-to-a-common-file.patch \
file://macsec-0029-macsec_linux-Add-a-driver-for-macsec-on-Linux-kernel.patch \
file://macsec-0030-mka-Remove-references-to-macsec_qca-from-wpa_supplic.patch \
file://macsec-0031-PAE-Make-KaY-specific-details-available-via-control-.patch \
file://macsec-0032-mka-Make-MKA-actor-priority-configurable.patch \
file://macsec-0033-mka-Fix-an-incorrect-update-of-participant-to_use_sa.patch \
file://macsec-0034-mka-Some-bug-fixes-for-MACsec-in-PSK-mode.patch \
file://macsec-0035-mka-Send-MKPDUs-forever-if-mode-is-PSK.patch \
file://macsec-0036-mka-Fix-the-order-of-operations-in-secure-channel-de.patch \
file://macsec-0037-mka-Fix-use-after-free-when-receive-secure-channels-.patch \
file://macsec-0038-mka-Fix-use-after-free-when-transmit-secure-channels.patch \
file://macsec-0039-macsec_linux-Fix-NULL-pointer-dereference-on-error-c.patch \
file://rebased-v2.6-0001-hostapd-Avoid-key-reinstallation-in-FT-handshake.patch \
file://rebased-v2.6-0002-Prevent-reinstallation-of-an-already-in-use-group-ke.patch \
file://rebased-v2.6-0003-Extend-protection-of-GTK-IGTK-reinstallation-of-WNM-.patch \
file://rebased-v2.6-0004-Prevent-installation-of-an-all-zero-TK.patch \
file://rebased-v2.6-0005-Fix-PTK-rekeying-to-generate-a-new-ANonce.patch \
file://rebased-v2.6-0006-TDLS-Reject-TPK-TK-reconfiguration.patch \
file://rebased-v2.6-0007-WNM-Ignore-WNM-Sleep-Mode-Response-without-pending-r.patch \
file://rebased-v2.6-0008-FT-Do-not-allow-multiple-Reassociation-Response-fram.patch \
file://rh1451834-nl80211-Fix-race-condition-in-detecting-MAC-change.patch \
file://rh1462262-use-system-openssl-ciphers.patch \
file://rh1497640-mka-add-error-handling-for-secy_init_macsec.patch \
file://rh1497640-pae-validate-input-before-pointer.patch \
file://rh1567474-0002-D-Bus-Add-pmf-to-global-capabilities.patch \
file://rh1570903-nl80211-Fix-NL80211_ATTR_SMPS_MODE-encoding.patch \
file://CVE-2019-9496-SAE-Fix-confirm-message-validation-in-error-cases.patch \
file://CVE-2019-9494-1.patch \
file://CVE-2019-9494-2.patch \
file://CVE-2019-9494-3.patch \
file://CVE-2019-9494-4.patch \
file://CVE-2019-9494-5.patch \
file://CVE-2019-9494-6.patch \
file://CVE-2019-9494-7.patch \
file://CVE-2019-9494-8.patch \
file://CVE-2019-9497.patch \
file://CVE-2019-9498-and-CVE-2019-9499.patch \
file://CVE-2019-11555-1.patch \
file://CVE-2019-11555-2.patch \
file://rebased-v2.6-0001-WPA-Ignore-unauthenticated-encrypted-EAPOL-Key-data.patch \
file://CVE-2019-9499.patch \
file://CVE-2019-9495-pre1.patch \
file://CVE-2019-9495-pre2.patch \
file://CVE-2019-9495-pre3.patch \
file://CVE-2019-9495.patch \
file://CVE-2019-13377-1.patch \
file://CVE-2019-13377-2-pre1.patch \
file://CVE-2019-13377-2-pre.patch \
file://CVE-2019-13377-2.patch \
file://CVE-2019-13377-3.patch \
file://CVE-2019-13377-4.patch \
file://CVE-2019-13377-5.patch \
file://CVE-2019-13377-6-pre.patch \
file://CVE-2019-13377-6.patch \
file://add-options-of-wpa_supplicant-service.patch \
file://allow-to-override-names-of-qt4-tools.patch \
file://backport-Add-support-for-wolfSSL-cryptographic-library.patch \
file://backport-Share-common-SAE-and-EAP-pwd-functionality-suitable-.patch \
file://backport-0001-CVE-2022-23303-CVE-2022-23304.patch \
file://backport-0002-CVE-2022-23303-CVE-2022-23304.patch \
file://backport-0003-CVE-2022-23303-CVE-2022-23304.patch \
file://backport-0004-CVE-2022-23303-CVE-2022-23304.patch \
"

# checksum changed
LIC_FILES_CHKSUM = "file://COPYING;md5=292eece3f2ebbaa25608eed8464018a3 \
                    file://README;beginline=1;endline=56;md5=3f01d778be8f953962388307ee38ed2b \
                    file://wpa_supplicant/wpa_supplicant.c;beginline=1;endline=12;md5=4061612fc5715696134e3baf933e8aba"
