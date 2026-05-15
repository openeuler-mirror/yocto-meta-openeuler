.. _yocto_meta_openeuler:

openeuler层结构及演进策略
=========================================

以下是一个openeuler新增层的主要目录结构样例(例如添加了meta-raspberrypi和meta-intel层):

::

 yocto-meta-openeuler/
 ├── bsp/
 │   ├── meta-openeuler-bsp/ 定制openeuler补丁
 │   │   ├── conf/
 │   │   │   ├── distro/
 │   │   │   │   └── openeuler-bsp.conf
 │   │   │   ├── layer.conf
 │   │   │   └── machine/
 │   │   │       └── openeuler-raspberrypi4-64.conf
 │   │   ├── intel/  定制intel的补丁，当meta-intel层生效时才生效
 │   │   └── raspberrypi/  定制树莓派的补丁，当meta-rapberrypi层生效时才生效
 │   │       ├── recipes-core/
 │   │       └── recipes-kernel/
 │   ├── meta-intel/  社区原生intel
 │   └── meta-raspberrypi/  社区原生树莓派
 ├── docs/  对外的openeuler文档目录
 └── meta-openeuler/  自研openeuler的qemu版本


 meta-openeuler/
 ├── classes/  自研公共类目录
 │   └── ….
 ├── conf/  定制的openeuler配置模板,含local.conf.sample等
 │   └── …
 ├── recipes-core/ 核心配方
 │   ├── busybox/
 │   │   └── busybox_1.34.1.bb
 │   ├── images/
 │   │   ├── openeuler-image.bb
 │   │   ├── qemu-aarch64.inc
 │   │   ├── qemu-arm.inc
 │   │   └── qemu.inc
 │   └── …
 │       └── …
 ├── recipes-devtools/ 工具类配方，如cmake等
 │   └── …
 ├── recipes-kernel/ 内核相关配方
 │   └── linux/
 │       └── linux-openeuler.bb
 ├── recipes-labtools/ 实验室工具配方
 └── recipes-support/ 其它配方依赖的配方，不打包到image
