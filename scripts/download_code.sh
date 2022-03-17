#!/bin/bash
set -e

create_manifest()
{
    cat > "${SRC_DIR}"/manifest.xml <<EOF
<!xml version="1.0" encodeing="utf-8">
<manifest>
    <remote name="gitee" fetch="https://gitee.com/" review="https://gitee.com/"/>
    <default revision="openEuler-21.09" remote="gitee" sync-j="8"/>
EOF
    cat "${SRC_DIR}"/code.list | sort | uniq > "${SRC_DIR}"/code.list.sort
    while read line
    do
        local revision="$(echo $line| awk '{print $2}')"
        local branchname="$(echo $line| awk '{print $3}')"
        local repo="$(echo $line| awk '{print $1}')"
        local localpath="$(basename ${repo} | sed "s|\.git$||")"
        echo "    <project name=\"${repo}.git\" path=\"${localpath}\" revision=\"${revision=}\" groups=\"openeuler\" upstream=\"${branchname}\"/>" >> "${SRC_DIR}"/manifest.xml
    done < "${SRC_DIR}"/code.list.sort
    echo "</manifest>" >> "${SRC_DIR}"/manifest.xml
    rm -f "${SRC_DIR}"/code.list.sort
}

update_code_repo()
{
    local repo="$1"
    local branch="-b $2"
    local realdir="$3"
    local pkg="$(basename ${repo})"
    local branchname="$2"
    #change dir name if required
    [[ -z "${realdir}" ]] || pkg="$(basename ${realdir})"
    #shallow clone for linux kernel as it's too large
    [[ "${pkg}" == "kernel-5.10" ]] && local git_param="--depth 1"
    pushd "${SRC_DIR}"
    # if git repo exits, continue, or clone the package repo
    test -d ./"${pkg}"/.git || { rm -rf ./"${pkg}";git clone "${URL_PREFIX}/${repo}" ${branch} ${git_param} -v "${pkg}"; }
    pushd ./"${pkg}"
    # checkout to branch, or report failure
    git checkout ${branchname} || echo "git checkout failure, please check ${pkg}"
    git branch | grep "^*" | grep " ${branchname}$" || exit 1
    # pull from orgin
    git config pull.ff only
    git pull || echo "git pull failure, please check ${pkg}"
    git status | grep "is up to date with" || exit 1
    local newest_commitid="$(git log --pretty=oneline  -n1 | awk '{print $1}')"
    #update the code list
    echo "${repo} ${newest_commitid} ${branchname}" >> "${SRC_DIR}"/code.list
    popd
    popd
}

