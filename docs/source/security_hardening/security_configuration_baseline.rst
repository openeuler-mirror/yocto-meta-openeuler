.. raw:: html

   <center>

openEuler Embedded安全配置基线

.. raw:: html

   </center>

.. raw:: html

   <div style="page-break-after:always;">

.. raw:: html

   </div>

.. raw:: html

   <div style="page-break-after:always;">

.. raw:: html

   </div>

.. raw:: html

   <div style="clear:both;" />

.. raw:: html

   <div style="page-break-after:always;">

.. raw:: html

   </div>

--------------

概述
=======================

目的
-----------

本文旨在指导openEuler Embedded用户根据自身使用场景，正确使用和配置、加固操作系统，从而获得安全可靠的服务。

使用对象
--------------

本文的读者及使用对象是使用openEuler Embedded系列版本的人员，及需要了解openEuler Embedded系列版本安全机制的开发、测试等人员。 

适用范围
--------------------

本基线适用于使用openEuler Embedded作为操作系统的人员。 

基线解释
--------------------------

本基线由openEuler Embedded团队输出并维护，落地实施过程中遇到问题，请在社区上讨论。

规则组织方式
------------------------------------------

每个安全配置规则内容都有统一的结构，各字段描述如下：

**规则背景说明** ：用于对规则进行解读说明。

**检查方法** ：提供该规则项的检查方法。提供经过验证的检查命令。

规则
======================

文件系统保护
----------------------------------------

确保/tmp、/var和/dev/shm所在分区设置合适的挂载选项
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

为了防止给系统带来风险，外置存储、日志分区、临时存储分区中不要有可执行文件、setuid可执行文件、设备节点等文件，各分区应使用nodev,
nosuid, noexec,
ro等挂载选项。对于数据文件等分区应以noexec方式挂载分区；对于文件禁止修改的分区应以ro方式挂载；对于不需要SUID/SGID的分区应以nosuid方式挂载；/var日志分区、/tmp目录应以nodev方式挂载。请根据场景判断分区挂载选项的合理性，使用对应的挂载选项。

**检查方法：**

查看/var日志分区、/tmp和/dev/shm是否设置了合适的挂载选项。
例如，通过以下命令查看是否为/var日志分区目录设置了合适的挂载选项：

.. code-block:: bash

    # 假设/var整个目录都为日志所用
    mount | grep var
    none on /var type tmpfs (rw,nosuid,nodev,relatime,mode=755)
    # 或 假设/var/volatile为对应日志分区
    mount | grep var
    tmpfs on /var/volatile type tmpfs (rw,nosuid,nodev,relatime,mode=755)

编辑/etc/fstab文件：

.. code-block:: bash

    <file system>        <dir>         <type>    <options>             <dump> <pass>
    /dev/sda1              /              ext4      acl,user_xattr          0      1
    /dev/sda2              /tmp           ext4      nodev,nosuid,noexec     0      0

-  nosuid：表示分区内的二进制文件无法使用setuid权限运行，应对不包含suid可执行文件的分区进行设置。
-  noexec:：表示分区不能包含可执行的二进制文件。
-  nodev：表示分区不能包含设备节点文件。
-  ro：表示分区以只读方式挂载。

确保系统中的重要文件和目录设置严格的访问权限
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

确保在系统中的重要文件和目录的权限设置正确，文件或目录仅能够被赋予该权限的用户或属组访问。

对系统中的文件，建议按文件类型进行访问权限设置：

-  配置文件：644或更严格
-  日志类文件：640或更严格
-  二进制可执行文件：755或更严格
-  库文件：755或更严格

**检查方法：**

系统中部分重要文件的权限见下表，不建议弱化这些文件/目录的默认权限设置：

