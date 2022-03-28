openEuler Embedded所支持的软件包
===================================


| oct名称：acl
| 功能说明：提供操纵访问控制列表的命令
| 详细说明：提供操作程序控制列表的getfacl和setfacl程序。
| 依赖关系：glibc >= 2.34;libacl1 >= 2.3.1;
| oct名称：libacl1
| 功能说明：提供用于访问POSIX访问控制列表的动态库
| 详细说明：提供libacl.so动态库，其中包含POSIX 1003.1e标准草案中用于操作访问控制列表的17个函数。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34;libattr1 >= 2.5.1;libattr1 >= 2.5.1
| oct名称：attr
| 功能说明：用于管理文件系统扩展属性
| 详细说明：一种在文件系统对象上操作扩展属性的工具集，特别是getfattr和setfattr工具。;还提供了一个attr命令，它在很大程度上兼容使用同名的SGI IRIX工具。
| 依赖关系：glibc >= 2.34;libattr1 >= 2.5.1
| oct名称：libattr1
| 功能说明：提供文件扩展属性支持的动态库
| 详细说明：提供libattr.so动态库，其中包含扩展属性库函数。
| 依赖关系：
| oct名称：audispd-plugins
| 功能说明：提供审计事件调度器的插件
| 详细说明：为audit系统、audispd的实时接口的提供插件；;此插件能够传达事件到远端及其或者为分析可疑行为的事件。
| 依赖关系：
| oct名称：audit
| 功能说明：为审计提供用户空间工具
| 详细说明：通过审计系统提供用户空间程序来存储和搜索审计记录生成。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34;libcap-ng >= 0.8.2;libcap-ng >= 0.8.2
| oct名称：auditd
| 功能说明：提供audit的守护进程
| 详细说明：
| 依赖关系：audit >= 3.0.1;config(auditd) = 3.0.1-r0;glibc >= 2.34;libcap-ng >= 0.8.2
| oct名称：bash
| 功能说明：命令处理器
| 详细说明：与sh兼容的命令解释器，从标准输入或文件中读取来执行命令，并结合了ksh和csh的有用功能。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34;libtinfo5 >= 6.2;libtinfo5 >= 6.2
| oct名称：bind
| 功能说明：域名系统（DNS）协议的一种实现
| 详细说明：提供DNS服务器，将主机名转换为IP地址；;提供解析器库，是与DNS交互式应用程序使用的例程；;提供工具，验证DNS服务是否正常运行。
| 依赖关系：/bin/sh;config(bind) = 9.11.14-r0;glibc >= 2.34;glibc >= 2.34;libcap >= 2.61;libcap >= 2.61;libcrypto1.1 >= 1.1.1m;libcrypto1.1 >= 1.1.1m;libz1 >= 1.2.11;libz1 >= 1.2.11
| oct名称：bind-utils
| 功能说明：用于查询DNS名称服务器
| 详细说明：从DNS名称服务器中获取信息。
| 依赖关系：bind >= 9.11.14;glibc >= 2.34;libreadline8 >= 8.1
| oct名称：libbfd
| 功能说明：二进制描述器
| 详细说明：提供libbfd-2.37.so动态库。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34;libz1 >= 1.2.11;libz1 >= 1.2.11
| oct名称：busybox
| 功能说明：许多常见UNIX实用程序的微小版本组合
| 详细说明：替代通常在filetuils、shellutils、findutils、textutils、grep、gzip、tar等中的实用程序，;提供相当完整的POSIX小型或嵌入式系统环境。
| 依赖关系：glibc >= 2.34;libtirpc3 >= 1.3.2
| oct名称：busybox-linuxrc
| 功能说明：提供初始化程序
| 详细说明：提供linuxrc和init程序。
| 依赖关系：busybox
| oct名称：libbz2-1
| 功能说明：bzip2运行时库
| 详细说明：提供libbz2.so.1动态库。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34
| oct名称：cifs-utils
| 功能说明：用于执行和管理Linu CIFS文件系统的挂载
| 详细说明：包含用于执行和管理Linux CIFS文件系统挂载的使用程序。
| 依赖关系：glibc >= 2.34
| oct名称：cracklib
| 功能说明：使用字典破解密码的库
| 详细说明：测试密码以确定它们是否匹配一定的安全导向特性，可阻止用户选择太过简单的密码。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34;libz1 >= 1.2.11;libz1 >= 1.2.11
| oct名称：cronie
| 功能说明：用于周期性执行指令
| 详细说明：提供cron的守护进程，cron用于在特定时间自动启动任务程序。
| 依赖关系：config(cronie) = 1.5.7-r0;glibc >= 2.34;libpam >= 1.5.2;libpam-runtime;pam-plugin-access;pam-plugin-loginuid
| oct名称：curl
| 功能说明：用于从远端服务器获取文件
| 详细说明：一个命令行工具，用于使用URL语法传输数据，支持多种协议和大量有用的技巧。
| 依赖关系：glibc >= 2.34;libcurl4 >= 7.79.1
| oct名称：libcurl4
| 功能说明：用于从URL传输数据的库
| 详细说明：curl共享库，用于使用不同的网络协议访问数据
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34
| oct名称：dhcp
| 功能说明：提供ISC DHCP软件使用的常用程序
| 详细说明：包含ISC DHCP服务端和客户端使用的常用程序。
| 依赖关系：bind >= 9.11.14;dhcp-libs >= 4.4.2;glibc >= 2.34
| oct名称：dhcp-libs
| 功能说明：ISC DHCP服务端和客户端使用的共享库
| 详细说明：提供ISC DHCP服务端和客户端使用的共享库。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34
| oct名称：dhcp-server
| 功能说明：提供ISC DHCP服务端
| 详细说明：提供DHCP服务端和dhcp守护进程。
| 依赖关系：/bin/sh;bind >= 9.11.14;bind >= 9.11.14;dhcp-libs >= 4.4.2;dhcp-libs >= 4.4.2;glibc >= 2.34;glibc >= 2.34
| oct名称：dhcp-server-config
| 功能说明：ISC DHCP服务端配置
| 详细说明：提供默认的DHCP服务端和dhcp守护进程配置文件。
| 依赖关系：/etc;/etc/default;/etc/default/dhcp-server;/etc/dhcp;/etc/dhcp/dhcpd.conf
| oct名称：dosfstools
| 功能说明：用于创建和检查MS-DOS FAT文件系统
| 详细说明：包含用于Linux中 创建和检查硬盘或软盘上的MS-DOS FAT文件系统的两个工具。
| 依赖关系：glibc >= 2.34
| oct名称：e2fsprogs
| 功能说明：用于管理ext2、ext3和ext4文件系统
| 详细说明：包含许多用于ext2、ext3和ext4文件系统中创建、检查、修改和纠正任何不一致的程序。
| 依赖关系：e2fsprogs-badblocks;e2fsprogs-dumpe2fs;glibc >= 2.34;libblkid1 >= 2.37.2;libcom-err2 >= 1.46.4;libe2p2 >= 1.46.4;libext2fs2 >= 1.46.4;libss2 >= 1.46.4;libuuid1 >= 2.37.2
| oct名称：e2fsprogs-badblocks
| 功能说明：用于检查磁盘装置中损坏的区块
| 详细说明：提供badblocks命令，用于检查磁盘装置中损坏的区块。
| 依赖关系：glibc >= 2.34;libcom-err2 >= 1.46.4;libext2fs2 >= 1.46.4
| oct名称：e2fsprogs-dumpe2fs
| 功能说明：用于查看格式化之后的文件系统信息
| 详细说明：提供dumpe2fs命令，用于查看格式化之后的文件系统信息。
| 依赖关系：glibc >= 2.34;libblkid1 >= 2.37.2;libcom-err2 >= 1.46.4;libe2p2 >= 1.46.4;libext2fs2 >= 1.46.4
| oct名称：e2fsprogs-e2fsck
| 功能说明：用于检查使用Linux ext2档案系统的partition
| 详细说明：提供e2fsck命令，用于检查使用Linux ext2档案系统的partition是否正常工作。
| 依赖关系：glibc >= 2.34;libblkid1 >= 2.37.2;libcom-err2 >= 1.46.4;libe2p2 >= 1.46.4;libext2fs2 >= 1.46.4;libuuid1 >= 2.37.2
| oct名称：e2fsprogs-mke2fs
| 功能说明：用于建立ext2文件系统
| 详细说明：提供mke2fs.conf和mke2fs.e2fsprogs，mke2fs命令用于建立ext2文件系统。
| 依赖关系：glibc >= 2.34;libblkid1 >= 2.37.2;libcom-err2 >= 1.46.4;libe2p2 >= 1.46.4;libext2fs2 >= 1.46.4;libuuid1 >= 2.37.2
| oct名称：libcom-err2
| 功能说明：e2fsprogs报错库
| 详细说明：一个错误信息显示库。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34
| oct名称：libe2p2
| 功能说明：e2fsprogs共享库
| 详细说明：提供libe2p.so.2和libe2p.so.2.3动态库。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34
| oct名称：libext2fs2
| 功能说明：e2fsprogs共享库
| 详细说明：提供libext2fs2.so.2和libext2fs.2.4动态库。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34;libblkid1 >= 2.37.2;libblkid1 >= 2.37.2;libcom-err2 >= 1.46.4;libcom-err2 >= 1.46.4
| oct名称：libss2
| 功能说明：e2fsprogs共享库
| 详细说明：提供libss.so.2和libss.so.2.0动态库。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34;libcom-err2 >= 1.46.4;libcom-err2 >= 1.46.4
| oct名称：libasm1
| 功能说明：用于处理编译对象的实用程序和DSO集合
| 详细说明：提供libasm-0.185.so和libasm.so.1动态库
| 依赖关系：/bin/sh;glibc >= 2.34;libdw1 >= 0.185;libelf1 >= 0.185
| oct名称：libelf1
| 功能说明：读写ELF文件的库
| 详细说明：提供libelf-0.185.so好libelf.so.1动态库
| 依赖关系：/bin/sh;glibc >= 2.34;libz1 >= 1.2.11
| oct名称：libdw1
| 功能说明：访问DWARF调试信息的库
| 详细说明：提供libdw-0.185.so和libdw.so.1动态库
| 依赖关系：glibc >= 2.34;libelf1 >= 0.185;libz1 >= 1.2.11
| oct名称：ethtool
| 功能说明：以太网网卡的设置工具
| 详细说明：允许在许多网络设备尤其是以太网设备中查询和更改设置，;例如速度、端口、自动协商、PCI位置、校验和卸载。
| 依赖关系：glibc >= 2.34
| oct名称：libexpat1
| 功能说明：XML解析器工具包
| 详细说明：提供libexpat.so.1好libexpat.so.1.8.1动态库
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：gcc-bin-toolchain-compilerlibs-aarch64
| 功能说明：编译工具链
| 详细说明：
| 依赖关系：/bin/sh
| oct名称：libglib-2.0-0
| 功能说明：通用使用程序库
| 详细说明：
| 依赖关系：/bin/sh;glibc >= 2.34;libffi8 >= 3.4.2;libmount1 >= 2.37.2;libpcre1 >= 8.45;libz1 >= 1.2.11
| oct名称：glibc
| 功能说明：GNU C库
| 详细说明：包含重要的共享库集：标准C库和标准数学库。
| 依赖关系：/bin/sh
| oct名称：grep
| 功能说明：用于打印与模式匹配的行
| 详细说明：提供grep命令，用于在一个或多个输入文件中搜索包含匹配指定的模式，;默认情况下，grep打印匹配的行。
| 依赖关系：glibc >= 2.34;libpcre1 >= 8.45
| oct名称：gzip
| 功能说明：GNU 数据压缩程序
| 详细说明：包含GNU gzip数据压缩程序。
| 依赖关系：glibc >= 2.34
| oct名称：libhttp-parser2.9
| 功能说明：解析http的库
| 详细说明：
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：iSulad
| 功能说明：云原生轻量级容器解决方案
| 详细说明：
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34;lcr >= 2.0.7;lcr >= 2.0.7;libcrypto1.1 >= 1.1.1m;libcrypto1.1 >= 1.1.1m;libcurl4 >= 7.79.1;libcurl4 >= 7.79.1;libevent >= 2.1.12;libevent >= 2.1.12;libevhtp >= 1.2.18;libevhtp >= 1.2.18;libhttp-parser2.9 >= 2.9.4;libhttp-parser2.9 >= 2.9.4;libz1 >= 1.2.11;libz1 >= 1.2.11;yajl >= 2.1.0;yajl >= 2.1.0
| oct名称：initscripts
| 功能说明：提供System V初始化脚本的基本支持
| 详细说明：提供System V初始化脚本的基本支持以及一些工具和实用程序。
| 依赖关系：/bin/sh;initd-functions;initd-functions
| oct名称：initscripts-functions
| 功能说明：shell公共函数
| 详细说明：提供一些基础的功能。
| 依赖关系：
| oct名称：iproute2-ip
| 功能说明：提供iproute2程序
| 详细说明：提供ip.iproute2工具。
| 依赖关系：glibc >= 2.34;libcap >= 2.61;libelf1 >= 0.185
| oct名称：iptables
| 功能说明：用于管理Linux内核包过滤功能的工具
| 详细说明：在Linux内核中控制网络包过滤代码，用于设置防火墙或IP伪装。
| 依赖关系：
| oct名称：iptables-modules
| 功能说明：用于组装各个模块
| 详细说明：
| 依赖关系：iptables-module-ip6t-ah;iptables-module-ip6t-dnat;iptables-module-ip6t-dnpt;iptables-module-ip6t-dst;iptables-module-ip6t-eui64;iptables-module-ip6t-frag;iptables-module-ip6t-hbh;iptables-module-ip6t-hl;iptables-module-ip6t-icmp6;iptables-module-ip6t-ipv6header;iptables-module-ip6t-log;iptables-module-ip6t-masquerade;iptables-module-ip6t-mh;iptables-module-ip6t-netmap;iptables-module-ip6t-redirect;iptables-module-ip6t-reject;iptables-module-ip6t-rt;iptables-module-ip6t-snat;iptables-module-ip6t-snpt;iptables-module-ip6t-srh;iptables-module-ipt-ah;iptables-module-ipt-clusterip;iptables-module-ipt-dnat;iptables-module-ipt-ecn;iptables-module-ipt-icmp;iptables-module-ipt-log;iptables-module-ipt-masquerade;iptables-module-ipt-netmap;iptables-module-ipt-realm;iptables-module-ipt-redirect;iptables-module-ipt-reject;iptables-module-ipt-snat;iptables-module-ipt-ttl;iptables-module-ipt-ulog;iptables-module-xt-addrtype;iptables-module-xt-audit;iptables-module-xt-bpf;iptables-module-xt-cgroup;iptables-module-xt-checksum;iptables-module-xt-classify;iptables-module-xt-cluster;iptables-module-xt-comment;iptables-module-xt-connbytes;iptables-module-xt-connlimit;iptables-module-xt-connmark;iptables-module-xt-connsecmark;iptables-module-xt-conntrack;iptables-module-xt-cpu;iptables-module-xt-ct;iptables-module-xt-dccp;iptables-module-xt-devgroup;iptables-module-xt-dscp;iptables-module-xt-ecn;iptables-module-xt-esp;iptables-module-xt-hashlimit;iptables-module-xt-helper;iptables-module-xt-hmark;iptables-module-xt-idletimer;iptables-module-xt-ipcomp;iptables-module-xt-iprange;iptables-module-xt-ipvs;iptables-module-xt-led;iptables-module-xt-length;iptables-module-xt-limit;iptables-module-xt-mac;iptables-module-xt-mark;iptables-module-xt-multiport;iptables-module-xt-nfacct;iptables-module-xt-nflog;iptables-module-xt-nfqueue;iptables-module-xt-osf;iptables-module-xt-owner;iptables-module-xt-physdev;iptables-module-xt-pkttype;iptables-module-xt-policy;iptables-module-xt-quota;iptables-module-xt-rateest;iptables-module-xt-recent;iptables-module-xt-rpfilter;iptables-module-xt-sctp;iptables-module-xt-secmark;iptables-module-xt-set;iptables-module-xt-socket;iptables-module-xt-standard;iptables-module-xt-statistic;iptables-module-xt-string;iptables-module-xt-synproxy;iptables-module-xt-tcp;iptables-module-xt-tcpmss;iptables-module-xt-tcpoptstrip;iptables-module-xt-tee;iptables-module-xt-time;iptables-module-xt-tos;iptables-module-xt-tproxy;iptables-module-xt-trace;iptables-module-xt-u32;iptables-module-xt-udp
| oct名称：iptables-module-ip6t-ah
| 功能说明：提供libip6t_ah.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-dnat
| 功能说明：提供libip6t_DNAT.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-dnpt
| 功能说明：提供libip6t_DNPT.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-dst
| 功能说明：提供libip6t_dst.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-eui64
| 功能说明：提供libip6t_eui64.so动态库
| 详细说明：
| 依赖关系：iptables >= 1.8.7
| oct名称：iptables-module-ip6t-frag
| 功能说明：提供libip6t_frag.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-hbh
| 功能说明：提供libip6t_hbh.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-hl
| 功能说明：提供libip6t_HL.so和libip6t_hl.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-icmp6
| 功能说明：提供libip6t_icmp6.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-ipv6header
| 功能说明：提供libip6t_ipv6header.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-log
| 功能说明：提供libip6t_LOG.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-masquerade
| 功能说明：提供libip6t_MASQUERADE.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-mh
| 功能说明：提供libip6t_mh.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-netmap
| 功能说明：提供libip6t_NETMAP.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-redirect
| 功能说明：提供libip6t_REDIRECT.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-reject
| 功能说明：提供libip6t_REJECT.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-rt
| 功能说明：提供libip6t_rt.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-snat
| 功能说明：提供libip6t_SNAT.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-snpt
| 功能说明：提供libip6t_SNPT.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ip6t-srh
| 功能说明：提供libip6t_srh.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-ah
| 功能说明：提供libipt_ah.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-clusterip
| 功能说明：提供libipt_CLUSTERIP.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-dnat
| 功能说明：提供libipt_DNAT.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-ecn
| 功能说明：提供libipt_ECN.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-icmp
| 功能说明：提供libipt_icmp.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-log
| 功能说明：提供libipt_LOG.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-masquerade
| 功能说明：提供libipt_MASQUERADE.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-netmap
| 功能说明：提供libipt_NETMAP.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-realm
| 功能说明：提供libipt_realm.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-redirect
| 功能说明：提供libipt_REDIRECT.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-reject
| 功能说明：提供libipt_REJECT.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-snat
| 功能说明：提供libipt_SNAT.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-ttl
| 功能说明：提供libipt_TTL.so和libipt_ttl.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-ipt-ulog
| 功能说明：提供libipt_ULOG.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-addrtype
| 功能说明：提供libxt_addrtype.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-audit
| 功能说明：提供libxt_AUDIT.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-bpf
| 功能说明：提供libxt_bpf.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-cgroup
| 功能说明：提供libxt_cgroup.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-checksum
| 功能说明：提供libxt_CHECKSUM.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-classify
| 功能说明：提供libxt_CLASSIFY.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-cluster
| 功能说明：提供libxt_cluster.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-comment
| 功能说明：提供libxt_comment.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-connbytes
| 功能说明：提供libxt_connbytes.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-connlimit
| 功能说明：提供libxt_connlimit.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-connmark
| 功能说明：提供libxt_CONNMARK.so和libxt_connmark.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-connsecmark
| 功能说明：提供libxt_CONNSECMARK.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-conntrack
| 功能说明：提供libxt_conntrack.so和libxt_state.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-cpu
| 功能说明：提供libxt_cpu.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-ct
| 功能说明：提供libxt_CT.so和libxt_NOTRACK.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-dccp
| 功能说明：提供libxt_dccp.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-devgroup
| 功能说明：提供libxt_devgroup.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-dscp
| 功能说明：提供libxt_DSCP.so和libxt_dscp.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-ecn
| 功能说明：提供libxt_ecn.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-esp
| 功能说明：提供libxt_esp.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-hashlimit
| 功能说明：提供ibxt_hashlimit.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-helper
| 功能说明：提供libxt_helper.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-hmark
| 功能说明：提供libxt_HMARK.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-idletimer
| 功能说明：提供libxt_IDLETIMER.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-ipcomp
| 功能说明：提供libxt_ipcomp.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-iprange
| 功能说明：提供libxt_iprange.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-ipvs
| 功能说明：提供libxt_ipvs.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-led
| 功能说明：提供libxt_LED.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-length
| 功能说明：提供libxt_length.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-limit
| 功能说明：提供libxt_limit.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-mac
| 功能说明：提供libxt_mac.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-mark
| 功能说明：提供libxt_MARK.so和libxt_mark.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-multiport
| 功能说明：提供libxt_multiport.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-nfacct
| 功能说明：提供libxt_nfacct.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-nflog
| 功能说明：提供libxt_NFLOG.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-nfqueue
| 功能说明：提供libxt_NFQUEUE.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-osf
| 功能说明：提供libxt_osf.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-owner
| 功能说明：提供libxt_owner.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-physdev
| 功能说明：提供libxt_physdev.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-pkttype
| 功能说明：提供libxt_pkttype.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-policy
| 功能说明：提供libxt_policy.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-quota
| 功能说明：提供libxt_quota.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-rateest
| 功能说明：提供libxt_RATEEST.so和libxt_rateest.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-recent
| 功能说明：提供libxt_recent.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-rpfilter
| 功能说明：提供libxt_rpfilter.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-sctp
| 功能说明：提供libxt_sctp.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-secmark
| 功能说明：提供libxt_SECMARK.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-set
| 功能说明：提供libxt_SET.so和libxt_set.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-socket
| 功能说明：提供libxt_socket.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-standard
| 功能说明：提供libxt_standard.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-statistic
| 功能说明：提供libxt_statistic.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-string
| 功能说明：提供libxt_string.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-synproxy
| 功能说明：提供libxt_SYNPROXY.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-tcp
| 功能说明：提供libxt_tcp.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-tcpmss
| 功能说明：提供libxt_TCPMSS.so和libxt_tcpmss.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-tcpoptstrip
| 功能说明：提供libxt_TCPOPTSTRIP.so库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-tee
| 功能说明：提供libxt_TEE.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-time
| 功能说明：提供libxt_time.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-tos
| 功能说明：提供libxt_TOS.so和libxt_tos.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-tproxy
| 功能说明：提供libxt_TPROXY.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-trace
| 功能说明：提供libxt_TRACE.so动态库
| 详细说明：
| 依赖关系：iptables >= 1.8.7
| oct名称：iptables-module-xt-u32
| 功能说明：提供libxt_u32.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：iptables-module-xt-udp
| 功能说明：提供libxt_udp.so动态库
| 详细说明：
| 依赖关系：glibc >= 2.34;iptables >= 1.8.7
| oct名称：libjson-c5
| 功能说明：C中json实现
| 详细说明：提供在C中处理json的动态库。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34
| oct名称：kexec
| 功能说明：重新启动新内核的快速重新引导功能部件
| 详细说明：提供kexec工具，促进新的内核在正常或恐慌重启中使用内核的kexec特性来重启。
| 依赖关系：glibc >= 2.34;libz1 >= 1.2.11
| oct名称：kmod
| 功能说明：将模块加载到内核中
| 详细说明：提供内核模块插入、删除、列出、检查属性、解析等工具。
| 依赖关系：glibc >= 2.34;libz1 >= 1.2.11
| oct名称：lcr
| 功能说明：轻量级容器
| 详细说明：提供轻量级容器动态库。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34;lxc >= 4.0.3;lxc >= 4.0.3;yajl >= 2.1.0;yajl >= 2.1.0
| oct名称：less
| 功能说明：文本文件浏览器
| 详细说明：提供less等命令，用于查看文本，类似于more，但具有更多的能力。
| 依赖关系：glibc >= 2.34;libtinfo5 >= 6.2
| oct名称：libaio1
| 功能说明：Linux原生异步I/O访问库
| 详细说明：提供给POSIX异步I/O工具内核加速的异步I/O功能。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34
| oct名称：libarchive
| 功能说明：用于处理流归档格式的库
| 详细说明：提供创建和读取不同流存档格式的功能。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34
| oct名称：libcap
| 功能说明：用于获取和设置POSIX.1e功能的库
| 详细说明：数据包捕获函数库，用于捕获网卡数据或分析pcap格式的抓包报文。
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34
| oct名称：libcap-bin
| 功能说明：提供libcap二进制工具
| 详细说明：提供/usr/sbin/capsh、/usr/sbin/getcap、/usr/sbin/getpcaps、/usr/sbin/setcap
| 依赖关系：glibc >= 2.34;libcap >= 2.61
| oct名称：libcap-ng
| 功能说明：备用POSIX功能库
| 详细说明：提供比传统libcap库更容易使用POSIX功能编程的库
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34
| oct名称：libcap-ng-bin
| 功能说明：提供libcap-ng二进制工具
| 详细说明：提供/usr/bin/captest、/usr/bin/filecap、/usr/bin/netcap、/usr/bin/pscap
| 依赖关系：glibc >= 2.34;libcap-ng >= 0.8.2
| oct名称：libestr0
| 功能说明：字符串处理必备库
| 详细说明：提供了rsyslog守护进程使用的字符串处理必备共享库
| 依赖关系：/bin/sh;glibc >= 2.34;glibc >= 2.34
| oct名称：libevent
| 功能说明：抽象异步事件通知库
| 详细说明：libevent API提供了一种机制，在文件描述符上发生特定事件或达到超时后执行回调函数。libevent旨在替换事件驱动网络服务器中发现的异步事件循环。应用程序只需要调用event_dispatch()，然后就可以动态添加或删除事件，而不必更改事件循环。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libevhtp
| 功能说明：libevhtp包的调试源
| 详细说明：此软件包为libevhtp包提供调试源。;调试源在开发使用此软件包的应用程序或调试此软件包时非常有用。
| 依赖关系：/bin/sh;glibc >= 2.34;libevent >= 2.1.12
| oct名称：libfastjson4
| 功能说明：JSON解析库
| 详细说明：一个JSON解析库，json-c的分叉，由rsyslog团队开发，用于rsyslog和liblognorm。;此软件包包括libfastjson库。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libffi8
| 功能说明：外部函数接口库
| 详细说明：libffi库为各种调用约定提供了一个可移植的高级编程接口。这允许程序员在运行时调用调用接口描述指定的任何函数。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libhugetlbfs
| 功能说明：用于大型翻译Lookaside缓冲区文件系统的帮助程序库
| 详细说明：libhugetlbfs包与Linux hugetlbfs交互，以透明的方式使大页面可供应用程序使用。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libnl-3-200
| 功能说明：内核网络套接字的便利库
| 详细说明：这个包包含一个方便的库，可以简化使用Linux内核的netlink套接字接口进行网络操作
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libnl-3-cli
| 功能说明：libnl3的命令行界面实用程序
| 详细说明：此软件包包含各种libnl3实用程序和它们所依赖的其他库
| 依赖关系：/bin/sh;glibc >= 2.34;libnl-3-200 >= 3.5.0;libnl-genl-3-200 >= 3.5.0;libnl-idiag-3-200 >= 3.5.0;libnl-nf-3-200 >= 3.5.0;libnl-route-3-200 >= 3.5.0
| oct名称：libnl-genl-3-200
| 功能说明：Netlink操作库
| 详细说明：提供libnl-genl-3.so.*
| 依赖关系：/bin/sh;glibc >= 2.34;libnl-3-200 >= 3.5.0
| oct名称：libnl-idiag-3-200
| 功能说明：libnl-idiag动态库
| 详细说明：提供libnl-idiag-3.so.*
| 依赖关系：/bin/sh;glibc >= 2.34;libnl-3-200 >= 3.5.0
| oct名称：libnl-nf-3-200
| 功能说明：NetFilter以及接口监控相关的Netlink操作库
| 详细说明：提供libnl-nf-3.so.*
| 依赖关系：/bin/sh;glibc >= 2.34;libnl-3-200 >= 3.5.0;libnl-route-3-200 >= 3.5.0
| oct名称：libnl-route-3-200
| 功能说明：提供NETLINK_ROUTE家族的API接口库
| 详细说明：提供libnl-route-3.so.*
| 依赖关系：/bin/sh;glibc >= 2.34;libnl-3-200 >= 3.5.0
| oct名称：libnl-xfrm-3-200
| 功能说明：libnl-xfrm动态库
| 详细说明：提供libnl-xfrm-3.so.*
| 依赖关系：/bin/sh;glibc >= 2.34;libnl-3-200 >= 3.5.0
| oct名称：libpcap1
| 功能说明：网络嗅探器库
| 详细说明：libpcap是数据包嗅探器程序使用的库。它为他们提供了一个接口，用于捕获和分析来自网络设备的数据包。;只有当您计划自己编译或编写这样的程序时，才需要此软件包。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libpcre1
| 功能说明：Perl兼容正则表达式的库
| 详细说明：PCRE库是一组函数，使用与Perl 5相同的语法和语义实现正则表达式模式匹配；;此PCRE库变体支持8位和UTF-8字符串。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libpwquality
| 功能说明：密码生成和密码质量检查库
| 详细说明：这是一个用于密码质量检查和生成通过检查的随机密码的库。;此库使用破解库和破解库字典执行一些检查。
| 依赖关系：/bin/sh;cracklib >= 2.9.7;glibc >= 2.34;libpam >= 1.5.2
| oct名称：libseccomp
| 功能说明：增强的seccomp库
| 详细说明：libseccomp库为Linux内核的syscall过滤机制（seccomp）提供了一个易于使用的接口。libseccomp API允许应用程序指定允许应用程序执行哪些syscall，以及可选的哪些syscall参数，所有这些都由Linux内核强制执行。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libselinux1
| 功能说明：SELinux运行时库
| 详细说明：libselinux提供了一个接口，用于获取和设置进程和文件安全上下文，以及获取安全策略决策。;（安全增强的Linux是内核和一些实施强制性访问控制策略的实用程序的一个功能，如类型实施、基于角色的访问控制和多级安全。）
| 依赖关系：/bin/sh;glibc >= 2.34;libpcre1 >= 8.45
| oct名称：libselinux-bin
| 功能说明：SELinux libselinux实用程序
| 详细说明：libselinux-bin软件包包含实用程序
| 依赖关系：glibc >= 2.34;libpcre1 >= 8.45;libselinux1 >= 3.3;libsepol2 >= 3.3
| oct名称：libsemanage2
| 功能说明：SELinux策略管理库
| 详细说明：libsemanage是策略管理库。使用libsepol和libselinux与SELinux系统交互，它还调用帮助程序来加载策略和检查file_contexts配置是否有效。
| 依赖关系：/bin/sh;audit >= 3.0.1;glibc >= 2.34;libbz2-1 >= 1.0.8;libselinux1 >= 3.3;libsepol2 >= 3.3
| oct名称：libsepol2
| 功能说明：SELinux二进制策略操作库
| 详细说明：提供SELinux二进制策略操作库
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libsepol-bin
| 功能说明：SELinux二进制策略操作工具
| 详细说明：libsepol提供了一个用于操作SELinux二进制策略的API。它由checkpolicy（策略编译器）和类似的工具，以及需要对二进制策略执行特定转换（如自定义策略布尔设置）的程序使用。
| 依赖关系：glibc >= 2.34;libsepol2 >= 3.3
| oct名称：libtirpc3
| 功能说明：与传输无关的RPC库
| 详细说明：传输独立RPC库(TI-RPC)是glibc中不支持IPv6地址的标准SunRPC库的替代。;此实现允许支持UDP和TCP over IPv4以外的其他传输。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libusb-1.0-0
| 功能说明：USB库
| 详细说明：Libusb是一个允许用户空间访问USB设备的库。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libwebsockets
| 功能说明：用于Websockets的轻量级C库
| 详细说明：这是用于轻量级websocket客户端和服务器的libwebsockets C库。
| 依赖关系：/bin/sh;glibc >= 2.34;libcrypto1.1 >= 1.1.1m;libssl1.1 >= 1.1.1m;libz1 >= 1.2.11
| oct名称：libxml2
| 功能说明：提供XML和HTML支持的库
| 详细说明：此库允许操作XML文件。它包括读取、修改和写入XML和HTML文件的支持。DTD支持，这包括解析和验证，即使是复杂的DtD，可以在解析时或在修改文档后更晚。输出可以是简单的SAX流，也可以是内存中类似DOM的表示。;在这种情况下，可以使用内置的XPath和XPointer实现来选择子节点或范围。提供灵活的输入/输出机制，具有现有的HTTP和FTP模块，并组合到URI库。
| 依赖关系：/bin/sh;glibc >= 2.34;libz1 >= 1.2.11
| oct名称：libxml2-utils
| 功能说明：用于操作XML文件的实用程序
| 详细说明：此软件包包含用于操作XML文件的实用程序。
| 依赖关系：glibc >= 2.34;libxml2 >= 2.9.12
| oct名称：logrotate
| 功能说明：用于旋转、压缩、邮寄和删除系统日志文件的Cron服务
| 详细说明：logrotate实用程序自动旋转、压缩、邮寄和删除日志文件。Logrotate可以设置为每天、每周、每月或当日志文件达到一定大小时处理日志文件。通常，logrotate作为每日cron作业运行。;它只管理普通文件，不参与systemd的日志轮换。
| 依赖关系：config(logrotate) = 3.18.1-r0;glibc >= 2.34;libacl1 >= 2.3.1;libpopt0 >= 1.18
| oct名称：lvm2
| 功能说明：Userland逻辑卷管理工具
| 详细说明：LVM2包括处理物理卷（硬盘、RAID系统、磁光等，多个设备（MD），请参阅mdm(8)，甚至环路设备，请参见Lostup(8))上的读/写操作的所有支持，从一个或多个物理卷创建卷组（虚拟磁盘种类），并在卷组中创建一个或多个逻辑卷（逻辑分区种类）。
| 依赖关系：/bin/sh;config(lvm2) = 2.03.14-r0;glibc >= 2.34;libaio1 >= 0.3.112;libblkid1 >= 2.37.2
| oct名称：lvm2-scripts
| 功能说明：提供blkdeactivate、fsadm、lvmdum命令
| 详细说明：提供/usr/sbin/blkdeactivate、/usr/sbin/fsadm和/usr/sbin/lvmdump
| 依赖关系：bash;lvm2 = 2.03.14-r0
| oct名称：lxc
| 功能说明：Linux内核容器的用户空间工具
| 详细说明：LXC是众所周知的、经过严格测试的低层次Linux容器运行时。
| 依赖关系：/bin/sh;gcc-bin-toolchain-compilerlibs-aarch64 >= 1.0;glibc >= 2.34;libcap >= 2.61;libseccomp >= 2.5.3;yajl >= 2.1.0
| oct名称：libform5
| 功能说明：libform动态库
| 详细说明：提供/usr/lib64/libform.so.*
| 依赖关系：/bin/sh;glibc >= 2.34;libncurses5 >= 6.3
| oct名称：libmenu5
| 功能说明：libmenu动态库
| 详细说明：提供/usr/lib64/libmenu.so.*
| 依赖关系：/bin/sh;glibc >= 2.34;libncurses5 >= 6.3
| oct名称：libncurses5
| 功能说明：libncurses动态库
| 详细说明：提供/lib64/libncurses.so.*
| 依赖关系：/bin/sh;glibc >= 2.34;libtinfo5 >= 6.3
| oct名称：libpanel5
| 功能说明：libpanel动态库
| 详细说明：提供/usr/lib64/libpanel.so.*
| 依赖关系：/bin/sh;glibc >= 2.34;libncurses5 >= 6.3
| oct名称：libtinfo5
| 功能说明：libtinfo动态库
| 详细说明：提供/lib64/libtinfo.so.*
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：ncurses
| 功能说明：CRT屏幕处理和优化包
| 详细说明：提供/usr/bin/tput、/usr/bin/tset功能
| 依赖关系：glibc >= 2.34;libtinfo5 >= 6.3
| oct名称：ncurses-terminfo
| 功能说明：终端描述数据库
| 详细说明：这是ncures包中维护的术语信息基本数据库。此数据库是4.4BSD术语帽文件的官方继承者，包含有关任何已知终端的信息。ncures库利用此数据库正确使用终端。
| 依赖关系：ncurses-terminfo-base
| oct名称：ncurses-terminfo-base
| 功能说明：提供终端信息基础
| 详细说明：提供/etc/terminfo/*
| 依赖关系：
| oct名称：nfs-utils
| 功能说明：NFS实用程序以及内核NFS服务器的支持客户端和守护程序
| 详细说明：nfs-utils软件包为内核NFS服务器和相关工具提供了一个守护程序，它提供了比大多数用户使用的传统Linux NFS服务器更高的性能级别。
| 依赖关系：glibc >= 2.34;libblkid1 >= 2.37.2;libtirpc3 >= 1.3.2;libuuid1 >= 2.37.2;nfs-utils-client
| oct名称：nfs-utils-client
| 功能说明：查询远程主机上的装载守护程序
| 详细说明：此软件包还包含showmount程序。Showmount查询远程主机上的装载守护程序，以了解有关远程主机上NFS（网络文件系统）服务器的信息。例如，showmount可以显示装载在该主机上的客户端。
| 依赖关系：config(nfs-utils-client) = 2.5.4-r0;glibc >= 2.34;libcap >= 2.61;libtirpc3 >= 1.3.2;nfs-utils-mount
| oct名称：nfs-utils-mount
| 功能说明：挂载或卸载文件系统
| 详细说明：此软件包还包含mount.nfs和umount.nfs程序。
| 依赖关系：glibc >= 2.34;libmount1 >= 2.37.2;libtirpc3 >= 1.3.2
| oct名称：openssh-keygen
| 功能说明：生成ssh公钥认证所需的公钥和私钥文件
| 详细说明：提供/usr/bin/ssh-keygen
| 依赖关系：glibc >= 2.34
| oct名称：openssh-misc
| 功能说明：ssh远程登陆管理主机
| 详细说明：提供/usr/bin/ssh、/usr/bin/ssh-add、/usr/bin/ssh-agent、/usr/bin/ssh-copy-id、/usr/bin/ssh-keyscan等
| 依赖关系：glibc >= 2.34;libz1 >= 1.2.11
| oct名称：openssh-scp
| 功能说明：远程复制命令
| 详细说明：提供/usr/bin/scp
| 依赖关系：glibc >= 2.34
| oct名称：openssh-sftp
| 功能说明：远程文件传输服务
| 详细说明：提供/usr/bin/sftp
| 依赖关系：glibc >= 2.34
| oct名称：openssh-sftp-server
| 功能说明：”sftp“协议的服务器端程序，使用加密的方式进行文件传输
| 详细说明：提供/usr/libexec/sftp-server
| 依赖关系：glibc >= 2.34
| oct名称：openssh-ssh
| 功能说明：ssh服务配置文件
| 详细说明：提供/etc/ssh/ssh_config
| 依赖关系：config(openssh-ssh) = 8.8p1-r0
| oct名称：openssh-sshd
| 功能说明：ssh服务进程启动
| 详细说明：提供/usr/sbin/sshd、/usr/libexec/openssh/sshd_check_keys等
| 依赖关系：config(openssh-sshd) = 8.8p1-r0;glibc >= 2.34;libpam >= 1.5.2;libz1 >= 1.2.11;openssh-keygen;pam-plugin-keyinit;pam-plugin-loginuid
| oct名称：openssl-conf
| 功能说明：openssl的主配置文件
| 详细说明：提供/etc/ssl/openssl.cnf
| 依赖关系：config(openssl-conf) = 1.1.1m-r0
| oct名称：libcrypto1.1
| 功能说明：OpenSSL crypto库
| 详细说明：提供/usr/lib64/libcrypto.so.*
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libssl1.1
| 功能说明：OpenSSL SSL库
| 详细说明：提供/usr/lib64/libssl.so.*
| 依赖关系：/bin/sh;glibc >= 2.34;libcrypto1.1 >= 1.1.1m
| oct名称：os-base
| 功能说明：提供OS基础
| 详细说明：提供hostname、passwd等配置信息
| 依赖关系：
| oct名称：libpci3
| 功能说明：PCI实用程序库
| 详细说明：libpci提供了对PCI配置空间的访问。
| 依赖关系：/bin/sh;glibc >= 2.34;libz1 >= 1.2.11
| oct名称：pciutils
| 功能说明：Linux内核的PCI实用程序
| 详细说明：lspci：此程序显示有关系统中所有PCI总线和设备的详细信息，取代原始的/proc/pci接口;;setpci：此程序允许读取和写入PCI设备配置寄存器。例如，您可以使用它调整延迟计时器;;update-pciids：此程序下载pci.ids文件的当前版本。
| 依赖关系：glibc >= 2.34;libpci3 >= 3.7.0;libz1 >= 1.2.11;pciutils-ids
| oct名称：pciutils-ids
| 功能说明：存放系统所有支持和不支持的硬件信息
| 详细说明：提供/usr/share/hwdata/pci.ids.gz
| 依赖关系：
| oct名称：policycoreutils
| 功能说明：显示当前seinux信息，修改selinux策略内各项规则的布尔值
| 详细说明：提供/etc/pam.d、/sbin/setsebool、/usr/bin/sestatus和/var/lib/selinux
| 依赖关系：glibc >= 2.34;libselinux1 >= 3.3;libsemanage2 >= 3.3
| oct名称：policycoreutils-fixfiles
| 功能说明：检查或矫正文件系统中的安全环境数据库
| 详细说明：提供/sbin/fixfiles
| 依赖关系：policycoreutils-setfiles
| oct名称：policycoreutils-hll
| 功能说明：提供/usr/libexec/selinux/hll/pp
| 详细说明：提供/usr/libexec/selinux/hll/pp
| 依赖关系：glibc >= 2.34;libsepol2 >= 3.3
| oct名称：policycoreutils-loadpolicy
| 功能说明：装载或替换新的二进制策略到内核中，保持使用当前的Bootlean值
| 详细说明：提供/sbin/load_policy
| 依赖关系：glibc >= 2.34;libselinux1 >= 3.3;libsepol2 >= 3.3
| oct名称：policycoreutils-semodule
| 功能说明：可以显示、加载、删除模块
| 详细说明：提供/sbin/semodule
| 依赖关系：glibc >= 2.34;libselinux;libsemanage2 >= 3.3;libsepol2 >= 3.3
| oct名称：policycoreutils-sestatus
| 功能说明：显示系统的详细状态
| 详细说明：提供/etc/sestatus.conf和/sbin/sestatus
| 依赖关系：libselinux;policycoreutils
| oct名称：policycoreutils-setfiles
| 功能说明：恢复或更改一部分文件的标签
| 详细说明：提供/sbin/restorecon、/sbin/restorecon_xattr和/sbin/setfiles
| 依赖关系：glibc >= 2.34;libselinux1 >= 3.3;libsepol2 >= 3.3
| oct名称：libpopt0
| 功能说明：一个用于解析命令行参数的C库
| 详细说明：Popt是一个用于解析命令行参数的C库。Popt受到getopt()和getopt_long()函数的严重影响。它通过允许更强大的参数扩展来改进它们。Popt可以解析任意argv[]样式数组，并根据命令行参数自动设置变量。Popt允许通过配置文件别名命令行参数，并包括用于使用类似shell的规则将任意字符串解析为argv[]数组的实用程序函数。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libprocps8
| 功能说明：procps库
| 详细说明：procps库可用于从/proc读取进程信息pseudo-file系统中的信息。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：procps
| 功能说明：/proc的ps实用程序
| 详细说明：procps包包含一组提供系统信息的系统实用程序。Procps包括ps、free、skill、snice、tload、top、uptime、vmstat、w和watch。
| 依赖关系：glibc >= 2.34;libncurses5 >= 6.3;libprocps8 >= 3.3.17;libtinfo5 >= 6.3;procps-sysctl
| oct名称：procps-sysctl
| 功能说明：控制和配置Linux内核及网络设置
| 详细说明：提供/etc/sysctl.conf
| 依赖关系：procps-lib
| oct名称：pstree
| 功能说明：显示进程状态树
| 详细说明：列出当前的进程，以及它们的树状结构
| 依赖关系：glibc >= 2.34;libtinfo5 >= 6.3
| oct名称：quota
| 功能说明：用于监控用户磁盘使用情况的系统管理工具
| 详细说明：包含系统管理工具，用于监控和限制每个文件系统的用户和或组磁盘使用情况。
| 依赖关系：glibc >= 2.34;libcom-err2 >= 1.46.4;libext2fs2 >= 1.46.4;libtirpc3 >= 1.3.2
| oct名称：libreadline8
| 功能说明：Readline库
| 详细说明：readline库由 Bourne Again Shell（bash，标准命令解释器）用于轻松编辑命令行。这包括历史记录和搜索功能。
| 依赖关系：/bin/sh;config(libreadline8) = 8.1-r0;glibc >= 2.34;libtinfo5 >= 6.3
| oct名称：rpcbind
| 功能说明：与传输无关的RPC端口映射程序
| 详细说明：Rpcbind是端口映射的替代品。虽然portmap仅支持INET (IPv4)上的UDP和TCP传输，但rpcbind可以配置为在TI-RPC支持的各种传输上工作。这包括IPv6上的TCP和UDP。此外，rpcbind还提供了有关端口映射的额外功能。
| 依赖关系：glibc >= 2.34;libtirpc3 >= 1.3.2
| oct名称：rsyslog
| 功能说明：用于Linux和Unix的增强系统日志
| 详细说明：Rsyslog是一个增强的多线程syslogd，支持MySQL、syslog/tcp、RFC 3195、允许的发件人列表、对任何消息部分的过滤和细粒度输出格式控制。它与库存sysklogd相当兼容，可以用作直接替换。;它的高级功能使它适合企业级、加密保护的系统日志中继链，同时也非常容易为新手用户设置。
| 依赖关系：config(rsyslog) = 8.2110.0-r0;glibc >= 2.34;libcurl4 >= 7.79.1;libestr0 >= 0.1.11;libfastjson4 >= 0.99.9;libuuid1 >= 2.37.2;libz1 >= 1.2.11;logrotate
| oct名称：sed
| 功能说明：GNU流文本编辑器
| 详细说明：sed（流编辑器）编辑器是流或批处理（非交互式）编辑器。Sed将文本作为输入，对文本执行操作或一组操作，并输出修改后的文本。sed执行的操作（替换、删除、插入等）可以在脚本文件或命令行中指定。
| 依赖关系：glibc >= 2.34
| oct名称：shadow
| 功能说明：用于管理用户和组帐户的实用程序
| 详细说明：此软件包包括将普通密码文件转换为影子密码格式以及管理用户和组帐户所需的程序。
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-runtime;pam-plugin-env;pam-plugin-faildelay;pam-plugin-group;pam-plugin-lastlog;pam-plugin-limits;pam-plugin-mail;pam-plugin-motd;pam-plugin-nologin;pam-plugin-rootok;pam-plugin-securetty;pam-plugin-shells;shadow-base;shadow-securetty
| oct名称：shadow-base
| 功能说明：提供sg工具
| 详细说明：提供/usr/bin/sg工具
| 依赖关系：
| oct名称：shadow-securetty
| 功能说明：安全终端
| 详细说明：提供/etc/securetty
| 依赖关系：
| oct名称：squashfs-tools
| 功能说明：用于创建squashfs文件系统的实用程序
| 详细说明：squashfs是Linux的高度压缩只读文件系统。此软件包包含用于操作squashfs文件系统的实用程序。
| 依赖关系：glibc >= 2.34;liblzma5 >= 5.2.5;libz1 >= 1.2.11
| oct名称：strace
| 功能说明：跟踪和显示与正在运行的进程关联的系统调用
| 详细说明：strace程序拦截并记录运行进程调用和接收的系统调用。strace可以打印每个系统调用、其参数和返回值的记录。strace对于诊断问题和调试以及教学目的都很有用。
| 依赖关系：glibc >= 2.34
| oct名称：tzdata-core
| 功能说明：时区说明
| 详细说明：描述可用时区的配置文件。
| 依赖关系：tzdata-core-2021e-r0.aarch64.rpm ;config(tzdata-core) = 2021e-r0
| oct名称：libblkid1
| 功能说明：块设备ID库
| 详细说明：块设备识别库，util-linux的一部分。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libfdisk1
| 功能说明：文件系统检测库
| 详细说明：用于文件系统检测的库。
| 依赖关系：/bin/sh;glibc >= 2.34;libblkid1 >= 2.37.2;libuuid1 >= 2.37.2
| oct名称：libmount1
| 功能说明：设备挂载库
| 详细说明：设计用于低级实用程序的库，如mount(8)和/usr/sbin/mount
| 依赖关系：/bin/sh;glibc >= 2.34;libblkid1 >= 2.37.2
| oct名称：libuuid1
| 功能说明：用于生成UUID的库
| 详细说明：用于生成通用唯一ID(UUID)的库。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：util-linux-su
| 功能说明：用于变更为其他使用者的身份
| 详细说明：提供su命令，用于变更使用者身份
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2
| oct名称：liblzma5
| 功能说明：Lempel–Ziv–Markov 链算法压缩库
| 详细说明：用于编码/解码LZMA文件的库。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：xz
| 功能说明：LZMA压缩实用程序
| 详细说明：XZ Utils试图使LZMA压缩易于在自由（如自由）操作系统上使用。这是通过提供类似于使用的工具和库来实现的，而不是最流行的现有压缩算法的等效工具和库。;LZMA是由伊戈尔·巴甫洛夫设计的通用压缩算法，作为7-Zip的一部分。它提供了高压缩比，同时保持了快速的解压缩速度。
| 依赖关系：glibc >= 2.34;liblzma5 >= 5.2.5
| oct名称：yajl
| 功能说明：又一个JSON库(YAJL)
| 详细说明：又是一个JSON库。YAJL是一个用ANSI C编写的小型事件驱动（SAX风格）JSON解析器，也是一个小型验证JSON生成器。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：libz1
| 功能说明：实现DEFLATE压缩算法的库
| 详细说明：zlib是一个通用的无损数据压缩库，实现了DEFLATE算法的API，例如gzip和ZIP存档格式正在使用后者。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：kernel
| 功能说明：Linux内核
| 详细说明：用于安装各组件
| 依赖关系：kernel-base
| oct名称：kernel-5.10.0
| 功能说明：内核模块
| 详细说明：用于内核模块
| 依赖关系：/bin/sh;kernel-image
| oct名称：kernel-image-5.10.0
| 功能说明：内核镜像
| 详细说明：用于安装内核镜像
| 依赖关系：kernel-image-zimage
| oct名称：kernel-image-zimage-5.10.0
| 功能说明：内核镜像
| 详细说明：提供zImage
| 依赖关系：/bin/sh
| oct名称：kernel-img
| 功能说明：内核镜像
| 详细说明：提供Image
| 依赖关系：
| oct名称：kernel-module-auth-rpcgss
| 功能说明：内核模块auth_rpcgss
| 详细说明：提供内核模块auth_rpcgss
| 依赖关系：/bin/sh;kernel-5.10.0;kernel-module-oid-registry;kernel-module-sunrpc
| oct名称：kernel-module-cifs
| 功能说明：内核模块cifs
| 详细说明：提供内核模块cifs
| 依赖关系：/bin/sh;kernel-5.10.0;kernel-module-libarc4;kernel-module-libdes
| oct名称：kernel-module-fscache
| 功能说明：内核模块fscache
| 详细说明：提供内核模块fscache
| 依赖关系：/bin/sh;kernel-5.10.0
| oct名称：kernel-module-grace
| 功能说明：内核模块grace
| 详细说明：提供内核模块grace
| 依赖关系：/bin/sh;kernel-5.10.0
| oct名称：kernel-module-ip-tables
| 功能说明：内核模块ip_tables
| 详细说明：提供内核模块ip_tables
| 依赖关系：/bin/sh;kernel-5.10.0;kernel-module-x-tables
| oct名称：kernel-module-ip6-tables
| 功能说明：内核模块ip6_tables
| 详细说明：提供内核模块ip6_tables
| 依赖关系：/bin/sh;kernel-5.10.0;kernel-module-x-tables
| oct名称：kernel-module-ip6table-filter
| 功能说明：内核模块ip6table_filter
| 详细说明：提供内核模块ip6table_filter
| 依赖关系：kernel-5.10.0;kernel-module-ip6-tables;kernel-module-x-tables
| oct名称：kernel-module-iptable-filter
| 功能说明：内核模块iptable_filter
| 详细说明：提供内核模块iptable_filter
| 依赖关系：kernel-5.10.0;kernel-module-ip-tables;kernel-module-x-tables
| oct名称：kernel-module-iptable-nat
| 功能说明：内核模块iptable_nat
| 详细说明：提供内核模块iptable_nat
| 依赖关系：kernel-5.10.0;kernel-module-ip-tables;kernel-module-nf-nat
| oct名称：kernel-module-libarc4
| 功能说明：内核模块libarc4
| 详细说明：提供内核模块libarc4
| 依赖关系：/bin/sh;kernel-5.10.0
| oct名称：kernel-module-libdes
| 功能说明：内核模块libdes
| 详细说明：提供内核模块libdes
| 依赖关系：/bin/sh;kernel-5.10.0
| oct名称：kernel-module-lockd
| 功能说明：内核模块lockd
| 详细说明：提供内核模块lockd
| 依赖关系：/bin/sh;kernel-5.10.0;kernel-module-grace;kernel-module-sunrpc
| oct名称：kernel-module-nf-conntrack
| 功能说明：内核模块nf_conntrack
| 详细说明：提供内核模块nf_conntrack
| 依赖关系：/bin/sh;kernel-5.10.0;kernel-module-nf-defrag-ipv4
| oct名称：kernel-module-nf-defrag-ipv4
| 功能说明：内核模块nf_defrag_ipv4
| 详细说明：提供内核模块nf_defrag_ipv4
| 依赖关系：/bin/sh;kernel-5.10.0
| oct名称：kernel-module-nf-defrag-ipv6
| 功能说明：内核模块nf_defrag_ipv6
| 详细说明：提供内核模块nf_defrag_ipv6
| 依赖关系：/bin/sh;kernel-5.10.0
| oct名称：kernel-module-nf-nat
| 功能说明：内核模块nf_nat
| 详细说明：提供内核模块nf_nat
| 依赖关系：/bin/sh;kernel-5.10.0;kernel-module-nf-conntrack
| oct名称：kernel-module-nfs-acl
| 功能说明：内核模块nfs_acl
| 详细说明：提供内核模块nfs_acl
| 依赖关系：/bin/sh;kernel-5.10.0;kernel-module-sunrpc
| oct名称：kernel-module-nfsd
| 功能说明：内核模块nfsd
| 详细说明：提供内核模块nfsd
| 依赖关系：/bin/sh;kernel-5.10.0;kernel-module-auth-rpcgss;kernel-module-grace;kernel-module-lockd;kernel-module-nfs-acl;kernel-module-sunrpc
| oct名称：kernel-module-nls-base
| 功能说明：内核模块nls_base
| 详细说明：提供内核模块nls_base
| 依赖关系：/bin/sh;kernel-5.10.0
| oct名称：kernel-module-oid-registry
| 功能说明：内核模块oid_registry
| 详细说明：提供内核模块oid_registry
| 依赖关系：/bin/sh;kernel-5.10.0
| oct名称：kernel-module-overlay
| 功能说明：内核模块overlay
| 详细说明：提供内核模块overlay
| 依赖关系：/bin/sh;kernel-5.10.0
| oct名称：kernel-module-sunrpc
| 功能说明：内核模块sunrpc
| 详细说明：提供内核模块sunrpc
| 依赖关系：/bin/sh;kernel-5.10.0
| oct名称：kernel-module-unix
| 功能说明：内核模块unix
| 详细说明：提供内核模块unix
| 依赖关系：/bin/sh;kernel-5.10.0
| oct名称：kernel-module-x-tables
| 功能说明：内核模块x_tables
| 详细说明：提供内核模块x_tables
| 依赖关系：/bin/sh;kernel-5.10.0
| oct名称：kernel-vmlinux
| 功能说明：内核镜像
| 详细说明：提供vmlinux
| 依赖关系：
| oct名称：libpam
| 功能说明：为应用程序提供身份验证的可扩展库
| 详细说明：提供/lib64/libpam.so.*、/lib64/libpam_misc.so.*和/lib64/libpamc.so.*
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：pam-plugin-access
| 功能说明：pam_access.so动态库
| 详细说明：提供/lib64/security/pam_access.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：libpam-runtime
| 功能说明：pam实用程序
| 详细说明：PAM（可插拔身份验证模块）是一种系统安全工具，允许系统管理员设置身份验证策略，而不必重新编译处理身份验证的程序。
| 依赖关系：config(libpam-runtime) = 1.5.2-r0;glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64;pam-plugin-deny-suffix64;pam-plugin-permit-suffix64;pam-plugin-unix-suffix64;pam-plugin-warn-suffix64
| oct名称：pam-plugin-debug
| 功能说明：pam_debug.so动态库
| 详细说明：提供/lib64/security/pam_debug.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-deny
| 功能说明：pam_deny.so动态库
| 详细说明：提供/lib64/security/pam_deny.so
| 依赖关系：libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-echo
| 功能说明：pam_echo.so动态库
| 详细说明：提供/lib64/security/pam_echo.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-env
| 功能说明：pam_env.so动态库
| 详细说明：提供/lib64/security/pam_env.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-exec
| 功能说明：pam_exec.so动态库
| 详细说明：提供/lib64/security/pam_exec.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-faildelay
| 功能说明：pam_faildelay.so动态库
| 详细说明：提供/lib64/security/pam_faildelay.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-faillock
| 功能说明：pam_faillock.so动态库
| 详细说明：提供/lib64/security/pam_faillock.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-filter
| 功能说明：pam_filter.so动态库
| 详细说明：提供/lib64/security/pam_filter.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-ftp
| 功能说明：pam_ftp.so动态库
| 详细说明：提供/lib64/security/pam_ftp.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-group
| 功能说明：pam_group.so动态库
| 详细说明：提供/lib64/security/pam_group.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-issue
| 功能说明：pam_issue.so动态库
| 详细说明：提供/lib64/security/pam_issue.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-keyinit
| 功能说明：pam_keyinit.so动态库
| 详细说明：提供/lib64/security/pam_keyinit.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-lastlog
| 功能说明：pam_lastlog.so动态库
| 详细说明：提供/lib64/security/pam_lastlog.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-limits
| 功能说明：pam_limits.so动态库
| 详细说明：提供/lib64/security/pam_limits.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-listfile
| 功能说明：pam_listfile.so动态库
| 详细说明：提供/lib64/security/pam_listfile.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-localuser
| 功能说明：pam_localuser.so动态库
| 详细说明：提供/lib64/security/pam_localuser.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-loginuid
| 功能说明：pam_loginuid.so动态库
| 详细说明：提供/lib64/security/pam_loginuid.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-mail
| 功能说明：pam_mail.so动态库
| 详细说明：提供/lib64/security/pam_mail.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-mkhomedir
| 功能说明：pam_mkhomedir.so动态库
| 详细说明：提供/lib64/security/pam_mkhomedir.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-motd
| 功能说明：pam_motd.so动态库
| 详细说明：提供/lib64/security/pam_motd.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-namespace
| 功能说明：pam_namespace.so动态库
| 详细说明：提供/lib64/security/pam_namespace.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-nologin
| 功能说明：pam_nologin.so动态库
| 详细说明：提供/lib64/security/pam_nologin.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-permit
| 功能说明：pam_permit.so动态库
| 详细说明：提供/lib64/security/pam_permit.so
| 依赖关系：libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-pwhistory
| 功能说明：pam_pwhistory.so动态库
| 详细说明：提供/lib64/security/pam_pwhistory.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-rhosts
| 功能说明：pam_rhostsso动态库
| 详细说明：提供/lib64/security/pam_rhostsso
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-rootok
| 功能说明：pam_rootok.so动态库
| 详细说明：提供/lib64/security/pam_rootok.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-securetty
| 功能说明：pam_securetty.so动态库
| 详细说明：提供/lib64/security/pam_securetty.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-setquota
| 功能说明：pam_setquota.so动态库
| 详细说明：提供/lib64/security/pam_setquota.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-shells
| 功能说明：pam_shells.so动态库
| 详细说明：提供/lib64/security/pam_shells.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-stress
| 功能说明：pam_stress.so动态库
| 详细说明：提供/lib64/security/pam_stress.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-succeed-if
| 功能说明：pam_succeed_if.so动态库
| 详细说明：提供/lib64/security/pam_succeed_if.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-time
| 功能说明：pam_time.so动态库
| 详细说明：提供/lib64/security/pam_time.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-timestamp
| 功能说明：pam_timestamp.so动态库
| 详细说明：提供/lib64/security/pam_timestamp.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-umask
| 功能说明：pam_umask.so动态库
| 详细说明：提供/lib64/security/pam_umask.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-unix
| 功能说明：pam_unix.so动态库
| 详细说明：提供/lib64/security/pam_unix.so
| 依赖关系：libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-usertype
| 功能说明：pam_usertypeso动态库
| 详细说明：提供/lib64/security/pam_usertypeso
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-warn
| 功能说明：pam_warn.so动态库
| 详细说明：提供/lib64/security/pam_warn.so
| 依赖关系：libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-wheel
| 功能说明：pam_wheel.so动态库
| 详细说明：提供/lib64/security/pam_wheel.so
| 依赖关系：glibc >= 2.34;libpam >= 1.5.2;libpam-suffix64
| oct名称：pam-plugin-xauth
| 功能说明：pam_xauth.so动态库
| 详细说明：提供/lib64/security/pam_xauth.so
| 依赖关系：libpam >= 1.5.2;libpam-suffix64
| oct名称：gdb
| 功能说明：用于C、C++、Fortran和其他语言的GNU源代码级调试器
| 详细说明：GDB是GNU调试器，允许您调试用C、C++、Java和其他语言编写的程序，方法是以受控的方式执行这些程序并打印它们的数据。
| 依赖关系：gcc-bin-toolchain-compilerlibs-aarch64 >= 1.0;glibc >= 2.34;libexpat1 >= 2.4.1;libgmp10 >= 6.2.1;libreadline8 >= 8.1;libtinfo5 >= 6.3
| oct名称：gdbserver
| 功能说明：GDB（GNU源级调试器）的独立服务器
| 详细说明：此软件包提供了一个程序，允许您在运行正在调试程序的计算机之外的计算机上运行GDB。
| 依赖关系：gcc-bin-toolchain-compilerlibs-aarch64 >= 1.0;glibc >= 2.34
| oct名称：libgmp10
| 功能说明：一个用于计算巨大数字的库
| 详细说明：GMP是一个用于任意精度算术的库，对有符号整数、有理数和浮点数进行操作。
| 依赖关系：/bin/sh;glibc >= 2.34
| oct名称：os-release
| 功能说明：添加openeuler版本信息
| 详细说明：添加openeuler版本信息，同时添加os-revision记录构建时间戳。;生成的镜像也放到时间戳目录便于区分不同版本
| 依赖关系：
| oct名称：packagegroup-base
| 功能说明：
| 详细说明：使用yocto的packagegroup类对openeuler的发布包按类型等进行分组，便于在image和sdk中添加包
| 依赖关系：
| oct名称：packagegroup-core-base-utils
| 功能说明：
| 详细说明：使用yocto的packagegroup类对openeuler的发布包按类型等进行分组，便于在image和sdk中添加包
| 依赖关系：
| oct名称：packagegroup-core-boot
| 功能说明：
| 详细说明：使用yocto的packagegroup类对openeuler的发布包按类型等进行分组，便于在image和sdk中添加包
| 依赖关系：
| oct名称：packagegroup-debugtools
| 功能说明：
| 详细说明：使用yocto的packagegroup类对openeuler的发布包按类型等进行分组，便于在image和sdk中添加包
| 依赖关系：
| oct名称：packagegroup-isulad
| 功能说明：
| 详细说明：使用yocto的packagegroup类对openeuler的发布包按类型等进行分组，便于在image和sdk中添加包
| 依赖关系：
| oct名称：packagegroup-openssh
| 功能说明：
| 详细说明：使用yocto的packagegroup类对openeuler的发布包按类型等进行分组，便于在image和sdk中添加包
| 依赖关系：
| oct名称：packagegroup-pam-plugins
| 功能说明：
| 详细说明：使用yocto的packagegroup类对openeuler的发布包按类型等进行分组，便于在image和sdk中添加包
| 依赖关系：

