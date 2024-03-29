.. _network_config:

openEuler Embedded网络配置
##############################

本文档将以树莓派4B配置为例，介绍如何在openEuler Embedded系统中配置网络，其它平台上的配置方法与树莓派类似。

有线网络配置
========================

.. note::

   根据使用的 init 程序，openEuler Embedded 提供了不同的网络配置管理：

   - 针对 busybox 镜像，使用 ``/etc/network/interfaces`` 实现基础的网络配置。
   - 针对 systemd 镜像，使用 ``systemd-networkd`` 进行网络配置。

   可以通过 ``ls -l $(which init)`` 确认您当前使用的镜像类型，并采用对应的网络配置方法。

1. 使用 /etc/network/interfaces 进行网络配置
--------------------------------------------

- **动态获取IP地址**

  如果树莓派通过网线连接了路由器，在树莓派启动时，会通过 dhclient 服务来获取IP。

  因为在 ``/etc/network/interfaces`` 文件中，有线网卡默认的配置是通过DHCP自动获取，即:

  .. code-block:: console

    # Wired or wireless interfaces
    auto eth0             # 系统启动后默认开启eth0网卡
    iface eth0 inet dhcp  # eth0 网卡使用DHCP来获取IP地址
    iface eth1 inet dhcp

- **配置静态IP地址**

  如果网线另一端设备未提供DHCP服务时，此时需要在两端设备上同时配置静态IP才能正常通信。

  1. 临时配置:

     在两端同时配置IP地址, 确保在同一子网中即可通信

     .. code-block:: console

        $ ifconfig <有线网卡名称> 192.168.10.x

  2. 永久配置:

    修改 ``/etc/network/interfaces`` 文件，为对应的有线网卡配置静态IP，以eth0为例：

    .. code-block:: console

       # 删除 iface eth0 inet dhcp，并配置静态IP:
       iface eth0 inet static        # eth0 网卡使用静态IP地址
           address 192.168.10.x      # IP地址
           netmask 255.255.255.0
           gateway 192.168.10.1

    修改成功后, 需要重启networking service更新配置文件：

    .. code-block:: console

       $ service networking restart

    更新配置文件后如果有线网卡没有自动启用的话, 可以手动使用命令up/down

    .. code-block:: console

       ifdown eth0
       ifup eth0

    最后可以通过ifconfig查看对应网卡的IP地址

    .. code-block:: console

       root@raspberrypi4-64:~# ifconfig
       eth0      Link encap:Ethernet  HWaddr xx:xx:xx:xx:xx:xx
             inet addr:192.168.10.x  Bcast:0.0.0.0  Mask:255.255.255.0
             UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
             RX packets:277 errors:0 dropped:0 overruns:0 frame:0
             TX packets:157 errors:0 dropped:0 overruns:0 carrier:0
             collisions:0 txqueuelen:1000
             RX bytes:30734 (30.0 KiB)  TX bytes:23751 (23.1 KiB)

       lo        Link encap:Local Loopback
             inet addr:127.0.0.1  Mask:255.0.0.0
             UP LOOPBACK RUNNING  MTU:65536  Metric:1
             RX packets:2 errors:0 dropped:0 overruns:0 frame:0
             TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
             collisions:0 txqueuelen:1000
             RX bytes:140 (140.0 B)  TX bytes:140 (140.0 B)

  .. seealso::

     关于 ``/etc/network/interfaces`` 的详细解释，可以参考 `network interface manpage。 <https://manpages.debian.org/stretch/ifupdown/interfaces.5.en.html>`_

2. 使用 systemd-networkd 进行网络配置
-------------------------------------

systemd-networkd.service 使用 ``.network`` 单元来进行网络配置，示例如下：

- **动态获取IP地址**

  .. code-block:: console

    # 1. 创建 eth0 对应的 network unit，并修改权限：
    $ cd /etc/systemd/network
    $ touch 50-eth0.network
    $ chmod 644 50-eth0.network

    # 2. 修改该文件，为 eth0 开启 DHCP：
    # 注意：[Match] 下的 Name 需要与网卡名称匹配。
    $ vi 50-eth0.network

      [Match]
      Name=eth0

      [Network]
      DHCP=yes

    # 3. 重启systemd服务，使网络配置生效：
    $ systemctl enable --now systemd-networkd

    # 4. 确认网络配置是否成功：
    $ ifconfig eth0

- **配置静态IP地址**

  .. code-block:: console

    # 1. 创建 eth0 对应的 network unit，并修改权限：
    $ cd /etc/systemd/network
    $ touch 50-eth0.network
    $ chmod 644 50-eth0.network

    # 2. 修改该文件，为 eth0 配置静态IP地址。
    # 注意：[Match] 下的 Name 需要与网卡名称匹配。
    $ vi 50-eth0.network

      [Match]
      Name=eth0

      [Network]
      DHCP=no
      Address=192.168.10.8/24

    # 3. 重启systemd服务，使网络配置生效：
    $ systemctl enable --now systemd-networkd

    # 4. 确认网络配置是否成功：
    $ ifconfig eth0

  .. seealso::

     关于 ``systemd network`` 的详细解释，可以参考 `systemd network manpage。 <https://www.jinbuguo.com/systemd/systemd.network.html>`_