+--------------------------+----------+----------+----------+
| **文件或目录**           | **属主** | **属组** | **权限** |
+==========================+==========+==========+==========+
| /dev/mem                 | root     | root     | 0640     |
+--------------------------+----------+----------+----------+
| /etc/fstab               | root     | root     | 0600     |
+--------------------------+----------+----------+----------+
| /etc/group               | root     | root     | 0644     |
+--------------------------+----------+----------+----------+
| /etc/init.d/             | root     | root     | 0750     |
+--------------------------+----------+----------+----------+
| /etc/init.d/\*           | root     | root     | 0750     |
+--------------------------+----------+----------+----------+
| /etc/passwd              | root     | root     | 0644     |
+--------------------------+----------+----------+----------+
| /etc/securetty           | root     | root     | 0600     |
+--------------------------+----------+----------+----------+
| /etc/security/opasswd    | root     | root     | 0600     |
+--------------------------+----------+----------+----------+
| /etc/shadow              | root     | root     | 0600     |
+--------------------------+----------+----------+----------+
| /etc/ssh/\*key           | root     | root     | 0400     |
+--------------------------+----------+----------+----------+
| /etc/ssh/\*key.pub       | root     | root     | 0644     |
+--------------------------+----------+----------+----------+
| /etc/ssh/sshd_config     | root     | root     | 0600     |
+--------------------------+----------+----------+----------+
| /etc/sysctl.conf         | root     | root     | 0600     |
+--------------------------+----------+----------+----------+
| /lib/modules/            | root     | root     | 0750     |
+--------------------------+----------+----------+----------+
| /root/                   | root     | root     | 0700     |
+--------------------------+----------+----------+----------+
| /tmp/                    | root     | root     | 1777     |
+--------------------------+----------+----------+----------+
| /dev/shm                 | root     | root     | 1777     |
+--------------------------+----------+----------+----------+
| /var/log/audit/          | root     | root     | 0750     |
+--------------------------+----------+----------+----------+
| /var/log/audit/audit.log | root     | root     | 0600     |
+--------------------------+----------+----------+----------+
| /var/log/                | root     | root     | 0750     |
+--------------------------+----------+----------+----------+
| /var/log/\*              | root     | root     | 0640     |
+--------------------------+----------+----------+----------+
| /var/log/secure或auth.log| root     | root     | 0640     |
+--------------------------+----------+----------+----------+
| /var/log/wtmp            | root     | root     | 0640     |
+--------------------------+----------+----------+----------+
| /bin/                    | root     | root     | 0755     |
+--------------------------+----------+----------+----------+
| /etc/                    | root     | root     | 0755     |
+--------------------------+----------+----------+----------+
| /home/                   | root     | root     | 0755     |
+--------------------------+----------+----------+----------+
| /lib/                    | root     | root     | 0755     |
+--------------------------+----------+----------+----------+
| /dev/                    | root     | root     | 0755     |
+--------------------------+----------+----------+----------+
| /init（软链接）          | root     | root     | 0777     |
+--------------------------+----------+----------+----------+
| /sbin/init               | root     | root     | 0755     |
+--------------------------+----------+----------+----------+
| /var/volatile/log        | root     | root     | 0750     |
+--------------------------+----------+----------+----------+
| /etc/motd                | root     | root     | 0644     |
+--------------------------+----------+----------+----------+
| /etc/issue               | root     | root     | 0644     |
+--------------------------+----------+----------+----------+
| /etc/issue.net           | root     | root     | 0644     |
+--------------------------+----------+----------+----------+

例如，通过以下命令检查/var/log/wtmp文件的权限设置，如果有返回结果则检查成功，否则检查失败：

.. code-block:: bash

    # find /var/log/wtmp -type f -user root -group root -perm 640
    /var/log/wtmp

确保umask缺省值设置为027或更严格
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

umask决定了用户创建的文件和目录的默认权限，一般在/etc/bashrc，/etc/profile.d/\*.sh，/etc/profile、$HOME/.bash_profile或$HOME/.profile中设置umask值。因此，系统必须设置umask值，推荐值为027或更严格。

umask如果设置不合理，可能导致新建文件权限过小或过大，从而影响系统正常运行或导致安全风险。

**检查方法：**

-  执行umask命令，查询默认的umask值：

.. code-block:: bash

    # umask
    0077

-  检查配置文件/etc/login.defs、/etc/profile、/etc/bashrc中umask值是否正确。例如，以下命令检查/etc/login.defs文件，获得umask值为077：

.. code-block:: bash

    # grep -iE "^\s*umask\s+" /etc/login.defs
    UMASK 077

-  使用root用户登录，创建文件或目录，确认权限是否正确：

.. code-block:: bash

    # touch test
    # ll test
    -rw-------    1 root     root             0 May 17 23:34 test

    # mkdir testdir
    # ll -d testdir/
    drwx------    2 root     root            40 May 17 23:35 testdir/

-  使用普通账户test登录，创建文件或目录，确认权限是否正确：

.. code-block:: bash

    $ touch test
    $ ll test
    -rw-------    1 test     test             0 May 17 23:55 test

    $ mkdir testdir
    $ ll -d testdir/
    drwx------    2 test     test            40 May 17 23:55 testdir/

