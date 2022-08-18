#!/bin/bash

create_manifest()
{
    cat > "${SRC_DIR}"/manifest.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<manifest>
    <remote name="gitee" fetch="https://gitee.com/" review="https://gitee.com/"/>
    <default revision="${SRC_BRANCH}" remote="gitee" sync-j="8"/>
EOF

    #add info for yocto-meta-openeuler
    pushd "${SRC_DIR}"/yocto-meta-openeuler/ >/dev/null
    #add info for yocto-meta-openeuler
    mycommitid="$(git log --pretty=oneline  -n1 | awk '{print $1}')"
    myrepo="openeuler/yocto-meta-openeuler"
    mybranch="$(git branch | grep "^* " | awk '{print $NF}')"
    git branch -a | grep "/${mybranch}$" || { mybranch="${mycommitid}"; }
    echo "${myrepo} yocto-meta-openeuler ${mycommitid} ${mybranch}" >> "${SRC_DIR}"/code.list
    popd  >/dev/null

    cat "${SRC_DIR}"/code.list | sort | uniq > "${SRC_DIR}"/code.list.sort
    while read line
    do
        local repo="$(echo $line| awk '{print $1}')"
        local localpath="$(echo $line| awk '{print $2}')"
        local revision="$(echo $line| awk '{print $3}')"
        local branchname="$(echo $line| awk '{print $4}')"
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
    local commitid="$4"
    local pkg="$(basename ${repo} | sed "s|\.git$||g")"
    local branchname="$2"
    [ -z "$branchname" ] && exit 1
    [ -z "$pkg" ] && exit 1
    #branch is also commitid,cannot clone -b <commitid>
    [[ "$branchname" == "$commitid" ]] && branch=""
    #change dir name if required
    [ -z "${realdir}" ] || pkg="$(basename ${realdir})"
    #shallow clone for linux kernel as it's too large
    [[ "${pkg}" == "kernel-5.10" ]] && local git_param="--depth 1"
    test -d "${SRC_DIR}" || mkdir -p "${SRC_DIR}"
    pushd "${SRC_DIR}"  >/dev/null
    # if git repo exits, continue, or clone the package repo
    test -d ./"${pkg}"/.git || { rm -rf ./"${pkg}";git clone "${URL_PREFIX}/${repo}" ${branch} ${git_param} -v "${pkg}"; }

    pushd ./"${pkg}"  >/dev/null
    # checkout to branch, or report failure
    git pull
    git checkout ${branchname} || { echo "ERROR: checkout ${repo} ${branchname} to ${pkg} failed";exit 1; }
    if git branch -a | grep -q "/${branchname}$";then
        git branch | grep "^*" | grep -q " ${branchname}$" || exit 1
        # pull from orgin
        git config pull.ff only
        git pull || echo "git pull failure, please check ${pkg}"
        LANG="en_US.UTF-8" LANGUAGE=eu_US:en git status | grep -Eq "is up to date with|is up-to-date with" || exit 1
    fi

    #check if checkout tag successfully
    local newest_commitid="$(git log --pretty=oneline  -n1 | awk '{print $1}')"
    if git tag -l | grep "^${branchname}$";then
        branchname="refs/tags/${branchname}"
        tagcommit=$(git show "${branchname}" | grep "^commit " | awk '{print $NF}')
        if [ "${tagcommit}" != "${newest_commitid}" ];then
            echo "${repo} ${branchname} checkout failed"
            exit 1
        fi
    fi

    if [ ! -z "$commitid" ];then
        git reset --hard "$commitid"
    fi
    #update the code list
    echo "${repo} ${pkg} ${newest_commitid} ${branchname}" >> "${SRC_DIR}"/code.list
    echo -e "===== Successfully download ${repo} ${branchname} ${newest_commitid} -> ${pkg} ...\n"
    popd  >/dev/null
    popd >/dev/null
}


