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
        local repo="$(echo $line| awk '{print $1}')"
        local localpath="$(basename ${repo} | sed "s|\.git$||")"
        echo "    <project name=\"${repo}.git\" path=\"${localpath}\" revision=\"${revision=}\" groups=\"openeuler\">" >> "${SRC_DIR}"/manifest.xml
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
    [[ -z "${realdir}" ]] || pkg="$(basename ${realdir})"
    [[ "${pkg}" == "kernel-5.10" ]] && local git_param="--depth 1"
    pushd "${SRC_DIR}"
    test -d ./"${pkg}"/.git || { rm -rf ./"${pkg}";git clone "${URL_PREFIX}/${repo}" ${branch} ${git_param} -v "${pkg}"; }
    pushd ./"${pkg}"
    git checkout origin/${branchname} -b ${branchname} || echo ""
    git checkout -f ${branchname}
    git branch | grep "^*" | grep " ${branchname}$" || exit 1
    git config pull.ff only
    while true
    do
        git reset --hard HEAD^ || echo ""
        git reset --hard HEAD
        git clean -dfx
        git status | grep "Your branch is behind " || continue
        git pull
        git status | grep "is up to date with" && break
    done
    local newest_commitid="$(git log --pretty=oneline  -n1 | awk '{print $1}')"
    echo "${repo} ${newest_commitid}" >> "${SRC_DIR}"/code.list
    popd
    popd
}

download_code()
{
    rm -f "${SRC_DIR}"/code.list
    update_code_repo openeuler/yocto-meta-openeuler openEuler-21.09
    update_code_repo openeuler/kernel openEuler-21.09 kernel-5.10
    update_code_repo src-openeuler/kernel openEuler-21.09 src-kernel-5.10
    update_code_repo src-openeuler/busybox openEuler-22.03-LTS-Next
    update_code_repo openeuler/yocto-embedded-tools openEuler-21.09
    update_code_repo openeuler/yocto-poky openEuler-21.09
    update_code_repo src-openeuler/yocto-pseudo openEuler-21.09
    update_code_repo src-openeuler/audit openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/cracklib openEuler-21.09
    update_code_repo src-openeuler/libcap-ng openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libpwquality openEuler-21.09
    update_code_repo src-openeuler/openssh openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/openssl openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/pam openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/shadow openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/ncurses openEuler-21.09
    update_code_repo src-openeuler/bash openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libtirpc openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/grep openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/pcre openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/less openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/gzip openEuler-22.03-LTS-Next 
    update_code_repo src-openeuler/xz openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/bzip2 openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/sed openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/json-c openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/ethtool openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/expat openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/acl openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/attr openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/readline openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libaio openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libffi openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/popt openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/binutils openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/elfutils openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/kexec-tools openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/psmisc openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/squashfs-tools openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/strace openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/util-linux openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libsepol openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libselinux openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libsemanage openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/policycoreutils openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/initscripts openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libestr openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libfastjson openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/logrotate openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/rsyslog openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/cifs-utils openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/dosfstools openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/e2fsprogs openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/iproute openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/iptables openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/bind openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/dhcp openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libhugetlbfs openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libnl3 openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libpcap openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/nfs-utils openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/rpcbind openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/cronie openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/kmod openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/kpatch openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libusbx openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/libxml2 openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/lvm2 openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/quota openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/pciutils openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/procps-ng openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/tzdata openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/glib2 openEuler-22.03-LTS-Next
    update_code_repo src-openeuler/raspberrypi-firmware openEuler-22.03-LTS-Next
}

download_iSulad_code()
{
   update_code_repo src-openeuler/zlib openEuler-21.09
   update_code_repo src-openeuler/libcap openEuler-22.03-LTS-Next
   update_code_repo src-openeuler/yajl openEuler-21.09
   update_code_repo src-openeuler/libseccomp openEuler-22.03-LTS-Next
   update_code_repo src-openeuler/curl openEuler-22.03-LTS-Next
   update_code_repo src-openeuler/lxc openEuler-21.09
   update_code_repo src-openeuler/lcr openEuler-21.09
   update_code_repo src-openeuler/clibcni openEuler-21.09
   update_code_repo src-openeuler/libarchive openEuler-22.03-LTS-Next
   update_code_repo src-openeuler/libevent openEuler-21.09
   update_code_repo src-openeuler/libevhtp openEuler-21.09
   update_code_repo src-openeuler/http-parser openEuler-21.09
   update_code_repo src-openeuler/libwebsockets openEuler-22.03-LTS-Next
   update_code_repo src-openeuler/iSulad openEuler-21.09
}

usage()
{
    echo "Tip: sh $(basename "$0") [top/directory/to/put/your/code]"
}


SRC_DIR="$1"
if [[ -z "${SRC_DIR}" ]];then
    usage
    SRC_DIR="$(cd $(dirname $0)/../../;pwd)"
fi
URL_PREFIX="https://gitee.com/"
download_code
download_iSulad_code
create_manifest