-  其他说明：使用ssh -C远程命令（如ssh root@xxx -C "umask"）或scp时，在/etc/profile等文件中配置的umask不会生效，因为ssh远程命令是非login shell，所以不会触发/etc/profile、bashrc中的umask。该情况的配置为高安全要求，可能影响ssh、scp的基本功能使用，在版本中不做自动配置，用户如需要进行加固，可通过在/etc/pam.d/sshd中加入如下内容：

.. code-block:: bash

    session optional pam_umask.so umask=0077

确保全局可写目录设置粘滞位
~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

全局可写目录下的文件，是文件替换攻击的高发区，是攻击者放置恶意程序的首选目标。
因此，需设置粘贴位，使得目录下的文件只有文件owner才能删除，避免个人文件被他人修改。

如果用户对目录有写权限，则可以删除其中的文件和子目录，即使该用户不是这些文件的所有者，而且也没有读或写许可。

**检查方法：**

使用如下命令查找有全局可写权限且未设置粘滞位的目录，返回为空表示未找到：

.. code-block:: bash

    # find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null  | sort

确保LD_LIBRARY_PATH和PATH变量被严格定义
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

LD_LIBRARY_PATH是Linux的环境变量，该环境变量包含动态库的搜索路径。程序加载动态链接库时，会优先从该环境变量指定的路径中获取。通常情况下该环境变量不应该被设置，如果被恶意设置为不正确的值，程序在运行时就有可能链接到不正确的动态库，导致安全风险。如果存在LD_LIBRARY_PATH环境变量的话，应审核其中的所有路径是否合法。

PATH是Linux的环境变量，该环境变量包含可执行文件路径。为防止系统命令被恶意的可执行文件替代，确保用户执行的都是合法的命令，所有帐户的PATH环境变量中应当避免包含当前目录“.”。非系统账号的PATH环境变量，定义的目录顺序的必须是：合法的系统目录，然后是合法的应用路径，最后是合法的用户目录。这里合法指的是目录在文件系统中存在，并符合系统的设计期望的路径。异常PATH值可能导致系统命令或库被恶意程序替代。

**检查方法：**

1. 检查在用户成功登录后会自动执行的脚本，如： :file:`/etc/profile` ，:file:`/etc/bashrc` ，:file:`$HOME/.profile` ，:file:`$HOME/.bashrc` ，:file:`/etc/ld.so.conf` 等，是否设置了 :file:`$LD_LIBRARY_PATH` 变量的值。

使用grep命令进行检查，例如，检查/etc/profile文件中是否设置了LD_LIBRARY_PATH值：

.. code-block:: bash

    # grep "LD_LIBRARY_PATH" /etc/profile

2. 检查当前用户上下文中是否存在LD_LIBRARY_PATH值，如果未设置LD_LIBRARY_PATH，则echo命令执行完以后打印为空，否则打印出当前设置的LD_LIBRARY_PATH值：

.. code-block:: bash

    # echo $LD_LIBRARY_PATH

3. 通过echo命令可以打印出当前用户上下文中PATH的值，检查是否存在非法路径，如 :file:`.` ，:file:`..` 等相对路径，:file:`/tmp` 等全局可写目录。openEuler
   embedded root用户上下文中PATH值如下：

.. code-block:: bash

    # echo $PATH
    /sbin:/usr/sbin:/usr/local/sbin:/root/bin:/usr/local/bin:/usr/bin:/bin

用户账户与环境
--------------------------

确保系统只有唯一的管理员账户
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

确保只有root帐户UID为0，因为在Linux中，UID为0的用户具有系统最高权限，系统中只能有一个。

如果存在非root的UID为0账号，容易被外界质疑，通过修改UID，隐藏普通账户的超级管理员权限。

**检查方法：**

执行如下命令，查找系统中的root用户：

.. code-block:: bash

    # cat /etc/passwd | awk -F: '{ if ($3 == 0) print $0 }'
    root:x:0:0:root:/root:/bin/bash

禁用系统账户登录
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

Linux系统中为某些服务而提供的账户通常称为系统用户，这些用户的UID通常小于500，应该删除不必要的系统账户，对于必须提供的系统账户，应该禁止为其提供交互Shell。

如果不禁止无登录需求账号的登陆功能，可能导致被利用登录系统执行任意命令。

**检查方法：**

