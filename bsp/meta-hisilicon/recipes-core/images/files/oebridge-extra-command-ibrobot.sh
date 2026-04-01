#!/bin/bash
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
export PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
export ROS_OS_OVERRIDE=rhel:8
pip3 install rosdepc
sed -i 's/sudo //g' /usr/local/lib/python3.11/site-packages/rosdepc/rosdepc.py
git clone -b master --single-branch  --depth 1 https://atomgit.com/openeuler/IB_Robot.git
cd IB_Robot/
git config --global http.sslVerify false
./scripts/setup.sh -y --git-http --no-sudo
source .shrc_local
./scripts/build.sh
