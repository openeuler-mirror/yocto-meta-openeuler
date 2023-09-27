.. _yocto_priority:

Yocto 元数据优先级
======================

本篇简要介绍 Yocto 元数据的优先级。

**总原则**：越往后解析的文件优先级越高。

一、常用底层配置文件解析顺序(从上往下)：

  .. code-block:: console

      bblayers.conf: 层配置文件，说明用到了哪些层;
      layer.conf: 各个层的配置文件, 说明怎么查找bb文件等;
      bitbake.conf: yocto核心配置文件;
      local.conf: 说明采用的bsp文件与distro文件;
      openeuler_hosttools.inc: openeuler用于配置主机工具的文件;
      ${MACHINE}.conf: bsp配置文件, 如qemu-aarch64.conf;
      ${DISTRO}.conf: distro配置文件, openeuler.conf;
      tcmode-external-openeuler.inc: 外部工具链配置。

  树莓派有些特殊，在 distro 文件之后又加了 machine 相关的配置文件。

二、常用类解析顺序(从上往下)：

  .. code-block:: console

      base.bbclass: 默认fetch、unpack、configure、compile、install任务;
      patch.bbclass: 默认patch任务;
      staging.bbclass: prepare_recipe_sysroot任务，安装依赖包提供的文件到recipe-sysroot和recipe-sysroot-native中；populate_sysroot任务，缓存install任务安装文件的子集到sysroot中；
      openeuler.bbclass: openeuler适配类;
      external_global.bbclass: 外部工具链全局配置类。

  全局类在 conf 文件之后解析，上述的类均可看作全局继承的类；独立继承的类则在全局类之后解析，如 bb 文件中使用了 inherit autotools 语句；
  全局类一般通过 INHERIT 字节配置，也可以通过 USER_CLASSES、PACKAGE_CLASSES、INHERIT_DISTRO 等字节配置，后续的这些字节最终还是被附加到 INHERIT 字节，为符合规范，可查看这些字节的定义进行适配。

三、实际上，我们可以根据 require、include、inherit 的位置去判断先后顺序，因为这些指令都是立即执行的，会在调用时立即解析。

  举例说明：

  .. code-block:: console

      local.conf 文件:
      require test.conf
      x = "1"

      test.conf 文件:
      x = "2"

  解析 local.conf 时发现 require 字节，则停止当前文件的解析，转而解析 test.conf，此时 x = "2"，test.conf 解析结束后继续解析 local.conf 剩下的内容，得到 x = "1"，则最终 x 为 1；include 与 inherit 同理。