执行如下命令检查系统中的系统用户的Shell是否设置正确，如果命令输出非空，则需要对命令所输出的用户进行处理：

.. code-block:: bash

    # cat /etc/passwd | awk -F: '($1!="root" && $3<500 && $7!="/sbin/nologin" && $7!="/bin/false" && $7!="/bin/sync") {print}'

确保连续3次输入错误口令后锁定用户
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

攻击者在对目标进行攻击时，最常用的手段是不断进行登录尝试，爆破用户的口令。因此，需要设置用户的失败登录重试次数，当用户连续失败登录达到阈值时，要对用户进行锁定。pam_faillock记录登录失败事件并在一定次数登录失败之后就不再允许登录，账号也因此被锁定一段时间，直到系统管理员解锁该账号。deny=N选项将最大登录次数设置为N。选项unlock_time=N设置达到最大登录次数之后账号被锁定的时长（秒）。

如果不限制登陆尝试次数，攻击者能不断进行登录尝试爆破用户口令。

**检查方法：**

在/etc/pam.d/common-auth文件中检查“连续失败登录次数”和“锁定时间”的配置情况：

.. code-block:: bash

    # cat /etc/pam.d/common-auth | grep "deny" | grep "unlock_time"
    auth required pam_faillock.so audit deny=3 even_deny_root unlock_time=300

对口令复杂度进行检查
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

禁止用户使用弱口令，openEuler Embedded当前的默认密码策略最小长度为8位。其中，root账户修改密码时不做该检查，与业界标准保持一致。PAM模块pam_pwquality提供多个配置项，可通过定制口令策略来实现口令复杂度检查。用户在修改口令时，输入新密码之后该模块会进行多种检查。

口令设置过于简单，容易被猜测，太短的口令容易被暴力破解工具猜测出来。

**检查方法：**

在/etc/pam.d/common-password文件中检查“设置口令复杂度”的配置情况：

.. code-block:: bash

    # grep -E "^[[:space:]]*password[[:space:]]+(required|requisite)[[:space:]]+pam_pwquality.so[[:space:]]+" /etc/pam.d/common-password 2>/dev/null | grep "retry=3" | grep "minlen=8"| grep "minclass=3"
    password requisite pam_pwquality.so try_first_pass minclass=3 minlen=8 lcredit=0 ucredit=0 dcredit=0 ocredit=0 reject_username gecoscheck retry=3 enforce_for_root

禁用历史密码
~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

频繁使用相同的历史口令容易造成口令泄露。

**检查方法：**

在/etc/pam.d/common-password文件中检查“禁用历史口令”的配置情况：

.. code-block:: bash

    cat /etc/pam.d/common-password | egrep "^\s*password\s+required\s+pam_pwhistory.so" | grep "enforce_for_root" | grep "use_authtok" | grep "remember=5"
    password required pam_pwhistory.so remember=5 use_authtok enforce_for_root

确保口令有效期设置正确
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

口令需要设置有效期，口令过期后用户重新登录时，提示口令过期，并强制修改，否则无法进入系统。

长期使用同一个口令将会增加口令被破解的可能（如暴力破解），同时增加密码泄露风险（如社会学攻击）。

**检查方法：**

-  检查/etc/login.defs文件中是否已经配置相关字段：

.. code-block:: bash

    # grep ^PASS_MAX_DAYS /etc/login.defs
    PASS_MAX_DAYS 90
    # grep ^PASS_MIN_DAYS /etc/login.defs
    PASS_MIN_DAYS 7
    # grep ^PASS_WARN_AGE /etc/login.defs 
    PASS_WARN_AGE 7

-  使用以下命令检查/etc/pam.d/common-account文件配置PAM模块验证用户的口令状态：

.. code-block:: bash

    # egrep "^\s*account\s+\[\s*success=1\s+new_authtok_reqd=done\s+default=ignore\s*\]\s+pam_unix.so" /etc/pam.d/common-account 2>/dev/null
    account [success=1 new_authtok_reqd=done default=ignore] pam_unix.so

确保设置Shell会话空闲超时间隔
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

当用户会话在900秒或更短的时间内没有活动的情况下应该超时退出。

会话超时时间设置过长，甚至永不超时，当管理员离开时没有退出登录，其他人员就可以直接在终端上以管理员权限进行操作。

**检查方法：**

通过以下命令检查/etc/profile及/etc/bashrc文件中是否设置Shell会话空闲超时间隔：