download_by_manifest()
{
    while read line
    do
        echo "$line" | grep -q "<project " || continue
        local name="$(echo "$line" | grep -o " name=.*" | awk -F\" '{print $2}')"
        local localpath="$(echo "$line" | grep -o " path=.*" | awk -F\" '{print $2}')"
        local revision="$(echo "$line" | grep -o " revision=.*" | awk -F\" '{print $2}')"
        local upstream="$(echo "$line" | grep -o " upstream=.*" | awk -F\" '{print $2}')"
        if [ x"$upstream" =~ x"refs/tags/" ];then
            branch=$(echo "$upstream" | sed "s|^refs/tags/||g")
            commitid=""
        else
            branch="$upstream"
            commitid="$revision"
        fi
        update_code_repo "$name" "$branch" "$localpath" "$commitid"

    done < "${MANIFEST}"
}

download_code()
{
    # add new package here if required
    rm -f "${SRC_DIR}"/code.list
    update_code_repo openeuler/kernel ${KERNEL_BRANCH} kernel-5.10
    update_code_repo src-openeuler/kernel ${SRC_BRANCH} src-kernel-5.10
    update_code_repo src-openeuler/busybox openEuler-22.09
    # dsoftbus repos
    update_code_repo openeuler/dsoftbus_standard ${SRC_BRANCH}
    update_code_repo src-openeuler/libboundscheck openEuler-22.09
    update_code_repo openeuler/yocto-embedded-tools master
    update_code_repo openeuler/yocto-poky ${SRC_BRANCH}
    update_code_repo src-openeuler/yocto-pseudo ${SRC_BRANCH}
    update_code_repo src-openeuler/audit openEuler-22.09
    update_code_repo src-openeuler/cracklib openEuler-22.09
    update_code_repo src-openeuler/libcap-ng openEuler-22.09
    update_code_repo src-openeuler/libpwquality openEuler-22.09
    update_code_repo src-openeuler/openssh ${SRC_BRANCH}
    update_code_repo src-openeuler/libnsl2 openEuler-22.09
    update_code_repo src-openeuler/openssl openEuler-22.09
    update_code_repo src-openeuler/pam openEuler-22.09
    update_code_repo src-openeuler/shadow openEuler-22.09
    update_code_repo src-openeuler/ncurses openEuler-22.09
    update_code_repo src-openeuler/bash openEuler-22.09
    update_code_repo src-openeuler/libtirpc openEuler-22.09
    update_code_repo src-openeuler/grep openEuler-22.09
    update_code_repo src-openeuler/pcre openEuler-22.09
    update_code_repo src-openeuler/less openEuler-22.09
    update_code_repo src-openeuler/gzip openEuler-22.09
    update_code_repo src-openeuler/xz openEuler-22.09
    update_code_repo src-openeuler/lzo openEuler-22.09
    update_code_repo src-openeuler/lz4 openEuler-22.09
    update_code_repo src-openeuler/bzip2 openEuler-22.09
    update_code_repo src-openeuler/sed openEuler-22.09
    update_code_repo src-openeuler/json-c openEuler-22.09
    update_code_repo src-openeuler/ethtool openEuler-22.09
    update_code_repo src-openeuler/expat openEuler-22.09
    update_code_repo src-openeuler/acl openEuler-22.09
    update_code_repo src-openeuler/attr openEuler-22.09
    update_code_repo src-openeuler/readline openEuler-22.09 
    update_code_repo src-openeuler/libaio openEuler-22.09
    update_code_repo src-openeuler/libffi openEuler-22.09
    update_code_repo src-openeuler/popt openEuler-22.09
    update_code_repo src-openeuler/binutils openEuler-22.09
    update_code_repo src-openeuler/elfutils openEuler-22.09
    update_code_repo src-openeuler/kexec-tools openEuler-22.09
    update_code_repo src-openeuler/psmisc openEuler-22.09
    update_code_repo src-openeuler/squashfs-tools openEuler-22.09
    update_code_repo src-openeuler/strace openEuler-22.09
    update_code_repo src-openeuler/util-linux openEuler-22.09 
    update_code_repo src-openeuler/libsepol openEuler-22.09
    update_code_repo src-openeuler/libselinux openEuler-22.09
    update_code_repo src-openeuler/libsemanage openEuler-22.09
    update_code_repo src-openeuler/policycoreutils openEuler-22.09
    update_code_repo src-openeuler/initscripts openEuler-22.09
    update_code_repo src-openeuler/libestr openEuler-22.09
    update_code_repo src-openeuler/libfastjson openEuler-22.09
    update_code_repo src-openeuler/logrotate openEuler-22.09
    update_code_repo src-openeuler/rsyslog openEuler-22.09
    update_code_repo src-openeuler/cifs-utils openEuler-22.09
    update_code_repo src-openeuler/dosfstools openEuler-22.09
    update_code_repo src-openeuler/e2fsprogs openEuler-22.09
    update_code_repo src-openeuler/iproute openEuler-22.09
    update_code_repo src-openeuler/iptables openEuler-22.09
    update_code_repo src-openeuler/bind ${SRC_BRANCH}
    update_code_repo src-openeuler/dhcp openEuler-22.09
    update_code_repo src-openeuler/libhugetlbfs openEuler-22.09
    update_code_repo src-openeuler/libnl3 openEuler-22.09
    update_code_repo src-openeuler/libpcap openEuler-22.09 
    update_code_repo src-openeuler/nfs-utils openEuler-22.09
    update_code_repo src-openeuler/rpcbind openEuler-22.09
    update_code_repo src-openeuler/cronie openEuler-22.09
    update_code_repo src-openeuler/kmod openEuler-22.09
    update_code_repo src-openeuler/kpatch ${SRC_BRANCH}
    update_code_repo src-openeuler/libusbx openEuler-22.09
    update_code_repo src-openeuler/libxml2 openEuler-22.09
    update_code_repo src-openeuler/lvm2 openEuler-22.09
    update_code_repo src-openeuler/quota openEuler-22.09
    update_code_repo src-openeuler/pciutils openEuler-22.09
    update_code_repo src-openeuler/procps-ng openEuler-22.09
    update_code_repo src-openeuler/tzdata openEuler-22.09
    update_code_repo src-openeuler/glib2 openEuler-22.09 
    update_code_repo src-openeuler/raspberrypi-firmware openEuler-22.09
    update_code_repo src-openeuler/gmp openEuler-22.09
    update_code_repo src-openeuler/gdb openEuler-22.09
    update_code_repo src-openeuler/libmetal master
    update_code_repo src-openeuler/OpenAMP master
    update_code_repo src-openeuler/sysfsutils openEuler-22.09
    update_code_repo src-openeuler/tcl ${SRC_BRANCH}
    update_code_repo src-openeuler/expect openEuler-22.09
    update_code_repo src-openeuler/jitterentropy-library ${SRC_BRANCH}
    update_code_repo src-openeuler/m4 openEuler-22.09
    update_code_repo src-openeuler/gdbm openEuler-22.09
    update_code_repo src-openeuler/libtool openEuler-22.09
    update_code_repo src-openeuler/libidn2 openEuler-22.09
    update_code_repo src-openeuler/libunistring openEuler-22.09
    update_code_repo src-openeuler/gnutls openEuler-22.09
    # openeuler nettle in 22.03 is newer than 22.09, use 22.03
    update_code_repo src-openeuler/nettle openEuler-22.03-LTS
    update_code_repo src-openeuler/rng-tools openEuler-22.09
    update_code_repo src-openeuler/bash-completion openEuler-22.09
    update_code_repo src-openeuler/coreutils openEuler-22.09
    update_code_repo src-openeuler/findutils openEuler-22.09
    update_code_repo src-openeuler/gawk openEuler-22.09
    update_code_repo src-openeuler/libmnl openEuler-22.09
    update_code_repo src-openeuler/libuv openEuler-22.09
    update_code_repo src-openeuler/flex openEuler-22.09
    update_code_repo src-openeuler/sqlite openEuler-22.09
    update_code_repo src-openeuler/bison openEuler-22.09
    update_code_repo src-openeuler/perl openEuler-22.09
    update_code_repo src-openeuler/userspace-rcu openEuler-22.09
    update_code_repo src-openeuler/lttng-ust openEuler-22.09
    update_code_repo src-openeuler/libdb openEuler-22.09
    update_code_repo src-openeuler/groff openEuler-22.09
    update_code_repo src-openeuler/nasm openEuler-22.09
    update_code_repo src-openeuler/syslinux openEuler-22.09
    update_code_repo src-openeuler/cdrkit openEuler-22.09
    #current yocto-opkg-utils has no 22.09, use master
    update_code_repo src-openeuler/yocto-opkg-utils master
    update_code_repo src-openeuler/python3 openEuler-22.09
    update_code_repo src-openeuler/libgpg-error openEuler-22.09
    update_code_repo src-openeuler/libgcrypt openEuler-22.09
    update_code_repo src-openeuler/kbd openEuler-22.09
    update_code_repo src-openeuler/autoconf-archive openEuler-22.09
    update_code_repo src-openeuler/libxslt openEuler-22.09
    # using higher version, otherwise there are too many cve patches to apply.
    update_code_repo src-openeuler/dbus openEuler-22.09
    update_code_repo src-openeuler/wpa_supplicant openEuler-22.09
    update_code_repo src-openeuler/grub2 openEuler-22.09
    update_code_repo src-openeuler/parted openEuler-22.09
    update_code_repo src-openeuler/intltool openEuler-22.09
    update_code_repo src-openeuler/tar openEuler-22.09
    update_code_repo src-openeuler/perl-XML-Parser openEuler-22.09
    update_code_repo src-openeuler/systemd openEuler-22.09
    update_code_repo src-openeuler/gnu-efi openEuler-22.09
    update_code_repo src-openeuler/screen openEuler-22.09
    update_code_repo src-openeuler/pcre2 openEuler-22.09
    update_code_repo src-openeuler/mosquitto openEuler-22.09
    update_code_repo src-openeuler/uthash openEuler-22.09
    update_code_repo src-openeuler/ppp openEuler-22.09
}

