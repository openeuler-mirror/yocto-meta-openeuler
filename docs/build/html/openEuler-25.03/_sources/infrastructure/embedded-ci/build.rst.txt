.. _build:

build镜像构建命令-build
######################################

该命令用于jenkins-file中执行各类镜像编译检查，来保证上传代码的合规性。

如果想在jenkins-file使用，则添加如下命令。

.. code-block:: console

    python3 main.py build

添加上述主命令之后，此命令的参数如下所示：

-c: build_code
---------------

该参数用于指定构建代码地址，此地址为jenkins中的具体地址，请按照示例并结合实际情况进行添加，该参数可以用于文件构建，openeuler_image构建及python包构建，具体示例如下：

.. code-block:: console

    -c /home/jenkins/agent/yocto-meta-openeuler

-target: target
----------------

该参数用于指定目标镜像来源，该参数可以用于文件构建，openeuler_image构建及python包构建，具体示例如下：

.. code-block:: console

    -target openeuler_image

-a: arch
---------

该参数用于指定构建架构，如aarch64，x86，arm32等，该参数只能用于openeuler_image构建，具体示例如下：

.. code-block:: console

    -a aarch64

-t: toolchain
--------------

该参数用于指定构建工具链，每个不同的架构有对应的工具链，该参数只能用于openeuler_image构建，具体示例如下：

.. code-block:: console

    -t /usr1/openeuler/gcc/openeuler_gcc_arm64le

-p: platform
-------------

该参数用于指定单板名称，该参数只能用于openeuler_image构建，具体示例如下：

.. code-block:: console

    -p qemu-aarch64

-i: image
----------

该参数用于指定镜像名称，该参数只能用于openeuler_image构建，具体示例如下：

.. code-block:: console

    -p openeuler-image

-i: img_cmds
-------------

该参数用于添加构建镜像内命令，当镜像构建完成之后可以进行执行验证，暂无具体示例，依个人情况而定，该参数只能用于openeuler_image构建。

-f: features
-------------

该参数用于指定构建特性，如x11，debug，musl等特性，无具体示例，按个人需求添加，该参数只能用于openeuler_image构建。

-dt: datetime
--------------

该参数用于确定版本时间戳，该参数可以用于文件构建，openeuler_image构建及python包构建，具体示例如下：

.. code-block:: console

    -dt datetime

-d: directory
--------------

该参数用于指定构建生成产物的存放地址，默认名称为build，该参数只能用于openeuler_image构建，具体示例如下：

.. code-block:: console

    -d qemu-aarch64


-s_in: sstate_cache_in
-----------------------

该参数用于指定缓存的构建软件包地址，在这里简要介绍一下sstate-cache，在yocto中，sstate-cache是用于加速构建过程的一种机制，它可以缓存已经构建过的软件包，以便在后续的构建过程中可以直接使用这些缓存，而不是重新编译这些软件包。具体来说，sstate-cache会将已经构建过的软件包的二进制文件、头文件、库文件打包存储在一个目录中。当需要重新构建某个软件包时，yocto会首先检查sstate-cache中是否已经存在该软件包的的缓存，如果存在，那直接使用缓存中的文件，而不需要重新编译。这种机制可以大大加快构建过程的速度，特别是在多次构建相同软件包的情况下。同时，sstate-cache还可以跨不同的构建机器共享，从而进一步提高构建效率。sstate-cache的指定有两种方式，一种是远程的web站点方式，一种是本地目录方式。该参数只能用于openeuler_image构建，使用方式如下：

指定本地目录地址：

.. code-block:: console

    -s_in "/home/jenkins/ccache/openeuler_embedded/${giteeTargetBranch}/sstate-cache/qemu-aarch64"

-s_out: sstate_cache_out
--------------------------

该参数用于指定构建完成的软件包进行缓存的地址，默认一般不进行添加，如有需要请按需求使用，该参数只能用于openeuler_image构建，具体示例如下：

.. code-block:: console

    -s_out "/home/jenkins/ccache/openeuler_embedded/${giteeTargetBranch}/sstate-cache/qemu-aarch64"

上述参数设置完毕后，一般会在命令结尾指定log日志存放地址，具体示例如下：

.. code-block:: console

    > ${logDir}/${randomStr}.log

其中logDir为jenkins-file中设置的指定值，randomStr为对应方法生成的uuid。