.. code-block:: bash

    # egrep "^\s*(export\s+)?TMOUT=" /etc/profile
    TMOUT=300
    # egrep "^\s*(export\s+)?TMOUT=" /etc/bashrc
    TMOUT=300

确保为系统的登录界面添加登录警告
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

操作系统不应将系统版本、应用服务器类型/功能等通过Warning
Banners暴露给用户，避免攻击者获取到系统信息，实施攻击。设置系统的登录提示信息，可实现隐藏系统版本等详细信息的目的。另外，为系统的登录界面添加登录警告，为惩戒恶意用户对系统的攻击行为，提供法律效力。

用户可根据需要，定制登录告警信息。

**检查方法：**

-  通以下命令检查/etc/motd、/etc/issue、/etc/issue.net文件是否设置登录警告，如果结果返回为空，则没有为系统的登录界面添加登录警告：

.. code-block:: bash

    # cat /etc/motd 2>/dev/null | egrep -v '^\s*#|^\s*$'
    Authorized uses only. All activity may be monitored and reported.
    #cat /etc/issue 2>/dev/null | egrep -v '^\s*#|^\s*$'
    Authorized uses only. All activity may be monitored and reported.
    #cat /etc/issue.net 2>/dev/null | egrep -v '^\s*#|^\s*$'
    Authorized uses only. All activity may be monitored and reported.

-  通过以下命令检查/etc/ssh/sshd_config文件是否设置Banner，如果返回为空，表示未配置：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep -i "^Banner"
    Banner /etc/issue.net

确保用户的口令必须用强哈希算法进行加密
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

对用户的口令使用强hash算法进行加密，能有效的降低口令被破解的风险。

**检查方法：**

在/etc/pam.d/common-password文件中检查“口令使用强Hash算法加密”的配置情况：

.. code-block:: bash

    # grep sha512 /etc/pam.d/common-password
    password [success=1 default=ignore] pam_unix.so use_authtok nullok sha512

确保限制su权限的使用
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

任何用户通过su到其他用户，就可以获得该用户的权限对系统进行操作，特别是直接通过su获取root权限，因此需要严格控制su权限的使用。su滥用可能引入提权风险。

**检查方法：**

检查/etc/pam.d/su中是否配置了非wheel组用户账号禁止使用su：

.. code-block:: bash

    # grep pam_wheel.so /etc/pam.d/su | grep required
    auth               required   pam_wheel.so use_uid

网络配置与防火墙
------------------------

确保记录所有欺骗包、源路由包、发送系统的重定向包
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

记录欺骗的包、源路由包和发给系统的重定向包有助于发现攻击源与制定防护措施。
log_martians可以用来启动记录不合法的IP来源，便于定位来自不合法的IP来源。

**检查方法：**

通过以下命令检查是否开启log_martians：

.. code-block:: bash

    # sysctl net.ipv4.conf.default.log_martians
    net.ipv4.conf.default.log_martians = 1
    # sysctl net.ipv4.conf.all.log_martians
    net.ipv4.conf.all.log_martians = 1

确保使能tcp_syncookies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

SYN
cookie用于防止由于攻击者快速建立大量半连接而产生的DoS攻击。开启参数之后内核在回应报文中包含一个特殊构造的TCP序列号用来识别合法报文。
推荐将该参数设置为1，减少系统在遭受SYN Flooding攻击时受到的影响。

**检查方法：**

通过以下命令检查是否使能tcp_syncookies：

.. code-block:: bash

    # sysctl net.ipv4.tcp_syncookies
    net.ipv4.tcp_syncookies = 1

禁止IP转发
~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

禁用IP转发功能可以防止具有多个网络接口的系统提供路由功能。

**检查方法：**

通过以下命令检查是否禁止IP转发功能：

.. code-block:: bash

    # sysctl net.ipv4.ip_forward
    net.ipv4.ip_forward = 0

禁止发送ICMP重定向
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

ICMP重定向用于发送路由信息到其他主机。如果是独立主机，不包含路由器功能，则不需要该功能。

攻击者可能利用侵入的主机发送非法的ICMP重定向到其他路由器设备，破坏路由。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # sysctl net.ipv4.conf.all.send_redirects
    net.ipv4.conf.all.send_redirects = 0
    # sysctl net.ipv4.conf.default.send_redirects
    net.ipv4.conf.default.send_redirects = 0

禁止源路由
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

