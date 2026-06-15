.. _yocto_recipe:

Yocto 标准配方解析
====================

要了解一个配方（\*.bb）是如何编写的，一个有效的方法是观察标准配方的例子。通过研究现有的配方文件，您可以了解配方的基本结构和语法，以及如何设置各种属性和参数。 :file:`poky/meta-skeleton` 中存在不少 Yocto 配方示例供参考，接下来拿其中两个配方文件进行解析，开发者可自行学习其余的配方示例。

**示例一：** :file:`meta-skeleton/recipes-skeleton/hello-single/hello_1.0.bb`

这个配方会生成一个在目标系统上运行的 hello 二进制程序并打包。

::

    ### 包描述信息
    DESCRIPTION = "Simple helloworld application"
    ### 包组分类
    SECTION = "examples"
    ### LICENSE信息
    LICENSE = "MIT"
    ### LICENSE 文件路径以及对应的 md5sum 校验值
    LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

    ### 源码文件位置，"file://" 开头表示文件为本地文件，不需要从官方链接下载
    SRC_URI = "file://helloworld.c"

    ### 构建时源码所在的目录
    S = "${WORKDIR}"

    ### 自定义 compile 任务
    do_compile() {
        ${CC} ${LDFLAGS} helloworld.c -o helloworld
    }

    ### 自定义 instanll 任务
    do_install() {
        install -d ${D}${bindir}
        install -m 0755 helloworld ${D}${bindir}
    }

配方目录结构如下：

::

    tree yocto-poky/meta-skeleton/recipes-skeleton/hello-single/
    ├── files
    ### 本地源码通常放置在配方同级 files、${BPN}、${BP} 目录下
    │   └── helloworld.c
    └── hello_1.0.bb

配方分析：

1. 在开始 Yocto 构建之前，需要指定源码文件的位置，通常在配方文件的 **SRC_URI** 变量中提供源码的下载路径或本地路径。Yocto 正确找到源码文件后，会将源码文件解压到 **WORKDIR** 目录，再进行下一步的编译过程。

2. 通常在配方文件的 **LIC_FILES_CHKSUM** 变量中指定 LICENSE 文件所在位置与校验值，这是必不可少的配置。由于源码只包含一个 .c 文件，而没有提供 LICENSE 文件，这里 LICENSE 文件指定了 poky 仓 :file:`MIT` 文件。

3. **do_install** 任务将产物安装到 **${D}** 目录中，这个目录通常代表目标系统的安装位置。安装完成后，Yocto 会进行进一步的处理。


这里运行 ``bitbake`` 程序进行测试：

