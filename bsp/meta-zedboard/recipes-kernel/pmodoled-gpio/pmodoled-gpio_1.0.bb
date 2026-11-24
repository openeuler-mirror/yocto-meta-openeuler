SUMMARY = "ZedBoard on-board OLED driver"
DESCRIPTION = "GPIOLib driver for the Digilent OLED on the ZedBoard, ported from \
Digilent's pmodoled-gpio staging driver to 5.10 (SPI bit-banged over PS EMIO GPIOs)."
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://pmodoled-gpio.c;beginline=1;endline=12;md5=9675f2c08e1b1c0c560ee070c7c8de73"

inherit module

COMPATIBLE_MACHINE = "zedboard"

SRC_URI = " \
    file://Makefile \
    file://pmodoled-gpio.c \
"

S = "${WORKDIR}"