源路由允许发送者指定其所发送的数据包经过的部分或者全部路由器。相比之下，非源路由包在网络中的传递路径则由网络中的路由器决定。

如果允许源路由数据包，则通过构造中间路由地址，可以用于访问专用地址系统；如果攻击者对原始报文截取，并利用源路由进行地址欺骗，则可以强制指定回传的报文都通过攻击者的设备进行路由返回，这样攻击者就可以成功接收到双向的数据包。

另外，大量报文被篡改后通过指定路由，则可以对内部网络进行定向攻击，可导致指定路由器负载过高，正常服务流量中断。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # sysctl net.ipv4.conf.all.accept_source_route
    net.ipv4.conf.all.accept_source_route = 0
    # sysctl net.ipv4.conf.default.accept_source_route
    net.ipv4.conf.default.accept_source_route = 0

禁止接收ICMP重定向
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

ICMP重定向消息包携带了路由信息，控制主机（路由器）发送包的路径。这是允许外部路由设备来更新系统路由表的一种方式。攻击者可以伪造ICMP重定向信息恶意修改系统路由表，使得系统向错误的网络地址发送数据包，攻击者则可以获取这些数据包。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # sysctl net.ipv4.conf.all.accept_redirects
    net.ipv4.conf.all.accept_redirects = 0
    # sysctl net.ipv4.conf.default.accept_redirects
    net.ipv4.conf.default.accept_redirects = 0

禁止接收安全ICMP重定向
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

安全ICMP重定向消息与ICMP重定向相同，但它们来自默认网关列表中的网关。

攻击者可以利用伪造的ICMP重定向消息恶意更改系统路由表，使它们向错误的网络发送数据包。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # sysctl net.ipv4.conf.all.secure_redirects
    net.ipv4.conf.all.secure_redirects = 0
    # sysctl net.ipv4.conf.default.secure_redirects
    net.ipv4.conf.default.secure_redirects = 0

禁止响应广播请求
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

允许接收广播或多播的ICMP echo和timestamp请求可能使系统遭到Smurf攻击。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # sysctl net.ipv4.icmp_echo_ignore_broadcasts
    net.ipv4.icmp_echo_ignore_broadcasts = 1

确保启用错误消息保护
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

攻击者通过发送违反RFC-1122的相应消息，可能导致文件系统中因存储了过多的错误日志而被填满。设置icmp_ignore_bogus_error_responses为1可以防止内核记录错误响应日志，防止无用的日志信息填满文件系统。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # sysctl net.ipv4.icmp_ignore_bogus_error_responses
    net.ipv4.icmp_ignore_bogus_error_responses = 1

确保启用反向路径过滤
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

攻击者可以实施IP地址欺骗，在目前网络攻击中使用比较多。通过反向地址过滤在收到数据包时，取出源IP地址，然后查看该路由器的路由表中是否有该数据包的路由信息。如果路由表中没有其用于数据返回的路由信息，那么极有可能是某人伪造了该数据包，于是路由便把它丢弃。设置net.ipv4.conf.all.rp_filter和net.ipv4.conf.default.rp_filter为1强制Linux内核启用反向路径过滤验证接收的包是否合法。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # sysctl net.ipv4.conf.all.rp_filter
    net.ipv4.conf.all.rp_filter = 1
    # sysctl net.ipv4.conf.default.rp_filter
    net.ipv4.conf.default.rp_filter = 1

网络服务配置
------------------------------

配置SSH
~~~~~~~~~~~~~~~~~~~~

确保使用V2协议版本的SSH
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

SSH1协议本身存在较多的未修复漏洞，且社区已不作为主流协议进行长期维护，容易使攻击者有机可乘，导致因传输协议不安全，而造成信息泄露、命令数据篡改等风险。与SSH
V1相比，SSH
V2进行了一系列功能改进并增强了安全性，例如基于迪菲-赫尔曼密钥交换的加密和基于消息认证码的完整性检查。SSH
V2还支持通过单个SSH连接任意数量的shell会话。SSH V2协议与SSH
V1不兼容，由于更加流行，一些实现（例如lsh和Dropbear）只支持SSH V2协议。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "Protocol 2"
    Protocol 2

确保设置SSH的SyslogFacility和LogLevel
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

OpenSSH中的日志配置关键字是SyslogFacility和LogLevel。

通过SyslogFacility设置syslog的facility，如：KERN, DAEMON, USER, AUTH,
MAIL等。

