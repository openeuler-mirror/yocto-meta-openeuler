# This file should be included in openeuler-image.bbappend, openeuler-image-ros.bbappend, etc.
# diff from ${MACHINE}.inc, it shoud not includ by live image

require recipes-core/images/bsp-${MACHINE}.inc

# all 3403 app and tools
IMAGE_INSTALL += " \
wpa-supplicant \
v4l-utils \
hostapd \
hibot-user-driver \
bluez5 \
${@bb.utils.contains("DISTRO_FEATURES", "ros", " \
ai-demolib \
mipi-ffmpeglib \
object-node \
gst-node \
pose-srv-node \
robot-det-node \
robot-localization \
joint-state-publisher \
astra-camera-msgs \
astra-camera-raw \
depth-image \
fitxxx \
imu-calib \
lsm10-v2 \
serial-imu \
sllidar-ros2 \
wr-ls-udp \
ydlidar-ros2-driver \
frame-relationship \
hirobot-cartographer \
costmap-converter \
costmap-converter-msgs \
teb-local-planner \
teb-msgs \
barcode-interface \
barcode-node \
camera \
mipi-camera \
zxing \
astra-camera \
dsp-bin \
depth-mini-seg \
get-pose-msg \
hirobot-base \
hirobot-bringup \
hirobot-depth-camera \
hirobot-description \
hirobot-get-goal-clear \
hirobot-goal-process \
hirobot-msgs \
hirobot-navigation2-teb \
hirobot-tof-plane-seg \
person-position-ack \
robot-charge-control \
robot-init-pose \
robot-bringup \
ros2-wheeltec-robot \
serial \
device-sample \
depth-image-proc \
depthimage-to-laserscan \
dtof-client-node \
dtof-node \
hirobot-description \
", "", d)}"


