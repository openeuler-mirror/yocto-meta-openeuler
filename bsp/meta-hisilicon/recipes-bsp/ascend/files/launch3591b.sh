#!/bin/bash

# mount cgroup if need, for non systemd case.
mount | grep "type cgroup"
if [ "$?" == "1" ];then
    mount -t tmpfs tmpfs /sys/fs/cgroup/
    mkdir -p /sys/fs/cgroup/cpu
    mount -t cgroup -o cpu cpu /sys/fs/cgroup/cpu
    mkdir -p /sys/fs/cgroup/devices
    mount -t cgroup -o devices devices /sys/fs/cgroup/devices
    mkdir -p /sys/fs/cgroup/freezer
    mount -t cgroup -o freezer freezer /sys/fs/cgroup/freezer
    mkdir -p /sys/fs/cgroup/cpuset
    mount -t cgroup -o cpuset cpuset /sys/fs/cgroup/cpuset
    mkdir -p /sys/fs/cgroup/memory
    mount -t cgroup -o memory memory /sys/fs/cgroup/memory
    echo 1 > /sys/fs/cgroup/memory/memory.use_hierarchy
    mkdir -p /sys/fs/cgroup/hugetlb
    mount -t cgroup -o hugetlb hugetlb /sys/fs/cgroup/hugetlb
    mkdir -p /sys/fs/cgroup/blkio
    mount -t cgroup -o blkio blkio /sys/fs/cgroup/blkio
fi

# launch offical driver setup
bash /var/minirc_boot.sh

# for hmi
if [ -e /var/davinci/driver/ascend_vdp_drm.ko ];then
    insmod /var/davinci/driver/ascend_vdp_drm.ko
fi

# other init.
# export LIBGL_ALWAYS_SOFTWARE=1

rfkill unblock all