LogLevel记录日志提供的详细程度，详细程度由低到高依次是：QUIET, FATAL,
ERROR, INFO, VERBOSE, DEBUG, DEBUG1, DEBUG2, DEBUG3。

使用DEBUG会导致记录非常详细的日志，存在隐私问题，这个日志级别只能用于调试，禁止在现网环境中使用。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "^\s*SyslogFacility AUTH"
    SyslogFacility AUTH
    # cat /etc/ssh/sshd_config | grep "^\s*LogLevel"
    LogLevel VERBOSE

禁止X11转发
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

除非必须在远端直接使用X11应用程序，否则应该禁止X11
Forwarding。如果允许X11
Forwarding，则存在被远端X11服务器上其他用户攻击的风险。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "^\s*X11Forwarding no"
    X11Forwarding no

确保设置SSH登录失败次数上限
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

设置SSH失败登录锁定次数为3次，可防止用户暴力登录破解密码。如果不配置该值，或者该值配置比较大，则单次连接过程中客户端可以尝试多次认证失败，降低了攻击开销。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "^\s*MaxAuthTries"
    MaxAuthTries 3

确保启用SSH的IgnoreRhosts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

IgnoreRhosts参数设为yes，则 :file:`.hosts` 和 :file:`.shosts` 文件将不会用于 :file:`RhostsRSAAuthentication` 或 :file:`HostbasedAuthentication` 。

设置 :file:`IgnoreRhosts` 为yes可以强制用户使用SSH时必须输入口令进行认证，避免通过域名污染或IP欺骗后无需口令即可直接入侵系统。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "^\s*IgnoreRhosts yes"
    IgnoreRhosts yes

禁止HostbasedAuthentication
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

:file:`HostbasedAuthentication` 参数设置是否信任通过 :file:`.rhosts` 或 :file:`/etc/hosts.equiv` 指定的主机或用户，使这些用户可以不输入口令即可通过认证。

设置 :file:`HostbasedAuthentication` 为no，强制用户使用SSH时必须输入口令进行认证，避免通过域名污染或IP欺骗后无需口令即可直接入侵系统。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "^\s*HostbasedAuthentication no"
    HostbasedAuthentication no

禁止root用户通过SSH远程登录
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

限制root通过SSH远端登录。如果未禁止远程root账号登录，那么攻击者获取到root口令之后就可以从网络上远程登录服务器进行攻击行为，root权限具备管理员权限增加了攻击面。

**注意：**

yocto构建工程在打包文件系统时候，默认使能了debug-tweaks模式，之前配置此项加固会被覆盖成未使能。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "^\s*PermitRootLogin no"
    PermitRootLogin no

禁止PermitEmptyPasswords
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

账号必须通过验证才能进行远程连接，登录系统，提升系统的安全性。若允许空口令登录，会增加空口令账号本身被攻击或被用来作为攻击账号的风险。

**注意：**

yocto构建工程在打包文件系统时候，默认使能了debug-tweaks模式，之前配置此项加固会被覆盖成未使能。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "^\s*PermitEmptyPasswords no"
    PermitEmptyPasswords no

禁止PermitUserEnvironment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

设置PermitUserEnvironment参数为no，禁止sshd服务处理 :file:`~/.ssh/environment` 文件和 :file:`~/.ssh/authorized_keys` 文件中的 :file:`environment=` 。减少sshd处理外部输入数据的接口，可以减少利用sshd漏洞攻击系统的风险。如果PermitUserEnvironment配置为yes，则攻击者可以通过修改SSH环境变量绕过安全机制，或者执行攻击代码。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "^\s*PermitUserEnvironment no"
    PermitUserEnvironment no

确保SSH使用已知安全的数据摘要算法
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

openssh默认的算法集中包含了hmac-sha2-512、hmac-sha2-256、hmac-sha2-512-etm\@openssh.com等算法，其中包含“-etm”的安全性更高，在安全conf中需要以正确的顺序配置算法。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # grep -i "^MACs" /etc/ssh/sshd_config
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com

确保设置SSH的ClientAliveInterval和ClientAliveCountMax
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

设置较短的会话超时时间可以减少会话被利用的风险，建议设置ClientAliveInterval为300秒（或更短），设置ClientAliveCountMax为0，则会话空闲300秒则自动终止。如果不设置会话超时，则非授权用户可能会利用该会话（例如，用户走开后没有锁定屏幕，则其他人可以继续使用SSH会话）。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "^\s*ClientAliveInterval 300"
    ClientAliveInterval 300
    # cat /etc/ssh/sshd_config | grep "^\s*ClientAliveCountMax 0"
    ClientAliveCountMax 0

