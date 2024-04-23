.. _hieulerpi-wifi:

海鸥派wifi使用
#####################

.. contents::

Station模式(连接wifi)
===========================

海鸥派使用wpa_supplicant管理网络连接。 ``wpa_supplicant`` 与 ``wpa_cli`` 需要
配合使用。wpa_supplicant用于后台网络管理，wpa_cli用于前台命令行交互。每个
wpa_supplicant进程管理一个无线网卡，多个无线网卡时需要启用多个进程进行管理。因此在执
行wpa_cli命令之前需要启动wpa_supplicant服务。下面介绍具体的使用方法。

启动wpa_supplicant
-----------------------------

wpa_supplicant有几个常用参数：

1. 指定配置文件 -c

2. 指定后台执行 -B

3. 指定管理的网络接口 -i

由于每个wpa_supplicant只管理一个wifi网卡，所以在启动时需要指定要管理的wifi网卡。

wpa_supplicant的配置文件路径一般是： ``/etc/wpa_supplicant``

.. code:: bash

   # 启动守护进程管理wlan0,
   # 指定配置文件为wpa_supplicant.conf
   # -B指定后台执行
   wpa_supplicant -B -iwlan0 -c/etc/wpa_supplicant.conf

.. note::

    参数\ ``-p``\ 用于指定进程间通信文件路径，如果不指定默认是\ ``/var/run/wpa_supplicant``\ ，
    如果\ ``wpa_supplicant``\ 指定了其它路径，则后续使用\ ``wpa_cli``\ 也要指定对应的路径。否则
    wpa_cli与wpa_supplicant无法通信。此处不指定，使用默认配置。

wpa_supplicant配置文件
--------------------------------

wpa_supplicant.conf文件最简可以是空文件，但是必须存在。一般包含如下内容。

.. code:: 

   ctrl_interface=/var/run/wpa_supplicant
   ctrl_interface_group=0
   update_config=1

如果希望wpa_supplicant启动直接连接网络则可以直接在配置文件中写入wifi信息。例如下面这样

.. code:: 

   ctrl_interface=/var/run/wpa_supplicant
   ctrl_interface_group=0
   update_config=1

   network={
       ssid="<wifi名>"
       psk="<wifi密码>"
   }

wpa_cli控制无线网卡
-------------------

常用命令
~~~~~~~~

+----------------+-------------------------+-------------------------+
| 命令           | 功能                    | 举例                    |
+================+=========================+=========================+
| interface      | 交互模式下指定无线网卡  | > interface wlan0       |
+----------------+-------------------------+-------------------------+
| scan           | 扫描附近wifi            |                         |
+----------------+-------------------------+-------------------------+
| scan_result    | 打印扫描结果            |                         |
+----------------+-------------------------+-------------------------+
| add_network    | 添加                    |                         |
|                | 一个新网络并返回网络ID  |                         |
+----------------+-------------------------+-------------------------+
| set_network    | 设置网络属性            | set_network             |
|                |                         | <network_id> ssid '""'  |
|                |                         | # 设置网络ssid          |
|                |                         | set_network             |
|                |                         | <network_id> psk '""' # |
|                |                         | 设置网络密码            |
|                |                         | set_network             |
|                |                         | <network_id> priority # |
|                |                         | 设置网络优先级          |
+----------------+-------------------------+-------------------------+
| enable_network | 使能网络                | enable_network          |
|                |                         | <network_id> #          |
|                |                         | 使能指定网络            |
+----------------+-------------------------+-------------------------+
| select_network | 选择连接已设置的网络    | select_network          |
|                |                         | <network_id>            |
+----------------+-------------------------+-------------------------+
| disconnect     | 断开网络连接            |                         |
+----------------+-------------------------+-------------------------+
| reconnect      | 重新连接到wifi          |                         |
+----------------+-------------------------+-------------------------+
| save_config    | 保存配置到配置文件      |                         |
+----------------+-------------------------+-------------------------+
| list_networks  | 列出当前保存的网络      |                         |
+----------------+-------------------------+-------------------------+
| terminate      | 终止wpa_supplicant服务  |                         |
+----------------+-------------------------+-------------------------+

交互形式
~~~~~~~~

可以直接运行\ ``wpa_cli``

.. code:: bash

   wpa_cli
   > interface wlan0 # 选择wlan0网口，如果只有一个的话可以不输入，默认选择wlan0
   > scan # 扫描附近wifi
   > scan_result # 显示wifi扫描结果
   > add_network # 添加一个新wifi,执行后会返回新网络的id,后续会用到
   > set_network <network_id> ssid '"<SSID>"' # 设置新网络的wifi名称，注意此处双引号外要再包裹一层单引号
   > set_network <network_id> psk '"<password>"' # 设置新网络的密码
   > enable_network <network_id> # 启用网络，此时会自动连接
   > save_config # 保存配置到配置文件
   > quit # 退出交互

命令形式
~~~~~~~~

命令形式只是在交互形式的基础上指定无线网卡,下面仅做举例说明

.. code:: bash

   wpa_cli -iwlan0 scan
   wpa_cli -iwlan0 scan_result

DHCP(动态获取IP)
------------------------

在连接到wifi后需要设置本地无线网卡的IP，保证海鸥派与路由设备在同一网段。

使用dhclient命令从网络动态获取IP。

.. code:: shell

    dhclient wlan0

AP模式(创建热点)
===========================

海鸥派使用hostapd服务管理热点。

修改配置文件
----------------

hostapd的配置文件路径： ``/etc/hostapd.conf`` ，需要修改的内容如下。

.. code:: shell

    # 指定开启热点的网卡
    interface=wlan0
    # 指定热点ssid
    ssid=test
    # 设置wpa模式
    wpa=2
    # 设置热点密码(没有该选项时可自行添加)
    wpa_passphrase=test1234

启动hostapd
----------------

.. code:: shell

    # 开启wlan0网卡
    ifconfig wlan0 up
    # 设置wlan0 IP地址
    ifconfig wlan0 192.168.1.1
    # 开启热点
    hostapd /etc/hostapd.conf -ddd &

DHCPD(为连接的设备分配IP)
-------------------------------

使用dhcpd服务为连接到当前热点的设备分配IP,对应的配置文件为： ``/etc/dhcp/dhcpd.conf``。
需要在海鸥派原来的配置文件后追加以下内容。

.. note::

    不使用DHCPD，只要设备与开发板正常连接使用静态IP也可以正常通信。手机或者平板等设备则可能会
    由于无法自动获取到IP地址认为热点有问题而自动断开。

.. code:: shell
    
    subnet 192.168.1.0 netmask 255.255.255.0 {
        range 192.168.1.10 192.168.1.100;
        option routers 192.168.1.1;
        option subnet-mask 255.255.255.0;
        option domain-name-servers 192.168.1.1;
    }


其中 ``range`` 的部分指定了分配IP的范围； ``routers`` 为连接的设备指定路由； ``subnet-mask``
为连接的设备指定子网掩码； ``domain-name-servers`` 为连接的设备指定域名服务器。