____

.. _network_config_wifi:

Wi-Fi网络配置
================================================

.. attention::

  当前只有22.09之后的版本默认支持以下方式配置Wi-Fi

当前树莓派Wi-Fi网络配置包括三部分: **1.使能无线驱动 2.增加Wi-Fi配置 3.启用Wi-Fi网卡**

- **使能无线驱动**

  修改/etc/network/interfaces文件中无线网卡wlan0的配置
  
  .. code-block:: console

     iface wlan0 inet dhcp
            wireless_mode managed
            wireless_essid any
            wpa-driver wext
            wpa-conf /etc/wpa_supplicant.conf
     # 当前树莓派所使用的无线网卡驱动是 nl80211系列
     # 因此将wpa-driver wext 改为 wpa-driver nl80211
     # 才能正确启动wpa_supplicant
     iface wlan0 inet dhcp
            wireless_mode managed
            wireless_essid any
            wpa-driver nl80211
            wpa-conf /etc/wpa_supplicant.conf

  修改完成后重启networking service使配置生效

- **增加Wi-Fi配置**

  通过wpa_supplicant配置文件增加Wi-Fi网络

  .. note::

    wpa_supplicant 是一款开源用户态软件, 其主要功能是提供用户和Wi-Fi驱动之间沟通的桥梁, 以及对Wi-Fi协议和加密认证. 是目前使用范围较广的Wi-Fi配置工具, 也还有其他配置工具wireless-tools, 当前openEuler Embedded仅引入wpa_supplicant工具.

  修改wpa_supplicant启动时所指定的配置文件/etc/wpa_supplicant.conf, 增加如下network字段的配置, 最简单的network配置可以只需要ssid和psk字段即可. 其他高级选项和字段可以参考: `wpa_supplicant官网文档 <http://w1.fi/cgit/hostap/plain/wpa_supplicant/README>`_

  .. code-block:: console

     network={
        # ssid Wi-Fi网络名称
        ssid="home"
        # psk Wi-Fi网络密码
        psk="very secret passphrase"
        # 可选, 隐藏的网络必须指定为1
        scan_ssid=1
        # 加密类型协议, 可选, 无此字段时会默认包含 WPA-PSK WPA-EAP
        key_mgmt=WPA-PSK
     }

  如果担心配置文件中明文密码泄漏, 可以使用wpa_passphrase工具加密后再写入配置文件即可, 其用法为: wpa_passphrase <ssid> <psk>

  .. code-block:: console

     wpa_passphrase test 12345678
     # 工具会输出如下形式, 将加密后的psk复制到配置文件中, 删除明文即可
     network={
        ssid="test"
        #psk="12345678"	    
        psk=fe727aa8b64ac9b3f54c72432da14faed933ea511ecab15bbc6c52e7522f709a
     }

- **启用Wi-Fi网卡**

  使用ifup启动Wi-Fi连接并自动获取IP地址

  .. code-block:: console

    root@raspberrypi4-64:~# ifup wlan0                  
    Successfully initialized wpa_supplicant

  使用ifconfig命令查看wlan0网卡, 已经具有IP地址, 并可以正常通信

  .. code-block:: console

    root@raspberrypi4-64:~# ifconfig
    eth0      Link encap:Ethernet  HWaddr xx:xx:xx:xx:xx:xx
            inet addr:192.168.10.x  Bcast:0.0.0.0  Mask:255.255.255.0
            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
            RX packets:565 errors:0 dropped:0 overruns:0 frame:0
            TX packets:425 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000 
            RX bytes:73072 (71.3 KiB)  TX bytes:51915 (50.6 KiB)

    lo        Link encap:Local Loopback  
            inet addr:127.0.0.1  Mask:255.0.0.0
            UP LOOPBACK RUNNING  MTU:65536  Metric:1
            RX packets:2 errors:0 dropped:0 overruns:0 frame:0
            TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000 
            RX bytes:140 (140.0 B)  TX bytes:140 (140.0 B)

    wlan0     Link encap:Ethernet  HWaddr xx:xx:xx:xx:xx:xx  
            inet addr:192.168.43.x  Bcast:192.168.43.255  Mask:255.255.255.0
            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
            RX packets:2 errors:0 dropped:0 overruns:0 frame:0
            TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000 
            RX bytes:365 (365.0 B)  TX bytes:432 (432.0 B)


  .. attention::
     
    当修改/etc/wpa_supplicant.conf配置文件后, 例如新增Wi-Fi网络配置或修改Wi-Fi网络配置, 需要使用ifdown wlan0来关闭网卡, ifup wlan0开启网卡使wpa_supplicant配置重新加载生效