确保设置SSH并发未认证连接数上限
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

部署SSH服务时，设置MaxStartups参数为限制并发未认证的连接数。例如，设置MaxStartups为10:30:100，则当未认证连接数达到10时，服务端开始丢弃30%的新连接，当未认证连接数达到100时，开始丢弃所有新的连接。未认证的连接在LoginGraceTime设置的时长（单位：秒）后自动断开。如果不限制并发连接数，可能导致恶意DOS攻击，消耗系统资源。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "^\s*MaxStartups"
    MaxStartups     10:30:100
    # cat /etc/ssh/sshd_config | grep "^\s*LoginGraceTime"
    LoginGraceTime 120

确保启用SSH的UsePAM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

SSH通过配置PAM认证，可以基于Linux系统的用户认证管理模块完成SSH远程登录用户的认证授权和管理，否则将无法方便和集中的配置认证规则。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "^\s*UsePAM"
    UsePAM yes

确保设置SSH文件的权限
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

ssh会把每个访问过计算机的公钥(public key)都记录在~/.ssh/known_hosts。当下次访问相同计算机时，OpenSSH会核对公钥。如果公钥不同，OpenSSH会发出警告，避免设备受到DNS
Hijack之类的攻击。

authorized_keys则保存认证过的机器的公钥信息，也需要设置权限避免被泄露或篡改。

**检查方法：**

通过以下命令检查/root/.ssh/known_hosts、/root/.ssh/authorized_keys文件的权限，owner和group为是否为root、root，权限是否为600，返回结果为空则表明/root/.ssh/known_hosts、/root/.ssh/authorized_keys文件的权限符合要求：

.. code-block:: bash

    # find /root/.ssh/known_hosts -maxdepth 0 \( ! -user root  -o  ! -group root  -o  -perm /177 \) 2>/dev/null
    # find /root/.ssh/authorized_keys -maxdepth 0 \( ! -user root  -o  ! -group root  -o  -perm /177 \) 2>/dev/null

确保设置SSH Banner
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**规则背景说明：**

SSH登录前显示提示信息。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # cat /etc/ssh/sshd_config | grep "^\s*Banner /etc/issue.net"
    Banner /etc/issue.net

运行时安全
---------------------------

确保使能用户态地址随机化保护
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

ASLR（Address space layout
randomization）是一种针对缓冲区溢出的安全保护技术，通过对堆（brk）、栈(stack)、共享库映射（mmap、vdso(X86)）线性区布局的随机化及增加攻击者预测目的地址的难度，防止攻击者直接定位攻击代码位置，达到防御攻击者利用溢出执行任意代码的目的。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # sysctl kernel.randomize_va_space
    kernel.randomize_va_space = 2

确保限制core dump功能的使用
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

缺省情况下应禁用core dump功能，因为core
dump功能可能会包含进程内存里的敏感信息。但是有时需要开启core
dump功能记录当时产生问题的原因，对于需要开启core
dump功能的需对日志输入的路径进行限制，同时需限制路径只允许特定用户访问。

openEuler
embedded默认关闭进程core功能，如果使用core功能，推荐使用更安全的openEuler
embedded
idump功能。idump是在Linux原生coredump功能上做安全增强，允许只转储栈的内容，以增加系统安全性；客户在网上环境应只转储栈空间。该功能默认关闭，用户打开该功能时，只能对该用户启动的进程生效，不影响系统其它进程。

**检查方法：**

输入以下命令并检查相应的命令返回：

.. code-block:: bash

    # sysctl fs.suid_dumpable
    fs.suid_dumpable = 0

日志与审计
------------------------

确保记录所有与认证相关的事件
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**规则背景说明：**

记录登录事件包括登录错误日志、记录SU命令的使用日志和其它鉴权事件包括 :file:`AUTH` 类型的日志等。以便帮助分析用户登录的情况、系统状况、root权限使用情况以及监视系统上的可疑活动，如监视攻击者尝试猜测管理员密码登录活动。

**检查方法：**

登录并检查日志文件中是否有登录认证日志。
在/etc/audit/audit.rules文件添加如下规则：

.. code-block:: bash

    -w /var/log/lastlog -p wa -k logins
    -w /var/log/tallylog -p wa -k logins
