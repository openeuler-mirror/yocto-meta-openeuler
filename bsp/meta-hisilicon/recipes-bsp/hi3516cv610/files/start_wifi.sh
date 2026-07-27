#!/bin/sh

mountpoint -q /proc 2>/dev/null || mount -t proc proc /proc
mountpoint -q /sys 2>/dev/null || mount -t sysfs sysfs /sys
mountpoint -q /dev 2>/dev/null || mount -t devtmpfs devtmpfs /dev 2>/dev/null

if [ ! -e /proc/10300000.usb20drd/mode ]; then
    /ko/load3516cv610_20s_openEuler -i -sensor0 sc4336p 2>/dev/null
    sleep 2
fi

killall wpa_supplicant 2>/dev/null
rmmod wifi_soc 2>/dev/null
rmmod plat_soc 2>/dev/null
sleep 0.5

echo host > /proc/10300000.usb20drd/mode
sleep 1

echo 60 > /sys/class/gpio/export 2>/dev/null
echo out > /sys/class/gpio/gpio60/direction
echo 0 > /sys/class/gpio/gpio60/value
sleep 0.5
echo 1 > /sys/class/gpio/gpio60/value
sleep 1

insmod /ko/wifi/plat_soc.ko
sleep 0.5
insmod /ko/wifi/wifi_soc.ko
sleep 1

wpa_supplicant -B -iwlan0 -c/etc/Wireless/wpa_supplicant.conf
sleep 2

udhcpc -i wlan0
