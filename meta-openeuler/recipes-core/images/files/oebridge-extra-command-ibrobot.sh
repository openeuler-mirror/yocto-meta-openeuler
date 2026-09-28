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

dnf reinstall lz4 lz4-devel -y --nogpgcheck --setopt=sslverify=0 --releasever=24.03
dnf install lttng-ust -y --nogpgcheck --setopt=sslverify=0 --releasever=24.03
# python3-lttngust is only in the oepkgs extras repo whose repodata
# download is unreliable (server truncates large files); download the
# RPM directly and install it, and pre-create the oepkgs repo config
# with enabled=0 so setup.sh's ensure_openeuler_extras_repo finds the
# file already configured and skips adding it (which would otherwise
# trigger the broken repodata download on every subsequent dnf call)
curl -sL -o /tmp/python3-lttngust.rpm \
    "https://repo.oepkgs.net/openeuler/rpm/openEuler-24.03-LTS/extras/aarch64/Packages/p/python3-lttngust-2.13.3-2.aarch64.rpm" \
    && rpm -ivh --nodeps /tmp/python3-lttngust.rpm \
    && rm -f /tmp/python3-lttngust.rpm
cat > /etc/yum.repos.d/oepkgs-extras.repo << 'REPO'
[oepkgs-extras]
name=oepkgs-extras
baseurl=https://repo.oepkgs.net/openeuler/rpm/openEuler-24.03-LTS/extras/aarch64/
enabled=0
gpgcheck=0
REPO
git clone -b 26.09.001 --single-branch  --depth 1 https://atomgit.com/openeuler/IB_Robot.git
cd IB_Robot/
git config --global http.sslVerify false
./scripts/setup.sh -y
