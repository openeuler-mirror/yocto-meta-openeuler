#!/bin/bash

PATH=/sbin:/bin:/usr/sbin:/usr/bin

echo "Checking root..."
if [ "$USER" != "root" ]; then
    echo "Need root permission, abort: part resize and driver init"
    echo "The system will not work properly"
    exit 0
fi

echo "Try resize mmcblk1(filesystem root)..."
rootdev=`cat /proc/cmdline | awk '{for(i=1;i<=NF;i++) if($i ~ /^root=/) print $i}' | awk -F '=' '{print $2}'`
echo "  check if root boot from sd-card: $rootdev"
if [ "$rootdev" == "/dev/mmcblk1p1" ];then
    TTSIZE=`cat /sys/block/mmcblk1/size`
    PTSIZE=$[$TTSIZE-400]
    expect -c "spawn parted -m /dev/mmcblk1 u s resizepart 1 $PTSIZE; expect \"Yes/No?\"; send \"Yes\r\"; expect eof"
    resize2fs /dev/mmcblk1p1
fi

echo "Checking part size..."
remaining_space=$(df --block-size=M / | tail -n 1 | awk '{print int($4)}')
if [ "$remaining_space" -lt 800 ]; then
    echo "ERROR: part size is not enough for driver launch, the system will not work properly"
    echo "  Please check whether the image disk is burned correctly."
    echo "  If you are using Linux to burn, please check whether the dd command has a size description."
    exit 0
fi

echo "Init User, Please change the passwd of HwHiAiUser later."
USER_NAME="HwHiAiUser"
SYS_USER="HwSysUser"
DM_USER="HwDmUser"
BASE_USER="HwBaseUser"
username=${USER_NAME}
usergroup=${USER_NAME}
sys_user=${SYS_USER}
sys_group=${SYS_USER}
dm_user=${DM_USER}
dm_group=${DM_USER}
base_user=${BASE_USER}
base_group=${BASE_USER}
! grep -q "^${usergroup}:" /etc/group 2>/dev/null && groupadd -g 1000 ${usergroup}
! id -u ${username} >/dev/null 2>&1 && useradd -u 1000 -g ${usergroup} -m ${username} -d /home/${username} -s /bin/bash
! grep -q "^${sys_group}:" /etc/group 2>/dev/null && groupadd -g 1100 ${sys_group}
! id -u ${sys_user} >/dev/null 2>&1 && useradd -u 1100 -g ${sys_group} -s /sbin/nologin -m ${sys_user}
! grep -q "^${dm_group}:" /etc/group 2>/dev/null && groupadd -g 1101 ${dm_group}
! id -u ${dm_user} >/dev/null 2>&1 && useradd -u 1101 -g ${dm_group} -s /sbin/nologin -m ${dm_user}
! grep -q "^${base_group}:" /etc/group 2>/dev/null && groupadd -g 1102 ${base_group}
! id -u ${base_user} >/dev/null 2>&1 && useradd -u 1102 -g ${base_group} -s /sbin/nologin -m ${base_user}
usermod -aG ${base_group} ${dm_user}
usermod -aG ${base_group} ${username}
usermod -aG ${usergroup} ${dm_user}
usermod -aG ${dm_group} ${username}
usermod -aG ${usergroup} ${base_user}

sed -i '/init_once\.sh/d' /etc/profile

sync

echo "Enable bsp services"
if [ -e /lib/systemd/system/ascend-bsp.service ];then
    systemctl enable /lib/systemd/system/ascend-bsp.service
    systemctl start ascend-bsp.service
else
    update-rc.d launch3591rc.sh start 90 5 .
    bash /etc/init.d/launch3591rc.sh
fi