download_code()
{
    # add new package here if required
    rm -f "${SRC_DIR}"/code.list
    update_code_repo openeuler/kernel ${SRC_BRANCH_FIXED} kernel-5.10
    update_code_repo src-openeuler/kernel ${SRC_BRANCH_FIXED} src-kernel-5.10
    update_code_repo src-openeuler/busybox ${SRC_BRANCH}
    update_code_repo openeuler/yocto-embedded-tools ${SRC_BRANCH_FIXED}
    update_code_repo openeuler/yocto-poky ${SRC_BRANCH_FIXED}
    update_code_repo src-openeuler/yocto-pseudo ${SRC_BRANCH_FIXED}
    update_code_repo src-openeuler/audit ${SRC_BRANCH}
    update_code_repo src-openeuler/cracklib ${SRC_BRANCH}
    update_code_repo src-openeuler/libcap-ng ${SRC_BRANCH}
    update_code_repo src-openeuler/libpwquality ${SRC_BRANCH}
    update_code_repo src-openeuler/openssh ${SRC_BRANCH}
    update_code_repo src-openeuler/openssl ${SRC_BRANCH}
    update_code_repo src-openeuler/pam ${SRC_BRANCH}
    update_code_repo src-openeuler/shadow ${SRC_BRANCH}
    update_code_repo src-openeuler/ncurses ${SRC_BRANCH}
    update_code_repo src-openeuler/bash ${SRC_BRANCH}
    update_code_repo src-openeuler/libtirpc ${SRC_BRANCH}
    update_code_repo src-openeuler/grep ${SRC_BRANCH}
    update_code_repo src-openeuler/pcre ${SRC_BRANCH}
    update_code_repo src-openeuler/less ${SRC_BRANCH}
    update_code_repo src-openeuler/gzip ${SRC_BRANCH}
    update_code_repo src-openeuler/xz ${SRC_BRANCH}
    update_code_repo src-openeuler/bzip2 ${SRC_BRANCH}
    update_code_repo src-openeuler/sed ${SRC_BRANCH}
    update_code_repo src-openeuler/json-c ${SRC_BRANCH}
    update_code_repo src-openeuler/ethtool ${SRC_BRANCH}
    update_code_repo src-openeuler/expat ${SRC_BRANCH}
    update_code_repo src-openeuler/acl ${SRC_BRANCH}
    update_code_repo src-openeuler/attr ${SRC_BRANCH}
    update_code_repo src-openeuler/readline ${SRC_BRANCH}
    update_code_repo src-openeuler/libaio ${SRC_BRANCH}
    update_code_repo src-openeuler/libffi ${SRC_BRANCH}
    update_code_repo src-openeuler/popt ${SRC_BRANCH}
    update_code_repo src-openeuler/binutils ${SRC_BRANCH}
    update_code_repo src-openeuler/elfutils ${SRC_BRANCH}
    update_code_repo src-openeuler/kexec-tools ${SRC_BRANCH}
    update_code_repo src-openeuler/psmisc ${SRC_BRANCH}
    update_code_repo src-openeuler/squashfs-tools ${SRC_BRANCH}
    update_code_repo src-openeuler/strace ${SRC_BRANCH}
    update_code_repo src-openeuler/util-linux ${SRC_BRANCH}
    update_code_repo src-openeuler/libsepol ${SRC_BRANCH}
    update_code_repo src-openeuler/libselinux ${SRC_BRANCH}
    update_code_repo src-openeuler/libsemanage ${SRC_BRANCH}
    update_code_repo src-openeuler/policycoreutils ${SRC_BRANCH}
    update_code_repo src-openeuler/initscripts ${SRC_BRANCH}
    update_code_repo src-openeuler/libestr ${SRC_BRANCH}
    update_code_repo src-openeuler/libfastjson ${SRC_BRANCH}
    update_code_repo src-openeuler/logrotate ${SRC_BRANCH}
    update_code_repo src-openeuler/rsyslog ${SRC_BRANCH}
    update_code_repo src-openeuler/cifs-utils ${SRC_BRANCH}
    update_code_repo src-openeuler/dosfstools ${SRC_BRANCH}
    update_code_repo src-openeuler/e2fsprogs ${SRC_BRANCH}
    update_code_repo src-openeuler/iproute ${SRC_BRANCH}
    update_code_repo src-openeuler/iptables ${SRC_BRANCH}
    update_code_repo src-openeuler/bind ${SRC_BRANCH}
    update_code_repo src-openeuler/dhcp ${SRC_BRANCH}
    update_code_repo src-openeuler/libhugetlbfs ${SRC_BRANCH}
    update_code_repo src-openeuler/libnl3 ${SRC_BRANCH}
    update_code_repo src-openeuler/libpcap ${SRC_BRANCH}
    update_code_repo src-openeuler/nfs-utils ${SRC_BRANCH}
    update_code_repo src-openeuler/rpcbind ${SRC_BRANCH}
    update_code_repo src-openeuler/cronie ${SRC_BRANCH}
    update_code_repo src-openeuler/kmod ${SRC_BRANCH}
    update_code_repo src-openeuler/kpatch ${SRC_BRANCH}
    update_code_repo src-openeuler/libusbx ${SRC_BRANCH}
    update_code_repo src-openeuler/libxml2 ${SRC_BRANCH}
    update_code_repo src-openeuler/lvm2 ${SRC_BRANCH}
    update_code_repo src-openeuler/quota ${SRC_BRANCH}
    update_code_repo src-openeuler/pciutils ${SRC_BRANCH}
    update_code_repo src-openeuler/procps-ng ${SRC_BRANCH}
    update_code_repo src-openeuler/tzdata ${SRC_BRANCH}
    update_code_repo src-openeuler/glib2 ${SRC_BRANCH}
    update_code_repo src-openeuler/raspberrypi-firmware ${SRC_BRANCH}
    update_code_repo src-openeuler/gmp ${SRC_BRANCH}
    update_code_repo src-openeuler/gdb ${SRC_BRANCH}
}

# download iSulad related packages
download_iSulad_code()
{
   update_code_repo src-openeuler/zlib ${SRC_BRANCH}
   update_code_repo src-openeuler/libcap ${SRC_BRANCH}
   update_code_repo src-openeuler/yajl ${SRC_BRANCH}
   update_code_repo src-openeuler/libseccomp ${SRC_BRANCH}
   update_code_repo src-openeuler/curl ${SRC_BRANCH}
   update_code_repo src-openeuler/lxc ${SRC_BRANCH}
   update_code_repo src-openeuler/lcr ${SRC_BRANCH}
   update_code_repo src-openeuler/libarchive ${SRC_BRANCH}
   update_code_repo src-openeuler/libevent ${SRC_BRANCH}
   update_code_repo src-openeuler/libevhtp ${SRC_BRANCH}
   update_code_repo src-openeuler/http-parser ${SRC_BRANCH}
   update_code_repo src-openeuler/libwebsockets ${SRC_BRANCH}
   update_code_repo src-openeuler/iSulad ${SRC_BRANCH}
}

usage()
{
    echo "Tip: sh $(basename "$0") [top/directory/to/put/your/code] [branch]"
}

SRC_DIR="$1"
# the git branch to sync
# you can set branch/tag/commitid
SRC_BRANCH="$2"
# the fixed git branch
SRC_BRANCH_FIXED="openEuler-21.09"

if [[ -z "${SRC_DIR}" ]];then
    usage
    SRC_DIR="$(cd $(dirname $0)/../../;pwd)"
fi

if [[ -z "${SRC_BRANCH}" ]];then
    usage
    # the latest release branch
    SRC_BRANCH="openEuler-22.03-LTS"
fi

URL_PREFIX="https://gitee.com/"
download_code
download_iSulad_code
create_manifest
