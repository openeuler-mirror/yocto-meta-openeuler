.. _yocto_poky4.0:

=======================
yocto poky 4.0 语法变更
=======================

- 常量名变更

.. csv-table::
    :header: "原常量名", "新常量名"
    :widths: 20, 20

    "BB_ENV_WHITELIST","BB_ENV_PASSTHROUGH"
    "BB_ENV_EXTRAWHITE","BB_ENV_PASSTHROUGH_ADDITIONS"
    "BB_HASHBASE_WHITELIST","BB_BASEHASH_IGNORE_VARS"
    "BB_HASHCONFIG_WHITELIST","BB_HASHCONFIG_IGNORE_VARS"
    "BB_HASHTASK_WHITELIST","BB_TASKHASH_IGNORE_TASKS"
    "BB_SETSCENE_ENFORCE_WHITELIST","BB_SETSCENE_ENFORCE_IGNORE_TASKS"
    "CVE_CHECK_PN_WHITELIST","CVE_CHECK_SKIP_RECIPE"
    "CVE_CHECK_WHITELIST","CVE_CHECK_IGNORE"
    "ICECC_USER_CLASS_BL","ICECC_CLASS_DISABLE"
    "ICECC_SYSTEM_CLASS_BL","ICECC_CLASS_DISABLE"
    "ICECC_USER_PACKAGE_WL","ICECC_RECIPE_ENABLE"
    "ICECC_USER_PACKAGE_BL","ICECC_RECIPE_DISABLE"
    "ICECC_SYSTEM_PACKAGE_BL","ICECC_RECIPE_DISABLE"
    "LICENSE_FLAGS_WHITELIST","LICENSE_FLAGS_ACCEPTED"
    "MULTI_PROVIDER_WHITELIST","BB_MULTI_PROVIDER_ALLOWED"
    "PNBLACKLIST","SKIP_RECIPE"
    "SDK_LOCAL_CONF_BLACKLIST","ESDK_LOCALCONF_REMOVE"
    "SDK_LOCAL_CONF_WHITELIST","ESDK_LOCALCONF_ALLOW"
    "SDK_INHERIT_BLACKLIST","ESDK_CLASS_INHERIT_DISABLE"
    "SSTATE_DUPWHITELIST","SSTATE_ALLOW_OVERLAP_FILES"
    "SYSROOT_DIRS_BLACKLIST","SYSROOT_DIRS_IGNORE"
    "UNKNOWN_CONFIGURE_WHITELIST","UNKNOWN_CONFIGURE_OPT_IGNORE"
    "WHITELIST_<license>","INCOMPATIBLE_LICENSE_EXCEPTIONS"

以下常量被去除：BB_STAMP_WHITELIST, BB_STAMP_POLICY, INHERIT_BLACKLIST, TUNEABI, TUNEABI_WHITELIST, and TUNEABI_OVERRIDE

- Fetch任务变更

由于上游源码的远程指向分支一直采用默认的值，这样对于将来的不确定因素导致采用其他分支将会变得不可实现，因此在指向远程分支的链接末尾添加了分支信息，并且由于github不再支持git协议的原因，因此需要在链接尾部额外添加protocol=https，例如：

    .. code-block:: console

        SRC_URI = "git:git.denx.de/u-boot.git;branch=master;protocol=https"

- 菜谱的变更

.. csv-table::
    :header: "菜谱", "变更日志"
    :widths: 20, 20

    "dbus-test","与dbus菜谱合并"
    "libid3tag","移动到meta-os层"
    "libportal","移动到meta-gnome层"
    "linux-yocto","移除5.14版本（5.15与5.10版本仍保留）"
    "python3-nose","在oe-core层不再有其相关依赖"
    "Rustfmt","在标准镜像中不再强制依赖"

- Python 变更

由于上游python3.10已经遗弃distutils，因此distutils相关类已经移到meta-python层，同样的菜谱中有对distutils*相关的类的继承要改成setuptools*

- Prelink 变更

在上游glibc的2.36版本中，因为在比较旧的版本中它导致了在编译过程中一些难以解决的错误，因此新版本中已经去掉。在上一版本honister中已经禁用的该功能，当然如果由于特殊的业务场景需要，也可以启动该功能，但是需要对应glibc支持才行。如果在菜谱中对你prelink有依赖，则需要删除。

- Reproducible 变更

Reproducible 相关功能已经作为一个标准功能参与到构建当中，因此其内容被移到base.bbclass中。如果在其他bb文件中有对reproducible的继承，在新版本中需要被移除掉。

- 构建主机系统的变更

1. 新版支持almaLinux主机系统用来替换CentOS，并且对于其他主机系统版本的支持有所变化，这些主机系统的版本将不再支持：CentOS 8，Ubuntu 16.04，Fedora 30，31，32
2. gcc的版本要求在7.5以上

- :append/:prepend 组合符号变更

在新版本中，使用 append、prepend 和 remove 组合符号时，只能使用等于号 (=) 或者双等号 (:=)。老版本中使用的加号 (+) 需要全部去掉。在使用 append 和 prepend 指向的内容时，需要在前面保留一个空格。另外，在 yocto 中，变量与这三个扩展符号之间的连接由下划线 (_) 改为冒号 (:)，例如 SRC_URI:append 或 SRC_URL:prepend 等。

具体详情可以参照https://docs.yoctoproject.org/migration-guides/migration-4.0.html