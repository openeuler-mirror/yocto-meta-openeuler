USER_NAME='HwHiAiUser'
SYS_USER='HwSysUser'
DM_USER='HwDmUser'
BASE_USER='HwBaseUser'
groupadd -g 1000 ${USER_NAME}
useradd -u 1000 -g ${USER_NAME} -s /bin/bash -m -d /home/${USER_NAME} ${USER_NAME}
groupadd -g 1100 ${SYS_USER}
useradd -u 1100 -g ${SYS_USER} -s /sbin/nologin ${SYS_USER}
groupadd -g 1101 ${DM_USER}
useradd -u 1101 -g ${DM_USER} -s /sbin/nologin ${DM_USER}
groupadd -g 1102 ${BASE_USER}
useradd -u 1102 -g ${BASE_USER} -s /sbin/nologin ${BASE_USER}
usermod -aG ${BASE_USER} ${DM_USER}
usermod -aG ${BASE_USER} ${USER_NAME}
usermod -aG ${USER_NAME} ${DM_USER}
usermod -aG ${DM_USER} ${USER_NAME}
usermod -aG ${USER_NAME} ${BASE_USER}
mkdir -p /usr/local/Ascend/
chmod 755 /usr/local
chmod 755 /usr/local/Ascend/
