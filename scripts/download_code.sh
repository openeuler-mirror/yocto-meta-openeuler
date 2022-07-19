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
    update_code_repo src-openeuler/busybox ${SRC_BRANCH}
    update_code_repo openeuler/yocto-embedded-tools ${SRC_BRANCH}
    update_code_repo openeuler/yocto-poky ${SRC_BRANCH}
    update_code_repo src-openeuler/yocto-pseudo ${SRC_BRANCH}
    update_code_repo src-openeuler/audit ${SRC_BRANCH}
    update_code_repo src-openeuler/cracklib ${SRC_BRANCH}
    update_code_repo src-openeuler/libcap-ng ${SRC_BRANCH}
    update_code_repo src-openeuler/libpwquality ${SRC_BRANCH}
    update_code_repo src-openeuler/openssh ${SRC_BRANCH}
    update_code_repo src-openeuler/libnsl2 ${SRC_BRANCH}
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
    update_code_repo src-openeuler/lzo ${SRC_BRANCH}
    update_code_repo src-openeuler/lz4 ${SRC_BRANCH}
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
    update_code_repo src-openeuler/libmetal ${SRC_BRANCH}
    update_code_repo src-openeuler/OpenAMP ${SRC_BRANCH}
    update_code_repo src-openeuler/sysfsutils ${SRC_BRANCH}
    update_code_repo src-openeuler/tcl ${SRC_BRANCH}
    update_code_repo src-openeuler/expect ${SRC_BRANCH}
    update_code_repo src-openeuler/jitterentropy-library ${SRC_BRANCH}
    update_code_repo src-openeuler/libtool ${SRC_BRANCH}
    update_code_repo src-openeuler/libidn2 ${SRC_BRANCH}
    update_code_repo src-openeuler/libunistring ${SRC_BRANCH}
    update_code_repo src-openeuler/gnutls ${SRC_BRANCH}
    update_code_repo src-openeuler/nettle ${SRC_BRANCH}
    update_code_repo src-openeuler/rng-tools ${SRC_BRANCH}
    update_code_repo src-openeuler/bash-completion ${SRC_BRANCH}
    update_code_repo src-openeuler/coreutils ${SRC_BRANCH}
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

clone_dsoftbus_code()
{
    update_code_repo openeuler/dsoftbus_standard ${SRC_BRANCH}
    update_code_repo openeuler/yocto-embedded-tools ${SRC_BRANCH}
    update_code_repo src-openeuler/libboundscheck ${SRC_BRANCH}
}

init_dsoftbus_codedir()
{
    rm -rf ${dsoftbus_build_dir}
    mkdir -p ${dsoftbus_buildtools}
    mkdir -p ${dsoftbus_thirdparty}
    mkdir -p ${dsoftbus_utils}
    mkdir -p ${dsoftbus_src}
}

unpack_dsoftbus_code()
{
    build="build-OpenHarmony-v3.0.2-LTS"
    gn="gn-linux-x86-1717"
    ninja="ninja-linux-x86-1.10.1"
    cJSON="third_party_cJSON-OpenHarmony-v3.0.2-LTS"
    jinja2="third_party_jinja2-OpenHarmony-v3.0.2-LTS"
    libcoap="third_party_libcoap-OpenHarmony-v3.0.2-LTS"
    markupsafe="third_party_markupsafe-OpenHarmony-v3.0.2-LTS"
    mbedtls="third_party_mbedtls-OpenHarmony-v3.0.2-LTS"
    bounds_checking_function="libboundscheck-v1.1.11"
    utils="utils_native-OpenHarmony-v3.0.2-LTS"

    #unpack build
    unzip -qd ${dsoftbus_build_dir} ${prefix_dir}/build/${build}.zip
    mv ${dsoftbus_build_dir}/${build} ${dsoftbus_build_dir}/build

    #unpack build_tools
    for i in  $gn $ninja
    do
        tar -C ${dsoftbus_buildtools} -zxf ${prefix_dir}/build_tools/${i}.tar.gz
    done

    #unpack third_party
    for i in  cJSON jinja2 libcoap markupsafe mbedtls
    do
	pkg=`eval echo '$'"$i"`
        unzip -qd ${dsoftbus_thirdparty} ${prefix_dir}/third_party/${i}/${pkg}.zip
        mv ${dsoftbus_thirdparty}/${pkg} ${dsoftbus_thirdparty}/${i}
    done

    #unpack boundcheck
    tar -C ${dsoftbus_thirdparty} -zxf ${SRC_DIR}/libboundscheck/${bounds_checking_function}.tar.gz
    mv ${dsoftbus_thirdparty}/${bounds_checking_function} ${dsoftbus_thirdparty}/bounds_checking_function

    #unpack utils
    unzip -qd ${dsoftbus_utils} ${prefix_dir}/utils/${utils}.zip
    mv ${dsoftbus_utils}/${utils} ${dsoftbus_utils}/native
}

init_dsoftbus_selfcode()
{
    toolchain_path="/usr1/openeuler/gcc/openeuler_gcc_arm64le"
    build_patch="0001-add-dsoftbus-build-support-for-embedded-env.patch"
    utils_patch="0001-Adaptation-for-dsoftbus.patch"
    boundscheck_patch="0001-Adaptation-for-dsoftbus.patch"

    #init gn root
    ln -s ${dsoftbus_build_dir}/build/build_scripts/build.sh ${dsoftbus_build_dir}/build.sh
    ln -s ${dsoftbus_build_dir}/build/core/gn/dotfile.gn ${dsoftbus_build_dir}/.gn

    #link selfcode
    ln -s ${prefix_dir}/productdefine ${dsoftbus_build_dir}/productdefine
    ln -s ${prefix_dir}/depend ${dsoftbus_build_dir}/depend
    ln -s ${SRC_DIR}/dsoftbus_standard ${dsoftbus_src}/dsoftbus

    #link toolchain
    ln -s ${toolchain_path} ${dsoftbus_build_dir}/toolchain

    #do patch
    patch -p1 -d ${dsoftbus_build_dir}/build < ${prefix_dir}/build/${build_patch}
    patch -p1 -d ${dsoftbus_utils}/native < ${prefix_dir}/utils/${utils_patch}
    patch -p1 -d ${dsoftbus_thirdparty}/bounds_checking_function < ${prefix_dir}/bounds_checking_function/${boundscheck_patch}
}

download_dsoftbus_code()
{
    prefix_dir="${SRC_DIR}/yocto-embedded-tools/dsoftbus"
    dsoftbus_build_dir="${SRC_DIR}/dsoftbus_build"
    dsoftbus_buildtools="${dsoftbus_build_dir}/prebuilts/build-tools/linux-x86/bin"
    dsoftbus_thirdparty="${dsoftbus_build_dir}/third_party"
    dsoftbus_utils="${dsoftbus_build_dir}/utils"
    dsoftbus_src="${dsoftbus_build_dir}/foundation/communication"

    clone_dsoftbus_code
    init_dsoftbus_codedir
    unpack_dsoftbus_code
    init_dsoftbus_selfcode
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
    elif [[ "$1" == "dsoftbus" ]];then
        SRC_DIR="$(cd $(dirname $0)/../../;pwd)"
        download_dsoftbus_code
    else
        download_code
        download_iSulad_code
        download_dsoftbus_code
        create_manifest
    fi
}

main "$@"
