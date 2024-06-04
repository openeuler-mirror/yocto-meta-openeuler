.. _yocto_development:

Yocto开发指导
=============

如何定制添加layer
*******************************

.. image:: ../../image/yocto/create_layer.png

即使你只有一两个配方文件，还是建议你创建自己的层，而不是把配方添加到OE-Core或者Yocto项目层，随着你的配方越来越多，这种好处更能体现出来，且容易迁移到你的其它
项目中去。你可以修改配置文件，使你的层添加到项目中。还可以用yocto-layer脚本来创建层。

通常一个layer的结构包含3个文件夹：conf、classes、recipes-xxx。开发人员可以自行创建recipes-\*文件夹，存放其他软件包的bb文件。recipes-xxx目录仅用于区分
不同类型的软件包/特性，实际可以作为一个recipes目录存放的。classes目录和poky原生的目录类似，主要存放自研的bbclass。conf目录是必须存在的，用于配置此layer的
信息。

 - classes: 类文件(.bbclass)中提供了一些可以和其他配方（和类文件在同一层中）共享的功能，多个配方可以从同一个类文件继承一些配置和功能。
 - conf: 这个区域包含了针对这个层和发行相关的配置信息（比如说conf/layer.conf)。local.conf和bblayers.conf的定制模板也可以放在此目录，构建时通过
   TEMPLATECONF变量指定。
 - recipes-xx: 包含了一些会影响全局的配方文件和配方追加文件。其中一些配方和追加文件被用来增加初始化脚本，特定发行版的配置和自定义的配方等文件。recepies-xx
   目录的例子就是recipes-core和recipes-kernel。不同recepies-\*目录下的内容和结构也会有所不同。通常来说，这些目录下含了配方文件(\*.bb)和配方追加文件(\*.bbappend)，
   还有一些针对发行版的配置文件和其他文件。

添加新层可以通过以下步骤完成：

1. 创建新层文件夹meta-xxx
#. 创建新层配置文件conf/layer.conf。
#. 告诉 Bitbake 关于新层bblayers.conf
#. 根据层类型，添加内容。如果层添加了对机器的支持，则在层内的 conf/machine/ 文件中添加机器配置。如果层添加了发行版策略，则在层内的 conf/distro/ 文件中添加发行版配置。如果层引入了新的配方，则将需要的配方放在该层内的 recipes-* 子目录中。

以下是一个层的主要目录结构:

::

  ./
 ├── build/ 编译目录
 │   ├── bitbake.lock
 │   └── conf/
 │       ├── local.conf
 │       └── bblayers.conf
 ├── meta-openeuler/  新层
 │   ├── classes/  如果需要提供公共类，则添加
 │   ├── recipe-core/
 │       ├── glibc/
 │            ├── files/
 │            ├── glibc_2.31.bb
 │            └── glibc.inc
 │   └── conf/
 │       ├── machine/ **按需添加** ，新硬件平台则需要
 │            ├── qemu_arm.conf
 │            └── qemu_aarch64.conf
 │       ├── distro/ **按需添加** ，新的发行版
 │            └── openeuler.conf
 │       ├── local.conf.sample
 │       ├── layer.conf
 │       └── bblayers.conf.sample
 └── meta/   原始yocto社区poky下
     ├── classes/
     │   └── base.bbclass
     └── conf/
         ├── bitbake.conf
         └── layer.conf

通过TEMPLATECONF变量指向新层的conf目录，yocto会自动将.sample赋值到build目录
当前也可以通过yocto提供的工具添加新的基础layer：

 | ``bitbake-layers create-layer ../layers/meta-hello`` 创建层
 | ``bitbake-layers add-layer meta-hello`` 将层添加到conf/bblayers.conf


添加image
*******************************

1）通过自定义bb文件添加image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

 | 添加bb文件如下：

::

  IMAGE_INSTALL = "packagegroup-core-x11-base package1 package2"
  inherit core-image

也可参考yocto提供的已有的image做定制修改

其中IMAGE_INSTALL中配置的名称必须使用 OpenEmbedded 表示法而不是 Debian 表示法作为名称（例如 glibc-dev 而不是 libc6-dev）

Yocto提供了一些默认的images的配方，可参考 `https://docs.yoctoproject.org/ref-manual/images.html <https://docs.yoctoproject.org/ref-manual/images.html>`_

2）通过自定义包组添加image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

 | 对于复杂的自定义image，自定义image的最佳方法是创建用于构建一个或多个image的自定义包组配方。

 | 包组配方的一个很好的例子是 meta/recipes-core/packagegroups/packagegroup-base.bb。

 | 通过PACKAGES 变量列出要生成的包组包。 inherit packagegroup 语句设置适当的默认值，并为 PACKAGES 语句中指定的每个包自动添加 -dev、-dbg 和 -ptest 补充包。

 | inherit packagegroup 语句应该位于配方顶部附近，当然在 PACKAGES 语句之前。

 | 对于 PACKAGES 中指定的每个包，可以使用 RDEPENDS 和 RRECOMMENDS 来提供父任务包应包含的包列表。您可以在 packagegroup-base.bb 配方中进一步查看这些示例。

 | 以下一个简短的虚构示例：


::

 DESCRIPTION = "My Custom Package Groups"

 inherit packagegroup

 PACKAGES = "\
     ${PN}-apps \
     ${PN}-tools \
     "

 RDEPENDS:${PN}-apps = "\
     dropbear \
     portmap \
     psplash"

 RDEPENDS:${PN}-tools = "\
     oprofile \
     oprofileui-server \
     lttng-tools"

 RRECOMMENDS:${PN}-tools = "\
     kernel-module-oprofile"

在前面的示例中，创建了两个包组包，并列出了它们的依赖项和推荐的包依赖项：packagegroup-custom-apps 和 packagegroup-custom-tools。要使用这些包组包构建映像，您需要将 packagegroup-custom-apps、 packagegroup-custom-tools 添加到 IMAGE_INSTALL。


添加一个新的配方bb
*******************************

使用recipetool自动添加bb文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

使用devtool自动添加bb文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

从零添加bb
^^^^^^^^^^^^^^^^^^

添加bbclass
***************************

添加新架构
***************************

支持多config
**************************

使用外部工具链
**************************

recipes版本选择
**************************

SRC_URI中文件和目录查找
*********************************

配方打包时如何分包
****************************

配方中添加日志打印
***************************

对指定架构或任务等进行定制配置（选项、补丁等）
******************************************************

编译选项配置
*****************************

依赖关系配置（包、任务）
************************************

配方中的虚拟provides
***************************