::

    ...
    $ oebuild bitbake
    ### 添加 meta-skeleton 层到构建
    $ bitbake-layers add-layer /usr1/openeuler/src/yocto-poky/meta-skeleton/
    ### BBLAYERS 变量定义了构建时需要加入的层（layers）的路径列表
    $ cat conf/bblayers.conf
    ...
    ### 由于存在多个 hello 配方，默认会构建高版本，这里选定构建 1.0 版本的配方
    ### 添加 PREFERRED_VERSION_hello = "1.0" 到 conf/local.conf
    $ vi conf/local.conf
    ### 解析元数据，了解下变量 PN
    $ bitbake-getvar -r hello --value PN
    hello
    ### 获取 hello 配方生成的子包名称
    $ bitbake-getvar -r hello PACKAGES
    #
    # $PACKAGES [2 operations]
    #   set /usr1/openeuler/src/yocto-poky/meta/conf/bitbake.conf:323
    #     "${PN}-src ${PN}-dbg ${PN}-staticdev ${PN}-dev ${PN}-doc ${PN}-locale ${PACKAGE_BEFORE_PN} ${PN}"
    #   set /usr1/openeuler/src/yocto-poky/meta/conf/documentation.conf:319
    #     [doc] "The list of packages to be created from the recipe."
    # pre-expansion value:
    #   "${PN}-src ${PN}-dbg ${PN}-staticdev ${PN}-dev ${PN}-doc ${PN}-locale ${PACKAGE_BEFORE_PN} ${PN}"
    PACKAGES="hello-src hello-dbg hello-staticdev hello-dev hello-doc hello-locale  hello"
    ### 获取 hello 子包应该包含的目录文件
    $ bitbake-getvar -r hello --value FILES:hello
    /usr/bin/* /usr/sbin/* /usr/libexec/* /usr/lib64/lib*.so.*             /etc /com /var             /bin/* /sbin/*             /lib64/*.so.*             /lib/udev /usr/lib/udev             /lib64/udev /usr/lib64/udev             /usr/share/hello /usr/lib64/hello/*             /usr/share/pixmaps /usr/share/applications             /usr/share/idl /usr/share/omf /usr/share/sounds             /usr/lib64/bonobo/servers
    $ bitbake hello
    ### 查看产物目录，MULTIMACH_TARGET_SYS 与构建架构有关
    $ cd tmp/work/MULTIMACH_TARGET_SYS/hello/1.0-r0/
    $ ls packages-split/
    hello  hello-dbg  hello-dev  hello-doc  hello-locale  hello-src  hello-staticdev  hello.shlibdeps
    ### 生成的目标二进制程序
    $ file packages-split/hello/usr/bin/helloworld 
    packages-split/hello/usr/bin/helloworld: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-aarch64.so.1, BuildID[sha1]=871a6e2dbb4b0af191e75a22aedeb15e9a9d88cd, for GNU/Linux 5.10.0, stripped
    ### 环境变量 BBPATH 定义为构建目录，回到 build 目录
    $ cd $BBPATH


从中可以看到：

1. PN 是 ``bitbake`` 执行的主要参数；
2. 一些公共的变量是在 :file:`bitbake.conf` 文件中有默认配置；
3. :file:`packages-split` 目录下的各个子目录的名称均来自于 **PACKAGES** 变量，这些子目录将会被打包为 rpm 包或其它类型的软件包；
4. 通过 **FILES:子包名** 配置每个子包包含的目录文件；
5. 配方将产物安装到 :file:`${D}${bindir}` 目录后，后续的打包过程都是自动完成的。

.. note::

    上述配方其实有一个关键的变量 ``B`` 没有显示定义出来，它定义了构建目录，在执行 do_configure、do_compile 和 do_install 任务时，都会提前进入这个目录。默认情况下，变量 ``B`` 与变量 ``S`` 是相同的。


**示例二：** :file:`meta-skeleton/recipes-skeleton/hello-autotools/hello_2.10.bb`

这个配方用于构建 GNU helloworld 软件包，它采用 Autotools 构建系统。

::

    DESCRIPTION = "GNU Helloworld application"
    SECTION = "examples"
    LICENSE = "GPL-3.0-only"
    ### 源码中包含了 LICENSE 信息，此处是相对 ${S} 目录查找 LICENSE 文件
    LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

    ### autotools helloworld 源码包链接
    SRC_URI = "${GNU_MIRROR}/hello/hello-${PV}.tar.gz"
    ### 对于上游源，需要提前添加校验值
    SRC_URI[sha256sum] = "31e066137a962676e89f69d1b65382de95a7ef7d914b8cb956f41ea72e0f516b"

    ### autotools 软件包继承 autotools 类，即可自动完成 configure、compile、install 等任务
    inherit autotools-brokensep gettext

这个例子配方简洁许多，不需要手动定义 do_configure、do_compile 和 do_install 等任务流程，但也能准确的进行编译构建。基于示例一继续测试：

::

    ### 注释上次测试添加的 PREFERRED_VERSION_hello = "1.0"
    $ vi conf/local.conf
    ### 解析元数据，了解下变量 PV（版本号）
    $ bitbake-getvar -r hello --value PV
    2.10
    $ bitbake hello
    $ cd tmp/work/MULTIMACH_TARGET_SYS/hello/2.10-r0/
    ### 生成的二进制程序
    $ file package/usr/bin/hello 
    package/usr/bin/hello: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-aarch64.so.1, BuildID[sha1]=d41b8156dfddb7cea242d28a840d6a94faa62c33, for GNU/Linux 5.10.0, stripped

:file:`package` 是一个总的产物目录，用于存放构建完成后的软件包。而 :file:`packages-split` 目录则包含了从 :file:`package` 目录中拆分出来的各个子目录，每个子目录对应一个单独的软件包。换句话说，:file:`packages-split` 目录中的内容是从 :file:`package` 目录中按照一定的规则拆分出来的，每个子目录都包含了对应软件包的完整构建产物，包括可执行文件、库文件、头文件等。

.. note::

    autotools-brokensep 类与 autotools 类的唯一差异是前者为树内构建（源代码树内部进行构建），后者为树外构建。


**其余的一些示例**

1. 内核配方示例：:file:`meta-skeleton/recipes-kernel/linux/linux-yocto-custom.bb`
2. 内核模块配方示例（单独编译）：:file:`meta-skeleton/recipes-kernel/hello-mod/hello-mod_0.1.bb`
3. 基于 cmake 构建系统示例：:file:`meta/recipes-core/expat/expat_2.5.0.bb`
4. 基于 meson 构建系统示例：:file:`meta/recipes-devtools/libmodulemd/libmodulemd_git.bb`
