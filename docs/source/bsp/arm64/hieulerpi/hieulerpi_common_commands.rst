.. _board_hieulerpi_common_commands:

========================================
欧拉派海鸥系列常用命令
========================================

本章主要介绍欧拉派海鸥系列使用过程中小部分常用命令。


版本信息查询
============
1. 【cat /etc/os-release】查看当前欧拉版本的信息

   .. code-block:: console

      sd3403 ~ # cat /etc/os-release
      ID=openeuler
      NAME="openEuler Embedded(openEuler Embedded Reference Distro)"
      VERSION="24.03 (openEuler24_03)"
      VERSION_ID=24.03
      PRETTY_NAME="openEuler Embedded(openEuler Embedded Reference Distro) 24.03 (openEuler24_03)"
      DISTRO_CODENAME="openEuler24_03"


2. 【env】显示当前的环境变量

   .. code-block:: console

      sd3403 ~ # env
      SHELL=/bin/bash
      HISTSIZE=1000
      HOSTNAME=sd3403
      EDITOR=vi
      PWD=/root
      LOGNAME=root
      PRODUCT_NAME=openeuler
      HOME=/root
      SSH_CONNECTION=192.168.10.111 53112 192.168.10.8 22
      TERM=vt200
      USER=root
      VISUAL=vi
      SHLVL=1
      INPUTRC=/etc/inputrc
      PAGER=more
      PS1=\[\033[32m\]\h \w\[\033[m\] \$
      SSH_CLIENT=192.168.10.111 53112 22
      TMOUT=300
      PATH=/sbin:/usr/sbin:/usr/local/sbin:/root/bin:/usr/local/bin:/usr/bin:/bin
      VERSION=1.0
      SSH_TTY=/dev/pts/0
      _=/usr/bin/env

3. 【uname -a】内核相关的版本、编译等信息；也可以用【cat /proc/version】

   .. code-block:: console

      sd3403 ~ # uname -a
      Linux sd3403 5.10.0 #1 SMP Mon Jan 22 11:42:56 UTC 2024 aarch64 aarch64 aarch64 GNU/Linux
      sd3403 ~ # cat /proc/version
      Linux version 5.10.0 (oe-user@oe-host) (aarch64-openeuler-linux-gnu-gcc (crosstool-NG 1.25.0) 10.3.1, GNU ld (crosstool-NG 1.25.0) 2.37) #1 SMP Mon Jan 22 11:42:56 UTC 2024


编辑
========
1. 【vi】HiEuler上使用vi作为编辑工具

   .. code-block:: console

      [语法]
      vi /etc/profile 打开用户设置环境的信息


2. 【bspmm】 设置某一个寄存器的值

   .. code-block:: console

      [语法]
      bspmm 0x0102F0198 0x1200 设置0x0102F0198寄存器的值为0x1200


网络通讯
====================================
1. 【ethtool】查看网卡的各种参数，例如接收/发送缓冲区大小和其它网络参数

   .. code-block:: console

      [语法]
      ethtool eth0 查看eth0网卡的参数
      ethtool -s eth0 speed 100 duplex full autoneg off 配置eth0为100兆网卡/全双工工作模式/关闭自协商模式


2. 【ifconfig】用于查看和配置网络接口的状态，显示处于RUNNING状态的网卡

   .. code-block:: console

      [语法]
      ifconfig eth0 192.168.0.11 netmask 255.255.255.0配置eth0网卡的ip与子网掩码
      ifconfig -a查看所有的网卡，包括未激活的网卡
      ifconfig eth0 up/down启动/关闭eth0网口


3. 【ifup/ifdown】用于启动和关闭网络接口

   .. code-block:: console

      [语法]
      ifup/ifdown eth0启动/禁止网络接口eth0

   .. note::

      【ifup/ifdown与ifconfig区别】
      ifup 与 ifdown 脚本是以 /etc/sysconfig/network-scripts/ifcfg-ethX文件来进行激活的！它会直接在/etc/sysconfig/network-scripts目录下搜索对应的配置文件(ifcfg-ethX)，修改文件里面的参数。例如，对于网卡eth0来说，它会找到ifcfg-eth0这个文件，然后对文件的内容加以设置和修改。所以在使用ifup/ifdown前，首先要确认ifcfg-ethX文件是否存在于正确的目录内，如果不存在则会启动或关闭失败，也就是说ifup和ifdown除了存在 ethX这个实体网卡之外，还要存在ifcfg-ethX文件才行。
      而ifconfig是手动修改网络接口参数，如果用了ifconfig 修改或设置网络接口参数，那么就无法用ifdown  ethX方式来关闭。这是因为ifdown会分析目前网络接口参数是否与文件ifcfg-ethX的配置参数是否一致，不一致的话，就会放弃操作。因此用ifconfig修改完后，需要用ifconfig  ethX  down 才能关闭该接口。

4. 【route】用于显示、添加、删除和修改IP路由表。它可以帮助你诊断网络问题，如路由不通、网络延迟等

   .. code-block:: console

      [语法]
      route -n以数字格式显示路由表
      route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.0.1添加路由
      route del -net 192.168.1.0 netmask 255.255.255.0删除路由
      route change -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.0.2修改路由


系统服务
============

1. 【systemctl】可以使用systemctl命令进行系统服务的操作

   .. code-block:: console

      [语法]
      systemctl daemon-reload修改了服务的配置文件后重新加载使其生效
      systemctl <action> <myservice>
      action：
      start：开始服务
      stop：停止服务
      enable：将服务添加到启动项中
      unmask：解除屏蔽的服务
      status：验证服务是否正在运行

2. 【service】使用service命令进行服务的启动/停止/重启/查看状态

   .. code-block:: console

      [语法]
      service <service_name> <action>
      action：
      start：开始服务
      stop：停止服务
      restart：重启服务
      status：查看服务状态

ROS2
====
1. 【source】用于读取并执行指定文件中的命令，通常用于加载环境变量脚本

   .. code-block:: console

      [语法]
      source /etc/profile.d/ros/setup.bash配置HiEuler上ros的环境

U-boot
======
1. 【print】查看当前的环境变量，和【printenv】命令一样

2. 【setenv】修改环境变量中某一项的配置

   .. code-block:: console

      [语法]
      setenv boot_media sd设置启动介质为SD卡

3. 【sa】保存环境变量配置，使用setenv修改后需要使用sa命令保存，然后再次使用print确认修改生效

4. 【re】重启单板，和【reset】命令一样


LiteOS
======
1. 【load_riscv】加载LiteOS镜像

   .. code-block:: console

      sd3403 ~ # load_riscv 0x44000000 /firmware/LiteOS.bin
      The RISCV started!

2. 【virt_tty】虚拟串口，用于调试LiteOS

   .. code-block:: console

      sd3403 ~ # virt-tty riscv
      Huawei LiteOS # help
      *******************shell commands:*************************
      cat           cd            dd            free          help          hwi           i2c_read      i2c_write
      ls            lsfd          memcheck      mkdir         proc_ipcm     pwd           reset         rm
      rmdir         ssp_read      ssp_write     stack         swtmr         systeminfo    task          uname
      writeproc