# download iSulad related packages
download_iSulad_code()
{
   update_code_repo src-openeuler/zlib openEuler-22.09
   update_code_repo src-openeuler/libcap openEuler-22.09
   update_code_repo src-openeuler/yajl openEuler-22.09
   update_code_repo src-openeuler/libseccomp openEuler-22.09
   update_code_repo src-openeuler/curl openEuler-22.09
   update_code_repo src-openeuler/lxc openEuler-22.09
   update_code_repo src-openeuler/lcr openEuler-22.09
   update_code_repo src-openeuler/libarchive openEuler-22.09
   update_code_repo src-openeuler/libevent openEuler-22.09
   update_code_repo src-openeuler/libevhtp openEuler-22.09
   update_code_repo src-openeuler/http-parser openEuler-22.09
   update_code_repo src-openeuler/libwebsockets openEuler-22.09
   update_code_repo src-openeuler/iSulad openEuler-22.09
}

usage()
{
    echo -e "Tip: sh "$THIS_SCRIPT" [top/directory/to/put/your/code] [branch] <manifest path>\n"
}

check_use()
{
    if [ -n "$BASH_SOURCE" ]; then
        THIS_SCRIPT="$BASH_SOURCE"
    elif [ -n "$ZSH_NAME" ]; then
        THIS_SCRIPT="$0"
    else
        THIS_SCRIPT="$(pwd)/download_code.sh"
        if [ ! -e "$THIS_SCRIPT" ]; then
            echo "Error: $THIS_SCRIPT doesn't exist!"
            return 1
        fi
    fi

    if [ "$0" != "$THIS_SCRIPT" ]; then
        echo "Error: This script cannot be sourced. Please run as 'sh $THIS_SCRIPT'" >&2
        usage
        return 1
    fi
}

main()
{
    SRC_DIR="$1"
    # the git branch to sync, you can set branch/tag/commitid
    SRC_BRANCH="$2"
    # manifest file include the git url, revision, path info
    MANIFEST="$3"
    KERNEL_BRANCH="5.10.0-60.18.0"

    check_use || return 1
    set -e

    if [ -z "${SRC_DIR}" ];then
        SRC_DIR="$(cd $(dirname $0)/../../;pwd)"
    fi
    SRC_DIR="$(realpath ${SRC_DIR})"

    if [ -z "${SRC_BRANCH}" ];then
        # the latest release branch
        SRC_BRANCH="openEuler-22.03-LTS"
    fi
    [ -z "${KERNEL_BRANCH}" ] && KERNEL_BRANCH="${SRC_BRANCH}"

    URL_PREFIX="https://gitee.com/"
    if [ -f "${MANIFEST}" ];then
        download_by_manifest
    else
        download_iSulad_code
        download_code
        create_manifest
    fi
}

main "$@"
